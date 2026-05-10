# Phần 14: Security và Governance

Mục tiêu của phần này: giúp bạn hiểu các nguyên tắc bảo mật và quản trị dữ liệu mà Senior Data Engineer cần biết khi làm SQL, data warehouse và pipeline production.

## 1. Vì sao Data Engineer cần biết security?

Data Engineer thường làm việc với dữ liệu nhạy cảm:

- Thông tin cá nhân.
- Email, số điện thoại.
- Địa chỉ.
- Dữ liệu giao dịch.
- Dữ liệu tài chính.
- Dữ liệu hành vi người dùng.

Nếu phân quyền sai hoặc lộ dữ liệu, hậu quả có thể rất nghiêm trọng.

Senior Data Engineer phải biết thiết kế quyền truy cập theo nguyên tắc an toàn, không chỉ làm query chạy được.

## 2. PII là gì?

PII là Personally Identifiable Information, dữ liệu có thể định danh cá nhân.

Ví dụ:

- Họ tên.
- Email.
- Số điện thoại.
- CMND/CCCD/passport.
- Địa chỉ.
- IP address trong một số ngữ cảnh.
- Device ID trong một số ngữ cảnh.

Không phải ai cũng nên được xem PII thô.

## 3. Least privilege

Least privilege nghĩa là cấp quyền tối thiểu cần thiết.

Không nên:

```sql
GRANT SELECT ON customer_pii TO analyst_role;
```

nếu analyst chỉ cần dữ liệu aggregate.

Tốt hơn:

```sql
GRANT SELECT ON mart_customer_summary TO analyst_role;
```

Hoặc cấp view đã masking.

## 4. Role-based access control

RBAC cấp quyền theo role thay vì theo từng user.

Ví dụ:

```sql
CREATE ROLE analyst_role;
CREATE ROLE data_engineer_role;
CREATE ROLE pii_admin_role;
```

Cấp quyền:

```sql
GRANT SELECT ON fact_orders TO analyst_role;
GRANT SELECT, INSERT, UPDATE ON stg_orders TO data_engineer_role;
```

Gán role cho user:

```sql
GRANT analyst_role TO user_anna;
```

Lợi ích:

- Dễ quản lý.
- Dễ audit.
- Tránh cấp quyền lung tung theo cá nhân.

## 5. GRANT và REVOKE

Cấp quyền:

```sql
GRANT SELECT ON dim_customer TO analyst_role;
```

Thu hồi:

```sql
REVOKE SELECT ON dim_customer FROM analyst_role;
```

Quyền phổ biến:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`
- `CREATE`
- `ALTER`
- `DROP`

Không cấp quyền ghi/xóa nếu người dùng chỉ cần đọc.

## 6. Views để kiểm soát dữ liệu

View có thể che cột nhạy cảm.

```sql
CREATE VIEW vw_customer_safe AS
SELECT
  customer_id,
  city,
  created_at
FROM dim_customer;
```

Analyst chỉ được quyền:

```sql
GRANT SELECT ON vw_customer_safe TO analyst_role;
```

Không cấp trực tiếp bảng gốc chứa email/phone.

## 7. Masking

Masking che một phần dữ liệu nhạy cảm.

Ví dụ email:

```sql
SELECT
  customer_id,
  SUBSTR(email, 1, 2) || '***' AS masked_email
FROM dim_customer;
```

Ví dụ phone:

```sql
SELECT
  customer_id,
  '***' || SUBSTR(phone_number, -4) AS masked_phone
