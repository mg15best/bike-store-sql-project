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

Las consultas analíticas (archivo `sql/05_analysis_queries.sql`) responden a las siguientes preguntas. Se muestra la consulta utilizada y un extracto representativo de los resultados obtenidos.

---

### P1 — ¿Cómo evolucionan las ventas mes a mes?

```sql
SELECT
    substr(order_date, 1, 7) AS year_month,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY substr(order_date, 1, 7)
ORDER BY year_month;
```

| year_month | total_sales |
|---|---|
| 2016-01 | 215 146,42 |
| 2016-06 | 210 562,12 |
| 2016-09 | 273 091,61 |
| 2017-01 | 285 616,48 |
| 2017-06 | 378 865,65 |
| 2018-01 | 381 430,10 |
| 2018-04 | 817 921,86 |

**Interpretación:** las ventas muestran una tendencia creciente año a año, con picos estacionales en septiembre y junio. Abril de 2018 destaca como el mes de mayor facturación del periodo analizado.

---

### P2 — ¿Cuánto vende cada tienda por mes?

```sql
SELECT
    store_name,
    substr(order_date, 1, 7) AS year_month,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY store_name, substr(order_date, 1, 7)
ORDER BY year_month, total_sales DESC;
```

| store_name | year_month | total_sales |
|---|---|---|
| Baldwin Bikes | 2016-01 | 132 894,30 |
| Santa Cruz Bikes | 2016-01 | 71 760,31 |
| Rowlett Bikes | 2016-01 | 10 491,82 |
| Baldwin Bikes | 2017-06 | 217 007,79 |
| Santa Cruz Bikes | 2017-06 | 129 461,18 |

**Interpretación:** Baldwin Bikes lidera sistemáticamente las ventas en todos los meses. Rowlett Bikes tiene un volumen notablemente menor, lo que puede indicar diferencias de mercado o de tamaño de la tienda.

---

### P3 — ¿Qué 10 productos generan más ingresos?

```sql
SELECT
    product_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;
```

| product_name | total_sales |
|---|---|
| Trek Slash 8 27.5 - 2016 | 555 558,61 |
| Trek Conduit+ - 2016 | 389 248,70 |
| Trek Fuel EX 8 29 - 2016 | 368 472,73 |
| Surly Straggler 650b - 2016 | 226 765,55 |
| Trek Domane SLR 6 Disc - 2017 | 211 584,62 |
| Surly Straggler - 2016 | 203 507,62 |
| Trek Remedy 29 Carbon Frameset - 2016 | 203 380,87 |
| Trek Powerfly 8 FS Plus - 2017 | 188 249,62 |
| Trek Madone 9.2 - 2017 | 175 899,65 |
| Trek Silque SLR 8 Women's - 2017 | 174 524,73 |

**Interpretación:** el Trek Slash 8 27.5 - 2016 es el producto estrella, con ingresos casi un 43% superiores al segundo. Los 10 primeros productos generan el 37% de los ingresos totales, señal de una alta concentración de ventas en el catálogo premium.

---

### P4 — ¿Quiénes son los 10 clientes con mayor gasto?

```sql
SELECT
    customer_name,
    ROUND(SUM(sales_amount), 2) AS total_spent
FROM vw_sales_enriched
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;
```

| customer_name | total_spent |
|---|---|
| Sharyn Hopkins | 34 807,94 |
| Pamelia Newman | 33 634,26 |
| Abby Gamble | 32 803,01 |
| Lyndsey Bean | 32 675,07 |
| Emmitt Sanchez | 31 925,89 |
| Melanie Hayes | 31 913,69 |
| Debra Burks | 27 888,18 |
| Elinore Aguilar | 25 636,45 |
| Corrina Sawyer | 25 612,70 |
| Shena Carter | 24 890,62 |

**Interpretación:** los 10 mejores clientes presentan gastos totales comparables entre sí (rango 24 890–34 807 €), lo que sugiere un segmento top bastante homogéneo. Son candidatos claros para programas de fidelización.

---

### P5 — ¿Qué categorías de producto generan más ventas?

```sql
SELECT
    category_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY category_name
ORDER BY total_sales DESC;
```

