WITH spine AS (
    SELECT 
        DATEADD(DAY, SEQ4(), '2024-01-01'::DATE) AS date_day 
    FROM TABLE(generator(rowcount => 1200))
)
SELECT 
    date_day, 
    YEAR(date_day) AS year, 
    MONTH(date_day) AS month, 
    MONTHNAME(date_day) AS month_name,
    DAYNAME(date_day) AS day_name, 
    (DAYOFWEEKISO(date_day) >= 6) AS is_weekend
FROM spine 
WHERE date_day <= '2026-12-31'
