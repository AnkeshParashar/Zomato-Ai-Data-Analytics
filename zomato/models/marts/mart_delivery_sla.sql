SELECT 
    city, 
    HOUR(order_timestamp) AS order_hour, 
    COUNT_IF(is_delivered) AS delivered_orders,
    ROUND(MEDIAN(delivery_time_min),1) AS p50, 
    ROUND(PERCENTILE_CONT(0.9) 
        WITHIN GROUP (ORDER BY delivery_time_min),1) AS p90
FROM {{ ref('fct_orders') }} 
WHERE is_delivered 
GROUP BY city, order_hour
