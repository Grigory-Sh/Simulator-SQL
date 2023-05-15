/*
Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры.
Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов.
Затем в отдельном столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры.
После этого сравните число заказов, доставленных каждым курьером, со средним значением в новом столбце. Если курьер доставил
больше заказов, чем в среднем все курьеры, то в отдельном столбце с помощью CASE укажите число 1, в противном случае укажите 0.
Колонку с результатом сравнения назовите is_above_avg, колонку с числом доставленных заказов каждым курьером — delivered_orders,
а колонку со средним значением — avg_delivered_orders. При расчёте среднего значения округлите его до двух знаков после запятой.
Результат отсортируйте по возрастанию id курьера.
Поля в результирующей таблице: courier_id, delivered_orders, avg_delivered_orders, is_above_avg
*/

SELECT
  courier_id,
  delivered_orders,
  ROUND(AVG(delivered_orders) OVER (), 2) AS avg_delivered_orders,
  CASE
    WHEN delivered_orders > ROUND(AVG(delivered_orders) OVER (), 2) THEN 1
    ELSE 0
  END AS is_above_avg
FROM
  (
    SELECT
      courier_id,
      COUNT(order_id) AS delivered_orders
    FROM
      courier_actions
    WHERE
      action = 'deliver_order'
      AND DATE_PART('year', time) = 2022
      AND DATE_PART('month', time) = 09
    GROUP BY
      courier_id
  ) AS t
ORDER BY
  courier_id