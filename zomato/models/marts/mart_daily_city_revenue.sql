SELECT
    order_date, 
    city, 
    COUNT(*) AS orders, 
    COUNT_IF(is_delivered) AS delivered_orders,
    ROUND(DIV0(COUNT_IF(order_status='Cancelled'), COUNT(*)),4) AS cancel_rate,
    SUM(IFF(is_delivered, sales_amount, 0)) AS gmv,
    ROUND(DIV0(SUM(IFF(is_delivered, sales_amount,0)), COUNT_IF(is_delivered)),2) AS aov
FROM {{ ref('fct_orders') }} 
GROUP BY 1,2
