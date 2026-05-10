# PROMPT_Review_Module04_Analytics_Engineering.md

## Mục tiêu

Review toàn bộ file `Module04_Analytics_Engineering.html` do Claude Code build.
Người review (Antigravity) kiểm tra theo checklist bên dưới và báo cáo kết quả theo format chuẩn.

---

## Files cần đọc trước khi review

1. `Module04_Analytics_Engineering.html` — file cần review
2. `repo_notes_M04.md` — ground truth về code và content trong repo
3. `module_template.html` — design system chuẩn
4. `master_de_roadmap.html` — phần M04 (kiến thức kỳ vọng, 3-level system)
5. `Module01_Docker_Terraform.html` — reference về style và structure đã approved

---

## CHECKLIST REVIEW

### ─────────────────────────────────────
### BLOCK A — KỸ THUẬT HTML/JS
### ─────────────────────────────────────

**A1. File mở được trên browser không lỗi**
- [ ] Mở file trên Chrome/Firefox, F12 Console không có lỗi JavaScript
- [ ] Không có uncaught TypeError, ReferenceError
- [ ] Không có failed network requests (fonts, external CDN nếu dùng)

**A2. Navigation hoạt động đúng**
- [ ] Click từng item trong sidebar (S0→S8) đều hiện đúng section tương ứng
- [ ] Section không active phải ẩn (display:none), không bị chồng lên nhau
- [ ] Active state (highlight) trên sidebar đúng với section đang xem
- [ ] showModule() function nhận đúng index → gọi đúng section ID

**A3. Interactive components hoạt động**
- [ ] Quiz: click đáp án → hiện explanation, không crash
- [ ] Quiz: đáp án đúng highlight màu xanh, sai highlight màu đỏ
- [ ] "Xem Solution" toggle: click mở/đóng đúng, không bị stuck
- [ ] Tab switcher (SQL/YAML/Jinja): click đổi tab hiện đúng content
- [ ] Checklist checkbox: tick → progress bar cập nhật đúng %
- [ ] Progress bar: đếm đúng số checkbox đã tick / tổng

**A4. CSS và Design**
- [ ] CSS variables khớp với module_template.html (màu, font, spacing)
- [ ] Hero banner render đúng: title, badges (level, thời gian, category)
- [ ] Code blocks có syntax highlight (không phải plain text)
- [ ] Info boxes (tip/warn/note/danger) có màu và icon đúng
- [ ] Responsive cơ bản: không bị overflow ngang trên viewport 1280px
- [ ] .practice-task component render đúng style

---

### ─────────────────────────────────────
### BLOCK B — NỘI DUNG S0 + S1
### ─────────────────────────────────────

**B1. S0 — Tổng quan**
- [ ] Có bảng 9 sections với tên và thời gian ước tính đầy đủ
- [ ] Giải thích được vấn đề Analytics Engineering giải quyết (SQL script rời rạc, không có lineage)
- [ ] Giải thích được vấn đề dbt giải quyết (transformation không reproducible)
- [ ] ASCII diagram data flow: Raw Source → Staging → Intermediate → Marts → BI Tool
- [ ] Đề cập rõ 2 learning paths: Path A (BigQuery + dbt Cloud) và Path B (DuckDB + dbt Core)
- [ ] Có exit criteria cụ thể

**B2. S1 — Lý thuyết nền: Analytics Engineering**
- [ ] 3 levels rõ ràng: Beginner / Intermediate / Senior
- [ ] Beginner: giải thích được AE role khác DE và Analyst
- [ ] Beginner: ELT vs ETL với analogy cụ thể, không chỉ định nghĩa khô
- [ ] Beginner: Fact/Dimension/Star schema giải thích trực quan (không chỉ buzzword)
- [ ] Intermediate: Kimball vs Inmon vs Data Vault — có trade-offs thực tế
- [ ] Senior: dbt trong modern data stack — vị trí trong toàn bộ pipeline
- [ ] Mental model 1 câu dbt xuất hiện rõ ràng
- [ ] So sánh dbt Core vs dbt Cloud vs SQLMesh có nội dung thực chất (2025 context)
- [ ] Có ít nhất 4 info boxes (tip/warn/note/danger) đan xen, không chỉ block text
- [ ] 6 câu quiz với explanation đầy đủ, scenario-based (không phải câu định nghĩa thuần túy)

