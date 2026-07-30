
-- ------------------------------------------------------------------------------
-- STEP 1: EXPLORATORY DATA ANALYSIS & STRUCTURE
-- ------------------------------------------------------------------------------

-- Q1: View top 10 records from the customers table to inspect its structure.
SELECT * FROM `target.customers` LIMIT 10;

-- Q2: View top 5 records from the geolocation table.
SELECT * FROM `target.geolocation` LIMIT 5;

-- Q3: Get the time range between which the orders were placed.
SELECT 
    MIN(order_purchase_timestamp) AS start_time, 
    MAX(order_purchase_timestamp) AS end_time 
FROM `target.orders`;

-- Q4: Count/Display the cities and states of the customers who ordered during a given period (Jan-Mar 2018).
SELECT 
    c.customer_city, 
    c.customer_state
FROM `target.orders` AS o
INNER JOIN `target.customers` AS c 
    ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
  AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 3;


-- ------------------------------------------------------------------------------
-- STEP 2: IN-DEPTH ORDER EXPLORATION (SEASONALITY & PEAK HOURS)
-- ------------------------------------------------------------------------------

-- Q5: Is there a growing trend in the number of orders placed over the past years or any monthly seasonality?
SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month, 
    COUNT(order_id) AS order_num
FROM `target.orders`
GROUP BY month
ORDER BY order_num DESC;

-- Q6: During which hours of the day do the customers mostly place their orders?
SELECT 
    EXTRACT(HOUR FROM order_purchase_timestamp) AS time, 
    COUNT(order_id) AS order_num
FROM `target.orders`
GROUP BY time
ORDER BY order_num DESC;


-- ------------------------------------------------------------------------------
-- STEP 3: DISTRIBUTION OF ORDERS & CUSTOMERS
-- ------------------------------------------------------------------------------

-- Q7: Get the month-on-month number of orders placed.
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month, 
    COUNT(*) AS num_orders
FROM `target.orders`
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- Q8: How are the customers distributed across all the states/cities?
SELECT 
    customer_city,
    customer_state, 
    COUNT(DISTINCT customer_id) AS customer_count
FROM `target.customers`
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC;


-- ------------------------------------------------------------------------------
-- STEP 4: ECONOMIC IMPACT & MONEY MOVEMENT
-- ------------------------------------------------------------------------------

-- Q9: Calculate the percentage increase in the cost of orders from year 2017 to 2018 (Include months Jan to Aug only).
WITH yearly_totals AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        SUM(p.payment_value) AS total_payment
    FROM `target.payments` AS p
    JOIN `target.orders` AS o 
        ON p.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY year
),
yearly_comparisons AS (
    SELECT 
        year, 
        total_payment,
        LAG(total_payment) OVER (ORDER BY year ASC) AS previous_year_payment
    FROM yearly_totals
)
SELECT 
    year,
    total_payment,
    previous_year_payment,
    ((total_payment - previous_year_payment) / previous_year_payment) * 100 AS percentage_increase
FROM yearly_comparisons
WHERE previous_year_payment IS NOT NULL; -- Filters out the base comparison year (2017)

-- Q10: Calculate the total and average value of order price and freight for each state.
SELECT 
    c.customer_state,
    AVG(oi.price) AS average_price,
    SUM(oi.price) AS sum_price,
    AVG(oi.freight_value) AS average_freight,
    SUM(oi.freight_value) AS sum_freight
FROM `target.orders` AS o
INNER JOIN `target.order_items` AS oi 
    ON o.order_id = oi.order_id
INNER JOIN `target.customers` AS c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state;


-- ------------------------------------------------------------------------------
-- STEP 5: SALES TRENDS & DELIVERY TIME PERFORMANCE
-- ------------------------------------------------------------------------------

-- Q11: Find the number of days taken to deliver each order from purchase date, and the difference between estimated and actual delivery.
SELECT 
    order_id,
    DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS days_to_delivery,
    DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS diff_estimated_delivery
FROM `target.orders`;

-- Q12: Find out the top 5 states with the highest average freight value.
SELECT 
    c.customer_state,
    AVG(oi.freight_value) AS average_freight
FROM `target.orders` AS o
INNER JOIN `target.order_items` AS oi 
    ON o.order_id = oi.order_id
INNER JOIN `target.customers` AS c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY average_freight DESC
LIMIT 5;

-- Q13: Find out the top 5 states with the highest average delivery time.
SELECT 
    c.customer_state,
    AVG(DATE_DIFF(DATE(o.order_delivered_customer_date), DATE(o.order_purchase_timestamp), DAY)) AS average_time_to_delivery
FROM `target.orders` AS o
INNER JOIN `target.order_items` AS oi 
    ON o.order_id = oi.order_id
INNER JOIN `target.customers` AS c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY average_time_to_delivery DESC
LIMIT 5;


-- ------------------------------------------------------------------------------
-- STEP 6: PAYMENT METHOD ANALYSIS
-- ------------------------------------------------------------------------------

-- Q14: Find the month-on-month number of orders placed using different payment types.
SELECT 
    p.payment_type,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS order_count
FROM `target.orders` AS o
INNER JOIN `target.payments` AS p 
    ON o.order_id = p.order_id
GROUP BY p.payment_type, year, month
ORDER BY p.payment_type, year, month;

-- Q15: Find the number of orders placed on the basis of the payment installments that have been paid.
SELECT 
    payment_installments,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM `target.payments`
GROUP BY payment_installments
ORDER BY payment_installments ASC;

--Q16: Identify the top 5 product categories with the highest number of items sold.
SELECT 
    'p.product category',
    COUNT(oi.product_id) AS total_items
FROM target.order_items as oi
INNER JOIN target.products p 
ON oi.product_id=p.product_id
GROUP BY 'p.product category'
ORDER BY total_items DESC
LIMIT 5;

--Q17: Find the total revenue generated by each unique payment type.
SELECT 
    payment_type,
    ROUND(SUM(payment_value),2) AS total_revenue
FROM target.payments
GROUP BY  payment.type
ORDER BY total_revenue DESC;

--Q18: Find the Total Number of Delayed Deliveries
SELECT 
    COUNT(order_id) AS total_delayed_orders
FROM target.orders
WHERE order_status='delivered'
AND order_delivered_customer_date>order_estimated_delivery_date;

--Q19: Calculate the Revenue Generated from Subsided Freight (Orders where Price > Freight)
SELECT 
    COUNT(order_id) AS total_orders,
    ROUND(SUM(price),2) AS total_revenue,
    ROUND(SUM(freight_value),2) AS total_frieght_cost
FROM target.order_items
WHERE price>freight_value;

--Q20: Count the Total Number of Active Sellers by State
SELECT 
    seller_state,
    COUNT(seller_id) as total_sellers
FROM target.sellers
GROUP BY seller_state
ORDER BY total_sellers;



