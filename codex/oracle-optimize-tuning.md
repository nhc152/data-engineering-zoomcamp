# Oracle Database Optimize & SQL Tuning

Tai lieu nay tong hop cac kien thuc quan trong khi toi uu database va toi uu cau lenh SQL trong Oracle. Muc tieu la giup ban hieu cach Oracle thuc thi SQL, cach doc execution plan, cach phat hien nguyen nhan cham, va cach dua ra huong toi uu dung.

## 1. Toi uu database la gi?

Toi uu database la qua trinh lam cho he thong co so du lieu:

- Tra ve ket qua nhanh hon.
- Su dung CPU, RAM, I/O it hon.
- Giam lock, deadlock, contention.
- On dinh hon khi du lieu tang lon.
- De bao tri va mo rong hon.

Toi uu database khong chi la them index. No bao gom:

- Thiet ke bang.
- Thiet ke khoa chinh, khoa ngoai.
- Chon kieu du lieu.
- Tao index hop ly.
- Cap nhat optimizer statistics.
- Viet SQL dung cach.
- Kiem tra execution plan.
- Toi uu cau hinh memory, undo, temp, tablespace.
- Giam tranh chap tai nguyen.
- Giam full table scan khong can thiet.
- Chia du lieu bang partition khi phu hop.

## 2. Toi uu SQL la gi?

Toi uu SQL la qua trinh viet lai hoac dieu chinh cau SQL de Oracle xu ly it viec hon nhung van tra ve ket qua dung.

Vi du chua tot:

```sql
SELECT *
FROM orders
WHERE TO_CHAR(order_date, 'YYYY') = '2026';
```

Van de:

- Lay tat ca cot bang `SELECT *`.
- Dung function `TO_CHAR` tren cot `order_date`, co the lam Oracle kho dung index.

Viet tot hon:

```sql
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01';
```

Loi ich:

- Chi lay cot can dung.
- Dieu kien loc theo range, than thien voi index tren `order_date`.

## 3. Tu duy quan trong khi tuning

Khi gap query cham, khong nen sua theo cam tinh. Nen di theo thu tu:

1. Query cham that hay chi cam giac?
2. Cham trong moi lan chay hay chi thinh thoang?
3. Query tra bao nhieu dong?
4. Bang co bao nhieu dong?
5. Oracle dang dung execution plan nao?
6. Uoc luong cua optimizer co sai khong?
7. Co dung index khong?
8. Co full table scan hop ly hay bat hop ly?
9. Co sort, hash, temp lon khong?
10. Co lock, wait event, I/O, CPU, network khong?

Nguyen tac: xem so lieu truoc, toi uu sau.

## 4. Oracle Optimizer la gi?

Oracle Optimizer la bo phan quyet dinh cach thuc thi SQL. No chon:

- Bang nao doc truoc.
- Dung index hay full table scan.
- Join bang cach nao.
- Thu tu join.
- Co can sort khong.
- Co can dung temporary tablespace khong.
- Chi phi uoc tinh cua tung phuong an.

Oracle hien dai chu yeu dung Cost-Based Optimizer, viet tat la CBO. CBO dua tren:

- Thong ke bang.
- Thong ke index.
- So dong.
- Do phan tan du lieu.
- Histogram.
- Dieu kien `WHERE`.
- Dieu kien `JOIN`.
- Bind variable.
- System statistics.

Neu statistics sai hoac cu, optimizer co the chon plan sai.

## 5. Execution Plan la gi?

Execution plan la ke hoach Oracle dung de chay mot cau SQL.

No cho biet:

- Oracle doc bang nao.
- Doc bang bang index hay full scan.
- Join theo cach nao.
- Loc dieu kien o dau.
- Sap xep o dau.
- Gom nhom o dau.
- Chi phi uoc tinh.
- So dong uoc tinh.
- Neu xem plan thuc te thi co ca so dong thuc te va buffer reads.

Execution plan la cong cu trung tam khi tuning SQL.

## 6. EXPLAIN PLAN trong Oracle

`EXPLAIN PLAN` cho biet plan uoc tinh truoc khi query chay.

Vi du:

```sql
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d
  ON e.department_id = d.department_id
WHERE e.department_id = 10;
```

Xem plan:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
```

Xem them predicate va cost:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +PREDICATE +COST'));
```

Luu y: `EXPLAIN PLAN` chi la uoc tinh. Query that co the chay theo plan khac trong mot so truong hop, nhat la khi co bind variable, adaptive plan, hoac cursor da ton tai.

## 7. EXPLAIN ANALYZE trong Oracle

Oracle khong dung cu phap:

