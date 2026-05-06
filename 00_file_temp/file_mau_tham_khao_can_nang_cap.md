### 1. JavaScript Functions
```javascript
function showModule(idx, el) {
  modules.forEach(m => m.classList.remove('active'));
  navItems.forEach(n => n.classList.remove('active'));
  modules[idx].classList.add('active');
  if (el) el.classList.add('active');
  else if (navItems[idx]) navItems[idx].classList.add('active');
  window.scrollTo(0,0);
}
function goNext(idx) {
  const nextIdx = Math.min(idx + 1, modules.length - 1);
  showModule(nextIdx, navItems[nextIdx]);
}
function goPrev(idx) {
  const prevIdx = Math.max(idx - 1, 0);
  showModule(prevIdx, navItems[prevIdx]);
}
function toggleSection(header) {
  const content = header.nextElementSibling;
  const toggle  = header.querySelector('.section-toggle');
  const isHidden = content.style.display === 'none';
  content.style.display = isHidden ? 'block' : 'none';
  toggle.textContent = isHidden ? '▼' : '▶';
}
function answerQuiz(el, correct, explanation) {
  const item   = el.closest('.quiz-item');
  const opts   = item.querySelectorAll('.quiz-opt');
  const explain = item.querySelector('.quiz-explain');
  opts.forEach(o => o.style.pointerEvents = 'none');
  el.classList.add(correct ? 'correct' : 'wrong');
  if (!correct) {
    opts.forEach(o => {
      if (o.getAttribute('onclick') && o.getAttribute('onclick').includes('true'))
        o.classList.add('correct');
    });
  }
  explain.textContent = (correct ? '✓ Chính xác! ' : '✗ Sai. ') + explanation;
  explain.classList.add('show');
}
function toggleSolution(btn) {
  const box  = btn.nextElementSibling;
  const show = box.classList.toggle('show');
  btn.textContent = show ? '🔼 Ẩn lời giải' : '💡 Xem lời giải';
}
function switchTab(groupId, tabId) {
  const group = document.getElementById(groupId);
  if (!group) return;
  group.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  const clicked = group.querySelector(`[onclick*="${tabId}"]`);
  if (clicked) clicked.classList.add('active');
  group.parentElement.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  const target = document.getElementById(tabId);
  if (target) target.classList.add('active');
}
function gradeFinalTest() {
  const questions = document.querySelectorAll('#final-test .test-question');
  const result    = document.getElementById('final-test-result');
  let correct = 0, answered = 0;
  const wrong = [], unanswered = [];

  questions.forEach(q => {
    const qNum    = q.dataset.q;
    const ans     = q.dataset.correct;
    const sel     = q.querySelector(`input[name="q${qNum}"]:checked`);
    q.classList.remove('correct','wrong','unanswered');
    if (!sel) { q.classList.add('unanswered'); unanswered.push(qNum); return; }
    answered++;
    if (sel.value === ans) { q.classList.add('correct'); correct++; }
    else { q.classList.add('wrong'); wrong.push({q:qNum, selected:sel.value, correct:ans}); }
  });

  const total = questions.length;
  const pct   = Math.round(correct/total*100);
  let level='', chip='warn', guide='';
  if (correct>=9)      { level='Xuất sắc'; chip='good'; guide='Nắm vững Dimensional Modeling! Commit artifact và bắt đầu Tuần 7 — Fact Data Modeling.'; }
  else if (correct>=7) { level='Tốt';      chip='good'; guide='Sẵn sàng tiếp tục. Ôn lại SCD2 và Cumulative Table trước khi sang Tuần 7.'; }
  else if (correct>=5) { level='Đạt';      chip='warn'; guide='Ôn lại W5.04 (SCD) và W5.05 (Cumulative Table) — đây là core của module này.'; }
  else                 { level='Cần ôn thêm'; chip='bad'; guide='Ôn lại toàn bộ module W5.02–W5.06. Thực hành viết actors_history_scd SQL trực tiếp.'; }

  const uHtml = unanswered.length ? `<p><strong>Chưa trả lời:</strong> Q${unanswered.join(', Q')}</p>` : '';
  const wHtml = wrong.length
    ? `<p><strong>Sai:</strong></p><ul class="mistake-list">${wrong.map(i=>`<li>Q${i.q}: chọn <strong>${i.selected}</strong>, đúng là <strong>${i.correct}</strong></li>`).join('')}</ul>`
    : '<p><strong>Tất cả đều đúng! 🎉</strong></p>';

  result.innerHTML = `
    <div class="score-row">
      <span class="score-chip ${chip}">Điểm: ${correct}/${total}</span>
      <span class="score-chip">Tỷ lệ: ${pct}%</span>
      <span class="score-chip ${chip}">Mức: ${level}</span>
      <span class="score-chip">Đã trả lời: ${answered}/${total}</span>
    </div>
    <p>${guide}</p>${uHtml}${wHtml}`;
  result.style.display = 'block';
  result.scrollIntoView({behavior:'smooth',block:'nearest'});
}
function resetFinalTest() {
  document.querySelectorAll('#final-test .test-question').forEach(q => {
    q.classList.remove('correct','wrong','unanswered');
    q.querySelectorAll('input[type="radio"]').forEach(i => i.checked = false);
  });
  const r = document.getElementById('final-test-result');
  r.style.display = 'none'; r.innerHTML = '';
}
```

### 2. CSS Classes
```css
/* info box */
.info-box { border-radius: 8px; border: 1px solid; padding: 14px 16px; }
.info-box.tip { border-color: var(--accent2); background: #2ea04310; }
.info-box.warn { border-color: var(--accent5); background: #d2940015; }
.info-box.note { border-color: var(--accent4); background: #6e40c915; }
.info-box.danger { border-color: var(--accent3); background: #f7816610; }

/* quiz component */
.quiz-item { background: var(--surface2); border: 1px solid var(--border); border-radius: 8px; }
.quiz-q { font-weight: 600; font-size: 0.88rem; }
.quiz-options { display: flex; flex-direction: column; gap: 6px; }

/* tab switcher */
.tab-group { display: flex; border-bottom: 1px solid var(--border); }
.tab { padding: 8px 18px; cursor: pointer; }
.tab-content { display: none; }

/* practice task */
.practice-task { background: var(--surface2); border: 1px solid var(--border); border-radius: 8px; }
.practice-task-header { background: #6e40c915; font-weight: 700; }
.practice-task-body { padding: 16px; }

/* checklist item */
.checklist { list-style: none; padding: 0; }
.checklist li { display: flex; align-items: flex-start; gap: 10px; }

/* collapsible/accordion */
.section-header { padding: 14px 20px; cursor: pointer; display: flex; }
.section-content { padding: 20px; background: var(--surface); }
.section-toggle { margin-left: auto; color: var(--text-muted); }

/* badge */
.badge { padding: 4px 12px; border-radius: 20px; border: 1px solid; }
.badge-blue { color: var(--accent); background: #1f6feb1a; }
.badge-green { color: var(--accent2); background: #2ea04326; }
.badge-orange { color: var(--accent5); background: #d2940026; }
.badge-purple { color: var(--accent4); background: #6e40c926; }

/* data table */
table { width: 100%; border-collapse: collapse; }
th { background: var(--surface2); border: 1px solid var(--border); }
td { padding: 8px 12px; border: 1px solid var(--border); }
```

### 3. Placeholder Pattern
```html
<div class="module" id="m1">...</div>
<div class="solution-box">...</div>
<div id="ddl-oracle" class="tab-content">...</div>
```

### 4. HTML Sidebar Navigation
```html
  <nav class="sidebar">
    <div class="sidebar-title">Chương Trình Học</div>
    <div class="level-label">▶ TUẦN 5–6 · DIMENSIONAL MODELING</div>
    <div class="nav-item active" onclick="showModule(0,this)"><span class="nav-number">W5.01</span>Tổng Quan & Mục Tiêu</div>
    <div class="nav-item" onclick="showModule(1,this)"><span class="nav-number">W5.02</span>Grain, Fact & Dimension</div>
    <div class="nav-item" onclick="showModule(2,this)"><span class="nav-number">W5.03</span>Star Schema vs Snowflake</div>
    <div class="nav-item" onclick="showModule(3,this)"><span class="nav-number">W5.04</span>SCD Type 1, 2, 3</div>
    <div class="nav-item" onclick="showModule(4,this)"><span class="nav-number">W5.05</span>Cumulative Table Design</div>
    <div class="nav-item" onclick="showModule(5,this)"><span class="nav-number">W5.06</span>Backfill Strategy</div>
    <div class="nav-item" onclick="showModule(6,this)"><span class="nav-number">W5.07</span>Bài Thực Hành & Artifact</div>
    <div class="nav-item" onclick="showModule(7,this)"><span class="nav-number">W5.08</span>Mini Test Tổng Kết</div>
  </nav>
```