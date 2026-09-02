-- ================================================
-- KPI 1-5: Overall Business Health Summary
-- Business Question: What are the headline numbers
-- that describe the overall health of the business?
-- ================================================

SELECT
    ROUND(SUM("Sales")::numeric, 2)                        AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                       AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                              AS total_orders,
    ROUND((SUM("Sales") / COUNT(DISTINCT "Order.ID"))::numeric, 2) AS avg_order_value
FROM public.superstore;

--query 2--
-- ================================================
-- KPI 6: Total Quantity Sold by Category
-- Business Question: How many units did the
-- business sell across each product category?
-- ================================================

SELECT
    "Category",
    SUM("Quantity")                                    AS total_quantity,
    ROUND(SUM("Sales")::numeric, 2)                    AS total_revenue,
    ROUND((SUM("Quantity")::numeric /
          SUM(SUM("Quantity")) OVER() * 100)::numeric, 2) AS quantity_share_pct
FROM public.superstore
GROUP BY "Category"
ORDER BY total_quantity DESC;

--REGIONAL PERFORMANCE--
-- Query 3: Regional Revenue and Profit Summary
-- Stakeholder Question: Which regions generate the most revenue
-- AND which are most profitable?
-- KPIs: Revenue by Region, Profit Margin by Region, AOV by Region
-- Expected: High revenue regions may NOT be most profitable
-- ------------------------------------------------
SELECT
    "Region",
    COUNT(DISTINCT "Order.ID")                                              AS total_orders,
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    ROUND((SUM("Sales") / COUNT(DISTINCT "Order.ID"))::numeric, 2)          AS avg_order_value
FROM public.superstore
GROUP BY "Region"
ORDER BY total_revenue DESC;


-- Query 4: Revenue Contribution Percentage by Region
-- Stakeholder Question: What share of total revenue does each region hold?
-- KPI: Revenue Contribution % by Region
-- Expected: A few regions likely dominate total revenue
-- ------------------------------------------------
SELECT
    "Region",
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND((SUM("Sales") / SUM(SUM("Sales")) OVER() * 100)::numeric, 2)     AS revenue_contribution_pct,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM(SUM("Profit")) OVER() * 100)::numeric, 2)   AS profit_contribution_pct
FROM public.superstore
GROUP BY "Region"
ORDER BY revenue_contribution_pct DESC;

-- Query 5: Average Order Value by Region
-- Stakeholder Question: Are customers in some regions
-- spending more per order than others?
-- KPI: AOV by Region
-- ------------------------------------------------
SELECT
    "Region",
    COUNT(DISTINCT "Order.ID")                                              AS total_orders,
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND((SUM("Sales") / COUNT(DISTINCT "Order.ID"))::numeric, 2)          AS avg_order_value
FROM public.superstore
GROUP BY "Region"
ORDER BY avg_order_value DESC;

-- Query 6: Underperforming Regions (Below Average Profit Margin)
-- Stakeholder Question: Which regions are underperforming?
-- KPI: Profit Margin by Region vs Company Average
-- Expected: Some regions will be well below 11.61% company average
-- ------------------------------------------------
SELECT
    "Region",
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    ROUND((
        SELECT SUM("Profit") / SUM("Sales") * 100
        FROM public.superstore
    )::numeric, 2)                                                           AS company_avg_margin,
    CASE
        WHEN (SUM("Profit") / SUM("Sales") * 100) <
             (SELECT SUM("Profit") / SUM("Sales") * 100 FROM public.superstore)
        THEN 'UNDERPERFORMING'
        ELSE 'Above Average'
    END                                                                      AS performance_flag
FROM public.superstore
GROUP BY "Region"
ORDER BY profit_margin_pct ASC;

--CATEGORY PERFORMANCE--
-- Query 7: Revenue and Profit by Category
-- Stakeholder Question: Which product category drives
-- the most revenue AND profit?
-- KPI: Revenue by Category, Profit Margin by Category
-- ------------------------------------------------
SELECT
    "Category",
    COUNT(DISTINCT "Order.ID")                                              AS total_orders,
    SUM("Quantity")                                                         AS total_units,
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    ROUND((SUM("Sales") / SUM(SUM("Sales")) OVER() * 100)::numeric, 2)     AS revenue_share_pct
FROM public.superstore
GROUP BY "Category"
ORDER BY total_revenue DESC;

