/*
Дополните запрос из предыдущего задания и с помощью оконной функции для каждого заказа
каждого пользователя рассчитайте, сколько времени прошло с момента предыдущего заказа. 
Для этого сначала в отдельном столбце с помощью LAG сделайте смещение по столбцу time
на одно значение назад. Столбец со смещёнными значениями назовите time_lag.
Затем отнимите от каждого значения в колонке time новое значение со смещением (либо можете
использовать уже знакомую функцию AGE). Колонку с полученным интервалом назовите time_diff.
Менять формат отображения значений не нужно, они должны иметь примерно следующий вид:
3 days, 12:18:22
По-прежнему не учитывайте отменённые заказы. Также оставьте в запросе порядковый номер
каждого заказа, рассчитанный на прошлом шаге. Результат отсортируйте сначала по возрастанию
id пользователя, затем по возрастанию порядкового номера заказа. Добавьте LIMIT 1000.
Поля в результирующей таблице: user_id, order_id, time, order_number, time_lag, time_diff
*/

SELECT
  user_id,
  order_id,
  time,
  order_number,
  LAG(time, 1) OVER (
    PARTITION BY user_id
    ORDER BY
      time
  ) AS time_lag,
  AGE(
    time,
    LAG(time, 1) OVER (
      PARTITION BY user_id
      ORDER BY
        time
    )
  ) AS time_diff
FROM
  (
    SELECT
      user_id,
      order_id,
      time,
      ROW_NUMBER() OVER (
        PARTITION BY user_id
        ORDER BY
          time
      ) AS order_number
    FROM
      user_actions
    WHERE
      order_id NOT IN (
        SELECT
          order_id
        FROM
          user_actions
        WHERE
          action = 'cancel_order'
      )
  ) AS t1
ORDER BY
  user_id ASC,
  order_number ASC
LIMIT
  1000