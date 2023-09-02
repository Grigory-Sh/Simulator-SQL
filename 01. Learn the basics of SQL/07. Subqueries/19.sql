/*
Для каждого заказа, в котором больше 5 товаров, рассчитайте время, затраченное на его доставку. 
В результат включите id заказа, время принятия заказа курьером, время доставки заказа и время,
затраченное на доставку. Новые колонки назовите соответственно time_accepted, time_delivered и delivery_time.
В расчётах учитывайте только неотменённые заказы. Время, затраченное на доставку,
выразите в минутах, округлив значения до целого числа. Результат отсортируйте по возрастанию id заказа.
Поля в результирующей таблице: order_id, time_accepted, time_delivered и delivery_time

Пояснение:
Чтобы перевести значение интервала в минуты, необходимо извлечь из него количество секунд,
а затем поделить это значение на количество секунд в одной минуте.
Для извлечения количества секунд из интервала можно воспользоваться следующей конструкцией:

SELECT EXTRACT(epoch FROM INTERVAL '3 days, 1:21:32')

Результат:
264092	

Функция EXTRACT работает аналогично функции DATE_PART, которую мы рассматривали на прошлых уроках, но имеет несколько иной синтаксис. Попробуйте воспользоваться функцией EXTRACT в этой задаче.
*/

SELECT
  order_id,
  MIN(time) AS time_accepted,
  MAX(time) AS time_delivered,
  ROUND(
    EXTRACT(
      epoch
      FROM
        MAX(time) - MIN(time)
    ) / 60
  ) :: INTEGER AS delivery_time
FROM
  courier_actions
WHERE
  order_id IN (
    SELECT
      order_id
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
      AND ARRAY_LENGTH(product_ids, 1) > 5
  )
GROUP BY
  order_id
ORDER BY
  order_id

-- OR

SELECT order_id,
       min(time) as time_accepted,
       max(time) as time_delivered,
       (extract(epoch
FROM   max(time) - min(time))/60)::integer as delivery_time
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   orders
                    WHERE  array_length(product_ids, 1) > 5)
   and order_id not in (SELECT order_id
                     FROM   user_actions
                     WHERE  action = 'cancel_order')
GROUP BY order_id
ORDER BY order_id