| category_name | total_sales |
|---|---|
| Mountain Bikes | 2 715 079,53 |
| Road Bikes | 1 665 098,49 |
| Cruisers Bicycles | 995 032,62 |
| Electric Bikes | 916 684,78 |
| Cyclocross Bicycles | 711 011,84 |
| Comfort Bicycles | 394 020,10 |
| Children Bicycles | 292 189,20 |

**Interpretación:** Mountain Bikes representa el 37% del total de ingresos, seguida de Road Bikes con el 23%. Juntas concentran el 60% de la facturación. Las bicicletas eléctricas ocupan el cuarto puesto, lo que refleja un crecimiento de esa categoría.

---

### P6 — ¿Qué marcas generan más ingresos?

```sql
SELECT
    brand_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY brand_name
ORDER BY total_sales DESC;
```

| brand_name | total_sales |
|---|---|
| Trek | 4 602 754,35 |
| Electra | 1 205 320,82 |
| Surly | 949 507,06 |
| Sun Bicycles | 341 994,93 |
| Haro | 185 384,55 |
| Heller | 171 459,08 |
| Pure Cycles | 149 476,34 |
| Ritchey | 78 898,95 |
| Strider | 4 320,48 |

**Interpretación:** Trek domina con el 63% de los ingresos totales, lo que supone una dependencia clara de una sola marca. Electra y Surly son referencias secundarias relevantes. La diversificación del portafolio podría ser un riesgo a considerar.

---

### P7 — ¿Cuál es el ranking mensual de tiendas por ventas?

```sql
WITH monthly_store_sales AS (
    SELECT
        store_name,
        substr(order_date, 1, 7) AS year_month,
        ROUND(SUM(sales_amount), 2) AS total_sales
    FROM vw_sales_enriched
    GROUP BY store_name, substr(order_date, 1, 7)
)
SELECT
    year_month,
    store_name,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY year_month
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM monthly_store_sales
ORDER BY year_month, sales_rank;
```

| year_month | store_name | total_sales | sales_rank |
|---|---|---|---|
| 2016-01 | Baldwin Bikes | 132 894,30 | 1 |
| 2016-01 | Santa Cruz Bikes | 71 760,31 | 2 |
| 2016-01 | Rowlett Bikes | 10 491,82 | 3 |
| 2017-06 | Baldwin Bikes | 217 007,79 | 1 |
| 2017-06 | Santa Cruz Bikes | 129 461,18 | 2 |
| 2017-06 | Rowlett Bikes | 32 396,68 | 3 |

**Interpretación:** el ranking es prácticamente estable a lo largo del tiempo: Baldwin (1.ª), Santa Cruz (2.ª), Rowlett (3.ª). La función `DENSE_RANK()` permite detectar empates de forma correcta.

---

### P8 — ¿Cuáles son los 3 productos más vendidos dentro de cada tienda?

```sql
WITH product_store_sales AS (
    SELECT
        store_name,
        product_name,
        ROUND(SUM(sales_amount), 2) AS total_sales
    FROM vw_sales_enriched
    GROUP BY store_name, product_name
)
SELECT *
FROM (
    SELECT
        store_name,
        product_name,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY store_name
            ORDER BY total_sales DESC
        ) AS rn
    FROM product_store_sales
)
WHERE rn <= 3
ORDER BY store_name, rn;
```

| store_name | product_name | total_sales | rn |
|---|---|---|---|
| Baldwin Bikes | Trek Slash 8 27.5 - 2016 | 363 719,09 | 1 |
| Baldwin Bikes | Trek Conduit+ - 2016 | 250 859,16 | 2 |
| Baldwin Bikes | Trek Fuel EX 8 29 - 2016 | 231 709,20 | 3 |
| Rowlett Bikes | Trek Slash 8 27.5 - 2016 | 76 719,81 | 1 |
| Rowlett Bikes | Trek Fuel EX 8 29 - 2016 | 55 476,81 | 2 |
| Rowlett Bikes | Trek Domane SLR 6 Disc - 2017 | 50 049,91 | 3 |
| Santa Cruz Bikes | Trek Slash 8 27.5 - 2016 | 115 119,71 | 1 |
| Santa Cruz Bikes | Trek Conduit+ - 2016 | 103 199,66 | 2 |
| Santa Cruz Bikes | Trek Fuel EX 8 29 - 2016 | 81 286,72 | 3 |

