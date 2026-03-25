# Bike Store SQL Project

## 1. Introducción

El presente proyecto tiene como objetivo el desarrollo de un **pipeline de datos en SQL** a partir de un dataset relacional del sector retail (tienda de bicicletas), con el fin de transformar datos crudos en un modelo analítico estructurado que permita responder preguntas de negocio.

El proyecto sigue una arquitectura en tres capas:

- **Staging** (datos crudos)
- **Core** (modelo relacional limpio)
- **Semantic** (vistas de negocio)

---

## 2. Dataset

El dataset está compuesto por múltiples archivos CSV que contienen información sobre:

- Clientes
- Pedidos
- Líneas de pedido
- Productos
- Marcas
- Categorías
- Tiendas
- Empleados
- Stock

Estos datos han sido obtenidos en Kaggle y representan una tienda de bicicletas con datos transaccionales reales.

---

## 3. Motor SQL utilizado

**SQLite** (gestionado a través de DBeaver y compatible con el CLI `sqlite3`)

SQLite permite trabajar de forma sencilla con datos locales, ejecutar consultas analíticas y crear estructuras como vistas, triggers y transacciones. Al ser un fichero `.db` autocontenido, facilita enormemente la reproducibilidad del proyecto.

> **Nota sobre FUNCTION/PROCEDURE:** SQLite no soporta funciones definidas por el usuario ni procedimientos almacenados en SQL puro. Como alternativa se ha utilizado un **trigger** (`trg_validate_discount`) que aplica lógica de validación equivalente a la que aportaría una función o procedimiento. Esto queda documentado en `sql/07_advanced_sql.sql`.

---

## 4. Estructura del proyecto

```
bike-store-sql-project/
├── data/                         # Datos originales (CSV)
│   ├── brands.csv
│   ├── categories.csv
│   ├── customers.csv
│   ├── order_items.csv
│   ├── orders.csv
│   ├── products.csv
│   ├── staffs.csv
│   ├── stocks.csv
│   └── stores.csv
├── sql/                          # Scripts SQL finales del proyecto
│   ├── 01_schema.sql             # Creación de tablas staging y core
│   ├── 02_load_staging.sql       # Carga de CSV en tablas staging
│   ├── 03_transform_core.sql     # Transformaciones hacia capa core
│   ├── 04_semantic_views.sql     # Vistas de negocio
│   ├── 05_analysis_queries.sql   # Consultas analíticas (10 estudios)
│   ├── 06_quality_checks_part1.sql  # Controles de calidad detallados
│   ├── 06_quality_checks_part2.sql  # Controles de calidad resumidos
│   └── 07_advanced_sql.sql       # Transacción y trigger
├── bike_store.db                 # Base de datos SQLite final (reproducible)
├── Scripts (sucio)/              # Borradores de trabajo
└── README.md
```

---

## 5. Preguntas de negocio

Las consultas analíticas responden a las siguientes preguntas:

1. ¿Cómo evolucionan las ventas mes a mes?
2. ¿Cuánto vende cada tienda por mes?
3. ¿Qué 10 productos generan más ingresos?
4. ¿Quiénes son los 10 clientes con mayor gasto?
5. ¿Qué categorías de producto generan más ventas?
6. ¿Qué marcas generan más ingresos?
7. ¿Cuál es el ranking mensual de tiendas por ventas?
8. ¿Cuáles son los 3 productos más vendidos dentro de cada tienda?
9. ¿Qué clientes tienen un gasto por encima de la media?
10. ¿Qué productos tienen mucho stock y pocas ventas?

---

## 6. Arquitectura del pipeline

### 6.1 Capa Staging (`stg_*`)

En esta capa se cargan los datos originales sin transformar directamente desde los CSV:

- `stg_brands`
- `stg_categories`
- `stg_customers`
- `stg_order_items`
- `stg_orders`
- `stg_products`
- `stg_staffs`
- `stg_stocks`
- `stg_stores`

Esta capa representa la entrada directa de los datos y preserva la estructura original.

### 6.2 Capa Core (`dim_*`, `fct_*`)

Se construye un modelo relacional estructurado con tablas de tipo dimensión y hecho.

#### Dimensiones:
- `dim_brands`
- `dim_categories`
- `dim_customers`
- `dim_products`
- `dim_stores`
- `dim_staffs`

#### Tablas de hechos:
- `fct_sales` — ventas a nivel de línea de pedido
- `fct_stock` — stock por producto y tienda

En esta capa se normalizan los datos y se establecen relaciones coherentes. La métrica clave calculada es:

```
sales_amount = quantity * list_price * (1 - discount)
```

### 6.3 Capa Semántica (`vw_*`)

Se crean vistas orientadas a negocio que simplifican el análisis evitando joins complejos:

- **`vw_sales_enriched`** — integra ventas con información de cliente, producto, marca, categoría, tienda y empleado.
- **`vw_store_monthly_kpis`** — proporciona métricas agregadas por tienda y mes.

---

## 7. SQL avanzado

### 7.1 Transacción explícita

