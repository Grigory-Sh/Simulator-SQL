/*
Как и в предыдущем задании, снова выведите id всех курьеров и их годы рождения, только теперь к извлеченному году примените функцию COALESCE.
Укажите параметры функции так, чтобы вместо NULL значений в результат попадало текстовое значение unknown. Названия полей оставьте прежними.
Отсортируйте итоговую таблицу сначала по убыванию года рождения курьера, затем по возрастанию id курьера.
Поля в результирующей таблице: courier_id, birth_year
*/

SELECT
  courier_id,
  COALESCE(
    CAST(DATE_PART('year', birth_date) AS VARCHAR),
    'unknown'
  ) AS birth_year
FROM
  couriers
ORDER BY
  birth_year DESC,
  courier_id ASC