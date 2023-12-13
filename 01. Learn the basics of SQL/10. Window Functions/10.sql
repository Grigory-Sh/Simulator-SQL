/*
По данным таблицы user_actions посчитайте число первых и повторных заказов на каждую дату.
Для этого сначала с помощью оконных функций и оператора CASE сформируйте таблицу,
в которой напротив каждого заказа будет стоять отметка «Первый» или «Повторный» (без кавычек).
Для каждого пользователя первым заказом будет тот, который был сделан раньше всего.
Все остальные заказы должны попасть, соответственно, в категорию «Повторный».
Затем на каждую дату посчитайте число заказов каждой категории.
Колонку с типом заказа назовите order_type, колонку с датой — date, колонку с числом заказов — orders_count.
В расчётах учитывайте только неотменённые заказы.
Результат отсортируйте сначала по возрастанию даты, затем по возрастанию значений в колонке с типом заказа.
Поля в результирующей таблице: date, order_type, orders_count
*/

SELECT
  date,
  order_type,
  COUNT(order_type) AS orders_count
FROM
  (
    SELECT
      user_id,
      time :: DATE AS date,
      CASE
        WHEN MIN(time) OVER (PARTITION BY user_id) = time THEN 'Первый'
        ELSE 'Повторный'
      END AS order_type
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
  ) AS t1
GROUP BY
  date,
  order_type
ORDER BY
  date,
  order_type