Se utilizó una transacción explícita (`BEGIN TRANSACTION … COMMIT`) para demostrar inserciones controladas en la tabla `fct_stock`. Esto garantiza la atomicidad de la operación.

### 7.2 Trigger

Se creó un trigger `trg_validate_discount` que impide insertar registros en `fct_sales` con descuentos fuera del rango [0, 1], reforzando la integridad de los datos a nivel de motor.

### 7.3 SQL analítico avanzado

- **CTEs** (expresiones de tabla comunes) para modularizar consultas complejas
- **Funciones de ventana**: `DENSE_RANK()` y `ROW_NUMBER()` con `PARTITION BY` y `ORDER BY`
- **Subconsultas** y `CROSS JOIN` para comparaciones contra agregados globales
- **`COALESCE`** para manejo de nulos en joins

---

## 8. Control de calidad de datos

### Checklist de calidad

| Control | Resultado |
|---|---|
| Valores de descuento fuera del rango [0, 1] | ✅ 0 registros inválidos |
| Claves huérfanas en `fct_sales` (clientes, productos, tiendas, empleados) | ✅ 0 registros huérfanos |
| Valores nulos en `shipped_date` | ✅ 0 nulos detectados |
| Cantidades negativas o cero en `fct_sales` | ✅ 0 registros inválidos |
| Precios de lista negativos o cero | ✅ 0 registros inválidos |
| Duplicados en claves primarias de dimensiones | ✅ 0 duplicados |
| Pedidos enviados después de la fecha requerida | ⚠️ 3718 pedidos retrasados (dato operativo, no error de datos) |
| Productos sin ninguna venta registrada | ⚠️ 28 productos sin ventas (posible problema de rotación) |

En general, los datos presentan una **alta calidad estructural**. Los dos hallazgos marcados en amarillo son insights de negocio relevantes, no errores de carga.

---

## 9. Supuestos y limitaciones

### Supuestos

- Los datos CSV se toman tal cual desde Kaggle; no se ha aplicado ninguna corrección de valores (solo limpieza estructural).
- El campo `shipped_date` con valor `NULL` en las tablas staging se interpreta como pedido aún no enviado; se conserva el nulo.
- `manager_id` puede ser `NULL` para el empleado de mayor rango (sin superior).
- Los precios y descuentos en los CSV son correctos; no se han detectado anomalías en el rango esperado.
- `order_status` es un código entero cuyo significado exacto no está documentado en el dataset original; se usa como dimensión de filtro.

### Limitaciones

- Dataset estático (no tiempo real); no refleja operaciones recientes.
- No incluye datos externos (costes, proveedores, devoluciones).
- Algunos campos con nulos (`phone`, `manager_id`) se mantienen por coherencia con el dataset original.
- SQLite no soporta `FUNCTION` ni `PROCEDURE` en SQL puro; se utilizó un `trigger` como alternativa equivalente.

---

## 10. Instrucciones de reproducción

### Opción A — Archivo de base de datos (recomendada)

El fichero `bike_store.db` incluye todas las tablas, vistas y el trigger ya cargados. Basta con abrirlo directamente con DBeaver o el CLI `sqlite3` y ejecutar las consultas de análisis (`05_analysis_queries.sql`).

### Opción B — Pipeline completo desde cero

Requiere tener instalado `sqlite3` (CLI) y los CSV en la carpeta `data/`.

```bash
# Desde la raíz del proyecto
sqlite3 bike_store.db < sql/01_schema.sql
sqlite3 bike_store.db < sql/02_load_staging.sql
sqlite3 bike_store.db < sql/03_transform_core.sql
sqlite3 bike_store.db < sql/04_semantic_views.sql
sqlite3 bike_store.db < sql/05_analysis_queries.sql
sqlite3 bike_store.db < sql/06_quality_checks_part1.sql
sqlite3 bike_store.db < sql/06_quality_checks_part2.sql
sqlite3 bike_store.db < sql/07_advanced_sql.sql
```

> **Nota:** `02_load_staging.sql` usa la directiva `.import` del CLI de SQLite. Si usas DBeaver, importa cada CSV manualmente con *File > Import Data* apuntando a la carpeta `data/` antes de ejecutar el script `03_transform_core.sql`.

---

## 11. Conclusiones

- El modelo permite analizar correctamente el rendimiento del negocio a nivel de tienda, producto, cliente y periodo temporal.
- Existe una concentración de ingresos en determinados productos y clientes, lo que sugiere estrategias de fidelización y gestión de catálogo.
- Se identifican **3718 pedidos retrasados** (enviados después de la fecha requerida), lo que apunta a ineficiencias logísticas relevantes. *(Conteo válido para el dataset estático actual; verificar con `06_quality_checks_part2.sql` si los datos cambian.)*
- Existen **28 productos sin ventas**, indicando oportunidades de optimización del catálogo o problemas de visibilidad comercial. *(Ídem.)*

---

## 12. Créditos

Dataset original obtenido de Kaggle: *Bike Store Relational Database*.  
Motor SQL: **SQLite 3**.  
Herramienta de gestión: **DBeaver Community Edition**.
