# Phần 9: Transaction và Consistency

Mục tiêu của phần này: giúp bạn hiểu transaction, lock, isolation và consistency đủ để xây pipeline không ghi sai dữ liệu, không gây lock lớn và xử lý retry an toàn.

## 1. Transaction là gì?

Transaction là một nhóm thao tác database được xem như một đơn vị công việc.

Ví dụ:

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 100000
WHERE account_id = 'A';

UPDATE accounts
SET balance = balance + 100000
WHERE account_id = 'B';

COMMIT;
```

Nếu mọi thứ thành công, `COMMIT`.

Nếu có lỗi, `ROLLBACK`.

Mục tiêu: không để hệ thống ở trạng thái nửa đúng nửa sai.

## 2. ACID

Transaction tốt thường có ACID:

### Atomicity

Tất cả thành công hoặc tất cả thất bại.

### Consistency

Dữ liệu chuyển từ trạng thái hợp lệ này sang trạng thái hợp lệ khác.

### Isolation

Transaction đồng thời không làm hỏng nhau.

### Durability

Khi commit xong, dữ liệu phải được lưu bền vững.

Data Engineer không cần là DBA, nhưng phải hiểu ACID để tránh pipeline ghi dữ liệu sai.

## 3. COMMIT và ROLLBACK

`COMMIT` xác nhận thay đổi:

```sql
COMMIT;
```

`ROLLBACK` hủy thay đổi chưa commit:

```sql
ROLLBACK;
```

Lỗi phổ biến:

- Commit từng dòng trong batch lớn.
- Transaction mở quá lâu.
- Không rollback khi job fail.
- Update/delete không có filter rõ.

## 4. Transaction trong ETL

Ví dụ load partition an toàn:

```sql
BEGIN;

DELETE FROM fact_daily_revenue
WHERE revenue_date = DATE '2026-05-08';

INSERT INTO fact_daily_revenue (
  revenue_date,
  revenue
)
SELECT
  CAST(order_date AS DATE) AS revenue_date,
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE);

COMMIT;
```

Nếu insert lỗi, rollback để tránh target bị xóa nhưng chưa insert lại.

Lưu ý: cú pháp transaction khác nhau tùy database và một số warehouse có auto-commit behavior riêng.

## 5. Isolation level

Isolation level quyết định transaction nhìn thấy dữ liệu của transaction khác như thế nào.

Các level phổ biến:

- Read uncommitted.
- Read committed.
- Repeatable read.
- Serializable.

Không phải database nào cũng hỗ trợ giống nhau.

## 6. Read committed

Transaction chỉ đọc dữ liệu đã commit.

Đây là default phổ biến trong nhiều database như Oracle, PostgreSQL.

Vấn đề có thể xảy ra:

- Non-repeatable read: đọc cùng một dòng hai lần thấy giá trị khác nếu transaction khác commit ở giữa.
- Phantom read: query cùng điều kiện hai lần thấy thêm/bớt dòng.

Trong pipeline, cần cẩn thận nếu source đang thay đổi trong lúc extract.

## 7. Repeatable read và Serializable

Repeatable read cố gắng đảm bảo đọc lại cùng record thấy cùng kết quả trong transaction.

Serializable là mức cô lập cao hơn, như thể transaction chạy tuần tự.

Đổi lại:

- Có thể lock nhiều hơn.
- Có thể conflict nhiều hơn.
- Có thể giảm concurrency.

Senior lesson: isolation càng cao không phải lúc nào càng tốt. Phải cân bằng correctness và concurrency.

## 8. MVCC

MVCC là Multi-Version Concurrency Control.

Ý tưởng:

- Database lưu nhiều phiên bản dữ liệu.
- Reader không nhất thiết block writer.
- Writer không nhất thiết block reader.

Oracle và PostgreSQL dùng MVCC theo cách riêng.

Lợi ích:

- Query đọc có thể thấy snapshot nhất quán.
- Giảm blocking giữa đọc và ghi.

Nhưng long-running query có thể gây áp lực undo/version storage.

## 9. Lock

Lock dùng để bảo vệ dữ liệu khi có transaction đồng thời.

Các loại thường gặp:

- Row lock.
- Table lock.
- Metadata/schema lock.

Ví dụ:

```sql
UPDATE orders
SET status = 'CANCELLED'
WHERE order_id = 1001;
```

Database sẽ lock dòng order `1001` cho đến khi commit/rollback.

Nếu transaction giữ lock quá lâu, session khác phải chờ.

## 10. Blocking

Blocking xảy ra khi session này đợi session khác nhả lock.

Ví dụ:

Session A:

```sql
UPDATE orders
SET status = 'PAID'
WHERE order_id = 1001;
```

Chưa commit.

Session B:

```sql
UPDATE orders
SET status = 'CANCELLED'
WHERE order_id = 1001;
```

Session B sẽ đợi session A.

Trong ETL, batch update lớn có thể block application nếu chạy trên database OLTP.

## 11. Deadlock

Deadlock xảy ra khi hai transaction chờ nhau.

Ví dụ:

Session A:

```text
Lock row 1 -> chờ row 2
```

Session B:

```text
Lock row 2 -> chờ row 1
```

Database thường phát hiện và kill một transaction.

Cách giảm deadlock:

- Update theo cùng thứ tự key.
- Transaction ngắn.
- Index tốt để tránh lock nhiều dòng.
- Không update quá rộng.

## 12. Dirty read, non-repeatable read, phantom read

### Dirty read

Đọc dữ liệu chưa commit của transaction khác.

### Non-repeatable read

Đọc cùng một dòng hai lần trong một transaction nhưng thấy giá trị khác.

### Phantom read

Query cùng điều kiện hai lần nhưng thấy thêm/bớt dòng.

Data Engineer cần hiểu để extract dữ liệu nhất quán, nhất là khi source đang ghi liên tục.

## 13. Consistent snapshot trong pipeline

Khi extract nhiều bảng liên quan, cần snapshot nhất quán.

Ví dụ:

- Extract `orders`.
- Extract `order_items`.

Nếu `orders` extract lúc 10:00, `order_items` extract lúc 10:10, dữ liệu có thể lệch.

Cách xử lý:

- Dùng transaction snapshot nếu database hỗ trợ.
- Dùng CDC log.
- Dùng watermark theo cùng mốc thời gian.
- Extract theo batch_id/source snapshot.

## 14. Idempotency và transaction

Retry pipeline sau lỗi phải an toàn.

Không an toàn:

```sql
INSERT INTO fact_orders
SELECT *
FROM stg_orders
WHERE order_date = DATE '2026-05-08';
```

An toàn hơn:

```sql
BEGIN;

