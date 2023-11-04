-- 経過期間を月で算出、12で割って年齢を求める
WITH
final AS (
SELECT CUSTOMER_ID ,CUSTOMER_BIRTHDAY,trunc(months_between(current_date(), customer_birthday) / 12)
FROM
{{ source('chura_training', 'customers') }}
)
SELECT * FROM final