-- Query 8: Revenue and Profit by Sub-Category
-- Stakeholder Question: Within each category, which
-- sub-categories drive or drag performance?
-- KPI: Revenue by Sub-Category
-- ------------------------------------------------
SELECT
    "Category",
    "Sub.Category",
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    SUM("Quantity")                                                          AS total_units
FROM public.superstore
GROUP BY "Category", "Sub.Category"
ORDER BY total_revenue DESC;

-- Query 9: Top 10 Products by Revenue
-- Stakeholder Question: Which specific products
-- drive the most revenue?
-- KPI: Top 10 Products by Revenue
-- ------------------------------------------------
SELECT
    "Product.Name",
    "Category",
    "Sub.Category",
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                                              AS times_ordered
FROM public.superstore
GROUP BY "Product.Name", "Category", "Sub.Category"
ORDER BY total_revenue DESC
LIMIT 10;





-- Query 10: Bottom 10 Products by Revenue
-- Stakeholder Question: Which products generate
-- the least revenue — candidates for discontinuation?
-- KPI: Bottom 10 Products by Revenue
-- ------------------------------------------------
SELECT
    "Product.Name",
    "Category",
    "Sub.Category",
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    COUNT(DISTINCT "Order.ID")                                              AS times_ordered
FROM public.superstore
GROUP BY "Product.Name", "Category", "Sub.Category"
ORDER BY total_revenue ASC
LIMIT 10;



-- Query 11: Products with Negative Total Profit
-- Stakeholder Question: Which products is the business
-- actively losing money on?
-- KPI: Products with Negative Profit
-- Expected: These are profit destroyers — every sale makes things worse
-- ------------------------------------------------
SELECT
    "Product.Name",
    "Category",
    "Sub.Category",
    COUNT(DISTINCT "Order.ID")                                              AS times_ordered,
    ROUND(SUM("Sales")::numeric, 2)                                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct
FROM public.superstore
GROUP BY "Product.Name", "Category", "Sub.Category"
HAVING SUM("Profit") < 0
ORDER BY total_profit ASC
LIMIT 15;


-- Query 12: Sub-Categories with High Discount and Low Margin
-- Stakeholder Question: Where is discounting destroying profitability?
-- KPI: Avg Discount vs Profit Margin by Sub-Category
-- Expected: High discount = low or negative margin pattern
-- ------------------------------------------------
SELECT
    "Sub.Category",
    "Category",
    ROUND(AVG("Discount")::numeric * 100, 2)                AS avg_discount_pct,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin_pct,
    ROUND(SUM("Sales")::numeric, 2)                         AS total_revenue,
    CASE
        WHEN AVG("Discount") > 0.3
         AND (SUM("Profit") / SUM("Sales")) < 0.1
        THEN 'HIGH RISK — High Discount + Low Margin'
        WHEN AVG("Discount") > 0.2
        THEN 'WATCH — Moderate Discount'
        ELSE 'Healthy'
    END                                                      AS risk_flag
FROM public.superstore
GROUP BY "Sub.Category", "Category"
ORDER BY avg_discount_pct DESC;

--TREND ANALYSIS--
-- Query 13: Monthly Revenue Trend
-- Stakeholder Question: Is revenue growing or declining
-- month over month?
-- KPI: Monthly Revenue Trend
-- ------------------------------------------------
SELECT
    "Year",
    "Month",
    "Month.Name",
    ROUND(SUM("Sales")::numeric, 2)                                         AS monthly_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS monthly_profit,
    COUNT(DISTINCT "Order.ID")                                              AS monthly_orders
FROM public.superstore
GROUP BY "Year", "Month", "Month.Name"
ORDER BY "Year" ASC, "Month" ASC;

