/*
Для каждого дня в таблице orders рассчитайте следующие показатели:
1. Выручку, полученную в этот день.
1. Суммарную выручку на текущий день.
1. Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.
Колонки с показателями назовите соответственно revenue, total_revenue, revenue_change.
Колонку с датами назовите date.
Прирост выручки рассчитайте в процентах и округлите значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, total_revenue, revenue_change
*/

SELECT date, SUM(price) AS revenue,
       SUM(SUM(price)) OVER (ORDER BY date) AS total_revenue,
       ROUND((SUM(price) - LAG(SUM(price), 1) OVER (ORDER BY date)) / LAG(SUM(price), 1) OVER (ORDER BY date) * 100, 2) AS revenue_change
FROM (SELECT order_id, creation_time::DATE AS date, UNNEST(product_ids) AS product_id
      FROM orders
      WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
LEFT JOIN products USING (product_id)
GROUP BY date
ORDER BY date

-- OR

SELECT date,
       revenue,
       sum(revenue) OVER (ORDER BY date) as total_revenue,
       round(100 * (revenue - lag(revenue, 1) OVER (ORDER BY date))::decimal / lag(revenue, 1) OVER (ORDER BY date),
             2) as revenue_change
FROM   (SELECT creation_time::date as date,
               sum(price) as revenue
        FROM   (SELECT creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using (product_id)
        GROUP BY date) t2