/*
Из таблицы couriers выведите всю информацию о курьерах,
которые в сентябре 2022 года доставили 30 и более заказов.
Результат отсортируйте по возрастанию id курьера.
Поля в результирующей таблице: courier_id, birth_date, sex

Пояснение:
Обратите внимание, что информация о курьерах находится в таблице couriers,
а информация о действиях с заказами — в таблице courier_actions.
*/

WITH table_1 AS (
  SELECT
    courier_id
  FROM
    courier_actions
  WHERE
    DATE_PART('month', time) = 9
    AND DATE_PART('year', time) = 2022
    AND action = 'deliver_order'
  GROUP BY
    courier_id
  HAVING
    count(distinct order_id) >= 30
)

SELECT
  courier_id,
  birth_date,
  sex
FROM
  couriers
WHERE
  courier_id IN (
    SELECT
      *
    FROM
      table_1
  )
ORDER BY
  courier_id