-- Query 14: Year over Year Revenue Growth
-- Stakeholder Question: Is the business growing
-- compared to last year?
-- KPI: YoY Revenue Growth
-- Expected: Positive growth each year
-- ------------------------------------------------
SELECT
    "Year",
    ROUND(SUM("Sales")::numeric, 2)                                         AS yearly_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS yearly_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                                              AS yearly_orders,
    ROUND(
        (SUM("Sales") - LAG(SUM("Sales")) OVER (ORDER BY "Year")) /
        NULLIF(LAG(SUM("Sales")) OVER (ORDER BY "Year"), 0) * 100
    , 2)                                                                     AS yoy_growth_pct
FROM public.superstore
GROUP BY "Year"
ORDER BY "Year" ASC;

-- Query 15: Monthly Profit Trend
-- Stakeholder Question: Is profitability consistent
-- over time or are there volatile months?
-- KPI: Monthly Profit Trend
-- ------------------------------------------------
SELECT
    "Year",
    "Month",
    "Month.Name",
    ROUND(SUM("Sales")::numeric, 2)                                         AS monthly_revenue,
    ROUND(SUM("Profit")::numeric, 2)                                        AS monthly_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2)                 AS monthly_margin_pct
FROM public.superstore
GROUP BY "Year", "Month", "Month.Name"
ORDER BY "Year" ASC, "Month" ASC;


--DISCOUNT IMPACT--
-- Query 16: Average Discount by Category
-- Stakeholder Question: Which categories receive
-- the highest average discounts?
-- KPI: Average Discount by Category
SELECT
    "Category",
    ROUND(AVG("Discount")::numeric * 100, 2)                AS avg_discount_pct,
    ROUND(SUM("Sales")::numeric, 2)                         AS total_revenue,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                              AS total_orders
FROM public.superstore
GROUP BY "Category"
ORDER BY avg_discount_pct DESC;

-- Query 17: Average Discount by Sub-Category
-- Stakeholder Question: Which specific sub-categories
-- are being over-discounted?
-- KPI: Average Discount by Sub-Category

SELECT
    "Sub.Category",
    "Category",
    ROUND(AVG("Discount")::numeric * 100, 2)                AS avg_discount_pct,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin_pct,
    ROUND(SUM("Sales")::numeric, 2)                         AS total_revenue
FROM public.superstore
GROUP BY "Sub.Category", "Category"
ORDER BY avg_discount_pct DESC;


-- Query 18: Profit Margin by Discount Range
-- Stakeholder Question: As discount increases,
-- what happens to profit margin?
-- KPI: Profit Margin by Discount Range
-- THIS IS YOUR MOST POWERFUL QUERY
-- Expected: Higher discount = lower/negative margin
-- ------------------------------------------------
SELECT
    CASE
        WHEN "Discount" = 0     THEN '1. No Discount (0%)'
        WHEN "Discount" <= 0.20 THEN '2. Low Discount (1-20%)'
        WHEN "Discount" <= 0.40 THEN '3. Medium Discount (21-40%)'
        ELSE                         '4. High Discount (41%+)'
    END                                                      AS discount_range,
    COUNT(DISTINCT "Order.ID")                              AS total_orders,
    ROUND(SUM("Sales")::numeric, 2)                         AS total_revenue,
    ROUND(SUM("Profit")::numeric, 2)                        AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin_pct,
    ROUND(AVG("Discount")::numeric * 100, 2)                AS avg_discount_pct
FROM public.superstore
GROUP BY discount_range
ORDER BY discount_range ASC;


-- Query 19: High Discount Orders with Negative Profit
-- Stakeholder Question: How many orders with high
-- discounts resulted in actual losses?
-- KPI: Revenue vs Profit by Discount Level
-- This gives you a concrete number for your recommendation
-- ------------------------------------------------
SELECT
    "Category",
    COUNT(DISTINCT "Order.ID")                               AS loss_making_orders,
    ROUND(SUM("Sales")::numeric, 2)                          AS revenue_from_losses,
    ROUND(SUM("Profit")::numeric, 2)                         AS total_loss_amount,
    ROUND(AVG("Discount")::numeric * 100, 2)                 AS avg_discount_pct
