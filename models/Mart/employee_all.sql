select 
*,
case when dbt_valid_to is null then 1 else 0 end as iscurrent
from 
{{ ref('dim_employee') }}