**B3. S1 — Lý thuyết nền: dbt Core Concepts**
- [ ] Phân biệt Models / Sources / Seeds rõ ràng
- [ ] ref() vs source(): giải thích được TẠI SAO phân biệt (lineage, graph dependency)
- [ ] Materialization 4 loại: view/table/incremental/ephemeral — có bảng trade-offs
- [ ] Incremental model: unique_key + merge concept xuất hiện ở Senior level
- [ ] dbt build vs dbt run: giải thích rõ tại sao build quan trọng hơn trong production
- [ ] Mental model 1 câu "dbt model = 1 SELECT" xuất hiện rõ ràng
- [ ] 6 câu quiz scenario-based với explanation đầy đủ

---

### ─────────────────────────────────────
### BLOCK C — NỘI DUNG S2 (CODE ANALYSIS)
### ─────────────────────────────────────

**C1. Cấu trúc thư mục**
- [ ] Tree diagram khớp với repo thực tế (cross-check với repo_notes_M04.md section 1)
- [ ] Phân biệt rõ class_notes/ (lý thuyết) vs taxi_rides_ny/ (code thực hành)

**C2. dbt_project.yml**
- [ ] Code được trích nguyên văn, syntax highlight YAML
- [ ] Giải thích: staging=view, intermediate=table, marts=table — tại sao từng layer
- [ ] Giải thích vars dev_start_date/dev_end_date — mục đích và cách dùng
- [ ] Ghi rõ điểm yếu: staging models KHÔNG dùng var() mà hardcode filter

**C3. sources.yml**
- [ ] Code được trích nguyên văn
- [ ] Giải thích conditional database/schema cho BigQuery vs DuckDB
- [ ] Freshness config: warn_after/error_after được giải thích ý nghĩa thực tế
- [ ] Ghi rõ rủi ro env_var fallback default

**C4. Staging models**
- [ ] Cả 2 files stg_green và stg_yellow được trích nguyên văn hoặc trích đoạn đủ hiểu
- [ ] safe_cast macro: giải thích tại sao dùng (cross-database, không crash khi invalid)
- [ ] Ghi rõ điểm yếu: hardcode date filter thay vì dùng var()

**C5. Intermediate models**
- [ ] int_trips_unioned: UNION ALL pattern được giải thích (schema alignment trước khi union)
- [ ] int_trips: surrogate key với dbt_utils.generate_surrogate_key — tại sao cần
- [ ] Ghi rõ: hardcode trip_type=1, ehail_fee=0 cho yellow

**C6. Marts models**
- [ ] fct_trips: INCREMENTAL + merge + unique_key=trip_id được giải thích đầy đủ
- [ ] Late-arriving data risk của max(pickup_datetime) filter được nêu rõ
- [ ] dim_vendors ref fct_trips: antipattern được nhận ra và giải thích
- [ ] get_trip_duration_minutes: cross-database DATEDIFF được giải thích

**C7. Macros và Seeds**
- [ ] 3 macros được trích nguyên văn hoặc đủ để hiểu logic
- [ ] Seeds: khi nào phù hợp vs không phù hợp production được đề cập

**C8. DAG Lineage**
- [ ] ASCII diagram đầy đủ từ source đến reporting
- [ ] Materialization annotated trên từng node
- [ ] Lineage dạng text: file nào ref file nào — khớp với repo_notes_M04.md section 4

**C9. Quiz và Tabs**
- [ ] Tab SQL/YAML/Jinja hoạt động
- [ ] 6 câu quiz về data flow/code structure, có explanation

---

### ─────────────────────────────────────
### BLOCK D — NỘI DUNG S3 (THỰC HÀNH)
### ─────────────────────────────────────

