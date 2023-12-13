/*
С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей
компании 10 и более дней. Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.
Будем считать, что наш сервис предлагает самые выгодные условия труда и поэтому за весь анализируемый
период ни один курьер не уволился из компании. Возможные перерывы между сменами не учитывайте — для нас
важна только разница во времени между первым действием курьера и текущей отметкой времени. Текущей
отметкой времени, относительно которой необходимо рассчитывать продолжительность работы курьера, считайте
время последнего действия в таблице courier_actions. Учитывайте только целые дни, прошедшие с первого
выхода курьера на работу (часы и минуты не учитывайте).
В результат включите три колонки: id курьера, продолжительность работы в днях и число доставленных заказов.
Две новые колонки назовите соответственно days_employed и delivered_orders.
Результат отсортируйте сначала по убыванию количества отработанных дней, затем по возрастанию id курьера.
Поля в результирующей таблице: courier_id, days_employed, delivered_orders
*/

SELECT
  courier_id,
  days_employed,
  delivered_orders
FROM
  (
    SELECT
      courier_id,
      DATE_PART(
        'day',
        AGE(
          (
            SELECT
              MAX(time)
            FROM
              courier_actions
          ),
          MIN(time)
        )
      ) AS days_employed,
      COUNT(order_id) FILTER (
        WHERE
          action = 'deliver_order'
      ) AS delivered_orders
    FROM
      courier_actions
    GROUP BY
      courier_id
  ) AS t
WHERE
  days_employed > 9
ORDER BY
  days_employed DESC,
  courier_id ASC

-- OR

SELECT courier_id,
       days_employed,
       delivered_orders
FROM   (SELECT courier_id,
               delivered_orders,
               date_part('days', max(max_time) OVER() - min_time) as days_employed
        FROM   (SELECT courier_id,
                       count(distinct order_id) filter (WHERE action = 'deliver_order') as delivered_orders,
                       min(time) as min_time,
                       max(time) as max_time
                FROM   courier_actions
                GROUP BY courier_id) t1) t2
WHERE  days_employed >= 10
ORDER BY days_employed desc, courier_id