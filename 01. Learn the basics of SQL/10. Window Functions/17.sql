/*
На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите её в колонке daily_revenue.
Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. Прирост выручки отразите как в абсолютных значениях, так
и в % относительно предыдущего дня. Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.
Для самого первого дня укажите прирост равным 0 в обеих колонках. При проведении расчётов отменённые заказы не учитывайте. Результат отсортируйте по колонке с датами по возрастанию.
Метрики daily_revenue, revenue_growth_abs, revenue_growth_percentage округлите до одного знака при помощи ROUND().
Поля в результирующей таблице: date, daily_revenue, revenue_growth_abs, revenue_growth_percentage
*/

WITH t1 AS (
  SELECT
    order_id,
    creation_time,
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
),
t2 AS (
  SELECT
    order_id,
    creation_time :: DATE AS date,
    price
  FROM
    t1
    LEFT JOIN products USING (product_id)
),
t3 AS (
  SELECT
    date,
    SUM(price) AS daily_revenue
  FROM
    t2
  GROUP BY
    date
),
t4 AS (
  SELECT
    date,
    daily_revenue,
    COALESCE(daily_revenue - LAG(daily_revenue, 1) OVER (), 0) AS revenue_growth_abs
  FROM
    t3
)

SELECT
  date,
  daily_revenue,
  revenue_growth_abs,
  COALESCE(
    ROUND(
      revenue_growth_abs :: DECIMAL / LAG(daily_revenue) OVER () :: DECIMAL * 100,
      1
    ),
    0
  ) AS revenue_growth_percentage
FROM
  t4
ORDER BY
  date

-- OR

SELECT date,
       round(daily_revenue, 1) as daily_revenue,
       round(coalesce(daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date), 0),
             1) as revenue_growth_abs,
       round(coalesce(round((daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date))::decimal / lag(daily_revenue, 1) OVER (ORDER BY date) * 100, 2), 0),
             1) as revenue_growth_percentage
FROM   (SELECT date(creation_time) as date,
               sum(price) as daily_revenue
        FROM   (SELECT order_id,
                       creation_time,
                       product_ids,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using(product_id)
        GROUP BY date) t2
ORDER BY date