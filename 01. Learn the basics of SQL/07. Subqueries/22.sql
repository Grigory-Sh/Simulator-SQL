/*
Используя функцию unnest, определите 10 самых популярных товаров в таблице orders.
Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего.
Если товар встречается в одном заказе несколько раз (когда было куплено несколько единиц товара),
это тоже учитывается при подсчёте. Учитывайте только неотменённые заказы.
Выведите id товаров и то, сколько раз они встречались в заказах (то есть сколько раз были куплены).
Новую колонку с количеством покупок товаров назовите times_purchased.
Результат отсортируйте по возрастанию id товара.
Поля в результирующей таблице: product_id, times_purchased

Пояснение:
В этом задании вам необходимо сначала развернуть списки с товарами в заказах,
а затем для каждого товара посчитать, сколько раз он встретился в заказах.
Для определения самых популярных товаров используйте оператор LIMIT.
Обратите внимание, что отсортировать результат необходимо по колонке с id товара.


*/

SELECT
  *
FROM(
    SELECT
      UNNEST(product_ids) AS product_id,
      COUNT(*) AS times_purchased
    FROM
      orders
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
      product_id
    ORDER BY
      times_purchased DESC
    LIMIT
      10
  ) AS t1
ORDER BY
  product_id

-- OR

SELECT product_id,
       times_purchased
FROM   (SELECT unnest(product_ids) as product_id,
               count(*) as times_purchased
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY product_id
        ORDER BY times_purchased desc limit 10) t
ORDER BY product_id