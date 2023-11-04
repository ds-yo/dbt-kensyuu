with
final as (
    select
        customer_id,
        customer_birthday
    from
        {{ source('chura_training', 'customers') }}
)

select * from final
