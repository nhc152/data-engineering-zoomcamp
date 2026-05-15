# PROMPT_Review_Module_08.md
# Review toàn diện file Module08_Cohorts_Projects_Assets.html

> Dùng cho: Antigravity review code sau khi Claude build xong 5 prompts.
> Mục tiêu: phát hiện lỗi kỹ thuật, nội dung sai, UX hỏng, thiếu sót so với spec.
> Cách chạy: paste toàn bộ prompt này vào Antigravity sau khi đã có `Module08_Cohorts_Projects_Assets.html`.

---

## BƯỚC 0 - ĐỌC FILE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ

Đọc TOÀN BỘ các file sau theo thứ tự:

1. `Module08_Cohorts_Projects_Assets.html` - file cần review.
2. `module_template.html` - chuẩn gốc về CSS/component.
3. `master_de_roadmap.html` - spec Module 08 nếu có.
4. `repo_notes_M08.md` - nguồn tổng hợp bắt buộc.
5. `projects/README.md`
6. `projects/datasets.md`
7. `cohorts/2022/README.md`
8. `cohorts/2023/README.md`
9. `cohorts/2024/README.md`
10. `cohorts/2025/README.md`
11. `cohorts/2026/README.md`
12. `cohorts/2026/project.md`
13. `cohorts/2025/02-workflow-orchestration/flows/01_getting_started_data_pipeline.yaml`
14. `cohorts/2025/02-workflow-orchestration/flows/04_gcp_kv.yaml`
15. `cohorts/2026/workshops/dlt/README.md`

KHÔNG bắt đầu review cho đến khi đã đọc xong tất cả file trên.
Mục đích: review phải đối chiếu HTML với source thực tế, không review bằng trí nhớ.

---

## BƯỚC 1 - KIỂM TRA KỸ THUẬT HTML/CSS/JS

Kiểm tra toàn bộ phần kỹ thuật của file. Với mỗi mục, ghi rõ `PASS / FAIL / WARNING` + mô tả cụ thể nếu không pass.

### 1.1 HTML Structure

- [ ] File có đúng `<!DOCTYPE html>` không?
- [ ] `<head>` có đủ charset UTF-8, viewport, title, Google Fonts?
- [ ] Title đúng: `Module 08 - Cohorts, Projects & Course Assets` hoặc biến thể rất gần, không sai module number.
- [ ] Tất cả 9 section div tồn tại: `id="s0"` đến `id="s8"`.
- [ ] Không còn placeholder `Đang xây dựng...`.
- [ ] Không có broken tag: thẻ mở không đóng, nested table/card sai.
- [ ] Code blocks dùng `<pre><code>` hoặc component tương đương và đóng tag đúng.

### 1.2 CSS Variables & Components

So sánh với `module_template.html`:

- [ ] CSS variables gốc tồn tại: color, surface, border, font, radius, shadow.
- [ ] Component classes có đủ:
  `.hero-banner`, `.sidebar`, `.nav-item`, `.section-content`, `.info-box`, `.quiz-block`, `.practice-task`, `.data-table`, `.code-block`, `.tab-container`, `.checklist-item`, `.badge`, `.progress-bar`.
- [ ] Không override CSS gây lỗi layout.
- [ ] Tables không tràn container.
- [ ] Sidebar và main content không overlap.
- [ ] Mobile/responsive không vỡ nghiêm trọng.

### 1.3 JavaScript Functions

Kiểm tra function tồn tại và hoạt động:

- [ ] `showModule(index)` - click S0-S8 hiển thị đúng section, nav active đúng.
- [ ] `toggleSection(id)` - dùng cho collapsibles/interview questions.
- [ ] `answerQuiz(questionId, answer, correct)` - click đáp án hiển thị đúng/sai + explanation.
- [ ] `toggleSolution(taskId)` - show/hide solution trong practice tasks.
- [ ] `switchTab(group, name)` - tab cohort/project/assets chuyển đúng.
- [ ] `toggleCheck(itemId)` - checklist tick/untick.
- [ ] `updateProgress()` - progress bar S8 cập nhật sau mỗi tick.
- [ ] Không có console error khi mở file.

### 1.4 Navigation