**D1. Setup môi trường**
- [ ] 2 paths song song: Local (DuckDB) và Cloud (BigQuery) được trình bày rõ ràng (tab hoặc section riêng)
- [ ] Commands copy-paste được, không có placeholder [YOUR_PROJECT] chưa điền context
- [ ] profiles.yml template đầy đủ với memory_limit và threads
- [ ] Verify thành công được mô tả rõ: output mong đợi của dbt debug

**D2. Chạy dbt pipeline đầu tiên**
- [ ] Thứ tự đúng: dbt deps → dbt seed → dbt run staging → dbt run → dbt test → dbt build
- [ ] Mỗi command: giải thích làm gì, output mong đợi
- [ ] dbt build vs dbt run: được nhấn mạnh ở bước này

**D3. Làm việc với từng layer**
- [ ] dbt compile để xem SQL compiled — được hướng dẫn
- [ ] --full-refresh context: khi nào dùng với staging
- [ ] fct_trips+: selector syntax được dùng thực tế

**D4. 3 bài tập thực hành**
- [ ] Task 1 (Beginner): đề rõ ràng, gợi ý đủ, solution đầy đủ và chạy được
- [ ] Task 2 (Intermediate): đề rõ ràng, gợi ý hợp lý, solution với ref() đúng
- [ ] Task 3 (Advanced): snapshot config đủ để chạy được, giải thích strategy
- [ ] Cả 3 tasks dùng .practice-task component đúng style

**D5. "Cố tình phá" section**
- [ ] 6 kịch bản đầy đủ
- [ ] Kịch bản 6 (source() thay vì ref()): giải thích rõ lỗi compile-time vs runtime
- [ ] Mỗi kịch bản: lỗi gì → tại sao → fix thế nào (đủ 3 phần)

---

### ─────────────────────────────────────
### BLOCK E — NỘI DUNG S4 + S5
### ─────────────────────────────────────

**E1. S4 — Production Thinking (6 câu)**
- [ ] Câu 1 FAILURE: đề cập dbt retry + target/run_results.json + quyết định --full-refresh
- [ ] Câu 2 SCALE: late-arriving data problem được mô tả với ví dụ cụ thể, có lookback window code
- [ ] Câu 3 IDEMPOTENCY: phân biệt rõ seeds/staging/incremental — cái nào idempotent, cái nào không
- [ ] Câu 4 DATA QUALITY: liệt kê columns thiếu test (cross-check với repo_notes_M04.md section 5)
- [ ] Câu 5 COST: staging view → BigQuery scan cost được giải thích, partition config code example
- [ ] Câu 6 SECURITY: env_var fallback risk + service account key risk + meta.owner pattern
- [ ] Mỗi câu có code example thực tế (không phải pseudocode)

**E2. S5 — Kiến thức nâng cao**
- [ ] Slim CI workflow được mô tả đủ: state:modified+ + defer + GitHub Actions YAML
- [ ] SCD Type 2 với snapshots: config đầy đủ, giải thích updated_at vs check strategy
- [ ] Unit tests (dbt v1.8+): có code example
- [ ] Materialization trade-offs: bảng view/table/incremental/ephemeral rõ ràng
- [ ] "Khi nào outgrow": 4 dấu hiệu cụ thể, không chung chung

---

### ─────────────────────────────────────
### BLOCK F — NỘI DUNG S6 + S7 + S8
### ─────────────────────────────────────

**F1. S6 — Lỗi thường gặp**
- [ ] Bảng 12 lỗi dùng class="data-table" đúng style
- [ ] Tất cả 12 lỗi từ prompt đều có mặt, không thiếu lỗi nào
- [ ] Error messages là thực tế (có thể search được), không phải mô tả chung chung
- [ ] Fix column: có action cụ thể, không chỉ "kiểm tra lại"
- [ ] Debugging checklist xuất hiện sau bảng

**F2. S7 — Interview Prep**
- [ ] 12 câu đủ, chia đúng 4/4/4 theo Junior/Mid/Senior
- [ ] Badge màu đúng: xanh lam/vàng/đỏ theo level
- [ ] Mỗi câu collapsible: click expand → answer chi tiết
- [ ] "Red flag: đừng nói..." xuất hiện trong mỗi câu answer
- [ ] Câu Senior 9 (pipeline fail 3h sáng): answer đủ technical depth, không chỉ nói "dùng retry"
- [ ] Câu Senior 11 (data model real-time + monthly): answer có actual trade-off design

