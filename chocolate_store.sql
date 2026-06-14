										-- DEFINICIÓN DE BD Y TABLAS
CREATE DATABASE choco_store

CREATE TABLE sales(
					order_id VARCHAR(15) PRIMARY KEY,
					order_date DATE,
					product_id VARCHAR(6),
					store_id VARCHAR(5),
					customer_id VARCHAR(15),
					quantity SMALLINT,
					unit_price FLOAT,
					discount FLOAT,
					revenue FLOAT,
					cost FLOAT,
					profit FLOAT,
					FOREIGN KEY(product_id) REFERENCES products(product_id),
					FOREIGN KEY(store_id) REFERENCES stores(store_id),
					FOREIGN KEY(customer_id) REFERENCES customers(customer_id))
					
					CREATE INDEX idx_unit_price ON sales(unit_price)
					CREATE INDEX idx_quantity ON sales(quantity)
					CREATE INDEX idx_discount ON sales(discount)
					CREATE INDEX idx_cost ON sales(cost)

CREATE TABLE stores(
					store_id VARCHAR(5) PRIMARY KEY,
					store_name VARCHAR(20),
					city CHAR(15),
					country CHAR(15),
					store_type CHAR(10))
CREATE TABLE customers1(
						customer_id VARCHAR(15) PRIMARY KEY,
						age INT,
						gender VARCHAR(6),
						loyalty_member BIT,
						join_date DATE)
CREATE TABLE products(
						product_id VARCHAR(6) PRIMARY KEY,
						product_name VARCHAR(25),
						brand CHAR(10),
						category CHAR(10),
						cocoa_percent INT,
						weight_g INT)
						drop table customers
										-- IMPORTACIÓN DE DATOS

BULK INSERT sales from 'sales.csv'
with (Firstrow= 2,
FieldTerminator= ',',
 ROWTERMINATOR = '\n',
  TABLOCK
)
BULK INSERT stores from 'stores.csv'
with (Firstrow= 2,
FieldTerminator= ',',
 ROWTERMINATOR = '\n',
  TABLOCK
)
BULK INSERT customers1 from 'customers.csv'
with (Firstrow= 2,
FieldTerminator= ',',
 ROWTERMINATOR = '\n',
  TABLOCK
)
BULK INSERT products from 'products.csv'
with (Firstrow= 2,
FieldTerminator= ',',
 ROWTERMINATOR = '\n',
  TABLOCK
)

										-- CONSULTAS DE INGRESO, COSTO Y GANANCIAS

--1. INGRESO Y GANANCIAS POR PAÍS Y MODALIDAD DE VENTAS

WITH SALES_METRICS AS (
						SELECT s.country,
								s.store_type,
								SUM((sa.quantity * sa.unit_price) - sa.discount) AS Revenue,
								SUM(((sa.quantity * sa.unit_price) - sa.discount) - sa.cost) AS Profit
								FROM stores s
								LEFT JOIN sales sa
								ON sa.store_id = s.store_id
								GROUP BY s.country, s.store_type)

SELECT country,
		store_type, 
		Revenue, 
		Profit
		FROM SALES_METRICS
		ORDER BY Revenue DESC

		
--2. LAS SEMANAS DE MAYOR INGRESO (INICIANDO LOS DÍAS LUNES)
SET DATEFIRST 1;
SELECT TOP (3) CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, order_date), 0) AS DATE) AS Order_date, 
		SUM((sa.quantity * sa.unit_price) - sa.discount) AS Revenue
		FROM stores s
		LEFT JOIN sales sa ON s.store_id= sa.store_id
		GROUP BY CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, order_date), 0) AS DATE)
		ORDER BY Revenue DESC
	

