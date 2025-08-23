{{ config(materialized='ephemeral') }}

TRUNCATE TABLE public.customers_staging;
