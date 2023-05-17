/*
Для каждого дня в таблицах orders и courier_actions рассчитайте следующие показатели:
1. Выручку, полученную в этот день.
2. Затраты, образовавшиеся в этот день.
3. Сумму НДС с продажи товаров в этот день.
4. Валовую прибыль в этот день (выручка за вычетом затрат и НДС).
5. Суммарную выручку на текущий день.
6. Суммарные затраты на текущий день.
7. Суммарный НДС на текущий день.
8. Суммарную валовую прибыль на текущий день.
9. Долю валовой прибыли в выручке за этот день (долю п.4 в п.1).
10. Долю суммарной валовой прибыли в суммарной выручке на текущий день (долю п.8 в п.5).
Колонки с показателями назовите соответственно revenue, costs, tax, gross_profit,
total_revenue, total_costs, total_tax, total_gross_profit, gross_profit_ratio, total_gross_profit_ratio
Колонку с датами назовите date.
Долю валовой прибыли в выручке необходимо выразить в процентах, округлив значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, costs, tax, gross_profit, total_revenue, total_costs, total_tax,
total_gross_profit, gross_profit_ratio,total_gross_profit_ratio

Чтобы посчитать затраты, в этой задаче введём дополнительные условия.
В упрощённом виде затраты нашего сервиса будем считать как сумму постоянных и переменных издержек. К постоянным
издержкам отнесём аренду складских помещений, а к переменным — стоимость сборки и доставки заказа. Таким образом,
переменные затраты будут напрямую зависеть от числа заказов.
Из данных, которые нам предоставил финансовый отдел, известно, что в августе 2022 года постоянные затраты
составляли 120 000 рублей в день. Однако уже в сентябре нашему сервису потребовались дополнительные помещения,
и поэтому постоянные затраты возросли до 150 000 рублей в день.
Также известно, что в августе 2022 года сборка одного заказа обходилась нам в 140 рублей, при этом курьерам мы
платили по 150 рублей за один доставленный заказ и ещё 400 рублей ежедневно в качестве бонуса, если курьер
доставлял не менее 5 заказов в день. В сентябре продакт-менеджерам удалось снизить затраты на сборку заказа до
115 рублей, но при этом пришлось повысить бонусную выплату за доставку 5 и более заказов до 500 рублей, чтобы
обеспечить более конкурентоспособные условия труда. При этом в сентябре выплата курьерам за один доставленный
заказ осталась неизменной.
*/

SELECT date, revenue, costs, tax, gross_profit,
       SUM(revenue) OVER (ORDER BY date) AS total_revenue,
       SUM(costs) OVER (ORDER BY date) AS total_costs,
       SUM(tax) OVER (ORDER BY date) AS total_tax,
       SUM(gross_profit) OVER (ORDER BY date) AS total_gross_profit,
       ROUND(gross_profit / revenue * 100, 2) AS gross_profit_ratio,
       ROUND(SUM(gross_profit) OVER (ORDER BY date) / SUM(revenue) OVER (ORDER BY date) * 100, 2) AS total_gross_profit_ratio
