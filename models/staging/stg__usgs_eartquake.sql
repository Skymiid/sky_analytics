with source as (
  select
    * 
  from
    {{ source('sky_source', 'usgs__earthquake') }}
)
select
  *
from
  source