**F3. S8 — Checklist & Tổng kết**
- [ ] 18 items checklist đủ, chia đúng 6/6/6 theo Beginner/Intermediate/Senior
- [ ] Progress bar: tick checkbox → % tự cập nhật
- [ ] Summary grid: 5 điểm chốt đủ, điểm 5 có AWS/Snowflake mapping
- [ ] Definition of Done: 5 checkboxes cụ thể
- [ ] Preview Module 05 có link đến Module05_Batch_Processing.html

---

### ─────────────────────────────────────
### BLOCK G — ACCURACY CHECK
### ─────────────────────────────────────

**G1. Code accuracy (cross-check với repo_notes_M04.md)**
- [ ] Tên models trong DAG diagram khớp với file thực tế trong repo
- [ ] Materialization assignments đúng: staging=view, intermediate=table, marts=table, fct_trips=incremental
- [ ] unique_key của fct_trips = trip_id (không phải tên khác)
- [ ] Packages đúng: dbt_utils v1.3.x và codegen v0.14.x
- [ ] dev_start_date='2019-01-01', dev_end_date='2019-02-01' — đúng
- [ ] dim_vendors ref fct_trips (không phải int_trips) — đúng và được note là antipattern

**G2. Concept accuracy**
- [ ] ref() tạo dependency trong DAG — không viết là "chỉ là alias"
- [ ] source() không dùng để ref model khác trong cùng project
- [ ] Incremental filter với max() là pattern thực tế của repo — không tự sáng tác filter khác
- [ ] dbt build = run + test + snapshot + seed theo đúng thứ tự dependency
- [ ] Surrogate key = hash(source + grain columns) — không mô tả sai là sequential integer

**G3. Commands accuracy**
- [ ] Tất cả dbt commands trong S3 là lệnh thực tế hoạt động được (không có flag giả)
- [ ] dbt build --select state:modified+ --state ./prod-artifacts — đúng syntax
- [ ] dbt source freshness — đúng command (không phải dbt test --select source:*)

---

## FORMAT BÁO CÁO

Sau khi review xong, báo cáo theo format sau:

```
=== REVIEW REPORT: Module04_Analytics_Engineering.html ===
Reviewer: [tên]
Date: [ngày]

TỔNG KẾT:
- Tổng items checked: XX / YY
- PASS: XX items
- FAIL: XX items
- CRITICAL FAIL (block publish): XX items

BLOCK A — KỸ THUẬT: XX/XX pass
BLOCK B — S0+S1: XX/XX pass
BLOCK C — S2 CODE: XX/XX pass
BLOCK D — S3 THỰC HÀNH: XX/XX pass
BLOCK E — S4+S5: XX/XX pass
BLOCK F — S6+S7+S8: XX/XX pass
BLOCK G — ACCURACY: XX/XX pass

CRITICAL ISSUES (phải fix trước khi dùng):
1. [Item ID] — [mô tả vấn đề]
2. ...

MEDIUM ISSUES (nên fix):
1. [Item ID] — [mô tả vấn đề]
2. ...

MINOR ISSUES (nice to fix):
1. [Item ID] — [mô tả vấn đề]
2. ...

VERDICT: APPROVE / APPROVE WITH FIXES / REJECT
```

---

## NOTES CHO REVIEWER

**Critical Fails** (verdict REJECT nếu có bất kỳ):
- File không mở được trên browser
- Navigation không hoạt động (không đi được từ S0 sang S8)
- DAG diagram sai so với repo thực tế
- Code examples trong S3 không chạy được

**Escalation:** Nếu phát hiện vấn đề không rõ đúng/sai, check lại `repo_notes_M04.md` section tương ứng. Nếu vẫn không rõ, ghi vào MEDIUM ISSUES để author (Claude) xác nhận trước khi quyết định.

**Không review:** Style/tone/wording của prose — chỉ review technical accuracy và functional correctness.
