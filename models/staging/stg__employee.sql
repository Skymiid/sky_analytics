with renamed as (
  select
    Id as employee_id,
    firstName as first_name,
    lastName as last_name,
    primaryWorkEmail as email,
    HireDate as hire_date,
    RehireDate as rehire_date,
    terminationdate as termination_date,
    active_status
  from
    {{ source('sky_source', 'employee_mock') }}
)
select
  *
from
  renamed