
-- Use the `ref` function to select from other models

select *
-- from {{ ref('my_first_dbt_model') }}
from raw.stripe.payments
where id = 1
