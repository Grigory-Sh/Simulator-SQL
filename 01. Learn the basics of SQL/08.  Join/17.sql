/*
По таблицам orders и courier_actions определите id десяти заказов, которые доставляли дольше всего.
Поле в результирующей таблице: order_id
*/

SELECT
  order_id
FROM
  (
    SELECT
      order_id,
      creation_time,
      time AS deliver_time
    FROM
      orders FULL
      JOIN courier_actions USING (order_id)
    WHERE
      action = 'deliver_order'
  ) AS t
ORDER BY
  deliver_time - creation_time DESC
LIMIT
  10

-- OR

SELECT order_id
FROM   orders
    RIGHT JOIN (SELECT order_id,
                       time as deliver_time
                FROM   courier_actions
                WHERE  action = 'deliver_order') as t using (order_id)
ORDER BY deliver_time - creation_time desc limit 10