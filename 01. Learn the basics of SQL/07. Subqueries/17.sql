/*
Рассчитайте средний размер заказов, отменённых пользователями мужского пола.
Средний размер заказа округлите до трёх знаков после запятой.
Колонку со значением назовите avg_order_size.
Поле в результирующей таблице: avg_order_size
*/

SELECT
  ROUND(AVG(array_length(product_ids, 1)), 3) AS avg_order_size
FROM
  orders
WHERE
  order_id IN (
    SELECT
      order_id
    FROM
      user_actions
    WHERE
      user_id IN (
        SELECT
          user_id
        FROM
          users
        WHERE
          sex = 'male'
      )
      AND action = 'cancel_order'
  )

-- OR

SELECT round(avg(array_length(product_ids, 1)), 3) as avg_order_size
FROM   orders
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order'
                       and user_id in (SELECT user_id
                                    FROM   users
                                    WHERE  sex = 'male'))