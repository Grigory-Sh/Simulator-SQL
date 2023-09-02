/*
Выясните, есть ли в таблице courier_actions такие заказы,
которые были приняты курьерами, но не были доставлены пользователям.
Посчитайте количество таких заказов.
Колонку с числом заказов назовите orders_count.
Поле в результирующей таблице: orders_count
*/

SELECT
  orders_undelivered,
  orders_canceled,
  orders_undelivered - orders_canceled AS orders_in_process
FROM
  (
    SELECT
      COUNT(order_id) FILTER (
        WHERE
          action = 'accept_order'
      ) AS orders_undelivered,
      COUNT(order_id) AS orders_canceled
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
  ) AS t1

-- OR

SELECT count(distinct order_id) as orders_undelivered,
       count(order_id) filter (WHERE action = 'cancel_order') as orders_canceled,
       count(distinct order_id) - count(order_id) filter (WHERE action = 'cancel_order') as orders_in_process
FROM   user_actions
WHERE  order_id in (SELECT order_id
                    FROM   courier_actions
                    WHERE  order_id not in (SELECT order_id
                                            FROM   courier_actions
                                            WHERE  action = 'deliver_order'))