- [ ] Sidebar đủ 9 nav items đúng tên:
  - S0: Tổng quan & Mục tiêu
  - S1: Bản đồ repo phụ trợ
  - S2: Cohorts qua các năm
  - S3: Homework & Workshops
  - S4: Final Project
  - S5: Course Assets
  - S6: Cách học & Lộ trình
  - S7: Review Checklist
  - S8: Tổng kết & Portfolio
- [ ] S0 active mặc định.
- [ ] Không nav item nào click ra màn hình trắng.

---

## BƯỚC 2 - KIỂM TRA NỘI DUNG TỪNG SECTION

Format báo cáo: `PASS | WARNING | FAIL`.

### S0 - Tổng quan & Mục tiêu

- [ ] Có hero title đúng Module 08.
- [ ] Có bảng 9 sections với thời gian ước tính.
- [ ] Nói rõ Module 08 là meta/support module, không phải module kỹ thuật lõi như 01-07.
- [ ] Có giải thích vai trò `cohorts/`, `projects/`, `images/`.
- [ ] Có scope: cohorts 2022-2026, final project docs, image assets.
- [ ] Có ASCII overview map README -> cohorts/projects/images.
- [ ] Có exit criteria cụ thể, actionable.

### S1 - Bản đồ repo phụ trợ

- [ ] Có giải thích `cohorts/` theo năm 2022-2026.
- [ ] Có phân biệt week-based vs module-based structure.
- [ ] Có giải thích `projects/README.md` và `projects/datasets.md`.
- [ ] Có nói NYC taxi dataset không được dùng cho final project nếu source docs nói vậy.
- [ ] Có giải thích `images/` root assets, architecture assets, AWS image.
- [ ] Có quiz scenario-based cho từng phần.
- [ ] Không bịa logic/code cho image assets.

### S2 - Cohorts qua các năm

- [ ] Có tree diagram cấp cao của `cohorts/`.
- [ ] Có timeline/matrix 2022-2026.
- [ ] 2022 mô tả đúng week folders và Airflow examples.
- [ ] 2023 mô tả đúng week folders, leaderboard, project, streaming Confluent/Spark files.
- [ ] 2024 mô tả đúng module folders, dlt/RisingWave workshops, leaderboard.
- [ ] 2025 mô tả đúng module folders, Kestra flows, dlt workshop, notebooks.
- [ ] 2026 mô tả đúng latest cohort, module 05 data platforms, updated dlt workshop.
- [ ] Có decision guide nên đọc cohort nào khi nào.
- [ ] Có warning không gộp homework cùng tên khác năm.

### S3 - Homework & Workshops

- [ ] Có inventory homework theo năm/module.
- [ ] Có nhóm homework theo chủ đề.
- [ ] Có workshop map: Piperider, dlt, RisingWave, current dlt.
- [ ] Có code/config mini deep-dive cho Airflow 2022, streaming 2023, Kestra 2025, DLT 2025/2026.
- [ ] Có ít nhất 5 practice tasks có hint + solution.
- [ ] Có lỗi học tập/cố tình phá liên quan đọc cohort sai context.
- [ ] Không khẳng định sai rằng homework ở các năm giống nhau hoàn toàn.

### S4 - Final Project

- [ ] Có phân tích `projects/README.md`.
- [ ] Có goal, requirements, rubric, peer review, submission rules.
- [ ] Có portfolio guidance và tips.
- [ ] Có plagiarism/reuse policy.
- [ ] Có phân tích `projects/datasets.md`.
- [ ] Có nói rõ dataset nào không được dùng theo docs.
- [ ] Có project architecture template.
- [ ] Có rubric self-check table.
- [ ] Có project anti-patterns.
- [ ] Có quiz về final project.

### S5 - Course Assets

- [ ] Có asset inventory table.
- [ ] Có đầy đủ architecture images:
  - `images/architecture/arch_v3_workshops.jpg`
  - `images/architecture/arch_v4_workshops.jpg`
  - `images/architecture/arch_v5_workshops.png`
  - `images/architecture/photo1700757552.jpeg`
- [ ] Có đầy đủ root tool assets:
  - `images/bruin.svg`
  - `images/dlthub.png`
  - `images/kestra.svg`
  - `images/mage.svg`
  - `images/piperider.png`
  - `images/rising-wave.png`