FROM dim_customer;
```

Một số platform hỗ trợ dynamic data masking ở cấp policy.

## 8. Row-level security

Row-level security giới hạn user chỉ xem một số dòng.

Ví dụ sales manager miền Bắc chỉ xem customer miền Bắc.

Ý tưởng view:

```sql
CREATE VIEW vw_orders_region AS
SELECT *
FROM fact_orders
WHERE region IN (
  SELECT region
  FROM user_region_access
  WHERE username = CURRENT_USER
);
```

Nhiều database/warehouse có policy row access riêng.

## 9. Column-level security

Column-level security giới hạn quyền xem cột.

Ví dụ:

- Analyst được xem `customer_id`, `city`.
- Chỉ PII admin được xem `email`, `phone_number`.

Nếu database không hỗ trợ column-level privilege tốt, dùng view safe.

## 10. Audit log

Audit log giúp biết:

- Ai truy cập bảng nào?
- Khi nào?
- Query gì?
- Export dữ liệu không?
- Có truy cập PII không?

Data Engineer cần phối hợp với DBA/Security để đảm bảo truy cập dữ liệu nhạy cảm được ghi nhận.

## 11. Data retention

Data retention là chính sách giữ dữ liệu bao lâu.

Ví dụ:

- Raw logs giữ 90 ngày.
- Fact orders giữ 5 năm.
- PII của user deleted phải xóa/mask sau 30 ngày.

Retention nên được tự động hóa bằng partition/drop/archive.

Ví dụ:

```sql
DELETE FROM raw_events
WHERE ingestion_date < CURRENT_DATE - INTERVAL '90' DAY;
```

Với bảng lớn, nên drop/archive partition thay vì delete từng dòng nếu có thể.

## 12. Encryption

Encryption gồm:

- At rest: mã hóa khi lưu trữ.
- In transit: mã hóa khi truyền qua network.

Data Engineer không phải lúc nào cấu hình trực tiếp, nhưng cần biết yêu cầu bảo mật:

- Không xuất PII ra file không mã hóa.
- Không gửi dữ liệu nhạy cảm qua kênh không an toàn.
- Không log secrets hoặc payload nhạy cảm.

## 13. Secrets management

Không hard-code password/API key trong SQL/script.

Không tốt:

```text
username = 'admin'
password = 'P@ssw0rd'
```

Tốt hơn:

- Secret manager.
- Environment variables.
- Managed identity/service account.
- Vault.

Trong SQL job, connection credentials phải được quản lý bởi orchestration/platform.

## 14. Data lineage

Lineage cho biết dữ liệu đi từ đâu đến đâu.

Ví dụ:

```text
stg_orders -> fact_orders -> agg_daily_revenue -> dashboard_revenue
```

Lineage giúp:

- Debug khi số liệu sai.
- Biết thay đổi bảng ảnh hưởng dashboard nào.
- Audit dữ liệu.
- Đánh giá impact trước khi sửa pipeline.

## 15. Data catalog

Data catalog lưu thông tin:

- Bảng có ý nghĩa gì.
- Owner là ai.
- Cột nào là PII.
- Freshness.
- Lineage.
- Data quality status.

Senior Data Engineer nên viết mô tả bảng/cột rõ ràng.

## 16. Governance trong naming và ownership

Mỗi bảng production nên có:

- Owner.
- Mô tả.
- Grain.
- SLA cập nhật.
- Data quality checks.
- Retention policy.
- Access policy.

Không nên có bảng production không ai chịu trách nhiệm.

## 17. Minh họa thực tế: cấp quyền cho analyst

Yêu cầu:

Analyst cần phân tích doanh thu theo city, không cần email/phone.

Không nên cấp:

```sql
GRANT SELECT ON dim_customer TO analyst_role;
```

nếu `dim_customer` chứa PII.

Tạo view:

```sql
CREATE VIEW vw_dim_customer_analytics AS
SELECT
  customer_key,
  customer_id,
  city,
  customer_segment
FROM dim_customer;
```

Cấp quyền:

```sql
GRANT SELECT ON vw_dim_customer_analytics TO analyst_role;
GRANT SELECT ON fact_orders TO analyst_role;
```

## 18. Lỗi security/governance phổ biến

- Cấp quyền trực tiếp vào bảng PII.
- Dùng chung account cho nhiều người.
- Không audit access.
- Không có owner cho bảng.
- Không có retention policy.
- Log dữ liệu nhạy cảm.
- Export dữ liệu nhạy cảm ra file cá nhân.
- Hard-code secrets trong script.
- Không document grain và meaning của bảng.

## 19. Checklist security/governance

- Bảng có chứa PII không?
- Ai cần quyền truy cập?
- Có thể cấp view thay vì bảng gốc không?
- Có masking cần thiết không?
- Có row-level/column-level control không?
- Có audit log không?
- Có owner không?
- Có retention policy không?
- Có lineage không?
- Secrets có được quản lý an toàn không?

## 20. Bài tập tự luyện

### Bài 1

Thiết kế view `vw_customer_safe` che email và phone.

### Bài 2

Liệt kê các cột PII thường gặp trong bảng customer.

### Bài 3

Giải thích nguyên tắc least privilege bằng ví dụ SQL.

### Bài 4

Thiết kế metadata cần có cho một bảng production.

### Bài 5

Đề xuất cách cấp quyền cho analyst cần xem doanh thu nhưng không được xem PII.

## 21. Từ fresher lên senior ở security/governance

Fresher thường nghĩ: "Có quyền đọc là dùng được."

Senior nghĩ:

- Dữ liệu này có nhạy cảm không?
- Người này có thật sự cần cột đó không?
- Nếu export ra ngoài thì rủi ro gì?
- Bảng này owner là ai?
- Nếu số liệu sai thì trace lineage thế nào?

Security và governance là phần làm cho hệ thống dữ liệu có thể vận hành ở quy mô doanh nghiệp.

