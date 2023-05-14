/*
Выясните, какие пары товаров покупают вместе чаще всего.
Пары товаров сформируйте на основе таблицы с заказами.
Отменённые заказы не учитывайте. В качестве результата выведите две колонки —
колонку с парами наименований товаров и колонку со значениями, показывающими,
сколько раз конкретная пара встретилась в заказах пользователей.
Колонки назовите соответственно pair и count_pair.
Пары товаров должны быть представлены в виде списков из двух наименований.
Пары товаров внутри списков должны быть отсортированы в порядке возрастания наименования.
Результат отсортируйте сначала по убыванию частоты встречаемости пары товаров в заказах,
затем по колонке pair — по возрастанию.
Поля в результирующей таблице: pair, count_pair
*/

WITH t1 AS (
  SELECT
    order_id,
    product_ids
  FROM
    orders
  WHERE
    order_id IN (
      SELECT
        order_id
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
    )
),
t2 AS (
  SELECT
    DISTINCT order_id,
    UNNEST(product_ids) AS product_id
  FROM
    t1
),
t3 AS (
  SELECT
    order_id,
    name
  FROM
    t2
    LEFT JOIN products USING (product_id)
),
t4 AS (
  SELECT
    order_id,
    A.name AS name_1,
    B.name AS name_2
  FROM
    t3 AS A
    INNER JOIN t3 AS B USING (order_id)
  WHERE
    A.name != B.name
),
t5 AS (
  SELECT
    order_id,
    CASE
      WHEN name_1 > name_2 THEN STRING_TO_ARRAY(name_2 || ', ' || name_1, ', ')
      ELSE STRING_TO_ARRAY(name_1 || ', ' || name_2, ', ')
    END AS pair
  FROM
    t4
)

SELECT
  pair,
  COUNT(order_id) / 2 AS count_pair
FROM
  t5
GROUP BY
  pair
ORDER BY
  count_pair DESC,
  pair ASC

-- OR

with main_table as (SELECT DISTINCT order_id,
                                    product_id,
                                    name
                    FROM   (SELECT order_id,
                                   unnest(product_ids) as product_id
                            FROM   orders
                            WHERE  order_id not in (SELECT order_id
                                                    FROM   user_actions
                                                    WHERE  action = 'cancel_order')
                               and order_id in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'create_order')) t join products using(product_id)
                    ORDER BY order_id, name)
SELECT pair,
       count(order_id) as count_pair
FROM   (SELECT DISTINCT a.order_id,
                        case when a.name > b.name then string_to_array(concat(b.name, '+', a.name), '+')
                             else string_to_array(concat(a.name, '+', b.name), '+') end as pair
        FROM   main_table a join main_table b
                ON a.order_id = b.order_id and
                   a.name != b.name) t
GROUP BY pair
ORDER BY count_pair desc, pair