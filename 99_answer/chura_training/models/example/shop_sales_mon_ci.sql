with customer_order as (
    select
        t2.customer_location,
        {{ month_format('t1.order_time') }} as month,
        t1.customer_id,
        t1.order_amount
    from
        {{ source('chura_training', 'orders') }} as t1
    left join {{ source('chura_training', 'customers') }} as t2
        on t1.customer_id = t2.customer_id
),

-- 月、顧客、都道府県毎に売り上げを集計、ランクづけ
final as (
    select
        month,
        customer_location,
        customer_id,
        sum(order_amount) as order_amount,
        rank()
            over (
                partition by customer_location, month
                order by sum(order_amount) desc
            )
            as order_rank
    from
        customer_order
    group by -- noqa: AM06
        month,
        customer_location,
        customer_id
)

select * from final