--3.  ¿QUIÉNES ADQUIEREN MÁS CHOCOLATE DURANTE LA SEMANA DE MÁS INGRESOS?
SELECT TOP (5) c.age, c.gender, 
				COUNT(c.loyalty_member) AS Loyalty,
				SUM((sa.quantity * sa.unit_price) - sa.discount) AS Revenue
				FROM customers1 c
				LEFT JOIN sales sa on sa.customer_id = c.customer_id
				WHERE sa.order_date IN (SELECT CAST(DATEADD(WEEK, -1 ,'2024-01-29') AS DATE)) --DATEADD -1 RESTA UNA SEMANA A PARTIR DEL LUNES 29 DE ENERO
				GROUP BY age, gender
				ORDER BY Revenue DESC

--4.  ¿LAS MUJERES CUENTAN CON MÁS MEMBRESÍAS?
SELECT gender, 
		COUNT(loyalty_member) as Loyalty 
		FROM customers1 
		GROUP BY gender 
		ORDER BY Loyalty

--5.  ARPU (AVERAGE REVENUE PER USER): INGRESO PROMEDIO POR USUARIO
WITH ARPU AS (
				SELECT SUM((sa.quantity * sa.unit_price) - sa.discount) AS Total_revenue,
						COUNT(DISTINCT c.customer_id) AS Count_users
						FROM customers1 c
						LEFT JOIN sales sa
						ON c.customer_id= sa.customer_id)

SELECT ROUND(Total_revenue/Count_users, 2) AS Arpu 
		FROM ARPU

--6. COSTO UNITARIO POR PRODUCTO
WITH SALES_METRICS AS (
						SELECT p.product_name,
								p.brand,
								ROUND(sa.cost/sa.quantity, 2) AS Unit_cost,
								SUM(((sa.quantity * sa.unit_price) - sa.discount) - sa.cost) AS Profit
								FROM products p
								LEFT JOIN sales sa
								ON sa.product_id = p.product_id
								GROUP BY p.product_name, p.brand, sa.cost, sa.quantity)

SELECT TOP (5) product_name,
				brand,
				Unit_cost,
				Profit
				FROM SALES_METRICS
				ORDER BY Unit_cost DESC


										-- CONSULTAS DE REGISTRO Y RETENCIÓN DE CLIENTES, CRECIMIENTO DEL NEGOCIO
		

--7. KPI DEL CONTEO DE CLIENTES REGISTRADOS

WITH REG_DATES AS (
					SELECT customer_id,
					CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, join_date), 0) AS DATE) as Reg_date --Trunca la fecha a mes				
					FROM customers1
					GROUP BY customer_id, 
					CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, join_date), 0) AS DATE))
SELECT r.Reg_date,
		CASE
			WHEN r.Reg_date > s.order_date THEN s.order_date	-- Algunas fechas de registro tienen inconsistencias (join_date > order_date)
			ELSE r.Reg_date
		END AS adjusted_join_date,
		COUNT (DISTINCT r.customer_id) AS Count_regs
		FROM sales s
		JOIN REG_DATES r
		ON s.customer_id = r.customer_id
		GROUP BY r.Reg_date,
		CASE
			WHEN r.Reg_date > s.order_date THEN s.order_date
			ELSE r.Reg_date END
				ORDER BY adjusted_join_date ASC, Count_regs DESC

--8. TASA DE RETENCIÓN MENSUAL
WITH ACTIVITY AS (
				SELECT customer_id,
						CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE) AS Order_date
						FROM sales
						GROUP BY customer_id, CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE))
					  
SELECT previous.Order_date,
		CAST((COUNT(DISTINCT currentA.customer_id) * 1.0 
         / NULLIF(COUNT(DISTINCT previous.customer_id),0)) * 100 AS DECIMAL(5,2)) AS Retention_rate
		FROM ACTIVITY AS previous
		LEFT JOIN ACTIVITY AS currentA
		ON previous.customer_id= currentA.customer_id
		AND currentA.Order_date=  DATEADD(MONTH, 1, previous.Order_date)
		GROUP BY previous.Order_date
		ORDER BY previous.Order_date ASC
						