FROM public.superstore
WHERE "Discount" > 0.40
  AND "Profit" < 0
GROUP BY "Category"
ORDER BY total_loss_amount ASC;


--1.--
SELECT 
	ROUND(SUM("Sales")::numeric,2) as total_sales,
	ROUND(SUM("Profit")::numeric,2) as total_profit,
	ROUND((SUM("Profit") / sum("Sales") * 100)::numeric,2) as profit_pct
FROM superstore;

select
	min("Year") as mm,
	max("Year") as mmm
FROM superstore;
--MOM ANALYSIS--
SELECT 
    "Year",
    SUM("Sales")                                AS total_revenue,
    SUM("Profit")                               AS total_profit,
    ROUND((SUM("Profit")  / SUM("Sales")* 100)::numeric, 2)    AS profit_margin_pct
FROM superstore
GROUP BY "Year"
ORDER BY "Year";

--
SELECT 
    "Year",
    SUM("Sales")                                            AS total_revenue,
    LAG(SUM("Sales")) OVER (ORDER BY "Year")                AS prev_year_revenue,
    ROUND((SUM("Sales") - LAG(SUM("Sales")) 
        OVER (ORDER BY "Year")) * 100.0 
        / LAG(SUM("Sales")) OVER (ORDER BY "Year"), 2)     AS revenue_growth_pct,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                       AS profit_margin_pct
FROM superstore
GROUP BY "Year"
ORDER BY "Year";
--MOM ANALYSIS--
SELECT 
    "Year",
    "Month",
    "Month.Name",
    SUM("Sales")                                AS monthly_revenue,
    SUM("Profit")                               AS monthly_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)            AS profit_margin_pct
FROM superstore
GROUP BY "Year", "Month", "Month.Name"
ORDER BY "Year", "Month";

SELECT 
    "Year",
    "Month",
    "Month.Name",
    SUM("Sales")                                        AS monthly_revenue,
    LAG(SUM("Sales")) OVER (ORDER BY "Year", "Month")   AS prev_month_revenue,
    ROUND((SUM("Sales") - LAG(SUM("Sales")) 
        OVER (ORDER BY "Year", "Month")) * 100.0 
        / LAG(SUM("Sales")) 
        OVER (ORDER BY "Year", "Month")::NUMERIC, 2)    AS mom_revenue_pct,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct
FROM superstore
GROUP BY "Year", "Month", "Month.Name"
ORDER BY "Year", "Month";


SELECT 
    "Month.Name",
    ROUND(AVG(mom_revenue_pct)::NUMERIC, 2) AS avg_mom_growth
FROM (
    SELECT 
        "Month",
        "Month.Name",
        ROUND((SUM("Sales") - LAG(SUM("Sales")) 
            OVER (ORDER BY "Year", "Month")) * 100.0 
            / LAG(SUM("Sales")) 
            OVER (ORDER BY "Year", "Month")::NUMERIC, 2) AS mom_revenue_pct
    FROM superstore
    GROUP BY "Year", "Month", "Month.Name"
) sub
GROUP BY "Month", "Month.Name"
ORDER BY "Month";

--DEEP DIVING INTO REGIONAL REVENUE--
SELECT DISTINCT("Region") from superstore;

SELECT 
    "Region",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
GROUP BY "Region"
ORDER BY total_revenue DESC,  total_profit DESC;
--drilling into southeast asia--
SELECT 
    "Category",
    SUM("Sales")                                    AS total_revenue,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount
FROM superstore
WHERE "Region" = 'Southeast Asia'
GROUP BY "Category"
ORDER BY profit_margin_pct ASC;
--drill into furniture category to see what causes negative profit--
SELECT 
	DISTINCT("Product.Name")
FROM superstore
WHERE "Region" = 'Southeast Asia' AND "Category" = 'Furniture'

SELECT 
    "Product.Name",
    SUM("Sales")                                    AS total_revenue,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount,
    ROUND((SUM("Sales") / 
        SUM("Quantity"))::NUMERIC, 2)               AS avg_unit_price,
    COUNT(DISTINCT "Order.ID")                      AS total_orders
