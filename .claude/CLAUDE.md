# DE-LEARNING Project Rules

## Project Context

Interactive HTML tutorial series for learning Data Engineering,
based on the **DataTalksClub data-engineering-zoomcamp** repository.

Target learner: Junior DE muốn đạt Senior DE
Commitment: 2–4 giờ/ngày | Timeline: 6–8 tháng
Reference roadmap: `master_de_roadmap.md`

---

## Folder Structure

```
DE-Learning/
├── .claude/
│   ├── CLAUDE.md              ← file này
│   ├── SOURCE_POLICY.md
│   ├── OUTPUT_STANDARD.md
│   ├── MEMORY.md
│   ├── REVIEW_CHECKLIST.md
│   └── README.md
├── data-engineering-zoomcamp/ ← source repo (READ-ONLY)
│   ├── 01-docker-terraform/
│   ├── 02-workflow-orchestration/
│   ├── 03-data-warehouse/
│   ├── 04-analytics-engineering/
│   ├── 05-data-platforms/
│   ├── 06-batch/
│   └── 07-streaming/
├── master_de_roadmap.md       ← master reference, đọc đầu tiên
├── file_mau_tham_khao_can_nang_cap.html ← UI/CSS/JS reference
├── Module01_Docker_Terraform.html
├── Module02_Orchestration.html
│   ...
└── Module07_Streaming.html
```

---

## Nguyên tắc cốt lõi

1. **Đọc code repo thực tế trước** — không viết content từ trí nhớ generic
2. **WHY trước HOW** — giải thích tại sao technology tồn tại trước khi dạy syntax
3. **3-Level system** — Beginner → Intermediate → Senior cho mọi concept
4. **Production thinking bắt buộc** — mọi module có failure scenarios, cost, monitoring
5. **Ví dụ từ repo thật** — trích code từ `data-engineering-zoomcamp/`, không dùng ví dụ generic
6. **7-bước learning flow** — Read → Run → Break → Debug → Explain → Improve → Document
7. **Logbook mindset** — khuyến khích learner ghi lỗi theo template trong `master_de_roadmap.md`

---

## Learner Profile

- Biết SQL cơ bản, chưa có kinh nghiệm DE thực chiến
- Junior DE muốn đạt Senior level
- Học tốt với: giải thích rõ → code thật → phá system → fix → ghi chép
- Cần structured progression, không phải notes rải rác
- Mục tiêu cuối: pass Senior DE interview + build portfolio xịn

---

## Default Output

Trừ khi có yêu cầu khác:
- Output: 1 file HTML duy nhất, standalone, inline CSS + JS
- Tên file: `ModuleXX_TopicName.html`
- Mở trực tiếp trên browser, không cần server
- Không tạo file phụ trừ khi được yêu cầu rõ

---

## Working Mode

Hệ thống handbook dài hạn — 7 module, mỗi file là một bài học hoàn chỉnh.
Mọi file phải feel như cùng một premium tutorial family.
Tối ưu cho: consistency, depth, practical value, portfolio quality.

Workflow: Claude Code build → Antigravity (Gemini Pro) review → patch nếu cần.
Viết content đủ sâu để vượt qua review đó ngay từ lần đầu.