```sql
EXPLAIN ANALYZE SELECT ...
```

giong PostgreSQL.

Cach tuong duong trong Oracle la:

1. Chay query that.
2. Thu thap runtime statistics.
3. Xem execution plan thuc te bang `DBMS_XPLAN.DISPLAY_CURSOR`.

Cach 1: bat thong ke cho session:

```sql
ALTER SESSION SET statistics_level = ALL;
```

Chay query:

```sql
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d
  ON e.department_id = d.department_id
WHERE e.department_id = 10;
```

Xem plan thuc te:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

Cach 2: dung hint cho tung query:

```sql
SELECT /*+ GATHER_PLAN_STATISTICS */
       e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d
  ON e.department_id = d.department_id
WHERE e.department_id = 10;
```

Sau do:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  NULL,
  NULL,
  'ALLSTATS LAST +PREDICATE +ALIAS +PEEKED_BINDS'
));
```

Day la cach nen dung khi tuning mot SQL cu the.

## 8. Cac cot quan trong trong execution plan

Vi du output:

```text
| Id | Operation                    | Name        | Starts | E-Rows | A-Rows | Buffers | A-Time |
|  0 | SELECT STATEMENT             |             |      1 |        |     10 |      50 |        |
|  1 |  NESTED LOOPS                |             |      1 |     10 |     10 |      50 | 00:00:01 |
|  2 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |      1 |      1 |      1 |       3 | 00:00:01 |
|  3 |    INDEX UNIQUE SCAN         | DEPT_PK     |      1 |      1 |      1 |       2 | 00:00:01 |
```

Y nghia:

- `Id`: ma so buoc trong plan.
- `Operation`: hanh dong Oracle thuc hien.
- `Name`: ten bang hoac index.
- `Starts`: so lan buoc do duoc thuc hien.
- `E-Rows`: Estimated Rows, so dong Oracle uoc tinh.
- `A-Rows`: Actual Rows, so dong thuc te.
- `Buffers`: so block doc tu buffer cache.
- `Reads`: so block doc tu disk.
- `A-Time`: thoi gian thuc te.
- `Cost`: chi phi uoc tinh, khong phai thoi gian that.

Cot can nhin dau tien khi tuning:

- `A-Rows`.
- `E-Rows`.
- `Buffers`.
- `Reads`.
- `Starts`.
- `A-Time`.

Neu `E-Rows` khac `A-Rows` rat lon, optimizer co the dang uoc luong sai.

Vi du:

```text
E-Rows = 10
A-Rows = 500000
```

Dieu nay cho thay Oracle nghi chi co 10 dong, nhung thuc te co 500000 dong. Plan duoc chon co the khong phu hop.

## 9. Cach doc execution plan

Thong thuong doc tu node con vao node cha, tu dong indent sau nhat len tren.

Vi du:

```text
| Id | Operation                    | Name        |
|  0 | SELECT STATEMENT             |             |
|  1 |  NESTED LOOPS                |             |
|  2 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |
|  3 |    INDEX UNIQUE SCAN         | DEPT_PK     |
|  4 |   TABLE ACCESS FULL          | EMPLOYEES   |
```

Cach hieu:

1. Oracle dung `INDEX UNIQUE SCAN` tren `DEPT_PK`.
2. Lay dong tu bang `DEPARTMENTS`.
3. Quet bang `EMPLOYEES`.
4. Join bang `NESTED LOOPS`.
5. Tra ket qua.

Khi doc plan, dung chi nhin `Cost`. Hay xem:

- So dong thuc te co lon khong.
- Buoc nao doc nhieu buffer nhat.
- Buoc nao lap lai nhieu lan.
- Buoc nao sort/hash lon.
- Full table scan co hop ly khong.
- Index scan co thuc su giam du lieu khong.

## 10. Cac operation pho bien

### TABLE ACCESS FULL

Oracle quet toan bo bang.

Khong phai luc nao cung xau. Full table scan co the tot khi:

- Bang nho.
- Query can lay phan lon du lieu trong bang.
- Index khong co tinh chon loc.
- Doc tuan tu nhanh hon doc index roi quay lai bang nhieu lan.

Nhung co the xau khi:

- Bang rat lon.
- Query chi can vai dong.
- Dieu kien loc co the dung index nhung khong dung duoc.

### INDEX UNIQUE SCAN

Dung unique index hoac primary key de tim mot gia tri duy nhat.

Thuong rat tot.

Vi du:

```sql
WHERE customer_id = 1001
```

neu `customer_id` la primary key.

### INDEX RANGE SCAN

Dung index de doc mot khoang gia tri.

Vi du:

```sql
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2026-02-01'
```

Tot khi khoang loc tra ve it dong so voi toan bang.

### INDEX FULL SCAN

Oracle doc toan bo index theo thu tu index.

Co the xay ra khi:

- Can du lieu da sap xep theo index.
- Cac cot can lay da nam trong index.
- Doc index nho hon doc bang.

### INDEX FAST FULL SCAN

Oracle doc toan bo index nhu mot bang nho hon.

Khac `INDEX FULL SCAN` o cho no khong dam bao thu tu.

### TABLE ACCESS BY INDEX ROWID

Oracle dung index de lay `ROWID`, sau do quay lai bang lay cot can thiet.

Neu so dong qua nhieu, viec quay lai bang nhieu lan co the ton I/O.

### NESTED LOOPS

Join theo kieu vong lap.

Tot khi:

- Bang ngoai tra ve it dong.
- Bang trong co index tren cot join.

Xau khi:

- Bang ngoai tra ve rat nhieu dong.
- Moi dong lai phai lookup bang trong.

### HASH JOIN

Oracle build hash table tu mot tap du lieu roi probe voi tap con lai.

Tot khi:

- Join luong du lieu lon.
- Dieu kien join dang equality.
- Khong co index phu hop hoac index khong hieu qua.

Co the ton PGA hoac TEMP neu du lieu lon.

### MERGE JOIN

Oracle sort hai tap du lieu theo cot join roi merge.

Tot khi:

- Du lieu da co thu tu.
- Can join luong du lieu lon.

Co the ton chi phi sort.

### SORT ORDER BY

Oracle sap xep de phuc vu `ORDER BY`.

Can xem co the dung index de tranh sort khong.

### SORT GROUP BY

Oracle sap xep de phuc vu `GROUP BY`.

### HASH GROUP BY

Oracle dung hash de gom nhom.

Co the nhanh hon sort group by, nhung co the ton memory.

## 11. Predicate Information

Khi dung:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE'));
```

