/*
Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа.
Для этого примените оконную функцию ROW_NUMBER к колонке с временем заказа.
Не забудьте указать деление на партиции по пользователям и сортировку внутри партиций.
Отменённые заказы не учитывайте. Новую колонку с порядковым номером заказа назовите order_number.
Результат отсортируйте сначала по возрастанию id пользователя, затем по возрастанию order_number.
Добавьте LIMIT 1000.
Поля в результирующей таблице: user_id, order_id, time, order_number
*/

SELECT
  user_id,
  order_id,
  time,
  ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY
      time
  ) AS order_number
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
ORDER BY
  user_id ASC,
  order_number ASC
LIMIT
  1000