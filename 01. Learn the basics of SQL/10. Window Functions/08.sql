/*
Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням.
Вы уже делали это в одной из предыдущих задач. При подсчёте числа заказов не учитывайте отменённые
заказы (их можно определить по таблице user_actions). Колонку с числом заказов назовите orders_count.
Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей
функцией AVG для расчёта скользящего среднего числа заказов. Скользящее среднее для каждой записи считайте
по трём предыдущим дням. Подумайте, как правильно задать границы рамки, чтобы получить корректные расчёты.
Полученные значения скользящего среднего округлите до двух знаков после запятой.
Колонку с рассчитанным показателем назовите moving_avg. Сортировку результирующей таблицы делать не нужно.
Поля в результирующей таблице: date, orders_count, moving_avg
*/

SELECT
  date,
  orders_count,
  ROUND(
    AVG(orders_count) OVER (
      ORDER BY
        date ROWS BETWEEN 3 PRECEDING
        AND 1 PRECEDING
    ),
    2
  ) AS moving_avg
FROM
  (
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
          creation_time :: DATE as date,
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
          date
      ) AS t1
  ) AS t2

-- OR

SELECT date,
       orders_count,
       round(avg(orders_count) OVER (ORDER BY date rows between 3 preceding and 1 preceding),
             2) as moving_avg
FROM   (SELECT date(creation_time) as date,
               count(order_id) as orders_count
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t