Oracle hien thi them `Predicate Information`.

Vi du:

```text
Predicate Information:
1 - filter("STATUS"='ACTIVE')
2 - access("CUSTOMER_ID"=1001)
```

Y nghia:

- `access`: dieu kien duoc dung de truy cap index/table hieu qua.
- `filter`: dieu kien loc sau khi da doc du lieu.

Thong thuong `access` tot hon `filter` vi no giup giam du lieu ngay tu dau.

## 12. Index la gi?

Index la cau truc du lieu giup Oracle tim dong nhanh hon ma khong can quet toan bo bang.

Tuong tu muc luc sach:

- Khong co muc luc: phai doc tung trang.
- Co muc luc: tim tu khoa trong muc luc, roi mo den trang can thiet.

Nhung index khong mien phi:

- Ton dung luong luu tru.
- Lam cham `INSERT`, `UPDATE`, `DELETE`.
- Can bao tri statistics.
- Qua nhieu index co the lam optimizer kho chon plan.

## 13. Khi nao nen tao index?

Nen can nhac tao index khi cot:

- Hay xuat hien trong `WHERE`.
- Hay xuat hien trong `JOIN`.
- Hay xuat hien trong `ORDER BY`.
- Hay xuat hien trong `GROUP BY`.
- Co tinh chon loc cao.
- Duoc dung de tim it dong trong bang lon.

Vi du nen co index:

```sql
SELECT *
FROM orders
WHERE customer_id = :customer_id
  AND status = 'PAID';
```

Co the can index:

```sql
CREATE INDEX idx_orders_customer_status
ON orders(customer_id, status);
```

## 14. Khi nao index khong hieu qua?

Index co the khong hieu qua khi:

- Bang qua nho.
- Query lay phan lon so dong.
- Cot co it gia tri khac nhau.
- Dieu kien loc khong chon loc.
- Dung function tren cot index.
- Dung wildcard dau chuoi voi `LIKE`.
- Kieu du lieu bi convert ngam.

Vi du cot `gender` chi co `M`, `F`, `O`. Index tren cot nay thuong khong hieu qua neu dung rieng le.

## 15. Composite Index

Composite index la index tren nhieu cot.

Vi du:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

Index nay tot cho:

```sql
WHERE customer_id = :customer_id
```

va:

```sql
WHERE customer_id = :customer_id
  AND order_date >= DATE '2026-01-01'
```

Nhung khong toi uu bang cho:

```sql
WHERE order_date >= DATE '2026-01-01'
```

vi `order_date` khong phai cot dau tien cua index.

Nguyen tac: thu tu cot trong composite index rat quan trong.

Thuong dat:

