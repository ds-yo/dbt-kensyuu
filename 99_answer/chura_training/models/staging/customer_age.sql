-- 経過期間を月で算出、12で割って年齢を求める
with
final as (
    select
        customer_id,
        customer_birthday,
        trunc(months_between(current_date(), customer_birthday) / 12) as age
    from
        {{ source('chura_training', 'customers') }}
)

select *
from final
