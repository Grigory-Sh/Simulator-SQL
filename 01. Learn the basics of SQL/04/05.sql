/*
Отберите из таблицы products все товары, названия которых либо начинаются со слова «чай»,
либо состоят из пяти символов. Выведите две колонки: id товаров и их наименования.
Результат должен быть отсортирован по возрастанию id товара.
Поля в результирующей таблице: product_id, name
*/

SELECT
  product_id,
  name
FROM
  products
WHERE
  SPLIT_PART(name, ' ', 1) = 'чай'
  OR LENGTH(name) = 5
ORDER BY
  product_id ASC