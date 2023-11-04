with month_calendar as (
    {{ dbt_utils.date_spine(
        datepart="month",
        start_date="'2012-01-01'",
        end_date="'2015-02-01'"
    )
    }}
)

select * from month_calendar
