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

**Зажание 2**

