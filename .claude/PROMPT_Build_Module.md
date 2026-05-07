# PROMPT — Build Module HTML Tutorial

> Dùng file này làm template prompt cho Claude Code CLI.
> Thay [MODULE_FOLDER], [MODULE_NUM], [MODULE_NAME], [TECH_STACK] trước khi chạy.
> Chạy từ thư mục gốc DE-Learning/

---

## Cách chạy

```bash
# Từ thư mục DE-Learning/
claude "$(cat .claude/PROMPT_Build_Module.md)" \
  --context "MODULE=01, TECH=Docker + Terraform"
```

Hoặc paste thẳng nội dung dưới vào Claude Code CLI.

---

## PROMPT NỘI DUNG

```
Bạn là Senior Data Engineer đang viết tài liệu học cho đồng nghiệp Junior.

=== BƯỚC 1: ĐỌC SOURCE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ ===

Đọc theo thứ tự:
1. master_de_roadmap.md — section "Module [MODULE_NUM]" để nắm scope và depth
2. data-engineering-zoomcamp/[MODULE_FOLDER]/ — ĐỌC TOÀN BỘ:
   - README.md
   - Tất cả file config: docker-compose.yaml, *.tf, *.yaml, .env.example
   - Tất cả scripts: *.py, *.sh, *.sql
   - Ghi chú: file nào là entry point, data flow là gì
3. module_template.html — lấy CSS variables, JS functions, component HTML patterns
4. .claude/OUTPUT_STANDARD.md — đọc toàn bộ trước khi bắt đầu viết

=== BƯỚC 2: XÂY DỰNG FILE ===

Tạo file: Module[MODULE_NUM]_[MODULE_NAME].html

File phải là standalone HTML, self-contained, inline CSS + JS.
Copy TOÀN BỘ CSS variables và component styles từ module_template.html.
Không bỏ qua bất kỳ section nào. Không viết placeholder "sẽ bổ sung sau".

=== CẤU TRÚC 8 SECTIONS (sidebar navigation) ===

S0 — Tổng quan & Mục tiêu
  - Bảng mini roadmap 8 sections + thời gian ước tính
  - Vấn đề thực tế [TECH_STACK] giải quyết
  - "Trước khi có [TECH_STACK], người ta làm gì?" — bối cảnh tại sao nó tồn tại
  - Data flow diagram (ASCII/HTML): nguồn → xử lý → đích
  - Exit criteria: "Bạn đã nắm module khi tự trả lời được..."

S1 — Lý thuyết nền
  - Concept cốt lõi theo 3 levels: Beginner → Intermediate → Senior
  - Analogy/metaphor giúp dễ nhớ
  - Mental model: 1-2 câu mô tả cách nghĩ về technology
  - So sánh với alternatives + bảng trade-offs
  - Info boxes: tip / warn / note / danger
  - 6-8 câu quiz scenario-based với explanation

S2 — Đọc hiểu code trong repo
  - Cấu trúc thư mục [MODULE_FOLDER] với giải thích từng file
  - Giải thích CHI TIẾT từng file quan trọng: mục đích, cấu trúc, điểm cần chú ý
  - Data flow diagram: file A → file B → output C
  - Config files: giải thích TỪNG block/section (không bỏ qua)
  - Code snippets TRÍCH NGUYÊN VĂN từ repo (không viết lại)
  - Multi-language tabs: Python / Bash / SQL / HCL / YAML tùy module
  - Quiz: hiểu data flow, ai gọi ai

S3 — Thực hành từng bước
  - Setup môi trường: commands thực tế, copy-paste được, verify thành công
  - 3 bài tập tăng dần (Task Beginner / Intermediate / Advanced)
    Mỗi task: đề bài → gợi ý → nút "Xem lời giải" (toggleSolution)
  - "Cố tình phá" section: 5 kịch bản break system cụ thể + bước debug từng bước

S4 — Production Thinking
  Trả lời ĐẦY ĐỦ 6 câu hỏi (lấy từ "Senior Questions" trong master_de_roadmap.md):
  1. Failure: fail lúc 3h sáng → debug từ đâu? Log ở đâu?
  2. Scale: data x100 → bottleneck ở đâu? Cần thay đổi gì?
  3. Idempotency: chạy lại 2 lần có safe không? Duplicate data không?
  4. Monitoring: biết pipeline healthy qua metric nào? Alert thế nào?
  5. Cost: tốn bao nhiêu? Tối ưu được gì? Cách estimate trước khi deploy?
  6. Security: credential lưu đúng chưa? Có secret hardcode không?
  Mỗi câu: answer chi tiết + code example nếu áp dụng được

S5 — Kiến thức nâng cao
  - Pro-tier patterns từ master_de_roadmap.md (section "Pro-tier patterns" của module)
  - Best practices production không có trong Zoomcamp repo
  - Trade-off table: khi NÊN và KHÔNG NÊN dùng [TECH_STACK]
    (lấy từ section "Decision Making" trong master_de_roadmap.md)
  - Khi nào outgrow tool này → dùng gì thay thế?

S6 — Lỗi thường gặp
  - Bảng: Lỗi | Nguyên nhân | Cách fix | Cách phòng tránh
  - Tối thiểu 8 lỗi, ưu tiên lỗi thực tế từ code trong repo
  - Error messages thực tế từ terminal (copy nguyên văn)
  - Debugging checklist theo thứ tự ưu tiên (check gì trước, check gì sau)
  - Nhắc learner ghi Logbook theo template trong master_de_roadmap.md

S7 — Interview Prep
  - 12 câu hỏi chia 3 level (badge màu khác nhau):
    Junior (4): concept, definition, basic usage
    Mid (4): trade-offs, khi nào dùng gì, so sánh
    Senior (4): system design, production issues, failure handling, optimize
  - Mỗi câu: click expand để xem gợi ý trả lời chi tiết
  - "Red flags": 3-5 điều interviewer KHÔNG muốn nghe
  - STAR framework gợi ý: cách kể project liên quan module này

S8 — Checklist & Tổng kết
  - Progress bar tự update
  - Checklist 15-20 items theo 3 level (Beginner / Intermediate / Senior)
  - Summary grid: 4-6 điểm chốt quan trọng nhất của module
  - Definition of Done (từ master_de_roadmap.md): tick đủ thì được sang module mới
  - Preview module tiếp theo: cần chuẩn bị gì?

=== JAVASCRIPT BẮT BUỘC ===

Implement đầy đủ, không bỏ sót:
  showModule(index, navItem)     — sidebar nav, update .active
  toggleSection(header)         — collapse/expand section
  answerQuiz(el, isCorrect, msg) — quiz feedback + explanation
  toggleSolution(btn)           — show/hide lời giải
  switchTab(groupId, tabId)     — multi-language tabs
  toggleCheck(box)              — checklist
  updateProgress()              — progress bar

=== CHẤT LƯỢNG BẮT BUỘC ===

- Không có placeholder hoặc "TODO: bổ sung sau"
- Không có section rỗng hoặc viết lướt
- Mọi code example phải trích từ repo thực tế, không viết minh họa generic
- Mọi concept phải có ví dụ áp dụng vào [TECH_STACK] trong context DE pipeline
- File phải mở được trực tiếp trên browser và fully functional

=== OUTPUT ===

Tên file: Module[MODULE_NUM]_[MODULE_NAME].html
Lưu tại: DE-Learning/ (cùng cấp với master_de_roadmap.md)
```

---

## Biến thế cho từng module

| Module | MODULE_FOLDER | MODULE_NUM | MODULE_NAME | TECH_STACK |
|---|---|---|---|---|
| 1 | 01-docker-terraform | 01 | Docker_Terraform | Docker + Terraform |
| 2 | 02-workflow-orchestration | 02 | Orchestration | Kestra / Airflow |
| 3 | 03-data-warehouse | 03 | Data_Warehouse | BigQuery |
| 4 | 04-analytics-engineering | 04 | Analytics_Engineering | dbt |
| 5 | 05-data-platforms | 05 | Data_Platforms | Bruin |
| 6 | 06-batch | 06 | Batch_Processing | Apache Spark |
| 7 | 07-streaming | 07 | Streaming | Kafka + Flink |
