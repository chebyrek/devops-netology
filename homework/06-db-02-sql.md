**Задача 1**  
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

**Задача 2**  
```
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)
```
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
```sql
select grantee, table_name, privilege_type
from information_schema.table_privileges
where table_name in ('clients', 'orders');
```
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

**Задача 3*  
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
1 row returned

-|orders_row_count</br>bigint|clients_row_count</br>bigint
-|---------------|-----------------
1|5|5

**Задача 4**  
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
