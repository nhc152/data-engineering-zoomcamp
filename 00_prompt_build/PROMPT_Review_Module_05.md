# PROMPT_Review_Module_05.md
# Review toàn diện file Module05_Data_Platforms.html

> Dùng cho: Antigravity review code sau khi Claude build xong 5 prompts
> Mục tiêu: Phát hiện lỗi kỹ thuật, nội dung sai, UX hỏng, thiếu sót so với spec
> Cách chạy: Paste toàn bộ prompt này vào Antigravity sau khi có file .html

---

## BƯỚC 0 — ĐỌC FILE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ

```
Đọc TOÀN BỘ các file sau theo thứ tự:

1.  Module05_Data_Platforms.html               ← file cần review
2.  module_template.html                        ← chuẩn gốc về CSS/component
3.  master_de_roadmap.html                      ← spec Module 05 và DoD
4.  data-engineering-zoomcamp/05-data-platforms/notes/01-introduction.md
5.  data-engineering-zoomcamp/05-data-platforms/notes/02-getting-started.md
6.  data-engineering-zoomcamp/05-data-platforms/notes/03-nyc-taxi-pipeline.md
7.  data-engineering-zoomcamp/05-data-platforms/notes/04-bruin-mcp.md
8.  data-engineering-zoomcamp/05-data-platforms/notes/05-bruin-cloud.md
9.  data-engineering-zoomcamp/05-data-platforms/notes/06-core-01-projects.md
10. data-engineering-zoomcamp/05-data-platforms/notes/06-core-02-pipelines.md
11. data-engineering-zoomcamp/05-data-platforms/notes/06-core-03-assets.md
12. data-engineering-zoomcamp/05-data-platforms/notes/06-core-04-variables.md
13. data-engineering-zoomcamp/05-data-platforms/notes/06-core-05-commands.md
14. Tất cả pipeline config files, asset files (.sql, .py, .yaml) trong repo

KHÔNG bắt đầu review cho đến khi đã đọc xong tất cả file.
Mục đích: review phải đối chiếu HTML với source code thực tế,
không thể review đúng nếu chỉ đọc HTML một mình.
```

---

## BƯỚC 1 — KIỂM TRA KỸ THUẬT HTML/CSS/JS

```
Kiểm tra toàn bộ phần kỹ thuật của file. Với mỗi mục, ghi rõ:
PASS / FAIL / WARNING + mô tả cụ thể nếu không pass.

═══════════════════════════════
1.1 HTML STRUCTURE
═══════════════════════════════

□ File có đúng DOCTYPE html không?
□ <head> có đủ: charset UTF-8, viewport meta, title, Google Fonts link?
□ Title tag đúng: "Module 05 — Data Platforms & Bruin"?
□ Không có broken tag nào (thẻ mở không có thẻ đóng)?
□ Tất cả 9 section div tồn tại: id="s0" đến id="s8"?
□ Không còn placeholder nào dạng <div id="sX" style="display:none"></div>
  còn trống (chưa có nội dung bên trong)?

═══════════════════════════════
1.2 CSS VARIABLES
═══════════════════════════════

So sánh với module_template.html — kiểm tra từng biến:
□ --color-primary tồn tại và đúng giá trị?
□ --color-secondary tồn tại và đúng giá trị?
□ --color-accent tồn tại và đúng giá trị?
□ --color-bg, --color-surface, --color-border tồn tại?
□ --font-main, --font-mono tồn tại?
□ --radius, --shadow tồn tại?
□ Tất cả component classes từ template có trong file:
  .hero-banner, .sidebar, .nav-item, .section-content,
  .info-box (tip/warn/note/danger), .quiz-block, .practice-task,
  .data-table, .code-block, .tab-container, .checklist-item,
  .badge, .progress-bar?
□ Không có CSS custom nào override template theo cách gây visual bug?

═══════════════════════════════
1.3 JAVASCRIPT FUNCTIONS
═══════════════════════════════

□ showModule(index) tồn tại và hoạt động đúng không?
  → Test: click S1 → S1 hiện, S0 ẩn, nav item S1 active
□ toggleSection(id) tồn tại?
  → Dùng cho collapsible sections trong S7 interview?
□ answerQuiz(questionId, answer, correct) tồn tại?
  → Click đáp án đúng → hiển thị đúng/sai + explanation?
□ toggleSolution(taskId) tồn tại?
  → Dùng trong S3 practice tasks?
□ switchTab(tabGroup, tabName) tồn tại?
  → Dùng trong S2 (SQL/YAML/Python tabs)?
□ toggleCheck(itemId) tồn tại?
  → Dùng cho checklist S8?
□ updateProgress() tồn tại và được gọi sau mỗi toggleCheck?
  → Progress bar S8 tự cập nhật khi tick?
□ Không có lỗi JavaScript nào (undefined function, syntax error)?
□ Không có lỗi console khi mở file trên browser?

═══════════════════════════════
1.4 NAVIGATION & SIDEBAR
═══════════════════════════════

□ Sidebar có đủ 9 nav items: S0 đến S8?
□ Tên từng nav item đúng:
  S0: Tổng quan & Mục tiêu
  S1: Lý thuyết nền
  S2: Đọc hiểu code repo
  S3: Thực hành từng bước
  S4: Production Readiness
  S5: Kiến thức nâng cao
  S6: Lỗi thường gặp
  S7: Interview Prep
  S8: Checklist & Tổng kết
□ S0 active mặc định khi mở file?
□ Click từng nav item → đúng section hiện lên?
□ Không có nav item nào click → màn hình trắng hoặc lỗi?

═══════════════════════════════
1.5 RESPONSIVE & VISUAL
═══════════════════════════════

□ File mở được trên Chrome/Firefox không lỗi layout?
□ Sidebar và main content không overlap nhau?
□ Code blocks có syntax highlight (hoặc ít nhất monospace font)?
□ Tables không tràn ra ngoài container?
□ Info boxes (tip/warn/note/danger) hiển thị đúng màu?
□ Badge colors đúng: Junior=xanh lam, Mid=vàng, Senior=đỏ?
□ Progress bar S8 render đúng (không bị 0% cứng đờ)?

Báo cáo tất cả FAIL và WARNING với dòng code cụ thể (line number).
```

---

## BƯỚC 2 — KIỂM TRA NỘI DUNG TỪNG SECTION

```
Đọc từng section, đối chiếu với spec build prompt và source code thực tế.
Format báo cáo: ✅ PASS | ⚠️ WARNING | ❌ FAIL

═══════════════════════════════
S0 — TỔNG QUAN & MỤC TIÊU
═══════════════════════════════

□ Có bảng 9 sections với tên + thời gian ước tính không?
□ Có giải thích vấn đề Data Platforms giải quyết không?
  (pipeline SQL rải rác, không có lineage, deploy bằng tay, incident không biết debug từ đâu)
□ Có giải thích "trước Bruin người ta làm gì"
  (shell scripts tuần tự, cron jobs, notebook pipelines, custom orchestrators) không?
□ Có data flow diagram ASCII không? Kiểm tra flow:
  Raw Source → [connection config] → Ingestr Asset → SQL/Python Asset → Output Table → BI Tool
□ Có DAG tổng quan NYC Taxi pipeline từ repo không?
  (raw source → ingest asset → staging asset → fact asset → reporting asset)
□ Có 2 learning paths rõ ràng không?
  Path A: Bruin CLI local (DuckDB/SQLite)
  Path B: Bruin Cloud
□ Có Exit criteria "Bạn đã nắm module này khi..." không?

═══════════════════════════════
S1 — LÝ THUYẾT NỀN
═══════════════════════════════

Phần Data Platforms & Orchestration:
□ Có giải thích Data Platform khác Data Warehouse và Data Pipeline thế nào không?
□ Có giải thích Asset-based thinking vs Task-based thinking không?
□ Có giải thích 3 khái niệm cốt lõi: Pipeline, Asset, Connection không?
□ Có giải thích DAG và dependency graph trong data platform không?
□ Có bảng so sánh Bruin vs dbt vs Airflow vs Dagster không?
□ Có mental model 1 câu: "Bruin = git-native data platform..." không?
□ Có đủ 6 câu quiz với explanation không?

Phần Bruin Core Concepts:
□ Có giải thích Projects, Pipelines, Assets hierarchy không?
□ Có giải thích 3 asset types: SQL, Python, Ingestr không?
□ Có giải thích Variables: built-in (start_date, end_date) vs custom không?
□ Có giải thích Connections: types, config location không?
□ Có bảng so sánh Bruin asset config vs dbt model config không?
□ Có mental model 1 câu: "Bruin asset = 1 file + metadata YAML block..." không?
□ Có đủ 6 câu quiz với explanation không?

═══════════════════════════════
S2 — ĐỌC HIỂU CODE REPO
═══════════════════════════════

□ Có tree diagram thư mục 05-data-platforms/ không?
  Kiểm tra có đủ: notes/ với tất cả 11 file .md, pipeline project files.

□ Phần Project config:
  Có trích code config thực tế từ repo không?
  Verify khớp NGUYÊN VĂN với file gốc — không được bịa thêm fields.
  Có giải thích từng block: project name, connections, default settings không?

□ Phần Pipeline config:
  Có trích pipeline YAML thực tế từ repo không?
  Có giải thích schedule syntax, default_parameters không?

□ Phần Ingestr Assets:
  Có trích code asset thực tế từ repo không?
  Có giải thích: asset type, source/destination connection, parameters không?
  Có giải thích tại sao dùng ingestr thay vì custom script không?

□ Phần SQL Assets:
  Có trích code SQL asset thực tế từ repo không?
  Có giải thích YAML metadata block trong SQL file không?
  Có giải thích depends declaration — so sánh với dbt ref() không?
  Có giải thích Variables {{ start_date }}, {{ end_date }} không?

□ Phần Python Assets (nếu có trong repo):
  Có trích code Python asset thực tế không?
  Có giải thích context object, decorator/metadata block không?

□ Phần Variables:
  Có liệt kê đầy đủ built-in variables không?
  Có giải thích bruin render command không?

□ Phần Connections:
  Có giải thích security pattern — credentials không commit vào git không?

□ Phần DAG Lineage:
  Có diagram ASCII đầy đủ khớp với actual repo pipeline không?
  Có annotate asset type trên từng node không?
  Có giải thích bruin lineage command output không?

□ Có Tabs: SQL / YAML / Python với switchTab() function không?
□ Có 6 câu quiz về data flow và cấu trúc code không?

═══════════════════════════════
S3 — THỰC HÀNH TỪNG BƯỚC
═══════════════════════════════

□ Có 2 tabs setup song song không? Tab A (Local CLI) và Tab B (Bruin Cloud)?

Tab A — Local:
□ Có lệnh cài Bruin CLI chính xác cho từng OS không?
□ Có connection config DuckDB template không?
□ Có bruin validate + bruin version verify steps không?
□ Có "Bạn biết setup đúng khi thấy..." section không?

Tab B — Cloud:
□ Có hướng dẫn tạo tài khoản Bruin Cloud không?
□ Có GitHub integration setup không?
□ Có "Bạn biết setup đúng khi thấy..." section không?

□ Có phần "Chạy pipeline đầu tiên" với các lệnh:
  bruin validate, bruin run, bruin run --asset, bruin run --downstream,
  bruin lineage, bruin render không?

□ Có step-by-step làm việc với từng layer (6 steps) không?

□ Có 3 practice tasks với độ khó tăng dần không?
  Task 1 Beginner: SQL asset mới với trip_duration_minutes
  Task 2 Intermediate: Pipeline mới với ingestr + SQL asset chain
  Task 3 Advanced: Incremental idempotent asset với date range

□ Mỗi task có: Đề bài, Gợi ý, Solution đầy đủ không?

□ Có "Cố tình phá" section với 6 kịch bản debug không?
  1. depends sai tên asset
  2. connection name không khớp
  3. upstream asset chưa tồn tại
  4. variable start_date không được set
  5. 2 bruin run song song cùng pipeline
  6. YAML indentation sai

═══════════════════════════════
S4 — PRODUCTION READINESS
═══════════════════════════════

□ Có đủ 6 câu production scenarios không?
  1. FAILURE: pipeline fail lúc 2h sáng, asset dirty state
  2. SCALE: từ demo data lên production TB/ngày
  3. IDEMPOTENCY: chạy 2 lần cùng date range
  4. DATA QUALITY: built-in checks + custom assertions
  5. COST & PERFORMANCE: full reload vs incremental, date range
  6. SECURITY: credentials, environment separation, Bruin MCP risks

□ Mỗi câu có answer chi tiết + code example không?
□ Có code example: incremental ingestr asset với date filter không?
□ Có code example: bruin run với date range flags không?
□ Có code example: environment-based connection config pattern không?
□ Có code example: quality check config trong asset YAML không?

═══════════════════════════════
S5 — KIẾN THỨC NÂNG CAO
═══════════════════════════════

□ Có phần Bruin Pro patterns:
  bruin run selector syntax, backfill workflow, bruin validate trong CI/CD không?
□ Có code example: GitHub Actions CI/CD workflow cho Bruin không?

□ Có phần Bruin MCP Integration (từ notes/04-bruin-mcp.md):
  Giải thích MCP là gì, Bruin MCP server setup, AI-assisted authoring workflow không?
  Có nêu rõ giới hạn của AI (business logic) không?

□ Có phần Bruin Cloud (từ notes/05-bruin-cloud.md):
  So sánh Bruin Cloud vs CLI, managed features, team collaboration không?

□ Có bảng Trade-offs đầy đủ không?
  Ingestr vs custom script, SQL vs Python asset,
  DuckDB vs BigQuery/Snowflake, Bruin vs dbt vs Airflow, Bruin Cloud vs self-hosted?

□ Có phần "Khi nào outgrow setup hiện tại" với 4 dấu hiệu không?

═══════════════════════════════
S6 — LỖI THƯỜNG GẶP
═══════════════════════════════

□ Có bảng đủ 12 lỗi với class="data-table" không?
□ 12 lỗi đúng như spec:
  1.  Asset not found
  2.  Connection not found in project config
  3.  Cannot find upstream asset
  4.  YAML parse error in asset header
  5.  Variable start_date is not defined
  6.  Duplicate rows after incremental run
  7.  DuckDB file locked
  8.  Circular dependency detected
  9.  Ingestr source table not found
  10. Insufficient permissions on destination
  11. bruin run timeout
  12. Schema mismatch: column not found
□ Error messages trong bảng là error thực tế (không bịa) — verify với repo/docs?
□ Có cột đầy đủ: Lỗi | Nguyên nhân | Cách fix | Cách phòng tránh không?
□ Có Debugging checklist theo thứ tự ưu tiên sau bảng không?
□ Có nhắc learner mở Logbook ghi lại lỗi không?

═══════════════════════════════
S7 — INTERVIEW PREP
═══════════════════════════════

□ Có đủ 12 câu hỏi với collapsible pattern không?
□ Phân bổ đúng: Junior 4 câu, Mid 4 câu, Senior 4 câu?
□ Badge colors đúng: Junior=xanh lam, Mid=vàng, Senior=đỏ?

Junior (verify 4 câu đúng topic):
□ Data Platform là gì, khác DW và Data Pipeline thế nào?
□ Asset, Pipeline, Connection — quan hệ giữa chúng?
□ Tại sao khai báo dependency quan trọng hơn chạy script thủ công?
□ SQL asset khác Python asset, khi nào dùng cái nào?

Mid (verify 4 câu đúng topic):
□ Variables start_date/end_date giải quyết vấn đề gì?
□ Incremental asset — chạy 2 lần có duplicate không?
□ bruin validate vs bruin run — khi nào dùng cái nào?
□ Debug khi pipeline fail mà log không đủ thông tin?

Senior (verify 4 câu đủ phức tạp):
□ Câu 9: incident 50GB/ngày fail sau 4 tiếng, dirty state — xử lý thế nào?
□ Câu 10: team 5 DE, branching và deployment strategy?
□ Câu 11: thiết kế platform cho e-commerce 3 sources?
□ Câu 12: AI-generated asset review checklist trước khi merge?

□ Mỗi câu có: gợi ý trả lời chi tiết + "Red flag: đừng nói..." không?
□ Câu Senior có thực sự phức tạp, không phải câu Junior thêm chữ "design" không?

═══════════════════════════════
S8 — CHECKLIST & TỔNG KẾT
═══════════════════════════════

□ Có progress bar với id="checklist-progress-fill" và "checklist-progress-text" không?
□ Có đủ 18 checklist items chia 3 level (6+6+6) không?

Beginner 6 items (verify topics):
□ Asset-based thinking vs Task-based thinking
□ Cài Bruin CLI + bruin --version
□ Tạo connection config không cần hỏi
□ bruin validate + đọc output
□ bruin run + verify data destination
□ Đọc lineage graph từ bruin lineage

Intermediate 6 items (verify topics):
□ Tự viết SQL asset: YAML header, depends, materialization, variables
□ Tự viết ingestr asset: source, destination, date range
□ Incremental asset: idempotency, khi nào --full-refresh
□ Debug lỗi connection và dependency
□ bruin run với selector flags
□ Tạo pipeline YAML với schedule

Senior 6 items (verify topics):
□ Thiết kế multi-asset pipeline với dependency chain
□ Incremental idempotent pipeline
□ CI/CD: bruin validate trong PR, bruin run trong deploy
□ Trade-offs Bruin vs dbt vs Airflow, justify
□ Bruin MCP config + AI-assisted authoring demo
□ 4 câu Senior interview không cần tài liệu

□ Có Summary grid 5 điểm chốt không?
  1. Bruin = git-native data platform
  2. Asset-based DAG = nguyên tắc nền tảng
  3. Variables + incremental = idempotency
  4. bruin validate + bruin lineage = bộ đôi kiểm tra
  5. Cloud/warehouse mapping

□ Có Definition of Done với 5 checkboxes không?
□ Có Preview Module 06 với link Module06_Batch_Processing.html không?
  Text: "Module tiếp theo: Batch Processing với Spark"
```

---

## BƯỚC 3 — FACT-CHECK KỸ THUẬT

```
Đây là phần quan trọng nhất. Đối chiếu từng claim kỹ thuật trong HTML
với source code thực tế trong repo. Ghi rõ từng sai lệch.

═══════════════════════════════
3.1 ASSET CONFIG ACCURACY — đối chiếu với actual asset files trong repo
═══════════════════════════════

□ Asset type names đúng theo Bruin spec:
  "ingestr" không phải "ingester" hay "ingest"
  "sql" không phải "SQL" hay "query"
  "python" không phải "Python" hay "py"
□ YAML metadata block syntax đúng — verify với actual files trong repo
□ depends field format đúng (list hay string? verify với repo)
□ materialization values đúng: "table", "view", "incremental" — đúng casing?
□ Connection field names đúng: source_connection, destination_connection — verify với repo
□ Variables syntax đúng: {{ start_date }} hay {start_date} hay $start_date?
  Verify với actual SQL files trong repo — phải khớp NGUYÊN VĂN

═══════════════════════════════
3.2 COMMAND ACCURACY — đối chiếu với notes/06-core-05-commands.md
═══════════════════════════════

□ bruin run flags đúng:
  --asset flag tên đúng không? (không phải --select hay --model)
  --downstream flag tồn tại không?
  --start-date và --end-date format đúng? (YYYY-MM-DD?)
  --full-refresh flag tên đúng không?
□ bruin validate — flags và output format đúng không?
□ bruin lineage — flags và output format đúng không?
□ bruin render — flags và output format đúng không?
□ Không bịa thêm flags không tồn tại trong Bruin CLI

═══════════════════════════════
3.3 PIPELINE CONFIG ACCURACY — đối chiếu với actual pipeline YAML trong repo
═══════════════════════════════

□ Pipeline YAML fields đúng: name, schedule, default_parameters — verify field names
□ Schedule syntax đúng — cron format hay Bruin built-in keywords?
□ Không bịa thêm fields không có trong actual pipeline config

═══════════════════════════════
3.4 BRUIN MCP ACCURACY — đối chiếu với notes/04-bruin-mcp.md
═══════════════════════════════

□ MCP config file format đúng — verify với notes
□ Bruin MCP server name/command đúng — verify với notes
□ Không confabulate features không có trong MCP notes

═══════════════════════════════
3.5 BRUIN CLOUD ACCURACY — đối chiếu với notes/05-bruin-cloud.md
═══════════════════════════════

□ Bruin Cloud features đúng — không bịa thêm features không có trong notes
□ Pricing/plan info nếu có — verify với notes, không đoán

═══════════════════════════════
3.6 CONCEPT ACCURACY
═══════════════════════════════

□ Giải thích về Asset-based DAG: "Bruin chạy assets theo dependency order,
  không phải theo thứ tự file" — HTML phát biểu đúng không?
□ Giải thích về Ingestr: "wrapper cho data movement tool, không cần viết connector code"
  — HTML phát biểu đúng không?
□ Giải thích về Variables: "start_date/end_date được set khi chạy bruin run,
  không hardcode trong file" — đúng không?
□ Giải thích về Incremental: "chỉ process data trong window, không full reload"
  — đúng không?
□ So sánh Bruin vs dbt: "Bruin có built-in ingestion (ingestr asset),
  dbt chỉ làm transformation" — đúng không? Verify với notes.

Liệt kê mọi claim kỹ thuật SAI trong HTML, kèm:
- Câu/đoạn sai trong HTML (line number nếu có)
- Giá trị đúng từ source code/repo
- Cách fix
```

---

## BƯỚC 4 — KIỂM TRA UX & COMPLETENESS

```
═══════════════════════════════
4.1 COMPLETENESS CHECK
═══════════════════════════════

□ File có đủ tất cả 9 sections có nội dung thực (không còn placeholder trống)?
□ Tổng số dòng hợp lý cho một module đầy đủ (ít nhất 1500 dòng)?
□ Không có section nào "quá mỏng" — ít hơn 50 dòng HTML?
□ Không có đoạn nào bị cắt giữa chừng (truncated mid-sentence)?
□ Tất cả code blocks có đóng tag đúng (</code>, </pre>)?
□ Tất cả tables có đóng tag đúng (</tr>, </td>, </table>)?

═══════════════════════════════
4.2 CONSISTENCY CHECK
═══════════════════════════════

□ Thuật ngữ nhất quán xuyên suốt:
  "Bruin" (không phải "bruin" lowercase ở chỗ không phải command)
  "Ingestr" hay "ingestr" — nhất quán hoặc giải thích abbrev
  "DuckDB" (không phải "duckdb" hay "Duck DB")
  "start_date" hay "start-date" — phân biệt variable name vs CLI flag
□ Asset type naming nhất quán: "SQL asset", "Python asset", "Ingestr asset"
□ Command format nhất quán: bruin run --asset vs bruin run -a — không trộn lẫn
□ Variable syntax nhất quán: {{ start_date }} dùng đúng format từ repo

═══════════════════════════════
4.3 UX CHECK
═══════════════════════════════

□ Quiz questions không bị lặp nhau giữa S1 và S2?
□ Practice tasks trong S3 có độ khó tăng dần thực sự không?
  (Task 1 < Task 2 < Task 3)
□ "Cố tình phá" kịch bản có thực sự hướng dẫn debug step-by-step không?
  (không chỉ liệt kê lỗi mà phải có "tìm log ở đâu, check gì trước")
□ Interview S7: câu Senior có đủ phức tạp không?
  (không phải câu Junior viết lại thành Senior bằng cách thêm chữ "design")
□ Checklist S8 items có actionable và verifiable không?
  (không phải "hiểu Bruin" — phải là "chứng minh được incremental không duplicate bằng row count")
□ Link Preview Module 06 có href="Module06_Batch_Processing.html" không?
□ 2 tabs setup S3 có thực sự song song và độc lập không?
  (người chỉ dùng Local không cần đọc Cloud tab và ngược lại)
```

---

## BƯỚC 5 — BÁO CÁO & FIX

```
Sau khi hoàn thành Bước 1-4, tạo báo cáo theo format sau:

═══════════════════════════════════════════════════════════
REVIEW REPORT — Module05_Data_Platforms.html
═══════════════════════════════════════════════════════════

TỔNG QUAN:
- Tổng số dòng file: ___
- Tổng số lỗi FAIL: ___
- Tổng số WARNING: ___
- Đánh giá tổng thể: [ ] Đạt — deploy được | [ ] Cần fix trước khi dùng

───────────────────────────────
NHÓM 1: LỖI KỸ THUẬT (phải fix ngay)
───────────────────────────────
Liệt kê từng FAIL từ Bước 1 và Bước 3:
[F01] [Loại lỗi] [Line number nếu có] [Mô tả] [Cách fix]
[F02] ...

───────────────────────────────
NHÓM 2: NỘI DUNG SAI/THIẾU (phải fix trước khi dùng)
───────────────────────────────
Liệt kê từng FAIL từ Bước 2 và fact-check Bước 3:
[C01] [Section] [Claim sai hoặc thiếu] [Giá trị đúng] [Cách fix]
[C02] ...

───────────────────────────────
NHÓM 3: WARNING (nên fix nhưng không block)
───────────────────────────────
[W01] [Section] [Vấn đề] [Đề xuất cải thiện]
[W02] ...

───────────────────────────────
NHÓM 4: PASSES TỐT (ghi nhận để không vô tình xóa khi fix)
───────────────────────────────
- Những section/component nào làm tốt, đúng spec
- Những insight kỹ thuật nào được giải thích tốt hơn cả spec yêu cầu

═══════════════════════════════════════════════════════════
SAU KHI BÁO CÁO: THỰC HIỆN FIX
═══════════════════════════════════════════════════════════

Thực hiện fix TẤT CẢ lỗi NHÓM 1 và NHÓM 2 ngay lập tức.
NHÓM 3 (WARNING): fix nếu không tốn quá 10 dòng code, skip nếu phức tạp.

Nguyên tắc khi fix:
- Chỉ sửa đúng chỗ bị lỗi, không rewrite section nguyên vẹn
- Với fact-check sai: lấy giá trị CHÍNH XÁC từ source code repo, không đoán
- Với JS function lỗi: test lại bằng cách trace call stack thủ công
- Sau mỗi fix: ghi "[FIXED F01]" vào báo cáo

Sau khi fix xong:
- Báo cáo số dòng trước và sau khi fix
- Liệt kê line number của từng thay đổi
- Xác nhận file mở được trên browser không lỗi console
```

---

> **Lưu ý cho Antigravity:**
> Bước 3 (Fact-check) là bước quan trọng nhất và dễ bỏ sót nhất.
> Claude hay "confabulate" — đặc biệt với Bruin vì đây là tool ít phổ biến hơn BigQuery/dbt.
> Bruin CLI flags, YAML field names, variable syntax — tất cả phải verify với source code repo,
> không tin vào memory. Nếu repo không có một feature nào đó, HTML không được nhắc đến feature đó.
