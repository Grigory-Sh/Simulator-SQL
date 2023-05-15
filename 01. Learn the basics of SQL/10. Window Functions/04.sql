/*
Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням.
При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions).
Колонку с днями назовите date, а колонку с числом заказов — orders_count.
Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию
в паре с агрегирующей функцией SUM для расчёта накопительной суммы числа заказов.
Не забудьте для окна задать инструкцию ORDER BY по дате. Колонку с накопительной
суммой назовите orders_cum_count. В результате такой операции значение накопительной
суммы для последнего дня должно получиться равным общему числу заказов за весь период.
Сортировку результирующей таблицы делать не нужно.
Поля в результирующей таблице: date, orders_count, orders_cum_count
*/

SELECT
  date,
  orders_count,
  SUM(orders_count) OVER (
    ORDER BY
      date
  ) AS orders_cum_count
FROM
  (
    SELECT
      creation_time :: DATE AS date,
      COUNT(order_id) AS orders_count
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
      DATE
  ) AS t