1. Cot dieu kien bang `=`.
2. Cot co tinh chon loc cao.
3. Cot dung range `>`, `<`, `BETWEEN`.
4. Cot phuc vu `ORDER BY` neu phu hop.

## 16. Covering Index

Covering index la index chua du cac cot query can, giup Oracle khong can quay lai bang.

Vi du:

```sql
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = :customer_id;
```

Index:

```sql
CREATE INDEX idx_orders_cover
ON orders(customer_id, order_id, order_date, total_amount);
```

Oracle co the doc tu index ma khong can doc bang.

Can than: khong nen dua qua nhieu cot vao index neu khong can, vi index se lon va lam DML cham.

## 17. Function-Based Index

Neu bat buoc dung function trong dieu kien, co the tao function-based index.

Vi du query:

```sql
SELECT *
FROM users
WHERE UPPER(email) = UPPER(:email);
```

Index:

```sql
CREATE INDEX idx_users_upper_email
ON users(UPPER(email));
```

Khi do Oracle co the dung index cho `UPPER(email)`.

## 18. Bitmap Index

Bitmap index phu hop voi:

- Bang lon.
- Cot co it gia tri distinct.
- Moi truong data warehouse.
- Truy van doc nhieu, ghi it.

Khong phu hop voi he thong OLTP ghi nhieu vi co the gay lock/contention cao.

Vi du:

```sql
CREATE BITMAP INDEX idx_sales_region
ON sales(region);
```

## 19. Index va DML

Moi index deu lam tang chi phi:

- `INSERT`: phai them entry vao index.
- `UPDATE`: neu sua cot nam trong index, phai cap nhat index.
- `DELETE`: phai xoa entry trong index.

Vi vay khong nen tao index theo kieu "cang nhieu cang tot".

Can xem:

- Query nao quan trong.
- Bang doc nhieu hay ghi nhieu.
- Index co duoc dung khong.
- Index co trung lap voi index khac khong.

## 20. Statistics trong Oracle

Statistics giup optimizer uoc luong chi phi.

Bao gom:

- So dong trong bang.
- So block.
- So gia tri distinct cua cot.
- Do rong trung binh cua cot.
- Histogram.
- Statistics cua index.

Cap nhat statistics:

```sql
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'HR',
    tabname => 'ORDERS'
  );
END;
/
```

Cap nhat statistics cho schema:

```sql
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS(
    ownname => 'HR'
  );
END;
/
```

Cap nhat voi cascade index:

```sql
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'HR',
    tabname => 'ORDERS',
    cascade => TRUE
  );
END;
/
```

## 21. Khi nao statistics co van de?

Dau hieu:

- Execution plan thay doi bat thuong.
- `E-Rows` lech xa `A-Rows`.
- Bang moi import nhieu du lieu nhung chua gather stats.
- Xoa nhieu du lieu nhung stats van cu.
- Query hom qua nhanh, hom nay cham sau khi du lieu thay doi.

Kiem tra stats:

```sql
SELECT table_name, num_rows, blocks, last_analyzed
FROM user_tables
WHERE table_name = 'ORDERS';
```

Kiem tra stats index:

```sql
SELECT index_name, num_rows, distinct_keys, leaf_blocks, last_analyzed
FROM user_indexes
WHERE table_name = 'ORDERS';
```

## 22. Histogram

Histogram giup Oracle hieu phan bo du lieu khong deu.

Vi du cot `status`:

- `ACTIVE`: 99% du lieu.
- `DELETED`: 1% du lieu.

Query:

```sql
WHERE status = 'DELETED'
```

rat khac voi:

```sql
WHERE status = 'ACTIVE'
```

Neu khong co histogram, optimizer co the nghi moi gia tri co ty le gan bang nhau.

Gather stats co histogram tu dong:

```sql
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'HR',
    tabname => 'USERS',
    method_opt => 'FOR ALL COLUMNS SIZE AUTO'
  );
END;
/
```

## 23. Bind Variable

Bind variable giup tai su dung SQL va giam hard parse.

Khong tot:

```sql
SELECT *
FROM orders
WHERE customer_id = 1001;

SELECT *
FROM orders
WHERE customer_id = 1002;
```

Tot hon:

```sql
SELECT *
FROM orders
WHERE customer_id = :customer_id;
```

Loi ich:

- Giam hard parse.
- Giam CPU.
- Tang kha nang reuse cursor.
- Giam ap luc shared pool.

Can luu y: voi du lieu bi lech, bind variable co the lam Oracle chon plan khong phu hop cho mot so gia tri. Khi do can xem bind peeking, adaptive cursor sharing, histogram.

## 24. Implicit Conversion

