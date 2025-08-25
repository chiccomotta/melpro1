{{ config(materialized='table') }}

SELECT
    "CustomerID" AS customer_id,
    UPPER("FirstName") AS customer_name_upper
FROM {{ source('public', 'customers_staging') }}