**Interpretación:** los mismos tres productos Trek dominan en las tres tiendas, aunque con proporciones distintas. Esto confirma el peso de la marca y sugiere que el catálogo de alta rotación es compartido. Rowlett muestra volúmenes mucho más bajos en términos absolutos.

---

### P9 — ¿Qué clientes tienen un gasto por encima de la media?

```sql
WITH customer_sales AS (
    SELECT
        customer_name,
        SUM(sales_amount) AS total_spent
    FROM vw_sales_enriched
    GROUP BY customer_name
),
avg_sales AS (
    SELECT AVG(total_spent) AS avg_spent
    FROM customer_sales
)
SELECT
    cs.customer_name,
    ROUND(cs.total_spent, 2) AS total_spent
FROM customer_sales cs
CROSS JOIN avg_sales a
WHERE cs.total_spent > a.avg_spent
ORDER BY total_spent DESC;
```

| customer_name | total_spent |
|---|---|
| Sharyn Hopkins | 34 807,94 |
| Pamelia Newman | 33 634,26 |
| Abby Gamble | 32 803,01 |
| … | … |
| *(543 clientes en total)* | |

Gasto medio por cliente: **5 324,87 €** — 543 de los 1 445 clientes (37,6%) superan esta cifra.

**Interpretación:** el segmento de clientes de alto valor representa más de un tercio de la base. El uso de `CROSS JOIN` con una subconsulta permite comparar cada cliente contra el promedio global de forma eficiente.

---

### P10 — ¿Qué productos tienen mucho stock y pocas ventas?

```sql
WITH sales_by_product AS (
    SELECT
        product_id,
        SUM(quantity) AS total_units_sold
    FROM vw_sales_enriched
    GROUP BY product_id
),
stock_by_product AS (
    SELECT
        product_id,
        SUM(quantity) AS total_units_in_stock
    FROM fct_stock
    GROUP BY product_id
)
SELECT
    p.product_name,
    COALESCE(s.total_units_sold, 0)        AS total_units_sold,
    COALESCE(st.total_units_in_stock, 0)   AS total_units_in_stock
FROM dim_products p
LEFT JOIN sales_by_product s
    ON p.product_id = s.product_id
LEFT JOIN stock_by_product st
    ON p.product_id = st.product_id
ORDER BY total_units_in_stock DESC, total_units_sold ASC
LIMIT 15;
```

| product_name | total_units_sold | total_units_in_stock |
|---|---|---|
| Trek 820 - 2016 | 0 | 1 054 |
| Trek XM700+ Lowstep - 2018 | 7 | 86 |
| Electra Townie Original 7D - 2017 | 27 | 82 |
| Trek Verve+ - 2018 | 5 | 79 |
| Sun Bicycles Cruz 7 - Women's - 2017 | 35 | 79 |
| Trek Powerfly 8 FS Plus - 2017 | 41 | 78 |
| Trek Domane AL 2 Women's - 2018 | 5 | 77 |
| Trek Domane SL 5 Disc - 2018 | 5 | 77 |

**Interpretación:** el Trek 820 - 2016 tiene 1 054 unidades en stock y cero ventas registradas, lo que es una señal de alerta clara. Varios modelos 2018 también muestran stock elevado con ventas mínimas, probablemente porque el dataset cubre solo el inicio de ese año.

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
- **`vw_store_monthly_kpis`** — proporciona métricas agregadas por tienda y mes (pedidos, unidades, facturación, descuento medio).
- **`vw_product_performance`** — consolida, por producto, las ventas totales, ingresos, descuento medio y stock disponible. Facilita el análisis de catálogo sin joins adicionales.

---

## 7. SQL avanzado

### 7.1 Transacción explícita

Se utilizó una transacción explícita (`BEGIN TRANSACTION … COMMIT`) para demostrar inserciones controladas en la tabla `fct_stock`. Esto garantiza la atomicidad de la operación.

