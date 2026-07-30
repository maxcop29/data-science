# Target E-Commerce SQL Analysis

Exploratory and business analysis of a Brazilian e-commerce dataset (customers, orders, order items, payments, sellers, products, geolocation) using SQL. The project walks through data exploration, seasonality, delivery performance, and revenue analysis, structured as a set of progressively deeper business questions.

## Dataset

The queries reference the following tables under the `target` schema:
- `customers` — customer id, city, state
- `orders` — order status, purchase/delivery/estimated delivery timestamps
- `order_items` — price, freight value per item
- `payments` — payment type, installments, payment value
- `products` — product category and attributes
- `sellers` — seller id and state
- `geolocation` — location coordinates

## Analysis Structure

**Step 1 — Exploratory Data Analysis & Structure**
- Preview `customers` and `geolocation` tables
- Determine the overall time range of orders
- Identify cities/states of customers who ordered in Jan–Mar 2018

**Step 2 — Order Seasonality & Peak Hours**
- Monthly order volume trend
- Hour-of-day distribution of order placement

**Step 3 — Distribution of Orders & Customers**
- Month-on-month order counts by year
- Customer distribution across states/cities

**Step 4 — Economic Impact & Money Movement**
- YoY percentage increase in order value (Jan–Aug, 2017 vs 2018)
- Average and total order price/freight by state

**Step 5 — Sales Trends & Delivery Performance**
- Days to delivery, and delivery vs. estimate variance
- Top 5 states by average freight value
- Top 5 states by average delivery time

**Step 6 — Payment Method Analysis**
- Month-on-month order counts by payment type
- Order counts by number of payment installments
- Top 5 product categories by items sold
- Total revenue by payment type
- Total delayed deliveries
- Revenue from orders where price exceeds freight cost
- Active seller count by state

## Tools

SQL (BigQuery standard SQL syntax — backtick-quoted table references, `EXTRACT`, `DATE_DIFF`, window functions)

## Notes

- Q9 uses a `LAG()` window function to compute year-over-year payment growth.
- Q11 and Q13 compute delivery duration using `DATE_DIFF` between purchase and actual/estimated delivery dates.
- Q16 and Q17 have minor bugs in the source file worth fixing before running: Q16 groups by the string literal `'p.product category'` instead of the actual column (should be `p.product_category_name` or equivalent), and Q17 groups by `payment.type` instead of `payment_type`.

## File

- `target.sql` — full set of 20 queries, organized by analysis step
