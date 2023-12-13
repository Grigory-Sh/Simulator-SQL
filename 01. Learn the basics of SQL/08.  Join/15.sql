/*
По данным таблиц orders, products и user_actions посчитайте ежедневную выручку сервиса.
Под выручкой будем понимать стоимость всех реализованных товаров, содержащихся в заказах.
Колонку с датой назовите date, а колонку со значением выручки — revenue.
В расчётах учитывайте только неотменённые заказы.
Результат отсортируйте по возрастанию даты.
Поля в результирующей таблице: date, revenue
*/

SELECT
  date,
  SUM(price) AS revenue
FROM
  (
    SELECT
      date,
      t1.product_id,
      price
    FROM
      (
        SELECT
          creation_time :: DATE AS date,
          UNNEST(product_ids) AS product_id
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
      ) AS t1
      LEFT JOIN products AS t2 ON t1.product_id = t2.product_id
  ) AS t3
GROUP BY
  date
ORDER BY
  date

-- OR

SELECT date(creation_time) as date,
       sum(price) as revenue
FROM   (SELECT order_id,
               creation_time,
               product_ids,
               unnest(product_ids) as product_id
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY date