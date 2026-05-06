# Output Standard

## Ngôn ngữ

- Giải thích: tiếng Việt
- Thuật ngữ kỹ thuật: giữ nguyên tiếng Anh
  (Docker, Terraform, Kafka, Spark, dbt, Airflow, Kestra, BigQuery,
  Python, SQL, GCP, AWS, API, ETL/ELT, pipeline, container, DAG, cluster...)
- UI labels: tiếng Việt
- Code comments: tiếng Anh (giữ đúng repo gốc)

---

## Tone & Style

Mentor-like — như người đi trước giải thích cho đồng nghiệp mới vào nghề.

Ưu tiên:
- Giải thích WHY trước HOW
- Ví dụ cụ thể từ code repo, không generic
- So sánh alternatives + trade-offs rõ ràng
- Kết nối concept với production reality
- Câu ngắn, rõ nghĩa

Tránh:
- Định nghĩa khô khan kiểu textbook
- Lý thuyết không ví dụ
- Oversimplify mất depth
- Buzzwords không cần thiết

---

## HTML Structure (giữ nguyên từ file mẫu)

File là standalone HTML, self-contained, inline CSS + JS.
Copy CSS variables và component patterns từ `file_mau_tham_khao_can_nang_cap.html`.

```
Layout:
  Hero banner (tên module, badges, mô tả ngắn)
  ↓
  Sidebar navigation (8 nav-items, dùng .nav-item + .active class)
  ↓
  Main content area (hiển thị section theo showModule())
```

CSS variables phải giữ nguyên từ file mẫu:
`--bg`, `--surface`, `--surface2`, `--border`, `--text`, `--text-muted`,
`--accent` (blue), `--accent2` (green), `--accent3` (red/danger),
`--accent4` (purple), `--accent5` (orange), `--code-bg`

---

## 8-Section Structure (bắt buộc đúng thứ tự)

### S0 — Tổng quan & Mục tiêu
**Nội dung:**
- Bảng mini roadmap: 8 sections + thời gian ước tính mỗi section
- Vấn đề thực tế mà technology này giải quyết (không phải định nghĩa)
- "Trước khi có [TECH], người ta làm thế nào?" — contextualize lý do tồn tại
- Data flow diagram dạng ASCII/HTML: source → transform → destination
- Exit criteria: "Bạn đã nắm module này khi tự trả lời được..."

**Độ dài:** Ngắn, orientation, không đi sâu vào concept

---

### S1 — Lý thuyết nền
**Nội dung:**
- Các concept cốt lõi — giải thích đơn giản trước, sâu dần theo 3 levels
- Analogy/metaphor để dễ nhớ (VD: Docker như shipping container)
- Mental model: 1–2 câu tóm tắt cách nghĩ về technology
- So sánh với alternatives + bảng trade-offs
- Info boxes: `.info-box.tip`, `.info-box.warn`, `.info-box.note`, `.info-box.danger`
- Quiz: 6–8 câu, scenario-based, có explanation

**Depth target:** Đủ để learner giải thích được cho người khác

---

### S2 — Đọc hiểu code trong repo
**Nội dung:**
- Cấu trúc thư mục với giải thích từng folder/file
- Giải thích từng file quan trọng: mục đích + cấu trúc + điểm cần chú ý
- Data flow: "File A gọi → File B → kết quả C"
- Config files (docker-compose, .tf, .yaml): giải thích từng block/section
- Code examples trích NGUYÊN VĂN từ repo, có syntax highlighting
- Multi-language tabs khi cần: `switchTab()` giữa Python / Bash / SQL / HCL / YAML
- Quiz: hiểu data flow, ai gọi ai

**Quan trọng:** Chỉ dùng code thực tế từ repo, không viết code minh họa khác

---

### S3 — Thực hành từng bước
**Nội dung:**
- Setup môi trường: commands thực tế, copy-paste được
- Verify thành công: "Bạn biết đã chạy đúng khi thấy..."
- 3 bài tập tăng dần (dùng `.practice-task`):
  - Task 1 (Beginner): follow tutorial, chạy lại
  - Task 2 (Intermediate): thay đổi một phần, tự cấu hình
  - Task 3 (Advanced): thêm tính năng, áp dụng vào context mới
  - Mỗi task: đề bài → gợi ý → `toggleSolution()` button
- "Cố tình phá" section: 5 kịch bản break system + cách debug
  (Lấy gợi ý từ phần Break/Debug trong `master_de_roadmap.md`)

---

### S4 — Production Thinking
**Nội dung:** 6 câu hỏi bắt buộc, mỗi câu có answer chi tiết + code example nếu có

1. **Failure:** Nếu fail lúc 3h sáng → debug từ đâu? Check log nào?
2. **Scale:** Nếu data volume x100 → bottleneck ở đâu? Thay đổi gì?
3. **Idempotency:** Chạy lại 2 lần có safe không? Duplicate data không?
4. **Monitoring:** Biết pipeline healthy qua metric nào? Alert thế nào?
5. **Cost:** Tốn bao nhiêu tiền? Tối ưu được gì? Cách estimate?
6. **Security:** Credential xử lý đúng chưa? Có secret hardcode không?

*Lấy "Senior Questions" từ `master_de_roadmap.md` section module tương ứng*

---

### S5 — Kiến thức nâng cao
**Nội dung:**
- Concepts cần cho Senior nhưng không có đủ trong Zoomcamp
- Best practices từ industry production
- Pro-tier patterns từ `master_de_roadmap.md` (multi-stage builds, remote state, slim CI...)
- Trade-off table: khi nào DÙNG vs KHÔNG DÙNG tool này
  (Lấy từ section "Decision Making" trong `master_de_roadmap.md`)
- Khi nào outgrow tool này, dùng gì thay thế và tại sao

---

### S6 — Lỗi thường gặp
**Nội dung:**
- Bảng: Lỗi | Nguyên nhân | Cách fix | Cách phòng tránh
- Tối thiểu 8–10 lỗi phổ biến nhất của technology này
- Error messages thực tế (copy từ terminal, không viết lại)
- Debugging checklist theo thứ tự ưu tiên
- Logbook template nhắc nhở learner ghi chép theo format trong `master_de_roadmap.md`

*Lấy gợi ý từ "Incident Simulation" table trong `master_de_roadmap.md`*

---

### S7 — Interview Prep
**Nội dung:**
- 12 câu hỏi chia 3 level (dùng badge màu phân biệt):
  - **Junior** (4 câu): concept, definition, basic usage
  - **Mid** (4 câu): trade-offs, khi nào dùng gì, so sánh tools
  - **Senior** (4 câu): system design, production issues, optimize, failure handling
- Click để xem gợi ý trả lời chi tiết (toggleSection hoặc quiz-explain pattern)
- "Red flags": những gì interviewer KHÔNG muốn nghe
- STAR framework gợi ý: cách kể project trong phỏng vấn
  (Lấy từ "Interview Mapping" trong `master_de_roadmap.md`)

---

### S8 — Checklist & Tổng kết
**Nội dung:**
- Progress bar tự động update khi tick
- Checklist 15–20 items theo 3 level:
  - Beginner (5–6 items): chạy được, hiểu cơ bản
  - Intermediate (5–6 items): tự build, debug được
  - Senior (5–8 items): production thinking, optimize, explain được
- Summary grid (`.summary-grid`): 4–6 điểm chốt quan trọng nhất
- Definition of Done: "Chuyển sang module tiếp theo khi..."
  (Dựa trên DoD trong `master_de_roadmap.md`)
- Bước tiếp theo: module nào, prereq gì cần chuẩn bị

---

## JavaScript Functions (bắt buộc implement đầy đủ)

```javascript
showModule(index, navItem)      // sidebar navigation, update .active class
toggleSection(header)           // collapse/expand .section-content
answerQuiz(el, isCorrect, msg)  // quiz: add .correct/.wrong, show .quiz-explain
toggleSolution(btn)             // show/hide .solution-box
switchTab(groupId, tabId)       // multi-language code tabs
toggleCheck(box)                // checklist tick/untick
updateProgress()                // recalculate và update progress bar width + text
```

---

## Component Patterns (copy từ file mẫu)

**Code block:**
```html
<div class="cmd-block">
  <div class="cmd-header">
    <span>● ● ●</span>
    <span>context-label.sh</span>
  </div>
  <pre>code here với <span class="kw2">keyword</span> và <span class="str">"string"</span></pre>
</div>
```

**Info box:**
```html
<div class="info-box tip">💡 <strong>Tip:</strong> nội dung</div>
<div class="info-box warn">⚠️ <strong>Cảnh báo:</strong> nội dung</div>
<div class="info-box note">📌 <strong>Lưu ý:</strong> nội dung</div>
<div class="info-box danger">🔥 <strong>Nguy hiểm:</strong> nội dung</div>
```

