# Simulator SQL

Схема базы данных:
![logo](https://storage.yandexcloud.net/klms-public/production/learning-content/152/1762/17923/51794/244290/2023_01_24_214337_negate.jpg)

## Структура и наполнение таблиц

### user_actions
действия пользователей с заказами.
| Столбец | Тип данных | Описание
--- | --- | ---
user_id | INT | id пользователя
order_id | INT | id заказа
action | VARCHAR(50) | действие пользователя с заказом; 'create_order' — создание заказа, 'cancel_order' — отмена заказа
time | TIMESTAMP | время совершения действия