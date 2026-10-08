USE databridge;

# Query1:
# Show overall session and order volume, trended by quarter for the life of the business.
SELECT
YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Year_,
QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Quarter_,
COUNT(DISTINCT s.website_session_id) AS total_sessions,
COUNT(DISTINCT o.order_id) AS total_orders
FROM website_sessions s
LEFT JOIN orders o ON s.website_session_id = o.website_session_id
GROUP BY YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')), QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i'))
ORDER BY Year_, Quarter_;

#Query2:
# Show quarterly figures since launch for session-to-order conversion rate, revenue per order, and revenue per session. 
SELECT
YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Year_,
QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Quarter_,
COUNT(DISTINCT s.website_session_id) AS total_sessions,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT s.website_session_id),4) AS session_to_order_conversion_rate,
ROUND(SUM(o.price_usd)/COUNT(DISTINCT o.order_id),2) AS revenue_per_order,
ROUND(SUM(o.price_usd)/COUNT(DISTINCT s.website_session_id),2) AS revenue_per_session
FROM website_sessions s
LEFT JOIN orders o ON s.website_session_id = o.website_session_id
GROUP BY YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')), QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i'))
ORDER BY Year_, Quarter_;

# Query3
# Show a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in.
SELECT
YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Year_,
QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Quarter_,
SUM(CASE WHEN s.utm_source='gsearch' AND s.utm_campaign='nonbrand' THEN 1 ELSE 0 END) AS orders_gsearch_nonbrand,
SUM(CASE WHEN s.utm_source = 'bsearch' AND s.utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS bsearch_nonbrand_orders,
    SUM(CASE WHEN s.utm_campaign = 'brand' THEN 1 ELSE 0 END) AS brand_search_orders,
    SUM(CASE WHEN s.utm_source = 'organic' THEN 1 ELSE 0 END) AS organic_orders,
    SUM(CASE WHEN s.utm_source IS NULL AND s.http_referer IS NULL THEN 1 ELSE 0 END) AS direct_typein_orders
FROM website_sessions s
LEFT JOIN orders o ON s.website_session_id = o.website_session_id
GROUP BY YEAR(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')), QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i'))
ORDER BY Year_, Quarter_;


# Query4
# Show the overall session-to-order conversion rate trends for those same channels by quarter, 
# and note any periods where major improvements or optimizations were made. 
SELECT
s.utm_source,
s.utm_campaign,
s.utm_content,
QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')) AS Quarter_,
COUNT(DISTINCT s.website_session_id) AS total_sessions,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT s.website_session_id),4) AS session_to_order_conversion_rate
FROM website_sessions s
LEFT JOIN orders o ON s.website_session_id = o.website_session_id
GROUP BY 
    QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')),
    s.utm_source,
    s.utm_campaign,
    s.utm_content
ORDER BY
    QUARTER(STR_TO_DATE(s.created_at, '%m/%d/%Y %H:%i')),
    s.utm_source,
    s.utm_campaign,
    s.utm_content;


# Query5
# Pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything about seasonality. 
SELECT p.product_name,
       MONTH(o.created_at) AS month_,
       SUM(o.order_id) AS total_sales,
       SUM(o.price_usd) AS total_revenue,
       SUM(o.price_usd-o.cogs_usd)
FROM order_items o LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name, month_
ORDER BY p.product_name, month_;
       

# Query6
# Pull monthly sessions to the /products page and show how the percentage of 
# those sessions clicking through another page has changed over time, along with 
# conversion from /products to placing an order. 
WITH product_sessions AS(
  SELECT s.website_session_id ,
  YEAR(s.created_at) AS year,
  MONTH(s.created_at) AS month
  FROM website_sessions s JOIN website_pageviews pv ON s.website_session_id= pv.website_session_id
  WHERE pv.pageview_url = '/products'
  GROUP BY s.website_session_id, year, month
),
clickthrough AS (
   SELECT DISTINCT ps.website_session_id,
   CASE WHEN COUNT(pv.website_pageview_id) >1 THEN 1 ELSE 0 END AS clicked_through
   FROM product_sessions ps JOIN website_pageviews pv ON ps.website_session_id = pv.website_session_id
   GROUP BY ps.website_session_id
),
orders AS (
   SELECT DISTINCT ps.website_session_id
   FROM product_sessions ps JOIN website_pageviews pv ON ps.website_session_id = pv.website_session_id
   WHERE pv.pageview_url = '/thank-you-for-your-order'
)
SELECT ps.month, 
     SUM(ct.clicked_through)/COUNT(DISTINCT ps.website_session_id)*100 AS percent_clickthrough,
     COUNT(DISTINCT o.website_session_id) * 1.0 / COUNT(DISTINCT ps.website_session_id) * 100 AS percent_conversion_to_order
FROM product_sessions ps
LEFT JOIN clickthrough ct
    ON ps.website_session_id = ct.website_session_id
LEFT JOIN orders o
    ON ps.website_session_id = o.website_session_id
GROUP BY ps.year, ps.month
ORDER BY ps.year, ps.month;


# Query7
# Pull sales data since the 4th product was made available as a primary product (December 05, 2014), and show how well each product cross-sells from one another. 
SELECT 
    oi1.product_id AS product_a,
    oi2.product_id AS product_b,
    COUNT(DISTINCT oi1.order_id) AS orders_with_both
FROM order_items oi1
JOIN order_items oi2 
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
WHERE oi1.created_at >= '2014-12-05'
GROUP BY oi1.product_id, oi2.product_id
ORDER BY orders_with_both DESC;