**Quiz item:**
```html
<div class="quiz-item">
  <div class="quiz-q">Câu hỏi?</div>
  <div class="quiz-opts">
    <div class="quiz-opt" onclick="answerQuiz(this, false, 'Giải thích sai')">A. Option</div>
    <div class="quiz-opt" onclick="answerQuiz(this, true, 'Giải thích đúng')">B. Option</div>
  </div>
  <div class="quiz-explain"></div>
</div>
```

**Practice task:**
```html
<div class="practice-task">
  <div class="practice-task-header">🔧 Task X — Tên task</div>
  <div style="padding:16px">
    <p>Đề bài...</p>
    <button class="solution-toggle" onclick="toggleSolution(this)">👁 Xem lời giải</button>
    <div class="solution-box">Lời giải...</div>
  </div>
</div>
```

---

## SQL Policy

### Quy tắc chung
- Luôn dùng tab buttons để phân biệt database (KHÔNG dùng plain heading)
- Giải thích ngắn sự khác biệt syntax bằng tiếng Việt ngay dưới tab

### Tab theo từng module

| Module | Tab hiển thị | Lý do |
|---|---|---|
| M01 — Docker + Terraform | PostgreSQL | DB chỉ là demo tool, không cần so sánh |
| M02 — Orchestration | PostgreSQL | Tương tự M01 |
| M03 — Data Warehouse | BigQuery · PostgreSQL · Oracle | SQL là nội dung chính, enterprise DWH thường dùng Oracle |
| M04 — Analytics Eng (dbt) | BigQuery · PostgreSQL · Oracle | dbt support cả 3 adapter, syntax Jinja khác nhau theo DB |
| M05 — Data Platforms | BigQuery | Platform-level, không focus SQL syntax |
| M06 — Spark | PySpark · SQL (Spark SQL) | Spark có Spark SQL riêng |
| M07 — Streaming | Không có SQL tab | Streaming không dùng SQL trực tiếp |

### Oracle — khi nào và cách thêm

Thêm Oracle tab vào **M03 và M04** vì:
- Enterprise data stack thực tế vẫn dùng Oracle rất nhiều (banking, insurance, telco)
- DE thường phải ingest data từ Oracle source vào DWH
- dbt có Oracle adapter, syntax Jinja có điểm khác biệt cần biết

Cách render Oracle tab:
```html
<div class="tab-group" id="sql-example-1">
  <div class="tab-buttons">
    <button class="tab-btn active" onclick="switchTab('sql-example-1', 'bq')">BigQuery</button>
    <button class="tab-btn" onclick="switchTab('sql-example-1', 'pg')">PostgreSQL</button>
    <button class="tab-btn" onclick="switchTab('sql-example-1', 'ora')">Oracle</button>
  </div>
  <div class="tab-content active" id="sql-example-1-bq">
    <!-- BigQuery SQL -->
  </div>
  <div class="tab-content" id="sql-example-1-pg">
    <!-- PostgreSQL SQL -->
  </div>
  <div class="tab-content" id="sql-example-1-ora">
    <!-- Oracle SQL -->
  </div>
</div>
<p class="tab-note">⚠️ Oracle dùng ROWNUM thay vì LIMIT, DATE format khác, sequence thay vì AUTO_INCREMENT.</p>
```

Những điểm khác biệt Oracle cần giải thích trong M03-M04:
- `LIMIT` → `ROWNUM` hoặc `FETCH FIRST N ROWS ONLY` (12c+)
- `AUTO_INCREMENT` → `SEQUENCE` + `TRIGGER`
- `BOOLEAN` không tồn tại → dùng `NUMBER(1)` hoặc `CHAR(1)`
- String concat: `||` thay vì `CONCAT()` (hoặc dùng cả hai)
- `NOW()` → `SYSDATE` hoặc `CURRENT_TIMESTAMP`
- Schema = User trong Oracle (khác với PostgreSQL/BigQuery)

---

## Consistency Rule

Mọi file ModuleXX phải feel như cùng family với `file_mau_tham_khao_can_nang_cap.html`:
- Cùng dark theme + CSS color variables
- Cùng component patterns (section, quiz, code block, info-box)
- Cùng sidebar navigation behavior
- Cùng Vietnamese mentor tone
- Cùng 3-level depth (Beginner → Intermediate → Senior)
