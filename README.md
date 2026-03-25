# \# Bike Store SQL Project



## \## 1. Introducción



El presente proyecto tiene como objetivo el desarrollo de un \*\*pipeline de datos en SQL\*\* a partir de un dataset relacional del sector retail (tienda de bicicletas), con el fin de transformar datos crudos en un modelo analítico estructurado que permita responder preguntas de negocio.



El proyecto sigue una arquitectura en tres capas:



\- \*\*Staging (datos crudos)\*\*

\- \*\*Core (modelo relacional limpio)\*\*

\- \*\*Semantic (vistas de negocio)\*\*







## \## 2. Dataset



El dataset está compuesto por múltiples archivos CSV que contienen información sobre:



\- Clientes

\- Pedidos

\- Líneas de pedido

\- Productos

\- Marcas

\- Categorías

\- Tiendas

\- Empleados

\- Stock



Estos datos han sido obtenidos en Kaggle y cargados en una base de datos SQLite mediante DBeaver.







## \## 3. Motor SQL utilizado



Se ha utilizado:



\*\*SQLite (gestionado a través de DBeaver)\*\*



Este motor permite trabajar de forma sencilla con datos locales, ejecutar consultas analíticas y crear estructuras como vistas, triggers y transacciones.







## \## 4. Estructura del proyecto





bike-store-sql-project/

│

├── data/ # Datos originales (CSV)

├── sql/ # Scripts SQL finales del proyecto

│ ├── 01\_schema.sql

│ ├── 02\_load\_staging.sql

│ ├── 03\_transform\_core.sql

│ ├── 04\_semantic\_views.sql

│ ├── 05\_analysis\_queries.sql

│ ├── 06\_quality\_checks.sql (part1 y part2)

│ ├── 07\_advanced\_sql.sql

│

├── bike\_store.db # Base de datos final

└── README.md

└── Scripts (los scrips en sucio entre otros)









## \## 5. Arquitectura del pipeline



### \### 5.1 Capa Staging



En esta capa se cargan los datos originales sin transformar:



\- stg\_brands  

\- stg\_categories  

\- stg\_customers  

\- stg\_order\_items  

\- stg\_orders  

\- stg\_products  

\- stg\_staffs  

\- stg\_stocks  

\- stg\_stores  



Esta capa representa la entrada directa de los datos.







### \### 5.2 Capa Core



Se construye un modelo relacional estructurado con tablas de tipo dimensión y hecho.



\#### Dimensiones:

\- dim\_brands  

\- dim\_categories  

\- dim\_customers  

\- dim\_products  

\- dim\_stores  

\- dim\_staffs  



\#### Tablas de hechos:

\- fct\_sales → ventas a nivel de línea de pedido  

\- fct\_stock → stock por producto y tienda  



En esta capa se normalizan los datos y se establecen relaciones coherentes.







### \### 5.3 Capa Semántica



Se crean vistas orientadas a negocio:



\- \*\*vw\_sales\_enriched\*\*  

&#x20; Integra ventas con información de cliente, producto, marca, categoría, tienda y empleado.



\- \*\*vw\_store\_monthly\_kpis\*\*  

&#x20; Proporciona métricas agregadas por tienda y mes.



Esta capa simplifica el análisis evitando joins complejos.







## \## 6. Transformaciones realizadas



Las principales transformaciones incluyen:



\- Unión de `orders` y `order\_items` para construir `fct\_sales`

\- Cálculo de la métrica:





sales\_amount = quantity \* list\_price \* (1 - discount)





\- Separación en dimensiones y hechos

\- Limpieza estructural de los datos sin alterar su naturaleza original







## \## 7. Análisis de negocio



Se han desarrollado múltiples consultas analíticas para responder preguntas clave:



\- Evolución temporal de las ventas

\- Productos con mayor generación de ingresos

\- Clientes más valiosos

\- Rendimiento por tienda

\- Análisis de stock vs ventas

\- Rankings por tienda y periodo



Se han utilizado:



\- CTEs

\- funciones de ventana (`ROW\_NUMBER`, `DENSE\_RANK`)

\- agregaciones avanzadas







## \## 8. Control de calidad de datos



Se realizaron diversos controles de calidad sobre el modelo de datos construido:



\- No se detectaron valores de descuento fuera del rango lógico \[0,1].

\- No se identificaron claves huérfanas en la tabla de ventas, lo que indica una correcta integridad referencial entre hechos y dimensiones.

\- Todos los registros de ventas contienen fecha de envío (`shipped\_date`), sin valores nulos.

\- No se detectaron cantidades negativas ni precios inválidos.

\- No se identificaron duplicados en claves principales de dimensiones.



\### Análisis de negocio derivado de la calidad:



\- Se identificaron \*\*3718 pedidos enviados después de la fecha requerida\*\*, lo que sugiere posibles ineficiencias logísticas o retrasos en la cadena de suministro.

\- Se detectaron \*\*28 productos sin ventas\*\*, lo que podría indicar problemas de rotación, exceso de catálogo o baja demanda.



En general, los datos presentan una \*\*alta calidad estructural\*\*, con oportunidades claras de análisis en el ámbito operativo y comercial.







## \## 9. SQL avanzado



Se han implementado elementos avanzados:



### \### 9.1 Transacción



Se utilizó una transacción explícita para demostrar inserciones controladas en la tabla de stock.



### \### 9.2 Trigger



Se creó un trigger que impide insertar registros en `fct\_sales` con descuentos fuera del rango \[0,1], reforzando la integridad de los datos.







## \## 10. Reproducibilidad



Para reproducir el proyecto:



1\. Cargar los CSV en tablas staging

2\. Ejecutar los scripts en orden:





01\_schema.sql

02\_load\_staging.sql

03\_transform\_core.sql

04\_semantic\_views.sql

05\_analysis\_queries.sql

06\_quality\_checks\_part1.sql

06\_quality\_checks\_part2.sql

07\_advanced\_sql.sql









## \## 11. Conclusiones



\- El modelo permite analizar correctamente el rendimiento del negocio.

\- Existe una concentración de ingresos en determinados productos y clientes.

\- Se identifican problemas logísticos relevantes (retrasos).

\- Existen oportunidades de optimización en el catálogo de productos.



\---



## \## 12. Limitaciones



\- Dataset estático (no tiempo real)

\- No incluye datos externos

\- Algunos campos con nulos se mantienen por coherencia del dataset original