FROM superstore
WHERE "Region" = 'Southeast Asia'
    AND "Category" = 'Furniture'
GROUP BY "Product.Name"
HAVING SUM("Profit") < 0
ORDER BY total_profit ASC;
--avg discount for furniture category--
SELECT 
    ROUND(AVG("Discount")::NUMERIC, 3)      AS avg_discount,
    MIN("Discount")                          AS min_discount,
    MAX("Discount")                          AS max_discount
FROM superstore
WHERE "Region" = 'Southeast Asia'
    AND "Category" = 'Furniture';

SELECT 
    "Product.Name",
    SUM("Sales")                                    AS total_revenue,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount
FROM superstore
WHERE "Region" = 'Southeast Asia'
    AND "Category" = 'Furniture'
GROUP BY "Product.Name"
HAVING AVG("Discount") > (
    SELECT AVG("Discount") 
    FROM superstore 
    WHERE "Region" = 'Southeast Asia' 
    AND "Category" = 'Furniture'
)
AND SUM("Profit") < 0
ORDER BY total_profit ASC;

--top 15 products with high discounts--
SELECT 
    "Product.Name",
    SUM("Sales")                                    AS total_revenue,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount
FROM superstore
WHERE "Region" = 'Southeast Asia'
    AND "Category" = 'Furniture'
GROUP BY "Product.Name"
HAVING AVG("Discount") > (
    SELECT AVG("Discount") 
    FROM superstore 
    WHERE "Region" = 'Southeast Asia' 
    AND "Category" = 'Furniture'
)
AND SUM("Profit") < 0
ORDER BY total_profit ASC
LIMIT 15;

--drill down to Emea region--
SELECT 
    "Category",
    SUM("Sales")                                    AS total_revenue,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount,
	COUNT(DISTINCT "Order.ID")                      AS total_orders
FROM superstore
WHERE "Region" = 'Emea'
GROUP BY "Category"
ORDER BY profit_margin_pct ASC;
--price and total orders comparision with other groups--
SELECT 
    "Region",
    COUNT(DISTINCT "Order.ID")                      AS total_orders,
    SUM("Sales")                                    AS total_revenue,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount,
    ROUND((SUM("Sales") / 
        SUM("Quantity"))::NUMERIC, 2)               AS avg_unit_price
FROM superstore
GROUP BY "Region"
ORDER BY profit_margin_pct ASC;

--
SELECT 
    "Category",
    "Ship.Mode",
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)         AS avg_shipping_cost,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                      AS total_orders
FROM superstore
WHERE "Region" = 'Emea'
GROUP BY "Category", "Ship.Mode"
ORDER BY profit_margin_pct ASC;

--EMEA low margin (5.4%) not caused by discounting. Root cause: expensive shipping modes
--— Same Day delivery for Technology and Second Class for Furniture generating negative margins. 
--Standard Class shipping in EMEA is profitable. Recommend shipping mode policy review for EMEA."
SELECT 
    "Category",
    "Ship.Mode",
    "Sub.Category",
    COUNT(DISTINCT "Order.ID")                      AS total_orders,
    SUM("Sales")                                    AS total_revenue,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)         AS avg_shipping_cost,
    ROUND((SUM("Sales") / 
        SUM("Quantity"))::NUMERIC, 2)               AS avg_unit_price,
    SUM("Profit")                                   AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                AS profit_margin_pct
FROM superstore
WHERE "Region" = 'Emea'
    AND (
        ("Category" = 'Technology' AND "Ship.Mode" = 'Same Day')
        OR
        ("Category" = 'Furniture' AND "Ship.Mode" = 'Second Class')
    )
GROUP BY "Category", "Ship.Mode", "Sub.Category"
ORDER BY profit_margin_pct ASC;

SELECT 
    "Product.Name",
    SUM("Sales")                                    AS total_revenue,
    SUM("Quantity")                                 AS total_qty,
    SUM("Profit")                                   AS total_profit,
    ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)         AS avg_shipping_cost
FROM superstore
WHERE "Region" = 'Emea'
    AND "Category" = 'Furniture'
    AND "Sub.Category" = 'Tables'
    AND "Ship.Mode" = 'Second Class'
GROUP BY "Product.Name"
ORDER BY total_profit ASC;

--"EMEA Tables via Second Class shipping: company absorbing high shipping costs (avg $80) while simultaneously offering heavy discounts. 
--Combined effect destroying margin. Either pass shipping cost to customer OR cap discounts for high-shipping-cost items."

--3.Are our high-revenue regions also our most profitable, or are some regions selling a lot but earning very little?
SELECT 
    "Region",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
GROUP BY "Region"
ORDER BY profit_margin_pct DESC ;

--4.Which product categories and sub-categories drive the most revenue and profit?
select * from superstore limit 2;

SELECT DISTINCT "Category", "Sub.Category"
FROM superstore
ORDER BY "Category", "Sub.Category";

SELECT 
    "Category",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
GROUP BY "Category"
ORDER BY profit_margin_pct DESC ;

--LOOKING INTO TECH CATEGORY--
SELECT 
    "Sub.Category",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
WHERE "Category" = 'Technology'
GROUP BY "Sub.Category"
ORDER BY total_revenue DESC ;

SELECT 
    "Sub.Category",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
WHERE "Category" = 'Office Supplies'
GROUP BY "Sub.Category"
ORDER BY total_revenue DESC ;


--why storage have low profit--
SELECT 
    "Product.Name",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders,
	ROUND(AVG("Discount")::NUMERIC, 3)              AS avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)         AS avg_shipping_cost
FROM superstore
WHERE "Sub.Category" = 'Storage' 
GROUP BY "Product.Name"
ORDER BY "profit_margin_pct" ;
--products with negative products--
SELECT 
    "Product.Name",
    SUM("Sales")                                        AS total_revenue,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)                  AS avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)             AS avg_shipping_cost
FROM superstore
WHERE "Sub.Category" = 'Storage'
GROUP BY "Product.Name"
HAVING SUM("Profit") < 0 
ORDER BY  "profit_margin_pct" ASC;
--products with high shipping and discounts--
SELECT 
    "Product.Name",
    SUM("Sales")                                        AS total_revenue,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)                  AS avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)             AS avg_shipping_cost
FROM superstore
WHERE "Sub.Category" = 'Storage'
GROUP BY "Product.Name"
HAVING SUM("Profit") < 0
    AND (
        AVG("Discount") > (SELECT AVG("Discount") FROM superstore WHERE "Sub.Category" = 'Storage')
        OR
        AVG("Shipping.Cost") > (SELECT AVG("Shipping.Cost") FROM superstore WHERE "Sub.Category" = 'Storage')
    )
ORDER BY total_profit ASC;


SELECT 
    "Product.Name",
    SUM("Sales")                                            AS total_revenue,
    SUM("Profit")                                          AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                       AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)                     AS avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)                AS avg_shipping_cost,
    ROUND((SUM("Sales") / SUM("Quantity"))::NUMERIC, 2)    AS avg_unit_price,
	COUNT(DISTINCT "Order.ID")                          AS total_orders,
    CASE 
        WHEN AVG("Discount") > (SELECT AVG("Discount") FROM superstore WHERE "Sub.Category" = 'Storage')
        AND AVG("Shipping.Cost") > (SELECT AVG("Shipping.Cost") FROM superstore WHERE "Sub.Category" = 'Storage')
        THEN 'Both'
        WHEN AVG("Discount") > (SELECT AVG("Discount") FROM superstore WHERE "Sub.Category" = 'Storage')
        THEN 'Discount'
        ELSE 'Shipping'
    END                                                     AS primary_cause
FROM superstore
WHERE "Sub.Category" = 'Storage'
GROUP BY "Product.Name"
HAVING SUM("Profit") < 0
    AND (
        AVG("Discount") > (SELECT AVG("Discount") FROM superstore WHERE "Sub.Category" = 'Storage')
        OR
        AVG("Shipping.Cost") > (SELECT AVG("Shipping.Cost") FROM superstore WHERE "Sub.Category" = 'Storage')
    )