Implicit conversion la viec Oracle tu dong chuyen kieu du lieu. No co the lam query cham va khong dung index.

Vi du cot `customer_id` la `NUMBER`, nhung query truyen string:

```sql
WHERE customer_id = '1001'
```

Nen dung:

```sql
WHERE customer_id = 1001
```

Vi du cot `created_at` la `DATE`, khong nen:

```sql
WHERE created_at = '2026-05-08'
```

Nen dung:

```sql
WHERE created_at = DATE '2026-05-08'
```

Hoac:

```sql
WHERE created_at >= DATE '2026-05-08'
  AND created_at <  DATE '2026-05-09'
```

## 25. Cac loi SQL thuong gap

### SELECT *

Khong nen:

```sql
SELECT *
FROM customers;
```

Nen:

```sql
SELECT customer_id, full_name, email
FROM customers;
```

Loi ich:

- Giam I/O.
- Giam network.
- Giam memory.
- De Oracle co co hoi dung covering index.

### Function tren cot index

Khong nen:

```sql
WHERE TRUNC(order_date) = DATE '2026-05-08'
```

Nen:

```sql
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
```

### LIKE co wildcard dau chuoi

Khong toi uu:

```sql
WHERE name LIKE '%an'
```

Tot hon neu nghiep vu cho phep:

```sql
WHERE name LIKE 'an%'
```

`LIKE '%abc%'` thuong kho dung B-tree index hieu qua. Neu can search text, xem Oracle Text index.

### OR qua nhieu dieu kien

Query:

```sql
WHERE status = 'PAID'
   OR payment_method = 'CARD'
```

Co the can xem lai index, rewrite bang `UNION ALL`, hoac dung bitmap index trong data warehouse.

Rewrite mau:

```sql
SELECT ...
FROM orders
WHERE status = 'PAID'

UNION ALL

SELECT ...
FROM orders
WHERE payment_method = 'CARD'
  AND status <> 'PAID';
```

### NOT IN co NULL

Can than voi:

```sql
WHERE customer_id NOT IN (
  SELECT customer_id
  FROM blacklist
)
```

Neu subquery tra ve `NULL`, ket qua co the khong nhu mong doi.

Thuong nen dung `NOT EXISTS`:

```sql
WHERE NOT EXISTS (
  SELECT 1
  FROM blacklist b
  WHERE b.customer_id = c.customer_id
)
```

### Pagination bang OFFSET lon

Cham:

```sql
SELECT *
FROM orders
ORDER BY order_id
OFFSET 100000 ROWS FETCH NEXT 20 ROWS ONLY;
```

Oracle phai bo qua 100000 dong.

Tot hon: keyset pagination.

```sql
SELECT *
FROM orders
WHERE order_id > :last_order_id
ORDER BY order_id
FETCH NEXT 20 ROWS ONLY;
```

## 26. JOIN tuning

Khi tuning join, can xem:

- Cot join co cung kieu du lieu khong.
- Cot join co index khong.
- Bang nao nen doc truoc.
- Dieu kien loc co duoc apply som khong.
- Join co lam nhan so dong bat thuong khong.
- Co thieu dieu kien join khong.

Vi du loi nghiem trong:

```sql
SELECT *
FROM orders o, customers c;
```

Day la Cartesian join, moi dong `orders` ket hop voi moi dong `customers`.

Dung:

```sql
SELECT o.order_id, c.full_name
FROM orders o
JOIN customers c
  ON c.customer_id = o.customer_id;
```

Nen co index:

```sql
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);
```

Neu `customers.customer_id` la primary key thi da co index.

## 27. EXISTS va IN

Hai cau nay co the duoc optimizer bien doi tuong duong trong nhieu truong hop.

Dung `EXISTS` khi muon kiem tra ton tai:

```sql
SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
);
```

Dung `IN` khi danh sach ro rang:

```sql
SELECT *
FROM orders
WHERE status IN ('PAID', 'SHIPPED');
```

Khi tuning, khong nen mac dinh `EXISTS` luon nhanh hon `IN`. Hay xem execution plan.

## 28. GROUP BY tuning

Query:

```sql
SELECT customer_id, COUNT(*), SUM(total_amount)
FROM orders
WHERE order_date >= DATE '2026-01-01'
GROUP BY customer_id;
```

Can xem:

- Dieu kien `WHERE` co loc duoc nhieu dong khong.
- Co index tren `order_date` khong.
- Co partition theo ngay khong.
- `GROUP BY` co tao sort/hash lon khong.
- TEMP tablespace co bi dung nhieu khong.

Neu bang rat lon, co the can:

- Partition theo `order_date`.
- Materialized view tong hop san.
- Summary table.
- Parallel query cho batch/report.

