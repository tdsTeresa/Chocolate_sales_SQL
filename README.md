
<h2>🍫 Descripción general:</h2>
<br>
Durante esta actividad se realiza una exploración de datos en SQL Server y un dashboard de Power BI para descubrir tendencias en un dataset de ventas de chocolate. Las consultas realizadas incluyen análisis de ingresos, costo unitario de productos, tasas de retención mensual de clientes y crecimiento en ventas, así como el Valor de vida del cliente (CLV) con análisis de cohortes.</a><br><br>
Conceptos clave:<br><br></b>
  • ARPU: Ingreso promedio por usuario.<br><br>
  • Tasa de retención: Calcula cuántos clientes permanecen con nuestro servicio o producto y cuánto dinero generan.<br><br>
  • Tasa de crecimiento: Cuánto crecen las ventas respecto al mes o año anterior.<br><br>
  • CLV: (Customer lifetime value) Valor de vida del cliente, en este ejercicio el CLV se determina con un análisis de cohortes. El análisis de cohortes es una técnica que observa el comportamiento de usuarios que comenzaron su registro o consumo de cierto producto o servicio en el mismo mes y sigue su evolución en el tiempo.
<br><br>
<h2>⚙️Tecnologías: </h2>
<br>
    • SQL Server <br>
    • Microsoft Power BI<br>
<br><br>

<h2>🖇️ Fuente: </h2><br>
https://www.kaggle.com/datasets/ssssws/chocolate-sales-dataset-2023-2024?select=calendar.csv
<br>
<br>
<br>
<h2>📊 Actividades: </h2>
<br>
  • Definición de base de datos e importación de datos.<br>
  • Consultas para extraer cálculos de precios y métricas.<br>
  • CTE y funciones de agregación.<br> 
  • Comparación de resultados en Power BI.<br> 
<br>
<br>
<h2><b></b>Exploración en Power BI</b></h2>
<br>
Resultados del dataset, a primera vista los ingresos y costos están casi a la par, generando muy bajas ganancias y siendo esto perjudicial para el negocio.<br>
<br><br>

![dashboard](images/dashboard.png)
<br><br><br>
<b>Resultados de consultas con SQL Server para recalcular ingresos, costos, y otras métricas. Ahora los ingresos están por arriba de los costos.</b><br><br>
Cada una de las tarjetas indica en color verde (ganancias) o rojo (perdidas) la comparación con el mes anterior de las métricas.<br><br>
El mapa de calor refleja el valor mensual del CLV. Las columnas indican el número de meses desde que el cliente ha realizado su primera compra (compras del mismo mes obtienen el valor 0, compras desde hace un mes, 1 y así sucesivamente hasta completar 24 meses -periodo enero 2023 a diciembre 2024), y las filas indican las fechas cohorte, periodo en que se ha llevado a cabo el registro o primera compra de los clientes (periodo enero 2023 a febrero 2024). Así, podemos comprender que el periodo con mayor CLV es de enero a agosto 2023.
<br><br>

![after_SQL_dashboard](images/dashboard2.png)
<br></br>
![after_SQL_dashboard](images/dashboard3.png)
<br><br>
<h2><b></b>Exploración en SQL </b></h2>
<br><br>
▫️Ingreso y ganancias por país y tipo de tienda<br><br>

![revenue_per_country](images/revenue_per_country.png)
<br><br><br>
▫️Las semanas de mayor ingreso (iniciando los días lunes)<br><br>

![revenue_per_week](images/revenue_per_week.png)
<br><br><br>
▫️Clientes más frecuentes durante la semana de mayor ingreso <br><br>
![frequent_user](images/frequent_user.png)
<br><br><br>
▫️Costo unitario por producto <br><br>

![unit_cost](images/unit_cost.png)
<br><br><br>
▫️Conteo de clientes registrados<br><br>
Se realizó una columna de ajuste de fechas (adjusted_join_date)  ya que algunos clientes contaban con fechas de registro posteriores a su primera compra.<br><br>
![adjusted_join_date](images/adjusted_join_date.png)
<br><br><br>

▫️Tasa de retención mensual<br><br>
![retention_rate](images/retention_rate.png)
<br><br><br>
▫️Tasa de crecimiento mensual en ventas<br><br>

![monthly_growth_rate](images/monthly_growth_rate.png)
<br><br><br>
▫️CLV Customer Lifetime Value (Valor de vida del cliente)<br><br>

![clv](images/clv.png)
<br><br><br>
▫️Organización del número de clientes por ingreso<br><br>

![bucketing](images/bucketing.png)
<br><br><br>
<h2>🔶 Observaciones generales:</h2>
<br>
• Los países con más ingresos han sido Reino Unido y Alemania. Las tiendas en aeropuertos aportan más ingresos y beneficios al negocio.<br>
• Las semanas con más ingresos han sido a finales de enero y septiembre de 2024.<br> 
• A finales de enero de 2024, los clientes más frecuentes tenían rangos de edad desde 34 a 57 años y fueron en su mayoría mujeres, sin embargo, los hombres son los clientes que cuentan con más membresías.<br>
• El ARPU es de 538.96 unidades monetarias.<br>
• Los productos con mayor costo y ganancias son White Chocolate 50% de Ferrero, White Chocolate 60% de Godiva y Truffle Chocolate 70% de Cadbury.<br>
• Los periodos con más registros de clientes fueron  diciembre 2021 y marzo 2022. <br>
• Las tasa de retención supera el 50% y sigue una tendencia de subida y bajada con los meses.<br>
• De la misma manera, las tasas de crecimiento del negocio también siguen una tendencia de subida y bajada con los meses.<br>
• El CLV disminuye con el paso del tiempo, algunos clientes disminuyen sus compras o ticket promedio.<br>
• EL grupo de clientes que más ingresos atrae al negocio es también el más numeroso.
<br>
