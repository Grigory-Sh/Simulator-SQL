/*
Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.
В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков после запятой.
Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. Отклонение считайте так: число заказов «минус» округлённое среднее значение.
Колонку с отклонением назовите orders_diff. Результат отсортируйте по возрастанию id пользователя.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff
*/

WITH table_1 AS (
  SELECT
    user_id,
    COUNT(order_id) AS orders_count
  FROM
    user_actions
  WHERE
    action = 'create_order'
  GROUP BY
    user_id
),
table_2 AS (
  SELECT
    ROUND(AVG(orders_count), 2) AS orders_avg
  FROM
    table_1
)

SELECT
  user_id,
  orders_count,
  (
    SELECT
      orders_avg
    FROM
      table_2
  ),
  (
    orders_count - (
      SELECT
        orders_avg
      FROM
        table_2
    )
  ) AS orders_diff
FROM
  table_1
ORDER BY
  user_id ASC
LIMIT
  1000