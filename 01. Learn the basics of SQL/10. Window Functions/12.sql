/*
Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов.
Выведите id курьеров, количество доставленных заказов и порядковый номер курьера в соответствии с числом доставленных заказов.
У курьера, доставившего наибольшее число заказов, порядковый номер должен быть равен 1, а у курьера
с наименьшим числом заказов —  числу, равному десяти процентам от общего количества курьеров в таблице courier_actions.
При расчёте номера последнего курьера округляйте значение до целого числа.
Колонки с количеством доставленных заказов и порядковым номером назовите соответственно orders_count и courier_rank.
Результат отсортируйте по возрастанию порядкового номера курьера.
Поля в результирующей таблице: courier_id, orders_count, courier_rank 
*/

SELECT
  courier_id,
  orders_count,
  ROW_NUMBER() OVER (
    ORDER BY
      orders_count DESC,
      courier_id ASC
  ) AS courier_rank
FROM
  (
    SELECT
      courier_id,
      COUNT(order_id) AS orders_count
    FROM
      courier_actions
    WHERE
      action = 'deliver_order'
    GROUP BY
      courier_id
  ) AS t
ORDER BY
  courier_rank
LIMIT
  (
    SELECT
      ROUND(COUNT(DISTINCT courier_id) * 0.1)
    FROM
      courier_actions
  )

-- OR

with courier_count as (SELECT count(distinct courier_id)
                       FROM   courier_actions)
SELECT courier_id,
       orders_count,
       courier_rank
FROM   (SELECT courier_id,
               count(distinct order_id) as orders_count,
               row_number() OVER (ORDER BY count(distinct order_id) desc, courier_id) as courier_rank
        FROM   courier_actions
        WHERE  action = 'deliver_order'
        GROUP BY courier_id
        ORDER BY orders_count desc, courier_id) as t1
WHERE  courier_rank <= round((SELECT *
                              FROM   courier_count)*0.1)