ORDER BY total_profit ASC;


--"248 Storage products. 67 loss-making. Root cause identified for 39:
--15 products → Both high discount + high shipping
--14 products → Discount above average
--10 products → Shipping cost above average--
--Remaining 28 products → cause unknown. COGS data not available. Likely procurement/pricing issue. Data gap flagged — need cost price data from finance team."

--avg discount and avg shipping fee--
SELECT 
    ROUND(AVG("Discount")::NUMERIC, 3)                  AS storage_avg_discount,
    ROUND(AVG("Shipping.Cost")::NUMERIC, 2)             AS storage_avg_shipping
FROM superstore
WHERE "Sub.Category" = 'Storage';


--5.Are there products we are actively losing money on every time we sell them?



SELECT 
    "Category",
    COUNT(DISTINCT "Product.Name")                      AS total_products,
    SUM(CASE WHEN "Profit" < 0 
        THEN 1 ELSE 0 END)                              AS negative_profit_orders,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)                  AS avg_discount
FROM superstore
GROUP BY "Category"
ORDER BY total_profit ASC;
---office supplies has 7k orderswith negative products --
SELECT 
    "Sub.Category",
    COUNT(DISTINCT "Product.Name")                      AS total_products,
    SUM(CASE WHEN "Profit" < 0 
        THEN 1 ELSE 0 END)                              AS negative_profit_orders,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    ROUND(AVG("Discount")::NUMERIC, 3)                  AS avg_discount
FROM superstore
WHERE "Category" = 'Office Supplies'
GROUP BY "Sub.Category"
ORDER BY total_profit ASC;
SELECT
	"Category",
	"Sub.Category",
	COUNT(DISTINCT "Product.ID" ) as count 
from superstore 
group by "Category", "Sub.Category";
SELECT
    "Category",
    "Sub.Category",
    COUNT(DISTINCT "Product.ID") AS count
FROM superstore
GROUP BY
    "Category",
    "Sub.Category";


SELECT 
    "Category",
    COUNT(DISTINCT "Product.Name")                          AS total_products,
    COUNT(DISTINCT CASE WHEN "Profit" < 0 
        THEN "Product.Name" END)                            AS loss_products,
    ROUND((COUNT(DISTINCT CASE WHEN "Profit" < 0 
        THEN "Product.Name" END) * 100.0 
        / COUNT(DISTINCT "Product.Name"))::NUMERIC, 2)      AS loss_product_pct,
    SUM(CASE WHEN "Profit" < 0 
        THEN "Profit" ELSE 0 END)                          AS total_loss,
    ROUND((SUM(CASE WHEN "Profit" < 0 
        THEN "Profit" ELSE 0 END) * 100.0 
        / SUM("Profit"))::NUMERIC, 2)                      AS loss_share_of_total_profit,
    COUNT(CASE WHEN "Profit" < 0 
        THEN 1 END)                                        AS loss_orders
FROM superstore
GROUP BY "Category"
ORDER BY total_loss ASC;

--looking into sub category to find loss contribution--
SELECT 
    "Category",
	"Sub.Category",
    COUNT(DISTINCT "Product.Name")                          AS total_products,
    COUNT(DISTINCT CASE WHEN "Profit" < 0 
        THEN "Product.Name" END)                            AS loss_products,
    ROUND((COUNT(DISTINCT CASE WHEN "Profit" < 0 
        THEN "Product.Name" END) * 100.0 
        / COUNT(DISTINCT "Product.Name"))::NUMERIC, 2)      AS loss_product_pct,
    SUM(CASE WHEN "Profit" < 0 
        THEN "Profit" ELSE 0 END)                          AS total_loss,
    ROUND((SUM(CASE WHEN "Profit" < 0 
        THEN "Profit" ELSE 0 END) * 100.0 
        / SUM("Profit"))::NUMERIC, 2)                      AS loss_share_of_total_profit,
    COUNT(CASE WHEN "Profit" < 0 
        THEN 1 END)                                        AS loss_orders
FROM superstore
GROUP BY "Category" , "Sub.Category"
ORDER BY total_loss ASC;
--need to find their contribution-
SELECT 
    "Category",
    "Sub.Category",
    COUNT(DISTINCT "Product.Name")                              AS total_products,
    COUNT(DISTINCT CASE WHEN product_total_profit < 0 
        THEN "Product.Name" END)                                AS net_loss_products,
    ROUND((COUNT(DISTINCT CASE WHEN product_total_profit < 0 
        THEN "Product.Name" END) * 100.0 
        / COUNT(DISTINCT "Product.Name"))::NUMERIC, 2)          AS loss_product_pct
  
FROM (
    SELECT 
        "Category",
        "Sub.Category",
        "Product.Name",
        SUM("Profit")                                           AS product_total_profit
    FROM superstore
    GROUP BY "Category", "Sub.Category", "Product.Name"
) sub
GROUP BY "Category", "Sub.Category"
ORDER BY  net_loss_products DESC;


select * from superstore limit 5;
--6.Is our discounting strategy helping sales volume or destroying profit margins?
WITH discount_buckets AS (
    SELECT 
        "Order.ID",
        "Product.Name",
        "Category",
        "Sub.Category",
        "Sales",
        "Profit",
        "Quantity",
        "Discount",
        CASE 
            WHEN "Discount" = 0          THEN '1. No Discount'
            WHEN "Discount" <= 0.10      THEN '2. Low (1-10%)'
            WHEN "Discount" <= 0.20      THEN '3. Medium (11-20%)'
            WHEN "Discount" <= 0.30      THEN '4. High (21-30%)'
            ELSE                              '5. Very High (31%+)'
        END                             AS discount_bucket
    FROM superstore
)
SELECT 
    discount_bucket,
    COUNT(DISTINCT "Order.ID")                          AS total_orders,
    SUM("Quantity")                                     AS total_quantity,
    SUM("Sales")                                        AS total_revenue,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    ROUND(AVG("Quantity")::NUMERIC, 2)                  AS avg_quantity_per_order
FROM discount_buckets
GROUP BY discount_bucket
ORDER BY discount_bucket;
--high discount strategry failed completly it neither bought volume
--nor provided profits but leads to negative profits
--Discounting strategy is destroying profit with zero volume benefit. 
--Avg order quantity stays flat at 3.4-3.8 units regardless of discount level. High discounts (21-30%) flip margin negative at -5.5%. Very high discounts (31%+) cause -51% margin loss. 5,794 orders — 
--the largest group after no-discount — fall in the most destructive bucket.


SELECT 
    "Sub.Category",
    SUM("Sales")                                        AS total_revenue,
    ROUND(SUM("Sales") * 100.0 / 
        SUM(SUM("Sales")) OVER()::NUMERIC, 2)           AS revenue_share_pct,
    SUM("Profit")                                       AS total_profit,
    ROUND((SUM("Profit") * 100.0 
        / SUM("Sales"))::NUMERIC, 2)                    AS profit_margin_pct,
    COUNT(DISTINCT "Order.ID")                          AS total_orders
FROM superstore
WHERE "Category" = 'Furniture'
GROUP BY "Sub.Category"
ORDER BY total_revenue DESC ;
  
   

--validation--
SELECT 
	CASE
       WHEN "Discount" = 0          THEN '1. No Discount'
        WHEN "Discount" <= 0.10      THEN '2. Low (1-10%)'
        WHEN "Discount" <= 0.20      THEN '3. Medium (11-20%)'
        WHEN "Discount" <= 0.30      THEN '4. High (21-30%)'
        ELSE                              '5. Very High (31%+)'
    END                             AS discount_bucket,
    COUNT(*)                        AS order_count
FROM superstore
GROUP BY discount_bucket
ORDER BY discount_bucket;

SELECT DISTINCT "Discount" 
FROM superstore 
ORDER BY "Discount" 
LIMIT 20;