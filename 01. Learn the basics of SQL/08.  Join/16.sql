/*

*/

WITH t1 AS (
  SELECT
    user_id,
    COUNT(order_id) FILTER (
      WHERE
        action = 'cancel_order'
    ) :: DECIMAL / count(order_id) FILTER (
      WHERE
        action = 'create_order'
    ) :: DECIMAL AS cancel_rate
  FROM
    user_actions
  GROUP BY
    user_id
  ORDER BY
    user_id asc
),
t2 AS (
  SELECT
    user_id,
    cancel_rate,
    sex
  FROM
    t1
    LEFT JOIN users USING (user_id)
)

SELECT
  COALESCE(sex, 'unknown') AS sex,
  ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM
  t2
GROUP BY
  sex
ORDER BY
  sex

-- OR

SELECT coalesce(sex, 'unknown') as sex,
       round(avg(cancel_rate), 3) as avg_cancel_rate
FROM   (SELECT user_id,
               sex,
               count(distinct order_id) filter (WHERE action = 'cancel_order')::decimal / count(distinct order_id) as cancel_rate
        FROM   user_actions
            LEFT JOIN users using(user_id)
        GROUP BY user_id, sex
        ORDER BY cancel_rate desc) t
GROUP BY sex
ORDER BY sex