### 7.2 Trigger

Se creó un trigger `trg_validate_discount` que impide insertar registros en `fct_sales` con descuentos fuera del rango [0, 1], reforzando la integridad de los datos a nivel de motor.

### 7.3 SQL analítico avanzado

- **CTEs** (expresiones de tabla comunes) para modularizar consultas complejas
- **Funciones de ventana**: `DENSE_RANK()`, `ROW_NUMBER()` y `NTILE()` con `PARTITION BY` y `ORDER BY`
- **`LAG()`** para calcular el crecimiento mes a mes en ventas (variación porcentual respecto al periodo anterior)
- **Subconsultas** y `CROSS JOIN` para comparaciones contra agregados globales
- **`COALESCE`** y `NULLIF` para manejo de nulos en joins y en la carga de datos

---

## 8. Control de calidad de datos

### Tratamiento de nulos en los CSV

Los archivos CSV originales contienen valores nulos representados como el texto literal 'NULL'.  
Durante la fase de transformación (`03_transform_core.sql`), estos valores se convierten en nulos reales mediante el uso de:

NULLIF(columna, 'NULL')

Esto permite que SQLite interprete correctamente los valores faltantes.

Principales casos detectados:

- `dim_customers.phone` — 1 267 valores nulos o teléfonos no disponibles
- `fct_sales.shipped_date` — 508 pedidos pendientes de envío o sin fecha de envío
- `dim_staffs.manager_id` — 1 valor nulo, seguramente director general, empleado sin superior jerárquico (no requería NULLIF porque la afinidad INTEGER de la columna destino ya lo convierte automáticamente)

### Checklist de calidad

| Control | Resultado |
|---|---|
| Teléfonos nulos en clientes |  1.267 nulos válidos |
| Empleado sin manager |  1 caso esperado |
| Pedidos no enviados |  508 registros |
| Descuentos fuera de rango [0,1] |  0 registros inválidos |
| Claves huérfanas en fct_sales |  0 registros |
| Cantidades negativas o cero |  0 registros |
| Precios inválidos |  0 registros |
| Duplicados en dimensiones |  0 registros |

---

### Insights de negocio derivados

- Se identificaron **458 pedidos distintos enviados después de la fecha requerida**, lo que sugiere posibles ineficiencias logísticas.
- Se detectaron **14 productos sin ventas**, lo que puede indicar baja rotación o exceso de catálogo.

Estos resultados no representan errores de datos, sino oportunidades de análisis operativo y comercial.

---

## 9. Supuestos y limitaciones

### Supuestos

- Los datos CSV se toman tal cual desde Kaggle; no se ha aplicado ninguna corrección de valores (solo limpieza estructural).
- Los CSV codifican nulos como el texto literal `NULL`; en la capa core se convierten a `NULL` real mediante `NULLIF()`.
- El campo `shipped_date` con valor `NULL` en las tablas staging se interpreta como pedido aún no enviado; se conserva el nulo real tras la conversión.
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
- Existe una concentración de ingresos notable: Trek representa el 63% de la facturación total y los 10 productos estrella generan el 37% de los ingresos. Esto hace al negocio vulnerable a cambios en la relación con esa marca.
- Se identifican **458 pedidos retrasados** (enviados después de la fecha requerida), lo que apunta a ineficiencias logísticas relevantes. *(Conteo de pedidos distintos; verificar con `06_quality_checks_part1.sql` si los datos cambian.)*
- Existen **14 productos sin ninguna venta registrada** en el periodo analizado, entre ellos el Trek 820 - 2016 con 1 054 unidades en stock. Esto indica oportunidades claras de optimización del catálogo.
- El 37,6% de los clientes (543 de 1 445) supera el gasto medio de 5 324,87 €, lo que delimita un segmento de alto valor con potencial para acciones de fidelización.
- Los datos de 2018 solo cubren hasta abril de forma completa; los meses posteriores tienen muy pocas transacciones y deben excluirse de comparativas anuales.

---

## 12. Créditos

Dataset original obtenido de Kaggle: *Bike Store Relational Database*.  
Motor SQL: **SQLite 3**.  
Herramienta de gestión: **DBeaver Community Edition**.
