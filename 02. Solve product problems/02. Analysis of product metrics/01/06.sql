/*
Для каждого товара, представленного в таблице products, за весь период времени в таблице orders рассчитайте следующие показатели:
1. Суммарную выручку, полученную от продажи этого товара за весь период.
2. Долю выручки от продажи этого товара в общей выручке, полученной за весь период.
Колонки с показателями назовите соответственно revenue и share_in_revenue. Колонку с наименованиями товаров назовите product_name.
Долю выручки с каждого товара необходимо выразить в процентах. При её расчёте округляйте значения до двух знаков после запятой.
Товары, округлённая доля которых в выручке составляет менее 0.5%, объедините в общую группу с названием «ДРУГОЕ» (без кавычек),
просуммировав округлённые доли этих товаров.
Результат должен быть отсортирован по убыванию выручки от продажи товара.
Поля в результирующей таблице: product_name, revenue, share_in_revenue
*/

SELECT product_name, SUM(revenue) AS revenue, SUM(share_in_revenue) AS share_in_revenue
FROM (SELECT CASE WHEN ROUND(SUM(price) / SUM(SUM(price)) OVER () * 100, 2) < 0.5 THEN 'ДРУГОЕ' ELSE name END product_name,
      SUM(price) AS revenue,
      ROUND(SUM(price) / SUM(SUM(price)) OVER () * 100, 2) AS share_in_revenue
      FROM (SELECT order_id, UNNEST(product_ids) AS product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      LEFT JOIN products USING (product_id)
      GROUP BY name) AS t2
GROUP BY product_name
ORDER BY revenue DESC

-- OR

SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT case when round(100 * revenue / sum(revenue) OVER (), 2) >= 0.5 then name
                    else 'ДРУГОЕ' end as product_name,
               revenue,
               round(100 * revenue / sum(revenue) OVER (), 2) as share_in_revenue
        FROM   (SELECT name,
                       sum(price) as revenue
                FROM   (SELECT order_id,
                               unnest(product_ids) as product_id
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')) t1
                    LEFT JOIN products using(product_id)
                GROUP BY name) t2) t3
GROUP BY product_name
ORDER BY revenue desc