- [ ] Có `images/aws/iam.png`.
- [ ] Không copy binary content.
- [ ] Nếu có thumbnail, path không broken.
- [ ] Có alt text hoặc mô tả vai trò ảnh.

### S6 - Cách học & Lộ trình

- [ ] Có learning strategy.
- [ ] Có 4 lộ trình: Beginner, Deep repo, Portfolio, Senior review.
- [ ] Có study plan 14 ngày.
- [ ] Có decision tree.
- [ ] Có Senior DE perspective.
- [ ] Có ít nhất 8 scenario cards.
- [ ] Không khuyến nghị học cohorts cũ như source chính nếu cohort mới hơn đã thay thế.

### S7 - Review Checklist

- [ ] Có cohort navigation review.
- [ ] Có final project review.
- [ ] Có asset review.
- [ ] Có 15 project defense/interview questions.
- [ ] Mỗi câu có answer guide.
- [ ] Mỗi câu có evidence cần chỉ trong repo/project.
- [ ] Mỗi câu có red flag.

### S8 - Tổng kết & Portfolio

- [ ] Có progress bar với `checklist-progress-fill` và `checklist-progress-text`.
- [ ] Có 28 checklist items chia 4 nhóm 7/7/7/7.
- [ ] Có summary grid 8 điểm chốt.
- [ ] Có file mapping.
- [ ] Có Definition of Done.
- [ ] Preview sau module không dùng link hỏng.

---

## BƯỚC 3 - FACT-CHECK NỘI DUNG

Đối chiếu từng claim quan trọng trong HTML với source repo hoặc `repo_notes_M08.md`.

### 3.1 Folder Scope Accuracy

- [ ] Module 08 chỉ claim về `cohorts/`, `projects/`, `images/`.
- [ ] Không gọi `images/` là module học kỹ thuật.
- [ ] Không nói `projects/` chứa project source code của học viên; nó là docs/rubric/datasets guidance.
- [ ] Không nói `cohorts/` thay thế module root 01-07; nó là cohort history/homework/workshop archive.

### 3.2 Cohorts Accuracy

- [ ] Cohorts tồn tại đúng: 2022, 2023, 2024, 2025, 2026.
- [ ] 2022 có week folders đúng và Airflow examples trong week 2/3.
- [ ] 2023 có `leaderboard.md`, `project.md`, `week_6_stream_processing` files.
- [ ] 2024 có `leaderboard.md`, dlt/RisingWave workshops.
- [ ] 2025 có Kestra flows trong `02-workflow-orchestration/flows`.
- [ ] 2026 có `05-data-platforms` và `07-streaming`.
- [ ] Không bịa cohort 2027 hoặc module không tồn tại.
- [ ] Mọi path nêu trong HTML tồn tại trong repo hoặc trong `repo_notes_M08.md`.

### 3.3 Project Docs Accuracy

- [ ] `projects/README.md` được mô tả là final project guidance.
- [ ] `projects/datasets.md` được mô tả là dataset suggestions.
- [ ] Claim về NYC taxi dataset không được dùng cho project khớp docs.
- [ ] Peer review/rubric/submission claims khớp `projects/README.md`.
- [ ] Không bịa rubric điểm số nếu không có trong source.
- [ ] Không hứa project sẽ được featured/accepted nếu docs chỉ nói có thể.

### 3.4 Assets Accuracy

- [ ] Tất cả image paths đúng.
- [ ] `README.md` overview image nếu nêu phải khớp actual path.
- [ ] Không nói SVG/PNG chứa logic/code.
- [ ] Không copy binary data vào HTML.
- [ ] Nếu HTML nhúng ảnh, relative path đúng từ file root HTML.
- [ ] Không dùng external image thay cho local asset nếu prompt yêu cầu local.

### 3.5 Concept Accuracy

- [ ] Module 08 được trình bày là meta module/course wrapper.
- [ ] Cohort cũ được mô tả là historical/reference, không mặc định là latest.
- [ ] Final project được mô tả là end-to-end application of modules, không chỉ một homework.
- [ ] Dataset selection có nhắc legal/PII/reproducibility risk nếu có advice.
- [ ] Portfolio advice không thay thế rubric bắt buộc.

