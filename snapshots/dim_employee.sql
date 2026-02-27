{% snapshot dim_employee %}

{% set cols = [
    'Id',
    'firstName',
    'lastName',
    'primaryWorkEmail',
    'HireDate',
    'RehireDate',
    'terminationdate',
    'active_status'
] %}

{{
    config(
      target_schema='snapshots',
      unique_key='Id',
      strategy='check',
      check_cols=cols,
      file_format='delta',
      invalidate_hard_deletes=True 
    )
}}

select * from {{ source('sky_source', 'employee_mock') }}

{% endsnapshot %}