FROM (SELECT date, revenue, costs_orders_0 + costs_orders_1 + costs_orders_2 AS costs, tax, revenue - costs_orders_0 - costs_orders_1 - costs_orders_2 - tax AS gross_profit
      FROM (SELECT date, SUM(price) AS revenue, SUM(tax) AS tax,
                   CASE WHEN DATE_PART('month', date) = 08 THEN COUNT(DISTINCT order_id) * 140 :: DECIMAL
                        WHEN DATE_PART('month', date) = 09 THEN COUNT(DISTINCT order_id) * 115 :: DECIMAL
                   END AS costs_orders_1
            FROM (SELECT creation_time::DATE AS date, order_id, UNNEST(product_ids) AS product_id
                  FROM orders
                  WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
            LEFT JOIN
                 (SELECT product_id, name, price,
                         CASE WHEN name IN ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз',
                                            'батон', 'йогурт', 'сливки', 'гречка', 'овсянка', 'макароны', 'баранина', 'апельсины','бублики',
                                            'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис',
                                            'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное',
                                            'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') THEN ROUND(price / 11, 2)
                         ELSE ROUND(price / 6, 2)
                         END AS tax
                  FROM products) AS t2
            USING (product_id)
            GROUP BY date) t3
      FULL JOIN
           (SELECT date,
                   CASE WHEN DATE_PART('month', date) = 08 THEN 120000 :: DECIMAL
                        WHEN DATE_PART('month', date) = 09 THEN 150000 :: DECIMAL
                   END AS costs_orders_0,
                   SUM(costs_orders) AS costs_orders_2
            FROM (SELECT time::DATE date, courier_id,
                         CASE WHEN COUNT(DISTINCT order_id) > 4 AND DATE_PART('month', time::DATE) = 08 THEN COUNT(DISTINCT order_id) * 150 + 400
                              WHEN COUNT(DISTINCT order_id) > 4 AND DATE_PART('month', time::DATE) = 09 THEN COUNT(DISTINCT order_id) * 150 + 500
                              ELSE COUNT(DISTINCT order_id) * 150
                         END costs_orders
                  FROM courier_actions
                  WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order') AND action = 'deliver_order'
                  GROUP BY time::DATE, courier_id) AS t4
            GROUP BY date) AS t5
USING (date)) AS t6
ORDER BY date

-- OR

SELECT date,
       revenue,
       costs,
       tax,
       gross_profit,
       total_revenue,
       total_costs,
       total_tax,
       total_gross_profit,
       round(gross_profit / revenue * 100, 2) as gross_profit_ratio,
       round(total_gross_profit / total_revenue * 100, 2) as total_gross_profit_ratio
FROM   (SELECT date,
               revenue,
               costs,
               tax,
               revenue - costs - tax as gross_profit,
               sum(revenue) OVER (ORDER BY date) as total_revenue,
               sum(costs) OVER (ORDER BY date) as total_costs,
               sum(tax) OVER (ORDER BY date) as total_tax,
               sum(revenue - costs - tax) OVER (ORDER BY date) as total_gross_profit
        FROM   (SELECT date,
                       orders_packed,
                       orders_delivered,
                       couriers_count,
                       revenue,
                       case when date_part('month', date) = 8 then 120000.0 + 140 * coalesce(orders_packed, 0) + 150 * coalesce(orders_delivered, 0) + 400 * coalesce(couriers_count, 0)
                            when date_part('month', date) = 9 then 150000.0 + 115 * coalesce(orders_packed, 0) + 150 * coalesce(orders_delivered, 0) + 500 * coalesce(couriers_count, 0) end as costs,
                       tax
                FROM   (SELECT creation_time::date as date,
                               count(distinct order_id) as orders_packed,
                               sum(price) as revenue,
                               sum(tax) as tax
                        FROM   (SELECT order_id,
                                       creation_time,
                                       product_id,
                                       name,
                                       price,
                                       case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 'овсянка',
                                                            'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис',
                                                            'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко',
                                                            'курица', 'лаваш', 'вафли', 'мандарины') then round(price/110*10, 2)                                                                                                                                                                                                                                                                                                                                                                                                                        2)
                                            else round(price/120*20, 2) end as tax
                                FROM   (SELECT order_id,
                                               creation_time,
                                               unnest(product_ids) as product_id
                                        FROM   orders
                                        WHERE  order_id not in (SELECT order_id
                                                                FROM   user_actions
                                                                WHERE  action = 'cancel_order')) t1
                                    LEFT JOIN products using (product_id)) t2
                        GROUP BY date) t3
                    LEFT JOIN (SELECT time::date as date,
                                      count(distinct order_id) as orders_delivered
                               FROM   courier_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                                  and action = 'deliver_order'
                               GROUP BY date) t4 using (date)
                    LEFT JOIN (SELECT date,
                                      count(courier_id) as couriers_count
                               FROM   (SELECT time::date as date,
                                              courier_id,
                                              count(distinct order_id) as orders_delivered
                                       FROM   courier_actions
                                       WHERE  order_id not in (SELECT order_id
                                                               FROM   user_actions
                                                               WHERE  action = 'cancel_order')
                                          and action = 'deliver_order'
                                       GROUP BY date, courier_id having count(distinct order_id) >= 5) t5
                               GROUP BY date) t6 using (date)) t7) t8