## 29. ORDER BY tuning

`ORDER BY` co the ton chi phi sort lon.

Vi du:

```sql
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = :customer_id
ORDER BY order_date DESC;
```

Index phu hop:

```sql
CREATE INDEX idx_orders_customer_date_desc
ON orders(customer_id, order_date DESC);
```

Index nay giup:

- Loc theo `customer_id`.
- Doc san theo `order_date DESC`.
- Giam hoac tranh sort.

## 30. Partitioning

Partitioning la chia bang lon thanh cac phan nho hon.

Phu hop khi:

- Bang rat lon.
- Du lieu co tinh theo thoi gian.
- Query thuong loc theo ngay/thang/nam.
- Can archive/drop du lieu cu nhanh.

Vi du partition theo ngay tao:

```sql
CREATE TABLE orders (
  order_id     NUMBER,
  customer_id  NUMBER,
  order_date   DATE,
  total_amount NUMBER
)
PARTITION BY RANGE (order_date) (
  PARTITION p202601 VALUES LESS THAN (DATE '2026-02-01'),
  PARTITION p202602 VALUES LESS THAN (DATE '2026-03-01'),
  PARTITION pmax    VALUES LESS THAN (MAXVALUE)
);
```

Loi ich lon nhat: partition pruning.

Query:

```sql
SELECT *
FROM orders
WHERE order_date >= DATE '2026-02-01'
  AND order_date <  DATE '2026-03-01';
```

Oracle chi can doc partition `p202602`, khong doc toan bang.

## 31. Local Index va Global Index

Voi partitioned table:

- Local index: moi partition co phan index rieng.
- Global index: mot index bao phu toan bang.

Local index de bao tri hon khi drop/truncate partition.

Global index co the tot cho truy van khong loc theo partition key, nhung bao tri phuc tap hon.

## 32. Materialized View

Materialized view luu san ket qua query.

Phu hop cho:

- Bao cao tong hop.
- Query tinh toan nang.
- Data warehouse.
- Du lieu khong can real-time tuyet doi.

Vi du:

```sql
CREATE MATERIALIZED VIEW mv_daily_sales
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
AS
SELECT TRUNC(order_date) AS sales_date,
       COUNT(*) AS order_count,
       SUM(total_amount) AS total_sales
FROM orders
GROUP BY TRUNC(order_date);
```

Query bao cao co the doc tu materialized view thay vi tinh lai tren bang goc.

## 33. Temporary Tablespace

TEMP duoc dung khi Oracle can:

- Sort lon.
- Hash join lon.
- Group by lon.
- Create index.
- Global temporary table.

Dau hieu TEMP co van de:

- Query report cham.
- Loi khong du temp.
- Wait event lien quan direct path read/write temp.

Can xem execution plan co:

- `SORT ORDER BY`.
- `SORT GROUP BY`.
- `HASH JOIN`.
- `TEMP TABLE TRANSFORMATION`.

## 34. Undo va Redo

Undo dung de:

- Rollback.
- Doc nhat quan.
- Flashback.

Redo dung de:

- Recovery.
- Ghi lai thay doi du lieu.

DML lon co the tao nhieu undo/redo.

Khi batch update/delete lon:

- Chia nho thanh batch.
- Commit theo lo hop ly.
- Tranh commit tung dong.
- Chay ngoai gio cao diem neu co the.
- Kiem tra index anh huong.

## 35. Lock va Blocking

Query cham khong phai luc nao cung do plan xau. Co the do bi lock.

Kiem tra session blocking:

```sql
SELECT sid, serial#, username, blocking_session, event, wait_class, seconds_in_wait
FROM v$session
WHERE blocking_session IS NOT NULL;
```

Kiem tra SQL dang chay:

```sql
SELECT s.sid, s.serial#, s.username, s.status, s.event, q.sql_text
FROM v$session s
LEFT JOIN v$sql q
  ON s.sql_id = q.sql_id
WHERE s.username IS NOT NULL;
```

Can than khi kill session. Nen hieu giao dich dang lam gi truoc.

## 36. Wait Event

Wait event cho biet session dang doi cai gi.

Mot so wait event hay gap:

- `db file sequential read`: doc single block, thuong lien quan index lookup.
- `db file scattered read`: doc multi-block, thuong lien quan full table scan.
- `direct path read temp`: doc tu TEMP.
- `direct path write temp`: ghi vao TEMP.
- `log file sync`: doi commit ghi redo.
- `enq: TX - row lock contention`: doi row lock.
- `library cache lock`: tranh chap trong shared pool.

Dung wait event de phan biet query cham do CPU, I/O, lock, temp, hay parse.

