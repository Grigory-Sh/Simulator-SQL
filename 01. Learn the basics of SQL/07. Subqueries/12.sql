/*
Определите количество отменённых заказов в таблице courier_actions и выясните,
есть ли в этой таблице такие заказы, которые были отменены пользователями,
но при этом всё равно были доставлены. Посчитайте количество таких заказов.
Колонку с отменёнными заказами назовите orders_canceled. Колонку с отменёнными,
но доставленными заказами назовите orders_canceled_and_delivered. 
Поля в результирующей таблице: orders_canceled, orders_canceled_and_delivered

Пояснение:
Для решения задачи пригодится оператор FILTER, который мы рассматривали в этом уроке.
*/

SELECT
  COUNT(order_id) FILTER (
    WHERE
      action = 'accept_order'
  ) AS orders_canceled,
  COUNT(order_id) FILTER (
    WHERE
      action = 'deliver_order'
  ) AS orders_canceled_and_delivered
FROM
  courier_actions
WHERE
  order_id IN (
    SELECT
      order_id
    FROM
      user_actions
    WHERE
      action = 'cancel_order'
  )