Liệt kê mọi claim sai với:
- Line number nếu có.
- Claim sai trong HTML.
- Giá trị đúng từ repo/source.
- Cách fix.

---

## BƯỚC 4 - UX & COMPLETENESS

### 4.1 Completeness

- [ ] File có ít nhất 1200 dòng hoặc đủ sâu tương đương.
- [ ] Không section nào quá mỏng dưới 50 dòng HTML.
- [ ] Không đoạn nào bị cắt giữa chừng.
- [ ] Tất cả tab groups có content cho từng tab.
- [ ] Tất cả quiz có explanation.
- [ ] Tất cả practice tasks có solution.
- [ ] Tất cả defense questions có red flag/evidence.
- [ ] Checklist progress hoạt động.

### 4.2 Consistency

- [ ] Dùng nhất quán `Module 08`, không copy sót Module 07/06.
- [ ] Dùng nhất quán `Cohorts, Projects & Course Assets`.
- [ ] File đích luôn là `Module08_Cohorts_Projects_Assets.html`.
- [ ] Output notes reference luôn là `repo_notes_M08.md`.
- [ ] Không còn `repo_notes_cohorts.md`.
- [ ] Không còn text `Đang xây dựng...`.

### 4.3 UX

- [ ] Nội dung không quá dàn trải như file inventory thuần túy; có decision guide/actionable flow.
- [ ] Tables đủ ngắn để đọc được, không tràn layout.
- [ ] Asset thumbnails không làm vỡ layout.
- [ ] Cards không nested quá sâu.
- [ ] Quiz/practice không lặp câu vô nghĩa.
- [ ] Project rubric section đủ thực dụng để self-review.
- [ ] Link/path preview không hỏng.

---

## BƯỚC 5 - BÁO CÁO & FIX

Sau khi hoàn thành Bước 1-4, tạo báo cáo theo format:

```text
REVIEW REPORT - Module08_Cohorts_Projects_Assets.html

TỔNG QUAN:
- Tổng số dòng file: ___
- Tổng số lỗi FAIL: ___
- Tổng số WARNING: ___
- Đánh giá tổng thể: [ ] Đạt - dùng được | [ ] Cần fix trước khi dùng

NHÓM 1: LỖI KỸ THUẬT (phải fix ngay)
[F01] [Line] [Mô tả] [Cách fix]

NHÓM 2: NỘI DUNG SAI/THIẾU (phải fix trước khi dùng)
[C01] [Section] [Claim sai/thiếu] [Giá trị đúng từ repo] [Cách fix]

NHÓM 3: WARNING (nên fix)
[W01] [Section] [Vấn đề] [Đề xuất]

NHÓM 4: PASSES TỐT
- Những phần đúng spec, đáng giữ lại.
```

SAU KHI BÁO CÁO: thực hiện fix tất cả lỗi nhóm 1 và nhóm 2 ngay.

Nguyên tắc fix:
- Chỉ sửa đúng chỗ lỗi, không rewrite toàn bộ section nếu không cần.
- Với fact-check sai, lấy giá trị chính xác từ source repo hoặc `repo_notes_M08.md`.
- Với JS lỗi, test lại bằng trace manual từng function.
- Với image path lỗi, sửa relative path theo vị trí file HTML ở repo root.
- Sau mỗi fix, ghi `[FIXED Fxx]` hoặc `[FIXED Cxx]` vào báo cáo.

Sau khi fix xong:
- Báo cáo số dòng trước/sau.
- Liệt kê file/line đã sửa.
- Xác nhận không còn placeholder.
- Xác nhận browser không có console error.

---

Lưu ý cho Antigravity:
- Bước 3 là quan trọng nhất. Claude dễ biến Module 08 thành module kỹ thuật mới, trong khi đây là meta module.
- Đặc biệt kiểm tra kỹ:
  - `cohorts/` là archive/history/homework/workshop.
  - `projects/` chỉ có docs/datasets guidance.
  - `images/` là static assets.
  - Latest cohort trong repo hiện là 2026.
  - Không copy sót `repo_notes_cohorts.md`.
  - Không bịa file ảnh hoặc cohort không tồn tại.
