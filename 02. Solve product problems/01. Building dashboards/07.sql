/*
На основе данных в таблице courier_actions для каждого дня рассчитайте,
за сколько минут в среднем курьеры доставляли свои заказы.
Колонку с показателем назовите minutes_to_deliver. Колонку с датами назовите date.
При расчёте среднего времени доставки округляйте количество минут до целых значений.
Учитывайте только доставленные заказы, отменённые заказы не учитывайте.
Результирующая таблица должна быть отсортирована по возрастанию даты.
Поля в результирующей таблице: date, minutes_to_deliver
*/

SELECT time::DATE date, ROUND(AVG(delivery_time))::INTEGER AS minutes_to_deliver
FROM (SELECT *, EXTRACT(epoch FROM MAX(time) OVER (PARTITION BY order_id) - MIN(time) OVER (PARTITION BY order_id)) / 60 AS delivery_time
      FROM courier_actions
      WHERE order_id IN (SELECT order_id FROM courier_actions WHERE action = 'deliver_order')) AS t
WHERE action = 'deliver_order'
GROUP BY time::DATE
ORDER BY date

-- OR

SELECT date,
       round(avg(delivery_time))::int as minutes_to_deliver
FROM   (SELECT order_id,
               max(time::date) as date,
               extract(epoch
        FROM   max(time) - min(time))/60 as delivery_time
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY order_id) t
GROUP BY date
ORDER BY date