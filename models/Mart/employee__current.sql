select * from {{ ref('dim_employee') }}
where dbt_valid_to is null 
