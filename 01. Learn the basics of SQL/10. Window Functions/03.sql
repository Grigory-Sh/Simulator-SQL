/*
Примените две оконные функции к таблице products — одну с агрегирующей функцией MAX,
а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены.
Для двух окон задайте инструкцию ORDER BY по убыванию цены.
Поместите результат вычислений в две колонки max_price и min_price.
Выведите всю информацию о товарах, включая значения в новых колонках.
Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
Поля в результирующей таблице: product_id, name, price, max_price, min_price
*/

SELECT
  product_id,
  name,
  price,
  MAX(price) OVER (
    ORDER BY
      price DESC
  ) AS max_price,
  MIN(price) OVER (
    ORDER BY
      price DESC
  ) AS min_price
FROM
  products
ORDER BY
  price DESC,
  product_id ASC