/*
Для каждого дня недели в таблицах orders и user_actions рассчитайте следующие показатели:
1. Выручку на пользователя (ARPU).
2. Выручку на платящего пользователя (ARPPU).
3. Выручку на заказ (AOV).
При расчётах учитывайте данные только за период с 26 августа 2022 года по 8 сентября 2022 года
включительно — так, чтобы в анализ попало одинаковое количество всех дней недели (ровно по два дня).
В результирующую таблицу включите как наименования дней недели (например, Monday),
так и порядковый номер дня недели (от 1 до 7, где 1 — это Monday, 7 — это Sunday).
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с наименованием дня
недели назовите weekday, а колонку с порядковым номером дня недели weekday_number.
При расчёте всех показателей округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию порядкового номера дня недели.
Поля в результирующей таблице: weekday, weekday_number, arpu, arppu, aov
*/

SELECT weekday, weekday_number, ROUND(revenue / active_users, 2) AS arpu, ROUND(revenue / paying_users, 2) AS arppu, ROUND(revenue / orders, 2) AS aov
FROM (SELECT weekday, weekday_number, SUM(price) AS revenue
      FROM (SELECT order_id, TO_CHAR(creation_time, 'Day') AS weekday, DATE_PART('isodow', creation_time) AS weekday_number, UNNEST(product_ids) AS product_id
            FROM orders
            WHERE DATE_PART('month', creation_time) IN (8, 9) AND DATE_PART('day', creation_time) IN (26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8)
            AND order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      LEFT JOIN products USING (product_id)
      GROUP BY weekday, weekday_number) AS t2
FULL JOIN
     (SELECT TO_CHAR(time, 'Day') AS weekday, DATE_PART('isodow', time) AS weekday_number,
             COUNT(DISTINCT user_id) AS active_users,
             COUNT(DISTINCT user_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users,
             COUNT(DISTINCT order_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS orders
      FROM user_actions
      WHERE DATE_PART('month', time) IN (8, 9) AND DATE_PART('day', time) IN (26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8)
      GROUP BY TO_CHAR(time, 'Day'), DATE_PART('isodow', time)) AS t3
USING (weekday, weekday_number)
ORDER BY weekday_number

-- OR

SELECT weekday,
       t1.weekday_number as weekday_number,
       round(revenue::decimal / users, 2) as arpu,
       round(revenue::decimal / paying_users, 2) as arppu,
       round(revenue::decimal / orders, 2) as aov
FROM   (SELECT to_char(creation_time, 'Day') as weekday,
               max(date_part('isodow', creation_time)) as weekday_number,
               count(distinct order_id) as orders,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                   and creation_time >= '2022-08-26'
                   and creation_time < '2022-09-09') t4
            LEFT JOIN products using(product_id)
        GROUP BY weekday) t1
    LEFT JOIN (SELECT to_char(time, 'Day') as weekday,
                      max(date_part('isodow', time)) as weekday_number,
                      count(distinct user_id) as users
               FROM   user_actions
               WHERE  time >= '2022-08-26'
                  and time < '2022-09-09'
               GROUP BY weekday) t2 using (weekday)
    LEFT JOIN (SELECT to_char(time, 'Day') as weekday,
                      max(date_part('isodow', time)) as weekday_number,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
                  and time >= '2022-08-26'
                  and time < '2022-09-09'
               GROUP BY weekday) t3 using (weekday)
ORDER BY weekday_number