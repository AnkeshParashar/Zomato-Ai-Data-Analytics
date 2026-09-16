SELECT
    f_id,
    item AS food_name,
    INITCAP(veg_or_non_veg) AS veg_or_non_veg
FROM {{ source('raw', 'food') }}
WHERE TRY_TO_NUMBER(f_id) IS NOT NULL
