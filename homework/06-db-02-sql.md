**Задание 1**  
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

**Задание 2**  
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