--9. TASA DE CRECIMIENTO MENSUAL EN VENTAS
WITH SALES1 AS (
				SELECT CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE) AS Order_date,
				SUM((quantity * unit_price) - discount) AS Total_revenue
				FROM sales
				GROUP BY CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE)),
	LAGGED AS (
				SELECT Order_date, Total_revenue,
				LAG(Total_revenue) OVER (ORDER BY Order_date ASC) AS Last_sales
				FROM SALES1)

SELECT Order_date,
		CAST(ROUND((Total_revenue - COALESCE(Last_sales, Total_revenue)) * 1.0 
		/	COALESCE(Last_sales, Total_revenue), 2) * 100 AS DECIMAL(10, 2)) AS Growth
		FROM LAGGED
		ORDER BY Order_date ASC

		
--10. CLV (CUSTOMER LIFETIME VALUE): VALOR DE VIDA DEL CLIENTE

-- ANÁLISIS DE COHORTES PARA DETERMINAR EL TOTAL DE CLV MENSUAL Y CLV ACUMULADO

WITH FIRST AS (
				SELECT c.customer_id,
						MIN(s.order_date) as Cohort
						FROM customers1 c
						LEFT JOIN sales s
						ON s.customer_id= c.customer_id
						GROUP BY c.customer_id),
REVENUE AS (
				SELECT f.Cohort,
					DATEDIFF(MONTH, f.Cohort, s.order_date) AS Cohort_month,
					COUNT(DISTINCT c.customer_id) AS Count_users,
					SUM((s.quantity * s.unit_price) - s.discount) AS Month_revenue,																				-- CLV mensual
					SUM(SUM((s.quantity * s.unit_price) - s.discount)) OVER (PARTITION BY f.Cohort ORDER BY DATEDIFF(MONTH, f.Cohort, s.order_date)) AS Total_CLV	-- CLV acumulado
					FROM sales s
					RIGHT JOIN customers1 c
					ON s.customer_id= c.customer_id
					INNER JOIN FIRST f 
					ON s.customer_id= f.customer_id
					GROUP BY f.Cohort, DATEDIFF(MONTH, f.Cohort, s.order_date))

SELECT Cohort_month,								-- Mes relativo: Diferencia en meses entre la primera compra y la fecha de cada pedido
		Cohort,										-- Fecha de la primera compra
		SUM(Month_revenue) AS Total_monthly_CLV,	-- Suma de CLV mensual
		Total_CLV									-- CLV acumulado
		FROM REVENUE
		GROUP BY Cohort_month, Cohort, Total_CLV
		ORDER BY Cohort_month, Cohort

--11. BUCKETING: ORGANIZACIÓN DE GRUPOS DE CLIENTES POR INGRESO

WITH USER_REVENUES AS (
						SELECT c.customer_id,
						SUM((s.quantity * s.unit_price) - s.discount) AS Total_revenue
						FROM customers1 c
						LEFT JOIN sales s
						ON c.customer_id= s.customer_id
						GROUP BY c.customer_id)

SELECT
		CASE 
			WHEN Total_revenue < 220 THEN 'Low-Revenue Users'
			WHEN Total_revenue < 530 THEN 'Mid-Revenue Users' -- Para establecer el promedio de ingresos, se tomó en cuenta ARPU = 538
			ELSE 'High-Revenue Users'
		END AS Revenue_group,
		COUNT(DISTINCT customer_id) AS Users
		FROM USER_REVENUES
		GROUP BY CASE
			WHEN Total_revenue < 220 THEN 'Low-Revenue Users'	-- Conteo de clientes que generan bajo ingreso
			WHEN Total_revenue < 530 THEN 'Mid-Revenue Users'	-- Clientes que generan un ingreso medio
			ELSE 'High-Revenue Users'							-- Clientes que generan alto ingreso
			END						
