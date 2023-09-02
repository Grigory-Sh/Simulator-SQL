/*
Для каждой даты в таблице user_actions посчитайте количество первых заказов, совершённых пользователями.
Первыми заказами будем считать заказы, которые пользователи сделали в нашем сервисе впервые. В расчётах учитывайте только неотменённые заказы.
В результат включите две колонки: дату и количество первых заказов в эту дату. Колонку с датами назовите date, а колонку с первыми заказами — first_orders.
Результат отсортируйте по возрастанию даты.
Поля в результирующей таблице: date, first_orders

Пояснение:
Учитывайте, что у каждого пользователя может быть всего один первый заказ (что вполне логично).
*/

SELECT
  date,
  COUNT(user_id) AS first_orders
FROM
  (
    SELECT
      user_id,
      DATE_TRUNC('day', MIN(time)) :: DATE AS date
    FROM
      user_actions
    WHERE
      order_id NOT IN (
        SELECT
          order_id
        FROM
          user_actions
        WHERE
          action = 'cancel_order'
      )
    GROUP BY
      user_id
  ) AS t1
GROUP BY
  date
ORDER BY
  date