## 37. AWR, ASH va SQL Monitor

Trong moi truong co license phu hop, Oracle co cac cong cu manh:

- AWR: Automatic Workload Repository, xem lich su tai he thong.
- ASH: Active Session History, xem session dang/da doi gi.
- SQL Monitor: xem query nang dang chay hoac vua chay.

Dung AWR de tra loi:

- Gio nao database cham?
- SQL nao ton tai nguyen nhat?
- Wait event nao cao?
- CPU hay I/O la diem nghen?

Dung SQL Monitor de xem:

- Buoc nao trong plan ton thoi gian.
- Parallel query co lech tai khong.
- Row source nao sinh nhieu dong.

## 38. Checklist tuning mot query cham

Dung checklist nay khi gap query cham:

1. Lay SQL text day du.
2. Lay bind variable neu co.
3. Chay query voi `GATHER_PLAN_STATISTICS`.
4. Xem plan bang `DBMS_XPLAN.DISPLAY_CURSOR`.
5. So sanh `E-Rows` va `A-Rows`.
6. Tim buoc co `Buffers` cao nhat.
7. Tim buoc co `Reads` cao nhat.
8. Tim buoc co `Starts` bat thuong.
9. Xem `Predicate Information`.
10. Kiem tra co implicit conversion khong.
11. Kiem tra function tren cot index.
12. Kiem tra index hien co.
13. Kiem tra statistics co cu khong.
14. Kiem tra histogram neu du lieu lech.
15. Kiem tra join order va join method.
16. Kiem tra sort/hash co dung TEMP nhieu khong.
17. Kiem tra query co tra qua nhieu dong khong.
18. Kiem tra paging co OFFSET lon khong.
19. Kiem tra lock/wait event neu cham bat thuong.
20. Sua SQL/index/stats tung buoc, do lai sau moi thay doi.

## 39. Mau lenh xem plan thuc te nen nho

Mau query:

```sql
SELECT /*+ GATHER_PLAN_STATISTICS */
       ...
FROM ...
WHERE ...;
```

Xem plan:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  NULL,
  NULL,
  'ALLSTATS LAST +PREDICATE +ALIAS +PEEKED_BINDS'
));
```

Neu biet `sql_id`:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  '&&sql_id',
  NULL,
  'ALLSTATS LAST +PREDICATE +ALIAS +PEEKED_BINDS'
));
```

Xem SQL trong shared pool:

```sql
SELECT sql_id, child_number, executions, elapsed_time, buffer_gets, disk_reads, sql_text
FROM v$sql
WHERE sql_text LIKE '%orders%'
ORDER BY elapsed_time DESC;
```

## 40. Cach danh gia index co nen tao khong

Truoc khi tao index, hoi:

- Query nay co quan trong khong?
- Query chay thuong xuyen khong?
- Bang co lon khong?
- Dieu kien loc co chon loc khong?
- Index co phuc vu duoc nhieu query khong?
- Index co trung voi index san co khong?
- Bang co ghi nhieu khong?
- Them index co lam cham DML dang ke khong?

Sau khi tao index:

- Chay lai query.
- Xem execution plan co dung index khong.
- So sanh `Buffers`, `Reads`, `A-Time`.
- Kiem tra cac query DML co bi anh huong khong.

## 41. Vi du tuning tong hop

Query cham:

```sql
SELECT *
FROM orders
WHERE TRUNC(order_date) = DATE '2026-05-08'
  AND status = 'PAID'
ORDER BY order_date DESC;
```

Van de:

- `SELECT *`.
- `TRUNC(order_date)` lam kho dung index tren `order_date`.
- Co `ORDER BY` can sort.
- Chua biet co index tren `status`, `order_date` khong.

Viet lai:

```sql
SELECT order_id, customer_id, order_date, total_amount, status
FROM orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
  AND status = 'PAID'
ORDER BY order_date DESC;
```

Index can can nhac:

```sql
CREATE INDEX idx_orders_status_date
ON orders(status, order_date DESC);
```

Neu `status = 'PAID'` tra ve qua nhieu dong, co the index thu tu khac tot hon tuy phan bo du lieu:

```sql
CREATE INDEX idx_orders_date_status
ON orders(order_date, status);
```

Khong nen doan. Hay test bang execution plan va runtime statistics.

## 42. Vi du doc E-Rows va A-Rows

Plan:

```text
| Id | Operation          | Name   | E-Rows | A-Rows | Buffers |
|  1 | HASH JOIN          |        |     10 | 200000 |  900000 |
|  2 |  TABLE ACCESS FULL | ORDERS |     10 | 200000 |  700000 |
```

