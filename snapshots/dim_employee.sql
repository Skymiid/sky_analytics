{% snapshot dim_employee %}

{% set cols = [
    'firstName',
    'lastName',
    'primaryWorkEmail',
    'HireDate',
    'RehireDate',
    'terminationdate',
    'Active_Status'
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