DELETE FROM fact_orders
WHERE order_date = DATE '2026-05-08';

INSERT INTO fact_orders
SELECT *
FROM stg_orders
WHERE order_date = DATE '2026-05-08';

COMMIT;
```

Hoặc dùng `MERGE` nếu key rõ.

## 15. Commit size trong batch

Commit quá thường xuyên:

- Chậm vì nhiều commit.
- Tạo overhead redo/log.
- Khó rollback logic.

Commit quá ít:

- Transaction quá lớn.
- Giữ lock lâu.
- Tốn undo/version storage.
- Nếu fail phải rollback nhiều.

Không có con số chung. Phải dựa vào:

- Kích thước batch.
- Loại database.
- Mức lock.
- SLA.
- Khả năng retry.

Senior thường batch theo partition/date/key range thay vì commit từng dòng.

## 16. Read consistency trong Oracle

Oracle cung cấp read consistency bằng undo.

Một query nhìn thấy dữ liệu nhất quán tại thời điểm query bắt đầu.

Nếu query chạy rất lâu và undo cần để reconstruct dữ liệu cũ đã bị ghi đè, có thể gặp lỗi liên quan snapshot too old.

Hàm ý với Data Engineer:

- Query quá lâu trên source OLTP có thể gây rủi ro.
- Nên extract incremental.
- Nên tránh full scan lớn trên OLTP giờ cao điểm.
- Nên dùng replica/reporting database nếu có.

## 17. Minh họa thực tế: pipeline làm mất dữ liệu tạm thời

Pipeline:

```sql
DELETE FROM agg_daily_revenue
WHERE revenue_date = DATE '2026-05-08';
```

Sau đó job fail trước khi insert lại.

Kết quả:

- Dashboard mất dữ liệu ngày 2026-05-08.

Cách sửa:

```sql
BEGIN;

DELETE FROM agg_daily_revenue
WHERE revenue_date = DATE '2026-05-08';

INSERT INTO agg_daily_revenue
SELECT ...
WHERE revenue_date = DATE '2026-05-08';

COMMIT;
```

Hoặc build vào bảng tạm rồi swap:

```sql
CREATE TABLE agg_daily_revenue_tmp AS
SELECT ...
WHERE revenue_date = DATE '2026-05-08';
```

Sau khi validate xong mới thay thế partition/target.

## 18. Lỗi transaction phổ biến

- Transaction quá dài.
- Commit từng dòng.
- Delete target rồi fail trước insert.
- Update không có index trên điều kiện filter.
- Update/delete thiếu `WHERE`.
- Extract nhiều bảng không cùng snapshot.
- Không thiết kế retry idempotent.
- Chạy batch nặng trên OLTP giờ cao điểm.
- Không kiểm tra blocking/lock khi query treo.

## 19. Checklist transaction/consistency

- Pipeline có chạy trong transaction cần thiết không?
- Nếu fail giữa chừng, target có bị nửa vời không?
- Retry có duplicate dữ liệu không?
- Có giữ lock quá lâu không?
- Update/delete có filter rõ không?
- Điều kiện update/delete có index/partition hỗ trợ không?
- Extract nhiều bảng có cùng watermark/snapshot không?
- Có late arriving data không?
- Có cần staging temp table trước khi swap không?
- Có kiểm tra row count sau commit không?

## 20. Bài tập tự luyện

### Bài 1

Giải thích vì sao delete partition rồi insert lại nên nằm trong cùng transaction nếu database hỗ trợ.

### Bài 2

Mô tả deadlock bằng ví dụ hai transaction update hai dòng ngược thứ tự.

### Bài 3

Thiết kế pipeline retry-safe cho bảng `fact_daily_revenue`.

### Bài 4

Giải thích vì sao commit từng dòng trong batch lớn thường không tốt.

### Bài 5

Nếu extract `orders` và `order_items` ở hai thời điểm khác nhau, có thể xảy ra lỗi gì?

## 21. Từ fresher lên senior ở phần consistency

Fresher thường nghĩ: "SQL chạy xong là dữ liệu đúng."

Senior nghĩ:

- Nếu job fail giữa chừng thì dữ liệu ra sao?
- Nếu hai job chạy cùng lúc thì sao?
- Nếu source thay đổi trong lúc extract thì sao?
- Nếu retry thì có duplicate không?
- Nếu transaction giữ lock 30 phút thì ảnh hưởng ai?

Consistency là phần ít hào nhoáng nhưng quyết định pipeline có đáng tin hay không.