Nhan xet:

- Oracle uoc tinh `ORDERS` chi co 10 dong phu hop.
- Thuc te co 200000 dong.
- Sai lech rat lon.
- Co the statistics cu, histogram thieu, hoac dieu kien loc kho uoc luong.

Huong xu ly:

- Kiem tra `last_analyzed`.
- Gather stats.
- Xem histogram cho cot loc.
- Kiem tra bind variable.
- Xem co implicit conversion/function khong.

## 43. SQL Profile, SQL Plan Baseline, Hint

Day la cac cong cu can than khi dung.

### Hint

Hint ep optimizer theo huong nao do.

Vi du:

```sql
SELECT /*+ INDEX(o idx_orders_customer_id) */
       *
FROM orders o
WHERE o.customer_id = :customer_id;
```

Khong nen lam dung hint vi:

- Du lieu thay doi thi hint co the thanh xau.
- SQL kho bao tri.
- Che giau van de stats/index/thiet ke.

### SQL Profile

SQL Profile giup optimizer co them thong tin de uoc luong tot hon. Thuong dung qua SQL Tuning Advisor.

### SQL Plan Baseline

SQL Plan Baseline giup on dinh plan, tranh regression khi optimizer chon plan moi xau hon.

Dung khi:

- Query quan trong.
- Plan moi gay cham.
- Can on dinh trong production.

Khong nen dung baseline de thay the viec sua nguyen nhan goc neu co the sua.

## 44. OLTP va Data Warehouse khac nhau

### OLTP

Dac diem:

- Nhieu giao dich nho.
- Insert/update/delete thuong xuyen.
- Can response time nhanh.
- Query thuong lay it dong.

Huong toi uu:

- B-tree index chon loc cao.
- Transaction ngan.
- Tranh lock lau.
- Tranh index qua nhieu.
- SQL dung bind variable.

### Data Warehouse

Dac diem:

- Du lieu lon.
- Doc va bao cao nhieu.
- Query tong hop nang.
- Load du lieu theo batch.

Huong toi uu:

- Partitioning.
- Bitmap index.
- Materialized view.
- Parallel query.
- Summary table.
- Compression.

## 45. Nhung viec khong nen lam

- Tao index cho moi cot.
- Thay doi SQL khi chua xem execution plan.
- Chi nhin cost ma khong xem runtime statistics.
- Gather stats lien tuc khong co chien luoc.
- Dung hint tran lan.
- Dung `SELECT *` trong query quan trong.
- Dung function tren cot loc ngay/thang.
- So sanh DATE voi string.
- Commit tung dong trong batch.
- Xoa du lieu lon trong gio cao diem.
- Kill session khi chua biet no dang lam gi.

## 46. Quy trinh tuning thuc te nen ap dung

1. Xac dinh SQL cham nhat.
2. Lay execution plan thuc te.
3. Xac dinh buoc ton tai nguyen nhat.
4. Xac dinh nguyen nhan: SQL, index, stats, join, sort, lock, I/O.
5. Dua ra thay doi nho nhat co y nghia.
6. Test lai voi cung bind/data.
7. So sanh truoc va sau.
8. Kiem tra tac dong phu.
9. Trien khai.
10. Theo doi sau trien khai.

## 47. Mau bao cao tuning

Khi ghi nhan mot ca tuning, nen co:

```text
SQL_ID:
Module/Application:
Thoi diem cham:
Thoi gian truoc tuning:
Thoi gian sau tuning:
Buffer gets truoc:
Buffer gets sau:
Disk reads truoc:
Disk reads sau:
Plan hash value truoc:
Plan hash value sau:
Nguyen nhan:
Thay doi da lam:
Rui ro:
Ket qua:
```

Bao cao nhu vay giup team hieu tuning co thuc su hieu qua khong.

## 48. Tom tat nhanh

Can nho:

- Execution plan la ban do Oracle chay SQL.
- `EXPLAIN PLAN` la uoc tinh.
- `DISPLAY_CURSOR` voi `ALLSTATS LAST` cho so lieu thuc te.
- `E-Rows` lech `A-Rows` lon la dau hieu optimizer uoc luong sai.
- `Buffers` cao cho thay query doc nhieu block.
- Index giup doc nhanh nhung lam DML cham hon.
- Composite index phu thuoc rat nhieu vao thu tu cot.
- Function tren cot index co the lam mat kha nang dung index.
- Statistics cu co the lam optimizer chon sai plan.
- Full table scan khong luon xau.
- Hint chi nen dung khi co ly do ro rang.
- Tuning phai do truoc va sau, khong sua theo cam tinh.

