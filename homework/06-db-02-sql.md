# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```yml
version: "3"
services:
  db:
    image: postgres:12
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - psdb:/var/lib/postgresql/data
      - psbk:/backup
volumes:
  psdb:
  psbk:
```  

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)
```
- описание таблиц (describe)
```
test_db=# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default           
    
-------------------+-------------------+-----------+----------+---------------------------------
----
 id                | integer           |           | not null | nextval('clients_id_seq'::regcla
ss)
 Фамилия           | character varying |           |          | 
 Страна проживания | character varying |           |          | 
 Заказ             | integer           |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_Страна проживания_idx" btree ("Страна проживания")
Foreign-key constraints:
    "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```
```
test_db=# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default               
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 Наименование | character varying |           |          | 
 Цена         | integer           |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```    
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```sql
select grantee, table_name, privilege_type
from information_schema.table_privileges
where table_name in ('clients', 'orders');
```
- список пользователей с правами над таблицами test_db
```
test_db=# \z
                                           Access privileges
 Schema |      Name      |   Type   |         Access privileges          | Column privileges | P
olicies 
--------+----------------+----------+------------------------------------+-------------------+--
--------
 public | clients        | table    | postgres=arwdDxt/postgres         +|                   | 
        |                |          | "test-admin-user"=arwdDxt/postgres+|                   | 
        |                |          | "test-simple-user"=arwd/postgres   |                   | 
 public | clients_id_seq | sequence |                                    |                   | 
 public | orders         | table    | postgres=arwdDxt/postgres         +|                   | 
        |                |          | "test-admin-user"=arwdDxt/postgres+|                   | 
        |                |          | "test-simple-user"=arwd/postgres   |                   | 
 public | orders_id_seq  | sequence |                                    |                   | 
(4 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
```sql
insert into orders (Наименование, Цена)
values ('Шоколад', 10),
        ('Принтер', 3000),
        ('Книга', 500),
        ('Монитор', 7000),
        ('Гитара', 4000);

insert into clients (Фамилия, "Страна проживания")
values ('Иванов Иван Иванович', 'USA'),
        ('Петров Петр Петрович', 'Canada'),
        ('Иоганн Себастьян Бах', 'Japan'),
        ('Ронни Джеймс Дио', 'Russia'),
        ('Ritchie Blackmore', 'Russia');
```
```sql
select  (
    select count(*)
    from  orders
    ) as orders_row_count,
    (
    select count(*)
    from  clients
    ) as clients_row_count
```
-|orders_row_count</br>bigint|clients_row_count</br>bigint
-|---------------|-----------------
1|5|5

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```sql
update clients
set Заказ = (select id from orders where Наименование = 'Книга')
where Фамилия = 'Иванов Иван Иванович';

update clients
set Заказ = (select id from orders where Наименование = 'Монитор')
where Фамилия = 'Петров Петр Петрович';

update clients
set Заказ = (select id from orders where Наименование = 'Гитара')
where Фамилия = 'Иоганн Себастьян Бах';
```
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
```sql
select Фамилия 
from clients
where Заказ is not NULL;
```
	
-|Фамилия</br>character varying
-|-
1|Иванов Иван Иванович
2|Петров Петр Петрович
3|Иоганн Себастьян Бах

Подсказка - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```
Seq Scan on clients  (cost=0.00..18.10 rows=806 width=32)
  Filter: ("Заказ" IS NOT NULL)
```
Числа, перечисленные в скобках (слева направо), имеют следующий смысл:

- Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.
- Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение строк дочернего (см. приведённый ниже пример с LIMIT).
- Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается, что узел выполняется до конца.
- Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).
- Строка Filter:... показывает используемое условие

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
```shell
pg_dump -U postgres test_db > /backup/test_db.sql # бэкап
```
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
Поднимите новый пустой контейнер с PostgreSQL.
```shell
docker run -e POSTGRES_PASSWORD=mysecretpassword --mount source=06-db-02-sql_psbk,target=/backup -d postgres:12
```
Восстановите БД test_db в новом контейнере.


```sql
--Создаю пустую базу и пользователей
create database test_db;
create user "test-admin-user" WITH PASSWORD '1';
create user "test-simple-user" WITH PASSWORD '2';
```
```shell
psql -U postgres -d test_db < /backup/test_db.sql # восстановление
```
Приведите список операций, который вы применяли для бэкапа данных и восстановления. 





