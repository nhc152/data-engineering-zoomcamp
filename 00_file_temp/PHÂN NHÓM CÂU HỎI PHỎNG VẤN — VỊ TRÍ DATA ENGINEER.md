**🗂️ PHÂN NHÓM CÂU HỎI PHỎNG VẤN — VỊ TRÍ DATA ENGINEER**

Trước khi đi vào chi tiết, đây là toàn bộ các nhóm chủ đề một DE thường bị hỏi:

![][image1]

Đây là 10 nhóm câu hỏi phỏng vấn DE — click vào từng nhóm để đi thẳng vào câu hỏi chi tiết. Dưới đây là mô tả nhanh từng nhóm và mức độ ưu tiên:

---

**Nhóm ưu tiên cao nhất** (gần như 100% buổi phỏng vấn DE sẽ hỏi):

Nhóm 1, 2, 3 là core kỹ thuật — ETL design, ODI, SQL tuning. Đây là những thứ bạn làm hằng ngày nên cần trả lời fluent, không do dự.

Nhóm 5 và 7 là điểm khác biệt của bạn so với các ứng viên khác — HA/DR 4 tầng và các case xử lý sự cố thực tế (DR 6 tiếng, pg\_repack 92%) rất hiếm DE có. Đây là "vũ khí bí mật" trong phỏng vấn.

**Nhóm quan trọng thứ 2:**

Nhóm 4, 6, 8 — DBA, Data Quality, Schema design. Thường hỏi ở vòng technical deep-dive hoặc khi interviewer muốn kiểm tra độ sâu.

**Nhóm bổ trợ:**

Nhóm 9 và 10 thường xuất hiện ở vòng HR hoặc cuối buổi phỏng vấn kỹ thuật. Nhóm 10 đặc biệt quan trọng nếu bạn apply vào công ty banking/fintech.

Bạn muốn mình đặt câu hỏi chi tiết cho nhóm nào trước?

**Nhóm 1: ETL & Pipeline Design — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

*Interviewer muốn biết bạn hiểu khái niệm hay chỉ làm theo template có sẵn*

---

**Q1.**

*"ETL và ELT khác nhau thế nào? Trong các dự án của bạn, bạn dùng approach nào và tại sao?"*

💡 **Gợi ý trả lời từ kinh nghiệm của bạn:** ETL: transform trước rồi mới load — phù hợp với hệ thống enterprise có rule nghiệp vụ phức tạp như AML, OFSAA. ELT: load raw trước, transform sau trong data warehouse — phù hợp cloud/big data. Bạn dùng ETL vì môi trường Oracle/ODI enterprise, rule nghiệp vụ banking cần kiểm soát chặt trước khi vào Core.

---

**Q2.**

*"Tại sao cần Staging layer? Nếu bỏ Staging, load thẳng từ Source vào Core thì có vấn đề gì?"*

💡 **Gợi ý trả lời:**

* Không thể rerun riêng bước transform nếu lỗi — phải extract lại từ nguồn tốn kết nối và thời gian

* Không có chỗ để làm DQ checks trước khi vào Core

* Nếu source system thay đổi schema → ảnh hưởng thẳng vào Core

* Staging là buffer: tách extract khỏi transform, dễ debug, dễ audit

*Bạn đã thiết kế Staging với 30+ bảng cho AML — hãy lấy đó làm ví dụ cụ thể.*

---

**Q3.**

*"Full load và incremental load khác nhau thế nào? Khi nào bạn chọn cái nào?"*

💡 **Gợi ý trả lời:**

* Full load: truncate rồi insert lại toàn bộ — đơn giản, an toàn, dùng cho bảng nhỏ hoặc dimension ít thay đổi

* Incremental: chỉ lấy dữ liệu mới/thay đổi — dùng cho bảng transaction lớn, giảm tải source

* Incremental cần cơ chế xác định "mới": timestamp, sequence number, CDC

*Trong AML, bạn xử lý incremental thế nào — dùng timestamp hay cơ chế khác?*

---

**Q4.**

*"Idempotency trong ETL là gì? Tại sao nó quan trọng?"*

💡 **Gợi ý trả lời:** Idempotent nghĩa là chạy lại nhiều lần vẫn cho kết quả như chạy 1 lần — không duplicate data. Quan trọng vì batch ETL có thể fail và cần rerun. Cách đảm bảo: dùng MERGE thay INSERT, dùng batch\_id để track, truncate staging trước khi load, check tồn tại trước khi insert.

*Bạn đã dùng batch\_id trong stored procedure AML — đây là ví dụ điển hình.*

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

*Interviewer muốn kiểm tra bạn thực sự thiết kế hay chỉ execute theo spec*

---

**Q5.**

*"Trong dự án AML Agribank, bạn thiết kế cơ chế handshake và kiểm soát batch như thế nào? Giải thích chi tiết luồng từ khi batch bắt đầu đến khi kết thúc."*

💡 **Gợi ý trả lời — đây là câu hỏi về thứ bạn tự thiết kế:**

* Batch bắt đầu: tạo record trong job\_log với batch\_id, status \= RUNNING, start\_time

* Handshake: kiểm tra DB link còn sống, kiểm tra source system đã sẵn sàng chưa

* Extract: pull data từ source vào Staging, ghi số bản ghi vào proc\_log

* Transform: gọi stored procedure theo thứ tự, mỗi SP nhận batch\_id

* DQ check: chạy validation, bản ghi lỗi → error\_table

* Load vào Core: chỉ load bản ghi đã pass DQ

* Kết thúc: update job\_log status \= SUCCESS/FAILED, end\_time, row\_count

* Rollback: nếu fail giữa chừng → rollback transaction, status \= FAILED, alert email

---

**Q6.**

*"SCD là gì? Bạn đề cập SCD-like change tracking trong dự án AML — bạn xử lý thế nào và tại sao không dùng SCD chuẩn?"*

💡 **Gợi ý trả lời:**

* SCD Type 1: overwrite — không giữ lịch sử

* SCD Type 2: thêm row mới với effective\_date, giữ lịch sử đầy đủ

* SCD Type 3: thêm cột previous\_value

* "SCD-like" trong AML: so sánh hash hoặc checksum của record hiện tại với record mới, nếu khác → đánh dấu changed. Không dùng SCD Type 2 chuẩn vì schema AML do vendor quy định, không thể thêm cột effective\_date tùy ý.

---

**Q7.**

*"Batch window là gì? Nếu batch ETL hằng đêm bị overrun — chạy quá giờ quy định — bạn xử lý thế nào?"*

💡 **Gợi ý trả lời:** Batch window: khung giờ cho phép ETL chạy, ví dụ 22h–5h sáng. Nếu overrun:

* Short-term: kill job ít quan trọng nhất, ưu tiên bảng core chạy trước

* Phân tích nguyên nhân: query nào chậm? Volume tăng đột biến? Resource contention?

* Giải pháp: tối ưu query, tăng parallelism, chia nhỏ batch, chạy incremental thay full load

* Reporting cho stakeholder: bảng nào bị delay, impact đến báo cáo buổi sáng

*Bạn đã xử lý tình huống batch overrun trong dự án nào chưa? Đây là cơ hội kể story thực tế.*

---

**Q8.**

*"Bạn thiết kế \~200 Program trong ODI cho LPBank OFSAA. Làm thế nào để đảm bảo dependency giữa các program được xử lý đúng? Nếu program số 150 fail thì sao?"*

💡 **Gợi ý trả lời:**

* ODI Package: các Step được nối theo On Success/On Failure

* Dependency: program B chỉ chạy sau A thành công → dùng conditional branch trong Package

* Program 150 fail: Package dừng lại hoặc route sang error branch tùy config

* Idempotency: rerun từ program 150 được, không cần chạy lại 1-149

* Alert: gửi email notification kèm log chi tiết step nào fail và lý do

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

*Interviewer muốn thấy bạn xử lý vấn đề như thế nào dưới áp lực*

---

**Q9.**

*"Sáng thứ Hai bạn vào làm, nhận được báo cáo từ team nghiệp vụ AML: 'Số lượng giao dịch đáng ngờ hôm nay giảm 60% so với thứ Sáu tuần trước, có vẻ dữ liệu bị thiếu.' Bạn điều tra theo thứ tự nào?"*

💡 **Gợi ý trả lời — thể hiện systematic thinking:**

1. Kiểm tra job\_log: batch thứ 7, Chủ nhật có chạy đủ không? Status SUCCESS hay FAILED?

2. Kiểm tra row count: Staging có đủ bản ghi không? So sánh với thứ Sáu

3. Kiểm tra error\_table: có bao nhiêu bản ghi bị reject? Lý do gì?

4. Kiểm tra DB link: kết nối đến IPCAS, SWIFT còn sống không?

5. Kiểm tra source: cuối tuần source system có maintenance không? Có missing file không?

6. Kiểm tra DQ check: có rule nào vô tình reject quá nhiều bản ghi không?

7. Report: xác định nguyên nhân, ước tính data bị thiếu, plan recovery

---

**Q10.**

*"Bạn cần migrate 300+ bảng từ hệ thống cũ sang hệ thống mới trong thời gian cutover ngắn — ví dụ 8 tiếng cuối tuần. Bạn lên kế hoạch như thế nào để đảm bảo 0 data loss và có thể rollback nếu cần?"*

💡 **Gợi ý trả lời — bạn đã làm điều này ở VAECO:**

* Phân loại bảng: critical (chạy trước), non-critical (chạy sau)

* Chạy thử dry-run nhiều lần trên môi trường test trước cutover

* Backup toàn bộ trước khi bắt đầu

* Song song hóa: chia bảng thành nhóm, chạy nhiều luồng cùng lúc

* Reconciliation: sau mỗi nhóm → kiểm tra row count, checksum

* Rollback plan: nếu \>X bảng fail → restore từ backup, revert về hệ thống cũ

* Communication: update status mỗi 30 phút cho stakeholder

---

**Q11.**

*"Một pipeline ETL đang chạy ổn 3 tháng, đột nhiên hôm nay chạy chậm gấp 5 lần dù không có thay đổi code nào. Nguyên nhân có thể là gì và bạn debug thế nào?"*

💡 **Gợi ý trả lời:** Checklist debug theo thứ tự:

* **Data volume**: source tăng đột biến? Cuối tháng/cuối quý thường có spike

* **Statistics cũ**: Oracle/PostgreSQL dùng stats cũ → chọn sai execution plan → gather stats lại

* **Index phân mảnh**: sau nhiều tháng insert/delete → rebuild index

* **Resource contention**: có job khác chạy cùng giờ không? CPU/RAM/I/O đang bị tranh

* **DB link chậm**: network giữa source và staging bị degraded

* **Lock/blocking**: session nào đó đang hold lock trên bảng target

---

**Q12.**

*"Nếu được thiết kế lại pipeline AML từ đầu với kinh nghiệm hiện tại, bạn sẽ thay đổi gì?"*

💡 **Đây là câu hỏi mở — thể hiện tư duy phản biện và growth mindset:** Không có câu trả lời đúng sai. Ví dụ bạn có thể nói:

* Thêm data lineage tracking: biết mỗi bản ghi Core đến từ source nào, qua transform nào

* Tách config khỏi code: rule mapping lưu trong bảng config, không hardcode trong SP

* Thêm automated reconciliation report gửi email sau mỗi batch

* Thiết kế retry mechanism tự động cho các lỗi transient (network timeout, DB link flap)

* Thêm monitoring dashboard realtime thay vì chỉ check log sau khi fail

---

**📊 Tổng kết nhóm 1**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | ETL vs ELT | ⭐ | AML, OFSAA |
| Q2 | Vai trò Staging | ⭐ | AML Agribank |
| Q3 | Full vs Incremental | ⭐ | AML, NHNN |
| Q4 | Idempotency | ⭐⭐ | AML Agribank |
| Q5 | Batch control & handshake | ⭐⭐⭐ | AML Agribank |
| Q6 | SCD-like change tracking | ⭐⭐⭐ | AML Agribank |
| Q7 | Batch window overrun | ⭐⭐ | LPBank, NHNN |
| Q8 | 200 Program dependency | ⭐⭐⭐ | LPBank OFSAA |
| Q9 | Điều tra dữ liệu thiếu | ⭐⭐⭐ | AML Agribank |
| Q10 | Kế hoạch migration cutover | ⭐⭐⭐ | VAECO AMOS |
| Q11 | Debug pipeline chậm đột ngột | ⭐⭐⭐ | VAECO, NHNN |
| Q12 | Thiết kế lại từ đầu | ⭐⭐ | Tất cả |

Bạn muốn **luyện tập trả lời** câu nào, hay chuyển sang **nhóm 2: ODI & ETL Tools**?

**Nhóm 2: ODI & ETL Tools — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"ODI 12c có kiến trúc gồm những thành phần chính nào? Mỗi thành phần làm gì?"*

💡 **Gợi ý trả lời:**

* **Master Repository**: lưu metadata toàn hệ thống — security, topology, version control. Chỉ có 1 Master Repository cho toàn organization

* **Work Repository**: lưu project — Models, Mappings, Packages, Procedures. Có thể có nhiều Work Repository (dev/test/prod)

* **Agent**: runtime engine thực sự execute code. Standalone Agent chạy như service trên server

* **ODI Studio**: GUI để design, develop, monitor

* **ODI Console**: web interface để monitor job đang chạy

*Bạn đã cài đặt và cấu hình toàn bộ stack này cho LPBank và AML — hãy kể lại.*

---

**Q2.**

*"Model trong ODI là gì? Tại sao phải tạo Model trước khi làm Mapping?"*

💡 **Gợi ý trả lời:** Model là metadata representation của một data store — bảng, view, file. Khi tạo Model, ODI reverse-engineer schema từ DB thực tế vào repository. Mapping cần Model vì nó tham chiếu đến các Datastore (bảng) đã được đăng ký trong Model — không có Model thì không biết cấu trúc source/target để map.

*Thực tế: mỗi khi source thay đổi schema, bạn phải reverse lại Model.*

---

**Q3.**

*"Mapping, Procedure và Package trong ODI khác nhau thế nào? Bạn dùng cái nào cho việc gì?"*

💡 **Gợi ý trả lời — đây là câu hỏi phân biệt người dùng thật với người chỉ đọc tài liệu:**

| Thành phần | Dùng để làm gì |
| :---- | :---- |
| **Mapping** | Di chuyển và transform data giữa source → target. Có visual canvas kéo thả |
| **Procedure** | Chạy code tùy ý: SQL, PL/SQL, shell script. Không có visual canvas |
| **Package** | Orchestrate: sắp xếp thứ tự chạy Mapping/Procedure, xử lý điều kiện rẽ nhánh, loop, error handling |

*Ví dụ thực tế của bạn: Mapping extract từ IPCAS vào Staging → Procedure transform/chuẩn hóa → Package gọi tất cả theo đúng thứ tự.*

---

**Q4.**

*"IKM là gì? Tại sao chọn đúng IKM lại ảnh hưởng lớn đến performance?"*

💡 **Gợi ý trả lời:** IKM (Integration Knowledge Module) là template quy định cách ODI load data vào target. Ví dụ với Oracle:

* **IKM Oracle Insert**: bulk insert, dùng APPEND hint → nhanh nhất

* **IKM Oracle Merge**: insert \+ update trong 1 statement → dùng cho incremental

* **IKM SQL Control Append**: row-by-row → chậm nhất, tránh dùng với bảng lớn

*Bạn đã tối ưu IKM ở LPBank — từ row-by-row sang bulk insert, đây là ví dụ điển hình.*

---

**Q5.**

*"Variable trong ODI dùng để làm gì? Bạn đã dùng Variable như thế nào trong thực tế?"*

💡 **Gợi ý trả lời:** Variable lưu giá trị runtime, dùng để:

* Truyền tham số vào Mapping/Procedure: ngày xử lý, batch\_id

* Điều kiện rẽ nhánh trong Package: nếu row\_count \> 0 thì chạy tiếp, ngược lại skip

* Lưu kết quả trung gian: đếm số bản ghi lỗi sau DQ check

*Ví dụ thực tế: Variable V\_BATCH\_DATE truyền ngày xử lý vào tất cả Mapping trong một Package, đảm bảo tất cả cùng xử lý đúng ngày.*

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q6.**

*"Khi một ODI Mapping chạy chậm, bạn debug và tối ưu theo quy trình nào? Kể case cụ thể bạn đã làm ở LPBank."*

💡 **Gợi ý trả lời — quy trình 5 bước:**

1. **ODI Operator**: xem execution statistics — step nào tốn thời gian nhất

2. **Xem generated SQL**: ODI generate SQL thực tế ra gì? Copy ra DBeaver/Toad chạy thử

3. **Explain Plan**: phân tích execution plan của SQL đó — Full Scan ở đâu?

4. **IKM**: đang dùng IKM gì? Đổi sang bulk insert chưa?

5. **Parallel hint**: thêm /\*+ PARALLEL(t, 4\) \*/ vào generated SQL qua LKM/IKM override

*Ví dụ LPBank: Mapping chạy 45 phút vì IKM row-by-row, đổi sang IKM Oracle Insert với APPEND \+ PARALLEL → còn 8 phút.*

---

**Q7.**

*"LKM là gì và khác IKM như thế nào? Bạn đã customize LKM/IKM bao giờ chưa?"*

💡 **Gợi ý trả lời:**

* **LKM** (Loading Knowledge Module): quy định cách load data từ source vào C$ (staging table tạm của ODI). Quan trọng khi source và target ở DB khác nhau

* **IKM**: quy định cách integrate từ C$ vào target

* Khi source là DB2, target là Oracle: LKM DB2 to Oracle (JDBC) → LKM xử lý cross-database, IKM xử lý Oracle-to-Oracle

Customize KM: có thể mở KM ra, sửa template SQL, thêm hint, thêm log statement — đây là advanced feature khi default KM không đủ.

---

**Q8.**

*"ODI error handling hoạt động như thế nào? Nếu một Mapping fail giữa chừng khi đang load 1 triệu bản ghi, chuyện gì xảy ra với dữ liệu đã load rồi?"*

💡 **Gợi ý trả lời:**

* ODI Mapping chạy trong 1 transaction (mặc định). Nếu fail → rollback toàn bộ → target sạch như trước

* Có thể cấu hình commit interval để commit từng X bản ghi — mất atomicity nhưng không bị rollback hết

* Với bảng 1 triệu dòng: tốt nhất để nguyên default (full transaction), đảm bảo data integrity

* Error table (E$): ODI có thể ghi các bản ghi lỗi vào E$ table thay vì rollback toàn bộ — dùng CKM (Check Knowledge Module)

---

**Q9.**

*"Talend Studio bạn đã dùng để làm gì? So sánh với ODI, bạn thấy tool nào phù hợp cho loại task nào?"*

💡 **Gợi ý trả lời từ kinh nghiệm thực tế của bạn:**

| Tiêu chí | ODI 12c | Talend Studio |
| :---- | :---- | :---- |
| Thế mạnh | Oracle-to-Oracle, tích hợp Oracle stack (OFSAA, EBS) | Multi-platform, DB2/SQL Server/Oracle/file |
| VAECO use case | Transfer sang AMOS (Oracle) | Migrate từ DB2/SQL Server sang Oracle Staging |
| Metadata | Mạnh — repository đầy đủ | Metadata đơn giản hơn |
| Khi nào dùng | Oracle ecosystem | Cross-platform migration |

*Thực tế VAECO: bạn dùng Talend cho phase đầu migrate từ AMASIS (DB2) vì Talend handle DB2 connector tốt hơn ODI.*

---

**Q10.**

*"Trong dự án LPBank với \~200 Program, bạn quản lý version và deploy như thế nào? Nếu cần rollback một Mapping đã deploy lên Production thì làm sao?"*

💡 **Gợi ý trả lời:**

* ODI có **Version Control** built-in: mỗi object có thể được version, lưu trong Master Repository

* Export/Import: export Scenario (compiled version của Mapping/Package) ra file XML, import vào môi trường khác

* Rollback: giữ Scenario version cũ, nếu cần rollback → delete Scenario mới, re-deploy Scenario cũ

* Best practice: không sửa trực tiếp trên Production — dev trên Work Repository dev, test trên test, sau đó export Scenario sang prod

*Bạn đã làm gì ở LPBank để quản lý 200 Program qua các môi trường? Đây là điểm hay để kể.*

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q11.**

*"Hệ thống LPBank có \~200 Program chạy hằng đêm. Sáng dậy thấy Package fail ở Program thứ 87\. ODI Operator báo lỗi 'ORA-01555: snapshot too old'. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời — đây là lỗi Oracle rất thực tế:**

* **ORA-01555** xảy ra khi UNDO segment bị overwrite trước khi query đọc xong — thường do query chạy quá lâu trong khi có nhiều DML khác

* Immediate fix: tăng UNDO\_RETENTION parameter, hoặc tăng UNDO tablespace

* Root cause: Mapping đó đang làm full scan bảng lớn trong khi batch khác đang chạy song song gây nhiều UNDO

* Giải pháp dài hạn: tối ưu Mapping đó cho chạy nhanh hơn, hoặc reschedule tránh chạy cùng giờ với job khác

---

**Q12.**

*"Bạn cần tích hợp một nguồn dữ liệu mới vào pipeline AML — một REST API thay vì DB. ODI không có connector REST native. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời — thể hiện tư duy giải quyết vấn đề:**

* Option 1: **Python script** call API, flatten JSON, insert vào Staging table → ODI đọc từ Staging như bình thường

* Option 2: **ODI Procedure** gọi external script Python/shell

* Option 3: **Talend** handle API call, Talend load vào Staging, ODI tiếp tục từ Staging

* Best practice: tách concern — ODI làm ETL trong DB, Python/Talend làm data ingestion từ external source

*Bạn đã dùng Python trong VAECO — đây là ví dụ gần với approach này.*

---

**Q13.**

*"Scenario trong ODI là gì? Tại sao phải generate Scenario trước khi chạy trên Production?"*

💡 **Gợi ý trả lời:** Scenario là compiled, executable version của một Mapping/Package/Procedure. Giống như compile code trước khi deploy:

* Design-time object (Mapping): có thể sửa bất cứ lúc nào, chưa executable

* Scenario: snapshot tại thời điểm generate, không bị ảnh hưởng nếu ai đó sửa design-time object

* Production chỉ chạy Scenario: đảm bảo stability, không ai sửa design làm ảnh hưởng job đang chạy

* Versioning: mỗi lần generate là một version mới của Scenario

---

**Q14.**

*"Nếu phải chuyển toàn bộ ODI project từ môi trường dev sang prod với \~200 Mapping/Package, quy trình bạn làm như thế nào để đảm bảo không miss gì?"*

💡 **Gợi ý trả lời — quy trình thực tế:**

1. **Export Smart Export** từ dev: export toàn bộ project kèm dependencies

2. **Kiểm tra Topology**: physical/logical schema trên prod đã được config đúng chưa?

3. **Import vào prod Work Repository**

4. **Generate tất cả Scenario**: generate mới hoàn toàn, không giữ Scenario cũ

5. **Test chạy thử**: chạy từng Package với chế độ Simulation trước

6. **Verify connections**: tất cả DB link, agent connection đều sống

7. **Cutover**: chạy thật lần đầu tiên với monitor chặt

---

**📊 Tổng kết nhóm 2**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | Kiến trúc ODI | ⭐ | LPBank, AML |
| Q2 | Model & Datastore | ⭐ | Tất cả |
| Q3 | Mapping vs Procedure vs Package | ⭐⭐ | AML, LPBank |
| Q4 | IKM & performance | ⭐⭐ | LPBank OFSAA |
| Q5 | Variable usage | ⭐⭐ | AML, LPBank |
| Q6 | Debug Mapping chậm | ⭐⭐⭐ | LPBank OFSAA |
| Q7 | LKM vs IKM, customize | ⭐⭐⭐ | VAECO, LPBank |
| Q8 | Error handling & transaction | ⭐⭐⭐ | AML Agribank |
| Q9 | ODI vs Talend so sánh | ⭐⭐ | VAECO AMOS |
| Q10 | Version control & deploy | ⭐⭐⭐ | LPBank OFSAA |
| Q11 | ORA-01555 xử lý | ⭐⭐⭐ | LPBank OFSAA |
| Q12 | REST API integration | ⭐⭐⭐ | AML, VAECO |
| Q13 | Scenario là gì | ⭐⭐ | LPBank, AML |
| Q14 | Deploy 200 Mapping lên prod | ⭐⭐⭐ | LPBank OFSAA |

---

Bạn muốn **luyện tập trả lời** câu nào trong nhóm này, hay chuyển sang **nhóm 3: SQL & Performance Tuning**?

**Nhóm 3: SQL & Performance Tuning — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"Execution Plan là gì? Bạn đọc Execution Plan như thế nào để tìm ra điểm bottleneck?"*

💡 **Gợi ý trả lời:** Execution Plan là kế hoạch Oracle/PostgreSQL chọn để thực thi một query — join method nào, access path nào, thứ tự các bước ra sao.

Cách đọc:

* Oracle: EXPLAIN PLAN FOR \<query\> rồi SELECT \* FROM TABLE(DBMS\_XPLAN.DISPLAY)

* PostgreSQL: EXPLAIN ANALYZE \<query\>

Các dấu hiệu bottleneck cần tìm:

* **Full Table Scan** trên bảng lớn → thiếu Index

* **Nested Loop** với bảng triệu dòng → nên dùng Hash Join

* **High Cost** ở một node cụ thể → node đó là bottleneck

* **Estimated rows** lệch xa **Actual rows** → statistics cũ, cần gather lại

* **Buffer Gets** cao → query đọc quá nhiều block

*Bạn đã phân tích execution plan trong NHNN DWH và VAECO — hãy kể case cụ thể.*

---

**Q2.**

*"Index là gì? Các loại Index phổ biến trong Oracle và PostgreSQL? Khi nào nên tạo Index, khi nào không?"*

💡 **Gợi ý trả lời:**

Các loại Index Oracle:

* **B-tree Index**: default, phù hợp cho equality và range query

* **Bitmap Index**: phù hợp cột ít giá trị phân biệt (status, gender), tốt cho DWH read-heavy

* **Function-based Index**: index trên expression UPPER(name), TRUNC(date)

* **Composite Index**: index trên nhiều cột, thứ tự cột quan trọng

Khi NÊN tạo Index:

* Cột thường xuyên xuất hiện trong WHERE, JOIN, ORDER BY

* Cột có high cardinality (nhiều giá trị phân biệt)

* Query cần trả về ít rows so với tổng bảng

Khi KHÔNG nên tạo Index:

* Bảng nhỏ — full scan vẫn nhanh

* Cột low cardinality (Y/N, status 2-3 giá trị) — Bitmap tốt hơn B-tree

* Bảng insert/update nhiều — Index làm chậm DML

* ETL staging table — truncate/insert toàn bộ, Index chỉ tốn overhead

---

**Q3.**

*"Partition trong Oracle là gì? Các loại Partition nào bạn đã dùng? Partition giúp ích gì cho ETL?"*

💡 **Gợi ý trả lời:**

Các loại Partition phổ biến:

* **Range Partition**: theo khoảng giá trị — thường theo ngày/tháng/năm. Phổ biến nhất trong DWH

* **List Partition**: theo danh sách giá trị cố định — ví dụ theo region

* **Hash Partition**: phân tán đều theo hash function — dùng khi không có cột range rõ ràng

* **Composite Partition**: kết hợp Range \+ List hoặc Range \+ Hash

Partition giúp ETL:

* **Partition Pruning**: query chỉ scan đúng partition cần thiết, bỏ qua phần còn lại

* **Partition Exchange**: swap partition trong O(1) — thay vì insert hàng triệu dòng, exchange một partition pre-populated

* **Drop old partition**: xóa dữ liệu cũ nhanh bằng DROP PARTITION thay vì DELETE từng dòng

* **Parallel load**: load nhiều partition song song

*Bạn đã tuning Partition cho bảng lớn ở NHNN DWH — hãy kể chi tiết.*

---

**Q4.**

*"MERGE statement dùng khi nào? Tại sao MERGE thường tốt hơn INSERT \+ UPDATE riêng biệt?"*

💡 **Gợi ý trả lời:** MERGE \= UPSERT: nếu record tồn tại thì UPDATE, chưa tồn tại thì INSERT — trong một statement duy nhất.

Tại sao tốt hơn INSERT \+ UPDATE riêng:

* **Một lần scan**: MERGE chỉ join source và target 1 lần. INSERT \+ UPDATE riêng phải scan target 2 lần

* **Atomic**: MERGE là một transaction, không có trạng thái trung gian

* **Idempotent**: chạy lại nhiều lần vẫn đúng

* **Less locking**: ít lock hơn vì ít statement hơn

MERGE INTO target t

USING source s ON (t.id \= s.id)

WHEN MATCHED THEN UPDATE SET t.value \= s.value

WHEN NOT MATCHED THEN INSERT (id, value) VALUES (s.id, s.value);

*Bạn đã dùng MERGE trong stored procedure AML cho SCD-like tracking.*

---

**Q5.**

*"Statistics trong Oracle/PostgreSQL là gì? Tại sao Statistics cũ lại làm query chậm đột ngột?"*

💡 **Gợi ý trả lời:** Statistics là metadata về data distribution: số rows, số distinct values, histogram phân phối giá trị, correlation giữa các cột. Optimizer dùng statistics để ước tính cost của từng execution plan và chọn plan tốt nhất.

Statistics cũ → Optimizer chọn sai plan:

* Ước tính 1.000 rows nhưng thực tế 10 triệu rows → chọn Nested Loop thay vì Hash Join

* Ước tính column selectivity sai → chọn Full Scan thay vì Index Scan

* Kết quả: query đột nhiên chậm dù data không thay đổi nhiều

Giải pháp:

* Oracle: DBMS\_STATS.GATHER\_TABLE\_STATS('schema', 'table')

* PostgreSQL: ANALYZE table\_name

* Schedule gather stats định kỳ hoặc sau batch load lớn

*Đây là nguyên nhân phổ biến nhất khiến query chậm đột ngột sau nhiều tháng chạy ổn.*

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q6.**

*"Giải thích kỹ thuật song song hóa bạn đã dùng để giảm batch VAECO từ 4 giờ xuống 30 phút. Tại sao kỹ thuật đó work trong trường hợp đó?"*

💡 **Đây là câu hỏi chắc chắn xuất hiện — bạn cần kể rõ từng bước:**

Tình huống: batch ETL migrate dữ liệu lịch sử nhiều năm, chạy tuần tự từng record → 4 tiếng.

Phân tích: dữ liệu có thể chia theo khoảng thời gian (tháng/quý), các khoảng độc lập nhau hoàn toàn — không có dependency.

Giải pháp:

\-- Thay vì chạy tuần tự:

\-- Process tháng 1/2020 → xong → tháng 2/2020 → xong → ...

\-- Song song hóa:

\-- Thread 1: Process Q1/2020

\-- Thread 2: Process Q2/2020  } chạy đồng thời

\-- Thread 3: Process Q3/2020

\-- Thread 4: Process Q4/2020

Tại sao work:

* Data partition theo thời gian → không có lock contention

* Mỗi thread write vào partition khác nhau → không conflict

* I/O và CPU được tận dụng song song thay vì tuần tự

Kết quả: 8 khoảng chạy song song 4 threads → lý thuyết giảm 4x, thực tế còn overhead → 4h → 30 phút (giảm 87.5%).

---

**Q7.**

*"Bạn có một query JOIN 3 bảng, trong đó có 1 bảng 50 triệu dòng. Query đang dùng Nested Loop và chạy rất chậm. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời — step by step:**

Bước 1 — Hiểu tại sao Optimizer chọn Nested Loop:

* Statistics cũ → ước tính rows quá thấp → nghĩ Nested Loop sẽ nhanh

* Gather stats lại: DBMS\_STATS.GATHER\_TABLE\_STATS

Bước 2 — Nếu sau gather stats vẫn Nested Loop:

* Dùng hint force Hash Join:

SELECT /\*+ USE\_HASH(a b c) \*/ ...

Bước 3 — Kiểm tra Index:

* Cột JOIN có Index không?

* Nếu có mà không dùng → có thể do implicit conversion (NUMBER JOIN VARCHAR → không dùng Index)

Bước 4 — Parallel query:

SELECT /\*+ PARALLEL(a, 4\) PARALLEL(b, 4\) \*/ ...

Bước 5 — Xem xét rewrite:

* Có thể dùng CTE (WITH clause) để materialize intermediate result?

* Có thể pre-aggregate trước khi JOIN không?

---

**Q8.**

*"Stored Procedure của bạn đang chạy ổn, nhưng hôm nay chạy chậm gấp 10 lần. Bạn debug theo thứ tự nào?"*

💡 **Gợi ý trả lời — checklist 6 bước:**

1\. KIỂM TRA DATA VOLUME

   → Tháng này có nhiều data hơn bình thường không?

   → SELECT COUNT(\*) so sánh với kỳ trước

2\. KIỂM TRA STATISTICS

   → LAST\_ANALYZED của các bảng liên quan là khi nào?

   → Gather stats lại và thử chạy lại

3\. KIỂM TRA EXECUTION PLAN

   → Dùng DBMS\_XPLAN với ALLSTATS LAST

   → So sánh estimated rows vs actual rows — lệch nhiều?

4\. KIỂM TRA LOCK/BLOCKING

   → Có session nào đang lock bảng không?

   → SELECT \* FROM V$LOCK / pg\_locks

5\. KIỂM TRA RESOURCE

   → CPU, I/O, memory lúc đó thế nào?

   → Có job khác chạy cùng lúc không?

6\. KIỂM TRA INDEX

   → Index có bị phân mảnh không?

   → Oracle: INDEX\_STATS, PostgreSQL: pg\_stat\_user\_indexes

---

**Q9.**

*"Bạn cần load 100 triệu bản ghi vào một bảng Oracle trong batch window 2 tiếng. Bạn thiết kế approach như thế nào?"*

💡 **Gợi ý trả lời — đây là câu hỏi thiết kế:**

\-- 1\. Disable constraints và indexes trước khi load

ALTER TABLE target DISABLE CONSTRAINT fk\_xxx;

ALTER INDEX idx\_xxx UNUSABLE;

\-- 2\. Direct Path Insert (bypass buffer cache)

INSERT /\*+ APPEND PARALLEL(target, 8\) NOLOGGING \*/ 

INTO target

SELECT ... FROM source;

COMMIT;

\-- 3\. Rebuild indexes sau khi load xong

ALTER INDEX idx\_xxx REBUILD PARALLEL 8;

\-- 4\. Re-enable constraints

ALTER TABLE target ENABLE CONSTRAINT fk\_xxx;

\-- 5\. Gather stats

DBMS\_STATS.GATHER\_TABLE\_STATS('schema', 'target');

Key techniques:

* **APPEND hint**: Direct Path Insert, bypass buffer cache, nhanh hơn 3-5x

* **NOLOGGING**: giảm redo log generation, tăng tốc đáng kể

* **PARALLEL**: tận dụng nhiều CPU core

* Disable Index trước, rebuild sau: tránh index update từng dòng

---

**Q10.**

*"WITH clause (CTE) trong SQL dùng khi nào? Nó có thực sự cải thiện performance không?"*

💡 **Gợi ý trả lời:** CTE dùng để:

* Chia query phức tạp thành các bước dễ đọc

* Tránh subquery lặp lại nhiều lần

* Recursive query (hierarchical data)

Về performance — câu trả lời phụ thuộc vào DB:

* **Oracle**: CTE mặc định không materialize — Optimizer có thể inline CTE vào query chính, kết quả tương đương subquery. Dùng /\*+ MATERIALIZE \*/ hint để force materialize nếu CTE dùng nhiều lần

* **PostgreSQL**: CTE mặc định materialize (như temp table) — chạy 1 lần, lưu kết quả. Từ PG 12 có thể dùng NOT MATERIALIZED

Khi CTE thực sự giúp performance:

* CTE được tham chiếu nhiều lần trong query — materialize tránh tính lại

* CTE có aggregate phức tạp — materialize kết quả trung gian

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q11.**

*"Một stored procedure trong DWH NHNN chạy report tổng hợp mất 3 tiếng, không kịp T+1. Bạn chỉ có 1 buổi chiều để tối ưu. Quy trình làm việc của bạn?"*

💡 **Gợi ý trả lời — time-boxed optimization:**

30 phút đầu — PHÂN TÍCH, không sửa gì:

  → Chạy SP với SET TIMING ON, xem từng bước mất bao lâu

  → Xác định top 3 query chậm nhất (80% thời gian thường ở 20% query)

  → EXPLAIN PLAN cho từng query đó

60 phút tiếp — QUICK WINS trước:

  → Statistics cũ? → Gather ngay, test lại — thường giảm 30-50% không cần sửa code

  → Full Scan có Index candidate rõ ràng? → Tạo Index, test lại

  → IKM row-by-row? → Đổi sang bulk insert

60 phút tiếp — DEEPER OPTIMIZATION:

  → Rewrite query phức tạp: subquery → JOIN, loop → set-based

  → Thêm PARALLEL hint cho query lớn

  → Xem xét Partition Pruning có đang work không

30 phút cuối — VERIFY & DOCUMENT:

  → Chạy lại toàn bộ SP, đo thời gian tổng

  → Document những gì đã thay đổi

  → Estimate kết quả cho stakeholder

---

**Q12.**

*"Bạn phát hiện một query đang dùng Index nhưng vẫn chậm. Nguyên nhân có thể là gì?"*

💡 **Gợi ý trả lời — đây là câu hỏi phân biệt junior và senior:**

Có Index nhưng vẫn chậm — 5 nguyên nhân phổ biến:

1. **Index được dùng nhưng vẫn phải đọc nhiều rows**: Index selectivity thấp — cột có ít giá trị phân biệt, Index scan vẫn trả về 30% bảng → full scan có thể nhanh hơn

2. **Index range scan \+ table access by rowid**: mỗi rowid là một random I/O → với kết quả lớn, random I/O tốn kém hơn sequential full scan

3. **Index phân mảnh**: sau nhiều tháng DELETE/INSERT → index blocks bị phân mảnh → nhiều I/O hơn cần thiết. Fix: ALTER INDEX idx REBUILD

4. **Wrong index**: query dùng Index nhưng không phải Index tốt nhất. Composite Index cần đúng thứ tự cột (leading column phải match WHERE clause)

5. **Index trên function**: WHERE UPPER(name) \= 'ABC' không dùng được Index trên name, phải có Function-based Index trên UPPER(name)

---

**Q13.**

*"Sự khác nhau giữa TRUNCATE và DELETE trong Oracle? Khi nào bạn dùng cái nào trong ETL?"*

💡 **Gợi ý trả lời:**

|  | TRUNCATE | DELETE |
| :---- | :---- | :---- |
| Tốc độ | Rất nhanh — O(1) | Chậm — scan từng row |
| Rollback | Không rollback được (DDL) | Rollback được (DML) |
| Trigger | Không kích hoạt trigger | Kích hoạt trigger |
| WHERE clause | Không có | Có — xóa có điều kiện |
| Redo log | Minimal | Full redo log |
| Reset HWM | Có — giải phóng space | Không |

Trong ETL:

* **Staging table**: dùng TRUNCATE trước mỗi batch — nhanh, không cần rollback

* **Xóa partition cũ**: ALTER TABLE ... DROP PARTITION còn nhanh hơn cả TRUNCATE

* **Xóa có điều kiện**: buộc phải dùng DELETE — ví dụ xóa records lỗi trong error\_table

* **Khi cần rollback**: dùng DELETE trong transaction

---

**Q14.**

*"Bạn có query chạy nhanh khi test với 10.000 rows, nhưng khi lên Production với 50 triệu rows thì chậm kinh khủng. Đây là anti-pattern gì và cách tránh?"*

💡 **Gợi ý trả lời:**

Đây là **scaling problem** — query không scale tuyến tính. Các anti-pattern phổ biến:

**1\. N+1 query trong loop:**

\-- BAD: loop 50 triệu lần

FOR rec IN (SELECT id FROM source) LOOP

  UPDATE target SET val \= x WHERE id \= rec.id;

END LOOP;

\-- GOOD: set-based

UPDATE target t SET val \= (SELECT val FROM source s WHERE s.id \= t.id);

\-- Hoặc dùng MERGE

**2\. Correlated subquery:**

\-- BAD: subquery chạy cho mỗi row của outer query

SELECT \*, (SELECT MAX(date) FROM orders WHERE cust\_id \= c.id) 

FROM customers c;

\-- GOOD: JOIN hoặc window function

SELECT c.\*, o.max\_date

FROM customers c

JOIN (SELECT cust\_id, MAX(date) max\_date FROM orders GROUP BY cust\_id) o

  ON o.cust\_id \= c.id;

**3\. Function trong WHERE clause:**

\-- BAD: index không dùng được

WHERE TO\_CHAR(created\_date, 'YYYY-MM') \= '2024-01'

\-- GOOD: range query dùng được index

WHERE created\_date \>= DATE '2024-01-01' 

  AND created\_date \< DATE '2024-02-01'

**4\. SELECT \* thay vì select đúng cột cần:** Với bảng 50M rows và nhiều cột — network và memory tăng đột biến.

---

**📊 Tổng kết nhóm 3**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | Đọc Execution Plan | ⭐⭐ | NHNN, VAECO |
| Q2 | Các loại Index | ⭐⭐ | NHNN DWH |
| Q3 | Partition types & ETL | ⭐⭐ | NHNN DWH |
| Q4 | MERGE statement | ⭐⭐ | AML Agribank |
| Q5 | Statistics & Optimizer | ⭐⭐ | Tất cả |
| Q6 | Song song hóa 4h→30p | ⭐⭐⭐ | VAECO AMOS |
| Q7 | Nested Loop → Hash Join | ⭐⭐⭐ | NHNN, LPBank |
| Q8 | Debug SP chậm đột ngột | ⭐⭐⭐ | NHNN, VAECO |
| Q9 | Load 100M rows trong 2h | ⭐⭐⭐ | VAECO migrate |
| Q10 | CTE performance | ⭐⭐ | LPBank, NHNN |
| Q11 | Tối ưu SP 3h → T+1 | ⭐⭐⭐ | NHNN DWH |
| Q12 | Index có nhưng vẫn chậm | ⭐⭐⭐ | NHNN, VAECO |
| Q13 | TRUNCATE vs DELETE ETL | ⭐⭐ | AML, Staging |
| Q14 | Scaling anti-patterns | ⭐⭐⭐ | VAECO migrate |

---

Bạn muốn **luyện tập trả lời** câu nào, hay chuyển sang **nhóm 4: Database Administration**, **nhóm 5: HA/DR** hoặc nhóm khác?

**Nhóm 4: Database Administration — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"Khi cài đặt Oracle 19c trên Linux lần đầu tiên cho một dự án mới, bạn cần chuẩn bị và cấu hình những gì trước khi bàn giao cho team ứng dụng?"*

💡 **Gợi ý trả lời — checklist thực tế bạn đã làm ở VAECO và AML:**

PRE-INSTALL:

  → Kiểm tra OS requirements: kernel parameters, swap space, ulimit

  → Tạo OS user oracle, group oinstall/dba

  → Cấu hình /etc/sysctl.conf: vm.swappiness, shmmax, semaphores

  → Cấu hình /etc/security/limits.conf: open files, max processes

INSTALL:

  → Chạy Oracle Universal Installer

  → Tạo database bằng DBCA (Database Configuration Assistant)

  → Chọn character set: AL32UTF8 cho đa ngôn ngữ

POST-INSTALL:

  → Cấu hình listener.ora, tnsnames.ora

  → Tạo tablespace riêng cho từng schema (DATA, INDEX, TEMP)

  → Cấu hình UNDO tablespace đủ lớn cho workload ETL

  → Cấu hình REDO log groups — ít nhất 3 groups, size đủ lớn

  → Setup RMAN backup

  → Cấu hình Archive Log mode nếu cần recovery

  → Tạo user/schema cho ứng dụng với đúng privileges

  → Test connection từ app server

  → Cấu hình Prometheus exporter để monitoring

*Bạn đã làm toàn bộ checklist này cho VAECO AMOS và AML Agribank.*

---

**Q2.**

*"Tablespace trong Oracle là gì? Bạn thiết kế tablespace như thế nào cho một hệ thống ETL?"*

💡 **Gợi ý trả lời:** Tablespace là logical storage unit — nhóm các data files vật lý lại thành một đơn vị quản lý. Schema objects (table, index) được assign vào tablespace.

Thiết kế cho ETL:

SYSTEM          → internal Oracle objects, không đụng vào

SYSAUX          → auxiliary Oracle objects

UNDOTBS         → UNDO data, cần đủ lớn cho long-running ETL

TEMP            → temporary operations (sort, hash join)

DATA\_TS         → bảng dữ liệu chính

STAGING\_TS      → bảng staging ETL — có thể để NOLOGGING

INDEX\_TS        → indexes tách riêng — dễ rebuild độc lập

ARCHIVE\_TS      → dữ liệu lịch sử, ít truy cập

Tại sao tách INDEX\_TS riêng: khi ETL load lớn cần rebuild index → chỉ affect INDEX\_TS, không ảnh hưởng DATA\_TS. Với I/O: có thể đặt DATA\_TS và INDEX\_TS trên disk khác nhau để parallel I/O.

---

**Q3.**

*"UNDO trong Oracle làm gì? Tại sao ETL cần cấu hình UNDO đủ lớn?"*

💡 **Gợi ý trả lời:** UNDO lưu trữ ảnh cũ (before image) của dữ liệu trước khi bị thay đổi. Dùng cho:

* **Rollback**: nếu transaction fail → dùng UNDO để restore về trạng thái cũ

* **Read Consistency**: query đang chạy thấy snapshot nhất quán tại thời điểm bắt đầu, dù có DML khác xảy ra sau

* **Flashback**: xem dữ liệu tại thời điểm trong quá khứ

ETL cần UNDO lớn vì:

* Transaction ETL chạy lâu (hàng giờ) → cần UNDO giữ before image suốt thời gian đó

* Nhiều session chạy song song → mỗi session dùng UNDO riêng

* Nếu UNDO không đủ → ORA-01555: Snapshot too old — lỗi bạn đã gặp ở LPBank

*UNDO\_RETENTION parameter: tối thiểu bằng thời gian của query/transaction dài nhất.*

---

**Q4.**

*"Archive Log mode trong Oracle là gì? Khi nào cần bật, khi nào không cần?"*

💡 **Gợi ý trả lời:**

**NOARCHIVELOG mode** (mặc định):

* Redo log files bị overwrite khi đầy

* Backup: chỉ có thể offline backup (shutdown DB trước)

* Recovery: chỉ restore về thời điểm backup gần nhất — mất data từ backup đến lúc crash

**ARCHIVELOG mode**:

* Redo log files được archive trước khi overwrite → có lịch sử đầy đủ

* Backup: online backup trong khi DB vẫn chạy (RMAN hot backup)

* Recovery: Point-in-Time Recovery — restore về bất kỳ thời điểm nào

Khi nào bật ARCHIVELOG:

* Production database — bắt buộc

* Cần online backup không downtime

* Cần HA/DR với Data Guard/Replication

Khi nào không cần:

* Dev/Test environment

* Database có thể rebuild từ scratch nhanh chóng

* ETL staging database thuần trung gian, data có thể reload

*Ở VAECO: DB App PostgreSQL bật WAL Archiving — equivalent với Oracle Archive Log.*

---

**Q5.**

*"Bạn quản lý PostgreSQL 14 cho VAECO. Các parameter quan trọng nhất cần tune trong postgresql.conf là gì?"*

💡 **Gợi ý trả lời — các parameter bạn đã config thực tế:**

\# Memory

shared\_buffers \= 25% RAM          \# Buffer cache chính

effective\_cache\_size \= 75% RAM    \# Hint cho optimizer

work\_mem \= 64MB                   \# Mỗi sort/hash operation

maintenance\_work\_mem \= 1GB        \# VACUUM, CREATE INDEX

\# WAL & Replication

wal\_level \= replica               \# Bắt buộc cho Streaming Replication

archive\_mode \= on                 \# Bật WAL Archiving

archive\_command \= 'cp %p /archive/%f'

max\_wal\_senders \= 5               \# Số Standby tối đa

wal\_keep\_size \= 1GB               \# Giữ WAL trên Primary cho Standby

\# Performance

max\_connections \= 200             \# Phù hợp với 1.000+ users qua connection pool

checkpoint\_completion\_target \= 0.9

random\_page\_cost \= 1.1            \# SSD storage

\# Logging

log\_min\_duration\_statement \= 1000 \# Log query \> 1 giây

log\_lock\_waits \= on               \# Log khi chờ lock

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q6.**

*"RMAN backup trong Oracle hoạt động thế nào? Bạn thiết kế backup strategy như thế nào cho hệ thống production?"*

💡 **Gợi ý trả lời:**

RMAN (Recovery Manager) là Oracle's built-in backup tool:

* Backup datafiles, control file, archive logs

* Incremental backup: chỉ backup blocks đã thay đổi

* Compression: giảm size backup đáng kể

* Catalog: lưu metadata backup history

Backup strategy điển hình cho production:

Daily:   Incremental Level 1 backup (chỉ changed blocks)

Weekly:  Full backup Level 0 (base cho incremental)

Monthly: Full backup lưu offsite

RMAN script ví dụ:

BACKUP INCREMENTAL LEVEL 1 

  FOR RECOVER OF COPY WITH TAG 'daily\_backup'

  DATABASE;

BACKUP ARCHIVELOG ALL DELETE INPUT;

Backup bao nhiêu lâu thì đủ: phụ thuộc RPO (Recovery Point Objective) — business chấp nhận mất tối đa bao nhiêu data? Nếu RPO \= 1 giờ → archive log backup mỗi giờ.

*Bạn đã duy trì backup hằng ngày cho VAECO — kể chi tiết strategy bạn dùng.*

---

**Q7.**

*"Tại sao backup PostgreSQL của VAECO chạy 3 giờ 5 phút? Bạn phân tích root cause như thế nào và tại sao pg\_repack giải quyết được vấn đề?"*

💡 **Đây là case đặc trưng nhất của bạn — cần kể rõ từng bước:**

**Bước 1 — Phát hiện vấn đề:** pg\_dump với \-j 8 (8 parallel jobs) vẫn chậm. Tăng \-j không giúp được gì. Đây là dấu hiệu bottleneck không phải ở số lượng table mà ở một table đơn cực lớn.

**Bước 2 — Phân tích:**

\-- Tìm bảng chiếm dung lượng lớn nhất

SELECT relname, pg\_size\_pretty(pg\_total\_relation\_size(oid))

FROM pg\_class ORDER BY pg\_total\_relation\_size(oid) DESC LIMIT 10;

\-- Kết quả: dbfs\_data TOAST table \= 81GB (\~33% toàn DB)

**Bước 3 — Hiểu tại sao \-j không giúp:**

* pg\_dump \-j parallel hóa theo TABLE — mỗi thread dump 1 table

* Một table đơn không thể chia cho nhiều thread → TOAST table 81GB chạy single-thread

* 81GB single-thread \= bottleneck tuyến tính

**Bước 4 — Root cause của 81GB TOAST:**

* Bảng dbfs\_data lưu \~2.4 triệu binary files (attachments, documents)

* PostgreSQL lưu large objects trong TOAST table riêng

* Sau nhiều năm insert/delete → TOAST bị bloat (dead tuples chiếm space nhưng không được giải phóng)

* Physical size 81GB nhưng actual data chỉ vài GB

**Bước 5 — Giải pháp pg\_repack:**

\# pg\_repack rebuild bảng online, không lock

\# Test trên DR Acceptance trước

pg\_repack \-d mydb \-t dbfs\_data

\# Kết quả: TOAST từ 81GB → 4GB

**Bước 6 — Kết quả:**

* Backup từ 3h05 → 15 phút (giảm 92%)

* Dung lượng backup từ 328GB → 18GB

*Tại sao test trên DR Acceptance trước: pg\_repack cần extra disk space tạm thời bằng size bảng đó → cần đảm bảo có đủ disk trước khi chạy Production.*

---

**Q8.**

*"Oracle và PostgreSQL có những điểm khác biệt quan trọng nào mà một DBA cần biết khi quản lý cả hai?"*

💡 **Gợi ý trả lời — từ kinh nghiệm thực tế của bạn:**

| Khía cạnh | Oracle | PostgreSQL |
| :---- | :---- | :---- |
| **Transaction** | Auto-commit OFF mặc định | Auto-commit ON mặc định |
| **NULL handling** | NULL ≠ empty string | NULL ≠ empty string (giống Oracle) |
| **Sequence** | NEXTVAL riêng biệt | SERIAL hoặc GENERATED ALWAYS |
| **Backup** | RMAN | pg\_dump, pg\_basebackup |
| **Replication** | Data Guard, GoldenGate | Streaming Replication, Logical Replication |
| **Storage** | Tablespace → Datafile | Database → Schema → Table |
| **Connection** | Dedicated server process | Process per connection — cần PgBouncer |
| **Vacuum** | Auto UNDO cleanup | Cần VACUUM để reclaim dead tuples |
| **Monitoring** | V$ views | pg\_stat\_\* views |
| **Licensing** | Commercial, đắt | Open source, miễn phí |

Điểm hay bị nhầm nhất:

* PostgreSQL cần **VACUUM** định kỳ để tránh table bloat — Oracle không có khái niệm này

* PostgreSQL **connections** tốn RAM nhiều hơn Oracle → cần connection pooler (PgBouncer) cho 1.000+ users

* Oracle **NULL và empty string** là khác nhau (Oracle coi '' là NULL)

---

**Q9.**

*"VACUUM trong PostgreSQL là gì? Tại sao bỏ qua VACUUM có thể gây ra vấn đề nghiêm trọng?"*

💡 **Gợi ý trả lời:**

PostgreSQL dùng MVCC (Multi-Version Concurrency Control): khi UPDATE/DELETE, row cũ không bị xóa ngay — được đánh dấu là "dead tuple". VACUUM thu dọn dead tuples này.

**Nếu không VACUUM:**

1. **Table bloat**: dead tuples chiếm space → bảng phình to vô hạn → scan chậm hơn. Đây chính là nguyên nhân TOAST 81GB ở VAECO

2. **Index bloat**: tương tự, index entries trỏ vào dead tuples → index lớn hơn cần thiết

3. **Transaction ID Wraparound** (nghiêm trọng nhất): PostgreSQL dùng 32-bit transaction ID, sau \~2 tỷ transactions sẽ wraparound. Nếu VACUUM không chạy kịp → DB sẽ shutdown để bảo vệ data integrity — production down hoàn toàn

Các loại VACUUM:

VACUUM table\_name;           \-- Thu dọn dead tuples, không lock

VACUUM FULL table\_name;      \-- Rebuild hoàn toàn, lock table, giống pg\_repack

VACUUM ANALYZE table\_name;   \-- Vacuum \+ update statistics

Autovacuum: PostgreSQL có daemon tự động chạy VACUUM. Cần tune các parameter cho hệ thống write-heavy:

autovacuum\_vacuum\_scale\_factor \= 0.01   \# Trigger khi 1% rows là dead

autovacuum\_analyze\_scale\_factor \= 0.005

---

**Q10.**

*"Bạn quản lý DB cho 1.000+ users concurrent ở VAECO. Làm thế nào để handle connection management hiệu quả?"*

💡 **Gợi ý trả lời:**

**Vấn đề**: PostgreSQL tạo 1 process per connection — 1.000 connections \= 1.000 processes. Mỗi process \~5-10MB RAM → 5-10GB RAM chỉ cho connections. Query planning overhead lớn.

**Giải pháp: Connection Pooler**

PgBouncer là connection pooler phổ biến nhất:

1.000 app connections → PgBouncer → 50-100 actual DB connections

Modes:

\- Session pooling: 1 client \= 1 DB connection (suốt session)

\- Transaction pooling: connection chỉ hold khi có transaction (hiệu quả nhất)

\- Statement pooling: connection trả về sau mỗi statement

**Cấu hình thực tế VAECO:**

* App server kết nối đến PgBouncer port 6432

* PgBouncer maintain pool 50-100 connections đến PostgreSQL

* 1.000+ users share pool đó → DB chỉ thấy 50-100 connections

**Monitoring connections:**

SELECT count(\*), state, wait\_event\_type

FROM pg\_stat\_activity

GROUP BY state, wait\_event\_type;

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q11.**

*"Lúc 2 giờ sáng, monitoring alert báo disk của Oracle DB server đã đạt 95%. ETL batch đêm đang chạy dở. Bạn xử lý như thế nào?"*

💡 **Gợi ý trả lời — không panic, xử lý có hệ thống:**

BƯỚC 1 — ĐÁNH GIÁ NHANH (5 phút):

  → Disk nào đầy? DATA disk, ARCHIVE LOG disk, hay TEMP?

  → df \-h để xem tất cả mount points

  → Batch đang ở bước nào? Có thể dừng an toàn không?

BƯỚC 2 — XỬ LÝ THEO LOẠI DISK:

  Nếu ARCHIVE LOG disk đầy (phổ biến nhất):

  → RMAN DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-1';

  → Giải phóng archive logs cũ đã backup xong

  → Batch có thể tiếp tục

  Nếu TEMP tablespace đầy:

  → Query nào đang sort lớn? → V$SORT\_USAGE

  → Kill session đó nếu có thể

  → Tăng TEMP tablespace: ALTER TABLESPACE TEMP ADD TEMPFILE SIZE 10G

  Nếu DATA disk đầy:

  → Nguy hiểm nhất — DB có thể crash

  → Dừng batch ngay lập tức

  → Tìm file lớn: find / \-size \+1G → xóa files không cần thiết

  → Add datafile mới: ALTER TABLESPACE DATA ADD DATAFILE SIZE 10G

BƯỚC 3 — SAU KHI GIẢI QUYẾT:

  → Resume batch nếu idempotent

  → Report incident, root cause

  → Long-term: setup alert ở 80% thay vì 95%

  → Xem xét auto-extend datafiles

---

**Q12.**

*"Một developer báo rằng query của họ chạy nhanh hôm qua nhưng hôm nay bị lock và phải chờ rất lâu. Bạn tìm và xử lý blocking session như thế nào?"*

💡 **Gợi ý trả lời:**

**Oracle:**

\-- Tìm blocking session

SELECT 

  s1.username || '@' || s1.machine AS blocking\_session,

  s2.username || '@' || s2.machine AS waiting\_session,

  s1.sid, s1.serial\#,

  s1.sql\_id AS blocking\_sql

FROM v$lock l1

JOIN v$lock l2 ON l1.id1 \= l2.id1 AND l2.block \= 0

JOIN v$session s1 ON l1.sid \= s1.sid

JOIN v$session s2 ON l2.sid \= s2.sid

WHERE l1.block \= 1;

\-- Kill blocking session nếu cần

ALTER SYSTEM KILL SESSION 'sid,serial\#' IMMEDIATE;

**PostgreSQL:**

\-- Tìm blocking

SELECT 

  pg\_blocking\_pids(pid) AS blocked\_by,

  pid, usename, query, state, wait\_event

FROM pg\_stat\_activity

WHERE cardinality(pg\_blocking\_pids(pid)) \> 0;

\-- Kill nếu cần

SELECT pg\_terminate\_backend(pid);

**Phân tích nguyên nhân:**

* Blocking thường do: transaction chưa COMMIT, long-running UPDATE không có Index → full scan → hold lock lâu

* Hỏi developer: có transaction nào chưa commit không? Application có COMMIT sau mỗi operation không?

---

**Q13.**

*"Bạn cần clone database Production xuống môi trường Test cho team QA dùng. Database 500GB. Quy trình bạn làm như thế nào?"*

💡 **Gợi ý trả lời — bạn đã làm điều này ở VAECO:**

**Oracle:**

Option 1 — RMAN Duplicate (nhanh, online):

  RMAN\> DUPLICATE TARGET DATABASE TO testdb

        FROM ACTIVE DATABASE NOFILENAMECHECK;

Option 2 — Export/Import Data Pump (chọn lọc schema):

  expdp system/pwd SCHEMAS=app\_schema 

        DIRECTORY=dpump\_dir DUMPFILE=prod\_clone.dmp

  impdp system/pwd SCHEMAS=app\_schema 

        DIRECTORY=dpump\_dir DUMPFILE=prod\_clone.dmp

**PostgreSQL (VAECO):**

\# pg\_basebackup: clone toàn bộ cluster

pg\_basebackup \-h prod\_host \-U replicator \\

  \-D /var/lib/postgresql/test\_data \-P \-Xs \-R

\# Hoặc pg\_dump/restore cho selective

pg\_dump \-h prod\_host \-U postgres mydb | \\

  psql \-h test\_host \-U postgres mydb

**Quan trọng — Data Masking trước khi giao QA:**

* Mask PII data: số CMND, số tài khoản, họ tên

* Ở hệ thống ngân hàng/AML: bắt buộc theo quy định bảo mật

UPDATE customers SET 

  account\_no \= 'XXXX' || SUBSTR(account\_no, \-4),

  full\_name \= 'Test User ' || id;

---

**Q14.**

*"Database production bị corrupted một số data blocks do lỗi storage. Bạn xử lý như thế nào?"*

💡 **Gợi ý trả lời:**

**Oracle:**

\-- Bước 1: Xác định blocks bị corrupt

SELECT \* FROM V$DATABASE\_BLOCK\_CORRUPTION;

\-- Hoặc sau khi phát hiện ORA-01578:

\-- ORA-01578: ORACLE data block corrupted (file\# X, block\# Y)

\-- Bước 2: RMAN Block Media Recovery (không cần restore toàn bộ)

RMAN\> BLOCKRECOVER DATAFILE 5 BLOCK 100, 200, 300;

\-- RMAN tìm good copy từ backup, restore đúng blocks đó

\-- Bước 3: Nếu không có backup:

\-- DBMS\_REPAIR để đánh dấu corrupt blocks, skip khi query

EXEC DBMS\_REPAIR.FIX\_CORRUPT\_BLOCKS('SCHEMA', 'TABLE');

**PostgreSQL:**

\# Dùng pg\_filedump để analyze

\# Zero out corrupt page (mất data nhưng DB không crash)

\# Restore từ backup \+ WAL replay đến thời điểm trước corruption

**Lesson learned:**

* Corruption thường do storage failure, không phải DB bug

* Checksum: bật data\_checksums khi init PostgreSQL cluster — phát hiện corruption sớm

* Oracle: DB\_BLOCK\_CHECKSUM \= TYPICAL

* Prevention tốt hơn recovery: RAID, redundant storage, regular backup verify

---

**📊 Tổng kết nhóm 4**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | Checklist cài đặt Oracle | ⭐⭐ | VAECO, AML |
| Q2 | Tablespace design ETL | ⭐⭐ | VAECO, NHNN |
| Q3 | UNDO & ORA-01555 | ⭐⭐ | LPBank, AML |
| Q4 | Archive Log mode | ⭐⭐ | VAECO, AML |
| Q5 | PostgreSQL key parameters | ⭐⭐ | VAECO |
| Q6 | RMAN backup strategy | ⭐⭐⭐ | VAECO, AML |
| Q7 | pg\_repack TOAST 92% | ⭐⭐⭐ | VAECO Bảo trì |
| Q8 | Oracle vs PostgreSQL DBA | ⭐⭐⭐ | VAECO |
| Q9 | VACUUM & bloat | ⭐⭐⭐ | VAECO |
| Q10 | Connection pooling 1000+ users | ⭐⭐⭐ | VAECO |
| Q11 | Disk đầy lúc 2h sáng | ⭐⭐⭐ | VAECO, AML |
| Q12 | Find & kill blocking session | ⭐⭐⭐ | VAECO, NHNN |
| Q13 | Clone Production → Test | ⭐⭐ | VAECO Bảo trì |
| Q14 | Block corruption recovery | ⭐⭐⭐ | VAECO |

---

Bạn muốn luyện tập trả lời câu nào, hay chuyển sang **nhóm 5: HA/DR & Replication** — nhóm bạn có kinh nghiệm xuất sắc nhất?

**Nhóm 5: HA/DR & Replication — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"HA và DR khác nhau thế nào? Trong hệ thống VAECO bạn xây dựng, đâu là HA và đâu là DR?"*

💡 **Gợi ý trả lời:**

|  | HA (High Availability) | DR (Disaster Recovery) |
| :---- | :---- | :---- |
| Mục tiêu | Tránh downtime do lỗi thông thường | Phục hồi khi thảm họa toàn bộ site |
| Phạm vi | Trong cùng datacenter | Datacenter khác, địa lý xa |
| RTO | Giây đến phút | Phút đến giờ |
| RPO | Gần 0 | Có thể mất vài phút data |
| Ví dụ | Primary → Standby cùng DC | Primary DC → DR site khác thành phố |

**Mapping vào hệ thống VAECO của bạn:**

Primary DC ──streaming──► Backup DC          \= HA

                                               (cùng datacenter hoặc gần)

Primary DC ──WAL archive─► Backup DR          \= DR

                        ──WAL archive─► DR Standby  \= DR

Primary DC → Backup DC: failover nhanh, RPO gần 0 → đây là HA layer Backup DR → DR Standby: ở site khác, dùng WAL archive → đây là DR layer

---

**Q2.**

*"RPO và RTO là gì? Hai chỉ số này ảnh hưởng thế nào đến thiết kế hệ thống replication?"*

💡 **Gợi ý trả lời:**

**RPO (Recovery Point Objective):** Tối đa bao nhiêu data có thể mất khi xảy ra sự cố.

* RPO \= 0: zero data loss — cần synchronous replication

* RPO \= 5 phút: chấp nhận mất tối đa 5 phút data — có thể dùng async replication

* RPO \= 1 giờ: archive log backup mỗi giờ là đủ

**RTO (Recovery Time Objective):** Tối đa bao lâu hệ thống có thể down trước khi phải hoạt động lại.

* RTO \= 1 phút: cần auto-failover với pre-warmed standby

* RTO \= 30 phút: manual failover có thể chấp nhận

* RTO \= 4 giờ: restore từ backup là đủ

**Ảnh hưởng đến thiết kế:**

RPO \= 0, RTO \= 1 phút  → Synchronous Streaming Replication

                          \+ Auto-failover (Patroni/repmgr)

                          → Đắt nhất, phức tạp nhất

RPO \= 5 phút, RTO \= 15 phút → Async Streaming Replication

                               \+ Manual failover

                               → VAECO approach

RPO \= 1 giờ, RTO \= 4 giờ → WAL Archive \+ Restore

                            → DR site xa

*Hệ thống VAECO của bạn target RPO và RTO là bao nhiêu? Đây là câu hỏi follow-up chắc chắn.*

---

**Q3.**

*"Streaming Replication trong PostgreSQL hoạt động như thế nào? Primary và Standby giao tiếp với nhau qua cơ chế gì?"*

💡 **Gợi ý trả lời — giải thích cơ chế từ đầu:**

PRIMARY                          STANDBY

────────                         ────────

\[WAL Writer\]                     \[WAL Receiver\]

    │                                 │

    │ generate WAL records            │

    ▼                                 │

\[WAL Buffer\]                         │

    │                                 │

    │◄────── TCP connection ──────────┘

    │        (replication slot)

    │

\[WAL Sender Process\]

    │

    └──► stream WAL records to Standby

         Standby apply WAL → catch up

**Chi tiết:**

1. Primary ghi mọi thay đổi vào WAL (Write-Ahead Log) trước khi apply vào data files

2. WAL Sender process trên Primary stream WAL records qua TCP đến Standby

3. WAL Receiver trên Standby nhận và ghi WAL vào local storage

4. Startup process apply WAL → Standby luôn có bản copy gần giống Primary

**Synchronous vs Asynchronous:**

* **Async** (mặc định): Primary commit ngay, Standby catch up sau → có thể lag → RPO \> 0

* **Sync**: Primary chờ Standby confirm nhận WAL trước khi báo commit thành công → RPO \= 0 nhưng latency tăng

**Replication lag monitoring:**

\-- Trên Primary

SELECT client\_addr, state, 

       pg\_wal\_lsn\_diff(pg\_current\_wal\_lsn(), sent\_lsn) AS send\_lag,

       pg\_wal\_lsn\_diff(sent\_lsn, replay\_lsn) AS replay\_lag

FROM pg\_stat\_replication;

---

**Q4.**

*"WAL là gì? Tại sao PostgreSQL và Oracle đều dùng WAL/Redo Log? Không có WAL thì sao?"*

💡 **Gợi ý trả lời:**

WAL (Write-Ahead Log) / Redo Log là log ghi lại mọi thay đổi TRƯỚC khi apply vào data files.

**Tại sao cần WAL:** Nếu không có WAL — DB crash giữa chừng khi đang write data → data files bị partial write → corruption.

WAL đảm bảo durability:

Không có WAL:

  1\. Modify data in buffer

  2\. Write to data file ── CRASH HERE ──► data file corrupt

Có WAL:

  1\. Write change to WAL (append-only, sequential, nhanh)

  2\. Confirm WAL written → return success to client

  3\. Eventually write to data file

  4\. CRASH HERE → replay WAL to reconstruct data file

**WAL dùng cho nhiều mục đích:**

* **Crash Recovery**: replay WAL sau crash

* **Replication**: stream WAL đến Standby

* **Point-in-Time Recovery**: replay WAL đến thời điểm bất kỳ

* **Logical Replication**: decode WAL thành logical changes

**WAL Archiving:** Copy WAL segments sang storage khác (NFS, S3) trước khi xóa → dùng cho DR site xa và PITR.

---

**Q5.**

*"Replication slot trong PostgreSQL là gì? Tại sao cần replication slot và nguy cơ nếu không quản lý cẩn thận?"*

💡 **Gợi ý trả lời:**

Replication slot đảm bảo Primary **không xóa WAL segments** cho đến khi Standby đã consume xong.

**Không có replication slot:**

* Primary xóa WAL cũ theo wal\_keep\_size

* Nếu Standby lag quá nhiều → WAL bị xóa trước khi Standby đọc → Standby mất sync → phải rebuild từ pg\_basebackup

**Có replication slot:**

\-- Tạo replication slot

SELECT pg\_create\_physical\_replication\_slot('standby\_slot');

\-- Standby dùng slot này → Primary giữ WAL cho đến khi Standby consume

**Nguy cơ của replication slot:** Nếu Standby bị down lâu → slot ngăn Primary xóa WAL → WAL tích tụ vô hạn → **disk đầy → Primary crash**.

Đây là case thực tế nguy hiểm. Giải pháp:

\-- Monitor slot lag

SELECT slot\_name, pg\_wal\_lsn\_diff(pg\_current\_wal\_lsn(), restart\_lsn) 

AS lag\_bytes FROM pg\_replication\_slots;

\-- Alert khi lag \> threshold

\-- Nếu Standby down lâu: drop slot để bảo vệ Primary

SELECT pg\_drop\_replication\_slot('standby\_slot');

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q6.**

*"Giải thích chi tiết kiến trúc PostgreSQL 14 HA/DR 4 tầng bạn xây dựng cho VAECO. Tại sao cần đến 4 tầng?"*

💡 **Gợi ý trả lời — đây là điểm mạnh nhất của bạn:**

┌─────────────────────────────────────────────────────┐

│                  DATACENTER CHÍNH                    │

│                                                      │

│  \[Primary DC\]                                        │

│   PostgreSQL 14                                      │

│   \- Nhận toàn bộ write từ app AMOS                  │

│   \- 1.000+ users                                     │

│        │                                             │

│        │ Streaming Replication (async)               │

│        ▼                                             │

│  \[Backup DC\]                                         │

│   Hot Standby                                        │

│   \- Sync gần realtime với Primary                   │

│   \- Sẵn sàng promote trong vài phút                │

│   \- Có thể phục vụ read queries                     │

└─────────────────────────────────────────────────────┘

         │

         │ WAL Archiving

         ▼

┌─────────────────────────────────────────────────────┐

│                   DR SITE (xa hơn)                   │

│                                                      │

│  \[Backup DR\]                                         │

│   Warm Standby                                       │

│   \- Nhận WAL archive từ Primary                     │

│   \- Có thể lag vài phút                             │

│        │                                             │

│        │ Cascade Streaming Replication               │

│        ▼                                             │

│  \[DR Standby\]                                        │

│   Cold Standby                                       │

│   \- Backup của Backup DR                            │

│   \- Last resort nếu tất cả trên fail               │

└─────────────────────────────────────────────────────┘

**Tại sao cần 4 tầng:**

* Primary → Backup DC: HA, failover nhanh, cùng datacenter

* Backup DC → Backup DR: DR layer 1, site khác

* Backup DR → DR Standby: DR layer 2, bảo vệ khỏi thảm họa toàn DR site

* Yêu cầu business VAECO: aviation MRO system, downtime ảnh hưởng trực tiếp đến bảo dưỡng máy bay → SLA rất cao

**Failover procedure:**

Scenario 1 — Primary DC fail:

  Promote Backup DC → New Primary

  DR Standby redirect WAL archive sang Backup DC mới

Scenario 2 — Cả datacenter chính fail:

  Promote Backup DR → New Primary

  DR Standby follow Backup DR

---

**Q7.**

*"Bạn đã phát triển hệ thống tự động đồng bộ WAL song song 4 luồng. Tại sao cần song song? Kỹ thuật chống chạy trùng bạn dùng là gì?"*

💡 **Gợi ý trả lời — case kỹ thuật rất hay:**

**Vấn đề khi sync WAL tuần tự:**

WAL segments: 000001, 000002, 000003, ... 000100

Tuần tự:

  Copy 000001 → done → copy 000002 → done → ...

  → Nếu mỗi segment \~16MB, 100 segments \= 1.6GB

  → Single thread copy qua network \= chậm

  → Replication lag tăng dần

**Giải pháp 4 luồng song song:**

\# Pseudo-code của script bạn viết

import threading

from queue import Queue

wal\_queue \= Queue()

def wal\_producer():

    \# Scan thư mục WAL archive trên Primary

    for wal\_file in get\_pending\_wal\_files():

        wal\_queue.put(wal\_file)

def wal\_worker(thread\_id):

    while True:

        wal\_file \= wal\_queue.get()

        if wal\_file is None:

            break

        try:

            rsync\_wal(wal\_file, dr\_target)

            mark\_completed(wal\_file)  \# Ghi vào tracking table

        except Exception as e:

            send\_alert\_email(f"Thread {thread\_id}: {e}")

            retry\_queue.put(wal\_file)

\# Start 4 workers

threads \= \[threading.Thread(target=wal\_worker, args=(i,)) for i in range(4)\]

**Cơ chế chống chạy trùng:**

\# Dùng lock file

LOCK\_FILE="/var/run/wal\_sync.lock"

if \[ \-f "$LOCK\_FILE" \]; then

    echo "Another instance running, exit"

    exit 1

fi

\# Tạo lock file với PID

echo $$ \> "$LOCK\_FILE"

trap "rm \-f $LOCK\_FILE" EXIT  \# Xóa khi script kết thúc

\# ... run sync logic ...

Hoặc dùng flock:

flock \-n /var/run/wal\_sync.lock ./wal\_sync.sh

**Tracking để tránh copy lại file đã xong:**

CREATE TABLE wal\_sync\_log (

    wal\_filename VARCHAR(100) PRIMARY KEY,

    synced\_at TIMESTAMP,

    thread\_id INT,

    status VARCHAR(20)  \-- COMPLETED, FAILED, IN\_PROGRESS

);

---

**Q8.**

*"Mô tả chi tiết cách bạn xử lý sự cố DR mất đồng bộ 6 tiếng mà không cần rebuild từ pg\_basebackup."*

💡 **Đây là case thực chiến xuất sắc nhất — kể rõ từng bước:**

**Tình huống:** DR Standby bị mất kết nối 6 tiếng (network outage hoặc server restart). Khi kết nối lại, Standby không thể sync tiếp vì WAL segments của 6 tiếng đó đã bị xóa khỏi Primary (Primary chỉ giữ WAL theo wal\_keep\_size).

**Lỗi điển hình:**

FATAL: requested WAL segment 000000010000002A00000001 

has already been removed

**Quy trình xử lý thông thường (không dùng):**

\# Rebuild từ pg\_basebackup — mất nhiều giờ với DB lớn

pg\_basebackup \-h primary \-D /var/lib/postgresql/data \-P \-Xs \-R

\# 500GB DB → có thể mất 3-4 tiếng

**Cách bạn xử lý — dùng WAL Archive:**

\# Bước 1: Xác định Standby đang ở WAL position nào

\# Trên Standby:

psql \-c "SELECT pg\_last\_wal\_receive\_lsn(), pg\_last\_wal\_replay\_lsn();"

\# Bước 2: WAL archive có đủ segments từ vị trí đó không?

ls /wal\_archive/ | grep "^00000001000000\[2-3\]"

\# Kiểm tra có đủ segments lấp đầy gap 6 tiếng

\# Bước 3: Cấu hình Standby dùng restore\_command từ archive

\# postgresql.conf trên Standby:

restore\_command \= 'cp /wal\_archive/%f %p'

\# Bước 4: Restart Standby trong recovery mode

\# Standby sẽ tự replay WAL từ archive để catch up

\# Không cần copy lại data files → tiết kiệm hàng giờ

\# Bước 5: Monitor recovery progress

tail \-f /var/log/postgresql/postgresql.log

\# "LOG: restored log file X from archive"

\# "LOG: recovery stopping before commit of transaction..."

\# Bước 6: Sau khi catch up, switch về Streaming Replication

\# Standby tự động switch khi archive WAL đã apply xong

\# và Primary WAL stream có thể tiếp tục từ đó

**Tại sao cách này work:**

* WAL Archive có đầy đủ 6 tiếng WAL segments còn nguyên

* Chỉ cần replay WAL, không cần copy lại 500GB data files

* Thời gian: replay 6 tiếng WAL \<\< copy 500GB qua network

**Kết quả:** Phục hồi trong vài chục phút, 0 data loss, không downtime.

---

**Q9.**

*"Failover và Switchover khác nhau thế nào? Sau khi failover xong, bạn rebuild Primary cũ thành Standby mới như thế nào?"*

💡 **Gợi ý trả lời:**

**Switchover** (có kế hoạch):

Graceful, planned maintenance:

  1\. Primary ngừng nhận write

  2\. Đợi Standby sync hoàn toàn (lag \= 0\)

  3\. Promote Standby → New Primary

  4\. Old Primary → New Standby


RPO \= 0 (zero data loss)

RTO \= vài phút

**Failover** (khẩn cấp):

Emergency, Primary đột ngột fail:

  1\. Phát hiện Primary down

  2\. Confirm Primary thực sự down (tránh split-brain)

  3\. Promote Standby → New Primary

  4\. App redirect connection đến New Primary


RPO \> 0 (có thể mất data chưa replicate kịp)

RTO \= phút

**Rebuild Primary cũ thành Standby mới (PostgreSQL):**

\# Sau failover, Primary cũ đã được sửa chữa (storage fix, etc.)

\# Cách 1: pg\_rewind (nhanh hơn) — PostgreSQL 9.5+

\# Chỉ sync delta giữa old Primary và New Primary

pg\_rewind \--target-pgdata=/var/lib/postgresql/data \\

          \--source-server="host=new\_primary user=postgres"

\# Cách 2: pg\_basebackup (đơn giản hơn, chậm hơn)

pg\_basebackup \-h new\_primary \-U replicator \\

  \-D /var/lib/postgresql/data \-P \-Xs \-R

\# Sau đó start PostgreSQL trong standby mode

\# Nó sẽ tự động follow New Primary

**pg\_rewind vs pg\_basebackup:**

* pg\_rewind: chỉ copy blocks đã thay đổi sau divergence point → nhanh hơn nhiều với DB lớn

* pg\_basebackup: copy toàn bộ → chậm nhưng luôn work

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q10.**

*"2 giờ sáng, Grafana alert báo: 'Primary DC PostgreSQL không phản hồi'. Bạn là DBA trực. Mô tả từng bước xử lý."*

💡 **Gợi ý trả lời — incident response chuẩn:**

BƯỚC 1 — XÁC NHẬN SỰ CỐ (5 phút):

  → SSH vào Primary server còn được không?

  → Ping server còn sống không?

  → PostgreSQL process còn chạy không?

    ps aux | grep postgres

  → Thử connect:

    psql \-h primary \-U postgres \-c "SELECT 1"

  → Check PostgreSQL log:

    tail \-100 /var/log/postgresql/postgresql.log


  QUAN TRỌNG: Phân biệt DB down vs network down vs server down

  → Nếu chỉ network: không failover vội → tránh split-brain

BƯỚC 2 — TRÁNH SPLIT-BRAIN (critical):

  → Confirm Primary THỰC SỰ không thể serve write

  → Nếu network partition: Primary vẫn chạy nhưng app không connect được

  → Nếu failover khi Primary còn sống → 2 Primary cùng nhận write → data diverge

  → Dùng STONITH (Shoot The Other Node In The Head) hoặc

    fence Primary trước khi promote Standby

BƯỚC 3 — PROMOTE STANDBY:

  \# Trên Backup DC (Standby)

  pg\_ctl promote \-D /var/lib/postgresql/data

  \# Hoặc dùng pg\_promote() function (PG 12+)

  psql \-c "SELECT pg\_promote();"

BƯỚC 4 — REDIRECT APPLICATION:

  → Update HAProxy / PgBouncer config

  → Hoặc update DNS / VIP trỏ sang New Primary

  → App reconnect tự động

BƯỚC 5 — VERIFY:

  → Chạy smoke test: insert 1 row, select lại

  → Kiểm tra replication lag với DR site

  → Monitor trong 15 phút đầu chặt chẽ

BƯỚC 6 — COMMUNICATION:

  → Notify team: failover complete, RTO \= X phút

  → Log incident: thời gian phát hiện, nguyên nhân, actions taken

BƯỚC 7 — POST-INCIDENT:

  → Sửa Primary cũ

  → Rebuild thành Standby mới

  → Root cause analysis

  → Prevent recurrence

---

**Q11.**

*"Replication lag đột nhiên tăng từ 0 lên 30 giây trên hệ thống VAECO. Bạn tìm nguyên nhân và xử lý thế nào?"*

💡 **Gợi ý trả lời:**

**Bước 1 — Đo lag chính xác:**

\-- Trên Primary

SELECT 

  application\_name,

  pg\_wal\_lsn\_diff(pg\_current\_wal\_lsn(), sent\_lsn)/1024 AS send\_lag\_kb,

  pg\_wal\_lsn\_diff(sent\_lsn, write\_lsn)/1024 AS write\_lag\_kb,

  pg\_wal\_lsn\_diff(write\_lsn, flush\_lsn)/1024 AS flush\_lag\_kb,

  pg\_wal\_lsn\_diff(flush\_lsn, replay\_lsn)/1024 AS replay\_lag\_kb

FROM pg\_stat\_replication;

**Bước 2 — Xác định lag ở tầng nào:**

Primary generate WAL ──► send ──► Standby write ──► flush ──► replay

send\_lag cao:    Network bottleneck giữa Primary và Standby

write\_lag cao:   Standby disk I/O chậm

replay\_lag cao:  Standby CPU bị load bởi query khác (read queries)

**Bước 3 — Xử lý theo nguyên nhân:**

Network lag:

  → Kiểm tra bandwidth: iftop, nethogs

  → ETL đang generate WAL nhiều → bình thường, lag sẽ giảm sau batch

  → Nếu network degraded: contact network team

Disk I/O lag trên Standby:

  → iostat \-x 1 → disk utilization

  → Có backup job đang chạy trên Standby không?

  → Prioritize WAL write: checkpoint\_completion\_target, bgwriter settings

Replay lag:

  → Standby đang phục vụ nhiều read query → CPU busy

  → max\_standby\_streaming\_delay: thời gian Standby chờ trước khi cancel query

    để apply WAL conflict

  → Cân nhắc tăng max\_standby\_streaming\_delay hoặc

    dedicated read replica riêng

---

**Q12.**

*"Bạn cần test toàn bộ DR plan của VAECO — simulate Primary DC fail và failover sang DR site. Bạn lên kế hoạch test như thế nào để không ảnh hưởng production?"*

💡 **Gợi ý trả lời:**

CHUẨN BỊ (1 tuần trước):

  → Thông báo stakeholder: DR test ngày X, Y giờ

  → Đảm bảo backup mới nhất

  → Verify Backup DC và DR site đang sync tốt

  → Prepare rollback plan nếu test fail

  → Chuẩn bị runbook từng bước

TRƯỚC KHI TEST:

  → Freeze change freeze: không deploy code mới 24h trước

  → Verify replication lag \= 0 trên tất cả tầng

  → Snapshot VM (nếu dùng virtualization)

  → Checklist sign-off từ team lead

THỰC HIỆN TEST:

  Giai đoạn 1 — Simulate Primary fail:

    → Stop PostgreSQL trên Primary DC (không phải server)

    → Hoặc block network từ Primary đến app servers

    → Đo RTO: bao lâu từ lúc Primary down đến khi app phục hồi?

  Giai đoạn 2 — Verify failover:

    → App kết nối được New Primary chưa?

    → Write/Read đều work không?

    → RPO: mất bao nhiêu data (so sánh transaction ID)?

  Giai đoạn 3 — Test DR site (nâng cao):

    → Simulate cả datacenter chính fail

    → Promote Backup DR → New Primary

    → Measure RTO và RPO

PHỤC HỒI SAU TEST:

  → Switchover về Primary cũ (có kế hoạch)

  → Verify data consistency

  → Document kết quả: RTO thực tế, RPO thực tế

POST-TEST:

  → So sánh với SLA: đạt không?

  → Gap analysis: chỗ nào chậm hơn dự kiến?

  → Update runbook dựa trên bài học

  → Schedule test định kỳ (quarterly)

---

**📊 Tổng kết nhóm 5**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | HA vs DR, mapping VAECO | ⭐⭐ | VAECO |
| Q2 | RPO vs RTO thiết kế | ⭐⭐ | VAECO |
| Q3 | Streaming Replication cơ chế | ⭐⭐ | VAECO |
| Q4 | WAL là gì, tại sao cần | ⭐⭐ | VAECO |
| Q5 | Replication slot & nguy cơ | ⭐⭐⭐ | VAECO |
| Q6 | Kiến trúc 4 tầng VAECO | ⭐⭐⭐ | VAECO |
| Q7 | WAL sync 4 luồng, chống trùng | ⭐⭐⭐ | VAECO Bảo trì |
| Q8 | DR mất đồng bộ 6 tiếng | ⭐⭐⭐⭐ | VAECO Bảo trì |
| Q9 | Failover vs Switchover, rebuild | ⭐⭐⭐ | VAECO |
| Q10 | Incident 2h sáng Primary down | ⭐⭐⭐⭐ | VAECO |
| Q11 | Replication lag tăng đột ngột | ⭐⭐⭐ | VAECO |
| Q12 | DR test plan | ⭐⭐⭐ | VAECO |

---

💡 **Lưu ý đặc biệt:** Nhóm 5 là **điểm khác biệt lớn nhất** của bạn so với các ứng viên DE khác. Hầu hết DE chỉ biết ETL và SQL — rất ít người có kinh nghiệm thực chiến về HA/DR 4 tầng, WAL sync 4 luồng và xử lý DR mất đồng bộ. Khi phỏng vấn, hãy chủ động đề cập những case này ngay cả khi interviewer chưa hỏi.

Bạn muốn luyện tập trả lời câu nào, hay chuyển sang **nhóm 6: Data Quality & Monitoring**?

**Nhóm 6: Data Quality & Monitoring — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"Data Quality là gì? Có bao nhiêu dimension của Data Quality và trong ETL bạn thường kiểm soát những dimension nào?"*

💡 **Gợi ý trả lời:**

6 dimension phổ biến nhất:

| Dimension | Ý nghĩa | Ví dụ trong AML |
| :---- | :---- | :---- |
| **Completeness** | Dữ liệu có đầy đủ không | transaction\_amount không được NULL |
| **Accuracy** | Dữ liệu có đúng không | Mã currency phải đúng ISO 4217 |
| **Consistency** | Dữ liệu nhất quán giữa các hệ thống | customer\_id trong transaction phải tồn tại trong customer table |
| **Timeliness** | Dữ liệu có đến đúng hạn không | Batch T+1 phải xong trước 6h sáng |
| **Uniqueness** | Không có duplicate | Mỗi transaction\_id chỉ xuất hiện 1 lần |
| **Validity** | Dữ liệu có đúng format/range không | Ngày không thể là 30/02, amount không thể âm |

**Trong ETL bạn đã làm:**

* AML Agribank: Completeness (not-null), Accuracy (ISO/LOV), Consistency (referential check)

* VAECO: Timeliness (batch window), Uniqueness (primary key check sau migrate)

* LPBank OFSAA: Consistency (row count match giữa source và target)

---

**Q2.**

*"Sự khác nhau giữa Data Quality check ở Staging layer và Core layer? Tại sao không chỉ check một chỗ?"*

💡 **Gợi ý trả lời:**

SOURCE → \[STAGING\] → \[CORE\]

            │           │

         DQ Check 1  DQ Check 2

**DQ check ở Staging:**

* Kiểm tra raw data từ nguồn: format đúng chưa, NULL ở đâu

* Mục tiêu: phát hiện vấn đề từ source sớm nhất

* Reject bản ghi lỗi vào error table, không block toàn batch

* Ví dụ: transaction\_date có đúng format DATE không?

**DQ check ở Core (trước khi load):**

* Kiểm tra sau transform: business rule đã apply đúng chưa

* Referential integrity: foreign key có tồn tại không

* Aggregate check: tổng amount Staging có khớp với Core không

* Ví dụ: customer\_id trong transaction phải có trong dim\_customer

**Tại sao cần cả hai:**

* Staging check: bắt lỗi từ nguồn — source system gửi sai data

* Core check: bắt lỗi transform — code ETL có bug không

* Nếu chỉ check Core: lỗi nguồn đã transform xong mới phát hiện → khó trace lại

* Nếu chỉ check Staging: lỗi logic transform không bị phát hiện

---

**Q3.**

*"Error table trong ETL dùng để làm gì? Bạn thiết kế error table như thế nào?"*

💡 **Gợi ý trả lời — từ kinh nghiệm AML của bạn:**

Error table lưu các bản ghi bị reject trong quá trình ETL, thay vì bỏ qua hoặc dừng toàn bộ batch.

**Schema điển hình:**

CREATE TABLE etl\_error\_log (

    error\_id        NUMBER GENERATED ALWAYS AS IDENTITY,

    batch\_id        VARCHAR2(50),       \-- Thuộc batch nào

    job\_name        VARCHAR2(100),      \-- Job nào phát hiện lỗi

    source\_system   VARCHAR2(50),       \-- Đến từ IPCAS, SWIFT, OSB...

    source\_table    VARCHAR2(100),      \-- Bảng nguồn

    error\_type      VARCHAR2(50),       \-- NOT\_NULL, REF\_INTEGRITY, FORMAT...

    error\_column    VARCHAR2(100),      \-- Cột nào bị lỗi

    error\_value     VARCHAR2(500),      \-- Giá trị bị lỗi

    error\_message   VARCHAR2(1000),     \-- Mô tả chi tiết

    source\_record   CLOB,              \-- Raw record bị lỗi (JSON/XML)

    created\_at      TIMESTAMP DEFAULT SYSTIMESTAMP,

    status          VARCHAR2(20)        \-- NEW, REVIEWED, RESOLVED

);

**Workflow xử lý error:**

Batch chạy

    │

    ├─► Bản ghi pass DQ → load vào Core

    │

    └─► Bản ghi fail DQ → insert vào etl\_error\_log

                               │

                               ├─► Alert email cho team nghiệp vụ

                               │

                               └─► Hậu kiểm: count lỗi / tổng bản ghi

                                   Nếu \> threshold → escalate

**Tại sao không dừng batch khi có lỗi:** Với hệ thống AML xử lý hàng triệu giao dịch, vài bản ghi lỗi là bình thường. Dừng toàn batch vì 10 bản ghi lỗi trong 5 triệu sẽ làm trễ toàn bộ hệ thống phân tích rủi ro.

---

**Q4.**

*"Reconciliation trong ETL là gì? Bạn thực hiện reconciliation như thế nào sau mỗi batch?"*

💡 **Gợi ý trả lời:**

Reconciliation là so sánh số liệu giữa source và target để đảm bảo không mất hay thêm data trong quá trình ETL.

**Các loại reconciliation:**

\-- 1\. Row count check

SELECT 

    'IPCAS\_TRANSACTIONS' AS source,

    COUNT(\*) AS source\_count

FROM ipcas\_db.transactions@db\_link

WHERE trunc(created\_date) \= trunc(sysdate) \- 1

UNION ALL

SELECT 

    'STAGING\_TRANSACTIONS',

    COUNT(\*)

FROM stg\_transactions

WHERE batch\_id \= :current\_batch\_id;

\-- Nếu source\_count ≠ staging\_count → alert

\-- 2\. Amount check (quan trọng với banking)

SELECT 

    SUM(transaction\_amount) AS source\_total

FROM ipcas\_db.transactions@db\_link

WHERE trunc(created\_date) \= trunc(sysdate) \- 1;

\-- So sánh với:

SELECT SUM(amount) FROM stg\_transactions WHERE batch\_id \= :bid;

\-- 3\. Hash/Checksum check (đảm bảo không bị corrupt)

SELECT ORA\_HASH(transaction\_id || amount || currency) 

FROM source ...

\-- So sánh với hash từ target

**Bạn đã làm reconciliation ở:**

* VAECO migrate: row count \+ checksum sau khi migrate 300+ bảng

* AML: count bản ghi sau mỗi batch ETL

* LPBank: row count Staging vs OFSAA target

---

**Q5.**

*"Prometheus và Grafana hoạt động theo mô hình gì? Tại sao chọn Prometheus thay vì các tool monitoring khác?"*

💡 **Gợi ý trả lời:**

**Kiến trúc pull-based:**

\[postgres\_exporter\]  \[node\_exporter\]  \[custom\_exporter\]

        │                   │                 │

        └───────────────────┴─────────────────┘

                            │

                    Prometheus scrape

                    mỗi 15 giây

                            │

                    \[Prometheus TSDB\]

                    lưu time-series data

                            │

                    ┌───────┴────────┐

                    │               │

                \[Grafana\]      \[AlertManager\]

                Dashboard      Gửi email/Slack

**Pull model vs Push model:**

* Pull: Prometheus chủ động scrape targets theo schedule

* Push (ví dụ Zabbix): agent chủ động gửi metrics đến server

* Pull tốt hơn cho DB monitoring: không cần cài agent phức tạp, chỉ cần exporter expose HTTP endpoint

**Tại sao Prometheus:**

* **Time-series native**: thiết kế cho metrics, query language PromQL rất mạnh

* **Alerting tích hợp**: AlertManager handle deduplication, routing, silencing

* **Ecosystem**: hàng trăm exporter có sẵn (postgres, node, oracle...)

* **Open source**: không cần license

* **Scalable**: có thể scrape hàng nghìn targets

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q6.**

*"Bạn setup Prometheus monitoring cho PostgreSQL VAECO từ đầu. Kể chi tiết các bước và những metrics quan trọng nhất cần theo dõi."*

💡 **Gợi ý trả lời — bạn đã làm điều này thực tế:**

**Bước 1 — Cài đặt exporters:**

\# Node exporter: metrics OS (CPU, RAM, Disk, Network)

./node\_exporter \--web.listen-address=":9100"

\# postgres\_exporter: metrics PostgreSQL

DATA\_SOURCE\_NAME="postgresql://postgres:pass@localhost/postgres?sslmode=disable" \\

./postgres\_exporter \--web.listen-address=":9187"

**Bước 2 — Cấu hình Prometheus scrape:**

\# prometheus.yml

scrape\_configs:

  \- job\_name: 'postgresql'

    static\_configs:

      \- targets: \['vaeco-db-primary:9187', 

                  'vaeco-db-standby:9187'\]

    

  \- job\_name: 'node'

    static\_configs:

      \- targets: \['vaeco-db-primary:9100',

                  'vaeco-db-standby:9100',

                  'vaeco-db-dr:9100'\]

**Bước 3 — Metrics quan trọng nhất:**

DATABASE HEALTH:

  pg\_up                          → DB còn sống không

  pg\_database\_size\_bytes         → Disk usage theo database

  pg\_stat\_database\_numbackends   → Số connections hiện tại

PERFORMANCE:

  pg\_stat\_database\_tup\_fetched   → Rows fetched (read load)

  pg\_stat\_database\_tup\_inserted  → Rows inserted (write load)

  pg\_locks\_count                 → Số locks đang hold

  pg\_stat\_activity\_count{state="active"} → Active queries

REPLICATION:

  pg\_replication\_lag             → Replication lag (giây)

  pg\_stat\_replication\_pg\_wal\_lsn\_diff → WAL bytes chưa sync

OS:

  node\_cpu\_seconds\_total         → CPU usage

  node\_memory\_MemAvailable\_bytes → RAM còn trống

  node\_disk\_io\_time\_seconds\_total → Disk I/O

  node\_filesystem\_avail\_bytes    → Disk space còn lại

**Bước 4 — Grafana Dashboard:** Tạo panels cho từng metric group, dùng threshold coloring:

* Xanh lá: bình thường

* Vàng: cảnh báo

* Đỏ: critical

---

**Q7.**

*"Bạn đã thiết lập alert rule với Prometheus cho VAECO. Viết alert rule cụ thể cho các tình huống: disk sắp đầy, replication lag cao, và DB down."*

💡 **Gợi ý trả lời — code thực tế:**

\# alerts.yml

groups:

  \- name: postgresql\_alerts

    rules:

    

    \# DB Down — critical, alert ngay

    \- alert: PostgreSQLDown

      expr: pg\_up \== 0

      for: 1m

      labels:

        severity: critical

      annotations:

        summary: "PostgreSQL DOWN trên {{ $labels.instance }}"

        description: "DB không phản hồi hơn 1 phút. Kiểm tra ngay\!"

    \# Replication lag cao

    \- alert: ReplicationLagHigh

      expr: pg\_replication\_lag \> 30

      for: 5m

      labels:

        severity: warning

      annotations:

        summary: "Replication lag {{ $value }}s trên {{ $labels.instance }}"

        description: "Standby đang lag {{ $value }} giây. Kiểm tra network."

    \- alert: ReplicationLagCritical

      expr: pg\_replication\_lag \> 300

      for: 2m

      labels:

        severity: critical

      annotations:

        summary: "Replication lag CRITICAL {{ $value }}s"

        description: "Standby lag hơn 5 phút. Nguy cơ mất đồng bộ\!"

    \# Disk sắp đầy

    \- alert: DiskSpaceWarning

      expr: |

        (node\_filesystem\_avail\_bytes{mountpoint="/"} / 

         node\_filesystem\_size\_bytes{mountpoint="/"}) \* 100 \< 20

      for: 10m

      labels:

        severity: warning

      annotations:

        summary: "Disk {{ $labels.instance }} còn {{ $value | humanize }}%"

    \- alert: DiskSpaceCritical

      expr: |

        (node\_filesystem\_avail\_bytes{mountpoint="/"} / 

         node\_filesystem\_size\_bytes{mountpoint="/"}) \* 100 \< 10

      for: 5m

      labels:

        severity: critical

      annotations:

        summary: "DISK SẮP ĐẦY {{ $labels.instance }}: còn {{ $value | humanize }}%"

    \# Connections gần đầy

    \- alert: TooManyConnections

      expr: |

        pg\_stat\_database\_numbackends / 

        pg\_settings\_max\_connections \* 100 \> 80

      for: 5m

      labels:

        severity: warning

      annotations:

        summary: "Connections {{ $value | humanize }}% max\_connections"

    \# CPU cao

    \- alert: HighCPU

      expr: |

        100 \- (avg by(instance) 

          (rate(node\_cpu\_seconds\_total{mode="idle"}\[5m\])) \* 100\) \> 85

      for: 10m

      labels:

        severity: warning

      annotations:

        summary: "CPU {{ $labels.instance }}: {{ $value | humanize }}%"

**Cấu hình AlertManager gửi email:**

\# alertmanager.yml

receivers:

  \- name: 'db-team'

    email\_configs:

      \- to: 'dba-team@vaeco.com'

        from: 'prometheus@vaeco.com'

        smarthost: 'smtp.vaeco.com:587'

        

route:

  group\_by: \['alertname', 'instance'\]

  group\_wait: 30s       \# Chờ 30s để group alerts cùng nhóm

  group\_interval: 5m    \# Re-alert mỗi 5 phút

  repeat\_interval: 4h   \# Repeat nếu vẫn còn alert

  receiver: 'db-team'


  routes:

    \- match:

        severity: critical

      receiver: 'db-team'

      repeat\_interval: 30m   \# Critical: repeat mỗi 30 phút

---

**Q8.**

*"Ngoài Prometheus/Grafana, bạn monitor ETL pipeline như thế nào? Làm thế nào để biết batch đêm nay có chạy đúng không?"*

💡 **Gợi ý trả lời — ETL monitoring khác với infra monitoring:**

**1\. Job log monitoring:**

\-- Dashboard query: status các job trong 24h qua

SELECT 

    job\_name,

    batch\_date,

    status,

    start\_time,

    end\_time,

    ROUND((end\_time \- start\_time) \* 24 \* 60, 1\) AS duration\_minutes,

    rows\_processed,

    error\_count

FROM etl\_job\_log

WHERE batch\_date \>= TRUNC(SYSDATE) \- 1

ORDER BY start\_time DESC;

**2\. Duration baseline alert:**

\-- Alert khi job chạy lâu hơn baseline 50%

SELECT job\_name, avg\_duration\_min,

       CASE WHEN today\_duration \> avg\_duration\_min \* 1.5 

            THEN 'SLOW \- INVESTIGATE'

            ELSE 'OK'

       END AS status

FROM (

    SELECT 

        job\_name,

        AVG(duration\_minutes) OVER (PARTITION BY job\_name) avg\_duration\_min,

        MAX(CASE WHEN batch\_date \= TRUNC(SYSDATE) 

                 THEN duration\_minutes END) today\_duration

    FROM etl\_job\_log

    WHERE batch\_date \>= TRUNC(SYSDATE) \- 30

);

**3\. Data freshness check:**

\-- Kiểm tra dữ liệu có cập nhật đúng hạn không

SELECT 

    table\_name,

    MAX(etl\_load\_date) AS last\_loaded,

    SYSDATE \- MAX(etl\_load\_date) AS hours\_since\_update,

    CASE WHEN SYSDATE \- MAX(etl\_load\_date) \> 1/24  \-- \> 1 giờ

         THEN 'STALE DATA \- ALERT'

         ELSE 'FRESH'

    END AS freshness\_status

FROM (

    SELECT 'STG\_TRANSACTIONS' table\_name, MAX(load\_dt) etl\_load\_date 

    FROM stg\_transactions

    UNION ALL

    SELECT 'CORE\_TRANSACTIONS', MAX(load\_dt) FROM core\_transactions

);

**4\. Morning report email tự động:**

\# Python script chạy 6h sáng, gửi email tóm tắt

def generate\_morning\_report():

    report \= {

        'batch\_date': yesterday,

        'jobs\_success': count\_success(),

        'jobs\_failed': count\_failed(),

        'total\_rows': sum\_rows\_processed(),

        'error\_records': count\_errors(),

        'slowest\_job': get\_slowest\_job(),

        'replication\_status': check\_replication\_lag()

    }

    send\_email(report, to='team@company.com')

---

**Q9.**

*"Khi nào thì một batch ETL nên fail hoàn toàn vs tiếp tục chạy dù có lỗi? Bạn thiết kế threshold như thế nào?"*

💡 **Gợi ý trả lời — đây là câu hỏi về thiết kế quyết định:**

**Nguyên tắc chung:** Lỗi nhỏ (vài bản ghi) → tiếp tục, ghi error table Lỗi lớn (nhiều bản ghi hoặc lỗi hệ thống) → dừng, alert ngay

**Phân loại lỗi:**

HARD FAILURE → Dừng batch ngay:

  \- DB link đứt → không lấy được data từ source

  \- Staging tablespace đầy → không write được

  \- Core table bị lock không release

  \- DQ error rate \> 10% → data source có vấn đề nghiêm trọng

SOFT FAILURE → Ghi error table, tiếp tục:

  \- Một vài bản ghi NULL ở trường không bắt buộc

  \- Duplicate key (đã load batch trước, idempotent)

  \- Format nhỏ không ảnh hưởng business logic

THRESHOLD ALERT → Tiếp tục nhưng alert:

  \- Error rate 1-5%: warning email

  \- Error rate 5-10%: urgent alert, cần review trước khi dùng data

  \- Error rate \>10%: stop batch

**Ví dụ code:**

\-- Sau bước DQ check

DECLARE

    v\_total\_rows    NUMBER;

    v\_error\_rows    NUMBER;

    v\_error\_rate    NUMBER;

BEGIN

    SELECT COUNT(\*) INTO v\_total\_rows FROM stg\_transactions 

    WHERE batch\_id \= p\_batch\_id;

    

    SELECT COUNT(\*) INTO v\_error\_rows FROM etl\_error\_log 

    WHERE batch\_id \= p\_batch\_id;

    

    v\_error\_rate := v\_error\_rows / NULLIF(v\_total\_rows, 0\) \* 100;

    

    IF v\_error\_rate \> 10 THEN

        \-- Dừng batch

        RAISE\_APPLICATION\_ERROR(-20001, 

            'Error rate ' || v\_error\_rate || '% exceeds threshold 10%');

    ELSIF v\_error\_rate \> 5 THEN

        \-- Alert nhưng tiếp tục

        send\_alert('High error rate: ' || v\_error\_rate || '%');

    END IF;

    

    \-- Tiếp tục load bản ghi pass DQ

    INSERT INTO core\_transactions

    SELECT \* FROM stg\_transactions s

    WHERE batch\_id \= p\_batch\_id

    AND NOT EXISTS (

        SELECT 1 FROM etl\_error\_log e 

        WHERE e.source\_record\_id \= s.transaction\_id

        AND e.batch\_id \= p\_batch\_id

    );

END;

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q10.**

*"Sáng thứ Hai nhận được báo cáo: 'Tổng số giao dịch đáng ngờ tuần này ít hơn tuần trước 40%, nhưng không có gì bất thường trong business.' Bạn điều tra thế nào?"*

💡 **Gợi ý trả lời — systematic investigation:**

BƯỚC 1 — KIỂM TRA JOB LOG (5 phút):

  → Tất cả batch cuối tuần có chạy thành công không?

  → Có batch nào fail và không retry không?

  → Duration có bất thường không?

  SELECT batch\_date, job\_name, status, rows\_processed, error\_count

  FROM etl\_job\_log

  WHERE batch\_date BETWEEN TRUNC(SYSDATE) \- 7 AND TRUNC(SYSDATE)

  ORDER BY batch\_date;

BƯỚC 2 — ROW COUNT COMPARISON (10 phút):

  → So sánh số bản ghi theo ngày:

  SELECT TRUNC(transaction\_date) dt, COUNT(\*) cnt

  FROM core\_transactions

  WHERE transaction\_date \>= SYSDATE \- 14

  GROUP BY TRUNC(transaction\_date)

  ORDER BY dt;


  → Ngày nào bị thiếu đột ngột?

BƯỚC 3 — SO SÁNH VỚI SOURCE (15 phút):

  → Count từ IPCAS, SWIFT, OSB

  → So với Staging và Core

  → Chênh lệch ở tầng nào?


  Source → Staging: lỗi extract

  Staging → Core:   lỗi transform hoặc DQ reject quá nhiều

BƯỚC 4 — KIỂM TRA ERROR TABLE:

  SELECT error\_type, source\_system, COUNT(\*) cnt

  FROM etl\_error\_log

  WHERE batch\_id LIKE 'BATCH\_2024%'

  GROUP BY error\_type, source\_system

  ORDER BY cnt DESC;


  → Có DQ rule nào bắt đầu reject nhiều hơn bình thường?

  → Source system có thay đổi format không?

BƯỚC 5 — KIỂM TRA DQ RULES:

  → Có rule nào mới được thêm vào tuần trước không?

  → Có rule nào threshold bị thay đổi không?

  → Rule ISO/LOV validation có bị update không?


  Ví dụ: thêm rule check transaction\_amount \> 0

  → Reject toàn bộ credit transactions (amount âm) → 40% giảm

BƯỚC 6 — KIỂM TRA DB LINK:

  → DB link đến SWIFT có bị intermittent không?

  → Check tnsnames, network log

BƯỚC 7 — REPORT:

  → Root cause: \[X\]

  → Data bị thiếu: \[Y\] bản ghi, \[Z\] ngày

  → Recovery plan: rerun batch, hoặc manual fix

  → Prevention: thêm automated reconciliation alert

---

**Q11.**

*"Grafana dashboard của bạn cho VAECO trông như thế nào? Bạn tổ chức panels như thế nào để DBA và developer đều dùng được?"*

💡 **Gợi ý trả lời — design dashboard thực tế:**

DASHBOARD 1: EXECUTIVE OVERVIEW (cho manager)

  ┌─────────────┬─────────────┬─────────────┬─────────────┐

  │ DB Status   │ Replication │ Disk Usage  │ Active Users│

  │ ● Primary OK│ Lag: 0.2s   │ 67% used    │ 847         │

  └─────────────┴─────────────┴─────────────┴─────────────┘

  ┌─────────────────────────────────────────────────────────┐

  │ ETL Job Status (last 24h)                               │

  │ ████████████████░░░ 18/20 SUCCESS  1 RUNNING  1 FAILED │

  └─────────────────────────────────────────────────────────┘

DASHBOARD 2: DATABASE PERFORMANCE (cho DBA)

  Row 1: CPU % | RAM % | Disk I/O MB/s | Network MB/s

  Row 2: Active Connections | Waiting Connections | Lock Count

  Row 3: Transactions/sec | Rows inserted/sec | Rows fetched/sec

  Row 4: Cache Hit Ratio | Checkpoint frequency | WAL generation rate

DASHBOARD 3: REPLICATION STATUS (cho DBA)

  Row 1: Primary LSN | Standby LSN | Lag bytes | Lag seconds

  Row 2: WAL archive status | DR sync status

  Row 3: Timeline: replication lag theo giờ (7 ngày)

DASHBOARD 4: ETL MONITORING (cho DE)

  Row 1: Jobs running | Jobs success today | Jobs failed today

  Row 2: Rows processed per job (bar chart)

  Row 3: Job duration vs baseline (line chart)

  Row 4: Error rate per source system

  Row 5: Data freshness table

DASHBOARD 5: SLOW QUERY LOG (cho developer)

  → Top 10 queries by duration

  → Query frequency

  → Queries causing locks

**Best practices từ kinh nghiệm VAECO:**

* Dùng template variables: chọn instance (primary/standby) mà không phải tạo nhiều dashboard

* Annotation: đánh dấu các event quan trọng (deploy, batch run) lên timeline

* Alert threshold hiển thị trực tiếp trên panel (đường kẻ đỏ ở 80% disk)

---

**Q12.**

*"Custom exporter cho Oracle không có sẵn như PostgreSQL. Bạn monitor Oracle metrics như thế nào?"*

💡 **Gợi ý trả lời:**

**Option 1 — oracledb\_exporter:**

\# Community exporter cho Oracle

DATA\_SOURCE\_NAME="oracle://user:pass@host:1521/service" \\

./oracledb\_exporter \--web.listen-address=":9161"

\# Metrics expose:

\# oracledb\_up

\# oracledb\_activity\_execute\_count

\# oracledb\_wait\_time\_\*

\# oracledb\_tablespace\_bytes

**Option 2 — Custom Python script:**

import cx\_Oracle

import prometheus\_client as prom

\# Custom metrics

tablespace\_used \= prom.Gauge(

    'oracle\_tablespace\_used\_bytes',

    'Tablespace used bytes',

    \['tablespace\_name'\]

)

def collect\_metrics():

    conn \= cx\_Oracle.connect(dsn)

    cursor \= conn.cursor()

    

    \# Tablespace usage

    cursor.execute("""

        SELECT tablespace\_name, 

               bytes\_used, bytes\_free

        FROM dba\_tablespace\_usage\_metrics

    """)

    for row in cursor:

        tablespace\_used.labels(row\[0\]).set(row\[1\])

    

    \# Active sessions

    cursor.execute("""

        SELECT COUNT(\*) FROM v$session 

        WHERE status \= 'ACTIVE'

    """)

    active\_sessions.set(cursor.fetchone()\[0\])

    

    \# Top wait events

    cursor.execute("""

        SELECT event, total\_waits

        FROM v$system\_event

        WHERE wait\_class \!= 'Idle'

        ORDER BY total\_waits DESC

        FETCH FIRST 10 ROWS ONLY

    """)

    ...

\# Expose metrics HTTP endpoint

prom.start\_http\_server(9200)

while True:

    collect\_metrics()

    time.sleep(60)

**Option 3 — Toad for Oracle built-in monitoring:** Với môi trường enterprise Oracle như AML Agribank, bạn đã dùng Toad for Oracle để monitor session, locks, tablespace trực tiếp.

---

**📊 Tổng kết nhóm 6**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | 6 DQ dimensions | ⭐⭐ | AML, VAECO |
| Q2 | DQ check Staging vs Core | ⭐⭐ | AML Agribank |
| Q3 | Error table design | ⭐⭐ | AML Agribank |
| Q4 | Reconciliation sau batch | ⭐⭐ | VAECO, LPBank |
| Q5 | Prometheus kiến trúc | ⭐⭐ | VAECO |
| Q6 | Setup Prometheus PostgreSQL | ⭐⭐⭐ | VAECO |
| Q7 | Alert rules thực tế | ⭐⭐⭐ | VAECO |
| Q8 | ETL pipeline monitoring | ⭐⭐⭐ | AML, LPBank |
| Q9 | Fail vs continue threshold | ⭐⭐⭐ | AML Agribank |
| Q10 | Điều tra data giảm 40% | ⭐⭐⭐⭐ | AML Agribank |
| Q11 | Grafana dashboard design | ⭐⭐⭐ | VAECO |
| Q12 | Oracle custom monitoring | ⭐⭐⭐ | AML, VAECO |

---

💡 **Lưu ý quan trọng:** Nhóm Data Quality hay bị hỏi kết hợp với domain banking — ví dụ *"Nếu dữ liệu AML bị thiếu do DQ reject, báo cáo tuân thủ pháp lý có thể sai → hậu quả là gì?"* Bạn cần thể hiện hiểu được impact business, không chỉ technical.

Bạn muốn tiếp tục **nhóm 7: Xử lý sự cố thực tế**, **nhóm 8: Data Modeling**, hay muốn **luyện tập trả lời** một câu cụ thể nào đó?

**Nhóm 8: Data Modeling & Schema Design — Câu hỏi chi tiết**

---

**🔵 CẤP ĐỘ 1 — Kiến thức nền tảng**

---

**Q1.**

*"Star Schema và Snowflake Schema khác nhau thế nào? Bạn đã dùng loại nào trong các dự án?"*

💡 \*\*Gợi ý trả lời:\*\*

![][image2]

So sánh thực tế cho công việc DE:

|  | Star Schema | Snowflake Schema |
| :---- | :---- | :---- |
| Dim table | Denormalized — tất cả trong 1 bảng | Normalized — tách ra nhiều bảng con |
| JOIN | Ít JOIN hơn → query nhanh hơn | Nhiều JOIN → phức tạp hơn |
| Storage | Tốn hơn (duplicate data) | Tiết kiệm hơn |
| Dùng khi | DWH analytics, báo cáo | Dim có hierarchy phức tạp |

**Mapping vào dự án của bạn:** NHNN DWH và LPBank OFSAA thường dùng Star Schema hoặc biến thể gần với Star — dim\_customer, dim\_date, dim\_account flat để query báo cáo nhanh.

---

**Q2.**

*"Fact table và Dimension table khác nhau thế nào? Bảng Bridge dùng khi nào?"*

💡 **Gợi ý trả lời:**

**Fact table**: lưu sự kiện đã xảy ra — transaction, giao dịch, event. Chứa nhiều foreign key đến dimension, và các measure (số, tiền, số lượng).

\-- Ví dụ fact table AML

CREATE TABLE fact\_transaction (

    transaction\_id    NUMBER PK,

    customer\_sk       NUMBER FK → dim\_customer,

    date\_sk           NUMBER FK → dim\_date,

    branch\_sk         NUMBER FK → dim\_branch,

    transaction\_type\_sk NUMBER FK → dim\_transaction\_type,

    \-- Measures

    amount            NUMBER(18,2),

    fee               NUMBER(18,2),

    exchange\_rate     NUMBER(10,6)

);

**Dimension table**: lưu ngữ cảnh mô tả — ai, ở đâu, khi nào, loại gì. Ít thay đổi hơn Fact.

CREATE TABLE dim\_customer (

    customer\_sk       NUMBER PK,   \-- Surrogate key

    customer\_id       VARCHAR2(20), \-- Natural key

    full\_name         VARCHAR2(200),

    id\_number         VARCHAR2(20),

    customer\_type     VARCHAR2(50),

    risk\_level        VARCHAR2(20),

    \-- SCD Type 2 fields

    effective\_date    DATE,

    expiry\_date       DATE,

    is\_current        CHAR(1)

);

**Bridge table** — dùng khi quan hệ Many-to-Many:

\-- Một transaction có thể liên quan nhiều account

\-- Một account có thể có nhiều transactions

\-- → Bridge table

CREATE TABLE bridge\_transaction\_account (

    transaction\_sk    NUMBER FK,

    account\_sk        NUMBER FK,

    role              VARCHAR2(50)  \-- 'SENDER', 'RECEIVER'

);

*Bạn đã thiết kế 3 nhóm bảng này trong AML Staging — dim, fact và bridge.*

---

**Q3.**

*"Surrogate key và Natural key khác nhau thế nào? Tại sao DWH thường dùng Surrogate key?"*

💡 **Gợi ý trả lời:**

**Natural key**: key có ý nghĩa business — CMND, mã tài khoản, mã giao dịch. Tồn tại trong source system.

**Surrogate key**: key nhân tạo do DWH tự sinh — thường là sequence number (1, 2, 3...). Không có ý nghĩa business.

Tại sao DWH dùng Surrogate key:

1\. SCD Type 2: cùng customer\_id nhưng thay đổi thông tin

   → Cần 2 rows khác nhau trong dim\_customer

   → Dùng surrogate\_key để phân biệt

   

   customer\_sk=1, customer\_id='C001', name='Nguyen A', effective=2020-01-01

   customer\_sk=2, customer\_id='C001', name='Nguyen B', effective=2023-06-01

2\. Performance: NUMBER JOIN nhanh hơn VARCHAR2 JOIN

3\. Source system thay đổi: nếu source đổi format natural key

   → DWH không bị ảnh hưởng vì đã dùng surrogate

4\. Integration: nhiều source system cùng customer\_id khác nhau

   → Surrogate key tạo unified identity

---

**Q4.**

*"SCD Type 1, 2, 3 là gì? Trong hệ thống AML, bạn nên dùng loại nào và tại sao?"*

💡 **Gợi ý trả lời:**

**SCD Type 1 — Overwrite:**

\-- Cập nhật thẳng, không giữ lịch sử

UPDATE dim\_customer SET risk\_level \= 'HIGH' WHERE customer\_id \= 'C001';

Dùng khi: data sai cần sửa, hoặc thông tin không cần lịch sử (địa chỉ email).

**SCD Type 2 — Add new row:**

\-- Đóng record cũ

UPDATE dim\_customer SET expiry\_date \= SYSDATE \- 1, is\_current \= 'N'

WHERE customer\_id \= 'C001' AND is\_current \= 'Y';

\-- Thêm record mới

INSERT INTO dim\_customer VALUES (

    seq\_customer\_sk.NEXTVAL, 'C001', 'Nguyen A', 'HIGH',

    SYSDATE, TO\_DATE('9999-12-31'), 'Y'

);

Dùng khi: cần toàn bộ lịch sử thay đổi — ai là gì vào ngày nào.

**SCD Type 3 — Add column:**

\-- Thêm cột lưu giá trị trước

ALTER TABLE dim\_customer ADD prev\_risk\_level VARCHAR2(20);

UPDATE dim\_customer SET 

    prev\_risk\_level \= risk\_level,

    risk\_level \= 'HIGH'

WHERE customer\_id \= 'C001';

Dùng khi: chỉ cần biết trạng thái trước và hiện tại — không cần toàn bộ lịch sử.

**Trong AML — nên dùng SCD Type 2:**

* AML yêu cầu audit trail hoàn chỉnh: khách hàng có risk level gì vào ngày giao dịch xảy ra?

* Khi điều tra giao dịch đáng ngờ năm 2022, phải biết risk level của customer vào đúng ngày đó

* SCD Type 2 join với fact\_transaction theo effective\_date ≤ transaction\_date ≤ expiry\_date

*Đây là lý do bạn dùng "SCD-like change tracking" trong AML — về bản chất là Type 2 đơn giản hóa.*

---

**🔵 CẤP ĐỘ 2 — Chuyên sâu kỹ thuật**

---

**Q5.**

*"Bạn thiết kế Staging schema cho hệ thống AML với 5+ hệ thống nguồn. Kể chi tiết cách bạn tổ chức 30+ bảng trong Staging."*

💡 **Gợi ý trả lời — đây là thiết kế thực tế của bạn:**

\-- Nguyên tắc đặt tên bảng Staging:

\-- STG\_{SOURCE}\_{ENTITY}

\-- Nhóm 1: Transaction data

STG\_IPCAS\_TRANSACTION     \-- Giao dịch từ IPCAS (core banking)

STG\_IPCAS\_TRANSFER        \-- Chuyển khoản

STG\_SWIFT\_MESSAGE         \-- Tin nhắn SWIFT quốc tế

STG\_OSB\_EVENT             \-- Events từ OSB (middleware)

\-- Nhóm 2: Customer/Party data

STG\_IPCAS\_CUSTOMER        \-- Thông tin khách hàng

STG\_IPCAS\_ACCOUNT         \-- Tài khoản

STG\_IPCAS\_BENEFICIARY     \-- Người thụ hưởng

\-- Nhóm 3: Reference/Lookup data

STG\_REF\_CURRENCY          \-- Danh mục tiền tệ

STG\_REF\_COUNTRY           \-- Danh mục quốc gia

STG\_REF\_BRANCH            \-- Chi nhánh

\-- Cột chuẩn mỗi bảng Staging đều có:

CREATE TABLE STG\_IPCAS\_TRANSACTION (

    \-- Business columns từ source

    transaction\_id        VARCHAR2(50),

    account\_id            VARCHAR2(30),

    amount                NUMBER(18,2),

    currency              VARCHAR2(3),

    transaction\_date      DATE,

    

    \-- ETL control columns

    batch\_id              VARCHAR2(50),   \-- Thuộc batch nào

    load\_dt               TIMESTAMP,      \-- Khi nào được load

    source\_system         VARCHAR2(20),   \-- 'IPCAS'

    record\_status         VARCHAR2(20),   \-- 'LOADED', 'DQ\_FAILED', 'PROCESSED'

    error\_message         VARCHAR2(500),  \-- Lý do DQ fail nếu có

    checksum              VARCHAR2(64)    \-- MD5 để detect thay đổi

);

**Tại sao tách theo source system:**

* Dễ debug: lỗi trong STG\_SWIFT thì chỉ liên quan SWIFT, không ảnh hưởng IPCAS

* Dễ rerun: chỉ cần rerun extract từ SWIFT, không cần rerun toàn bộ

* Audit: biết rõ mỗi bản ghi đến từ đâu

---

**Q6.**

*"Partition strategy trong Staging và Core table của bạn như thế nào? Tại sao chọn Range Partition theo ngày?"*

💡 **Gợi ý trả lời:**

**Staging table — partition nhẹ:**

\-- Staging thường chỉ giữ data ngắn hạn (7-30 ngày)

\-- Partition theo batch\_date để drop partition cũ dễ dàng

CREATE TABLE STG\_IPCAS\_TRANSACTION (

    ...

    batch\_date DATE

)

PARTITION BY RANGE (batch\_date) (

    PARTITION p\_2025\_01 VALUES LESS THAN (DATE '2025-02-01'),

    PARTITION p\_2025\_02 VALUES LESS THAN (DATE '2025-03-01'),

    PARTITION p\_max    VALUES LESS THAN (MAXVALUE)

)

ENABLE ROW MOVEMENT;

\-- Dọn dẹp: drop partition cũ hơn 30 ngày

ALTER TABLE STG\_IPCAS\_TRANSACTION DROP PARTITION p\_2025\_01;

\-- O(1) thay vì DELETE hàng triệu rows

**Core/Fact table — partition quan trọng hơn:**

\-- Fact transaction: dữ liệu nhiều năm, partition theo tháng

CREATE TABLE FACT\_TRANSACTION (

    ...

    transaction\_date DATE

)

PARTITION BY RANGE (transaction\_date)

INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))  \-- Auto-partition mỗi tháng

(

    PARTITION p\_init VALUES LESS THAN (DATE '2020-01-01')

);

\-- INTERVAL partition: Oracle tự tạo partition mới mỗi tháng

\-- Không cần maintenance thủ công

**Tại sao Range Partition theo ngày:**

* ETL query theo ngày: WHERE transaction\_date \= :batch\_date → Partition Pruning, chỉ scan đúng partition

* Drop partition cũ: xóa data cũ không dùng nhanh

* Parallel load: mỗi tháng load vào partition riêng → parallel

---

**Q7.**

*"Index strategy trong DWH khác với OLTP như thế nào? Bạn tạo Index gì cho Fact table và Dimension table?"*

💡 **Gợi ý trả lời:**

**OLTP (Core banking IPCAS):**

* Nhiều INSERT/UPDATE/DELETE → Index cần cân nhắc overhead

* Index trên PK và FK là chủ yếu

* Ít index để không làm chậm write

**DWH (NHNN, OFSAA):**

* Read-heavy, write ít (chỉ batch load hằng đêm)

* Có thể tạo nhiều index hơn vì write không quan trọng tốc độ như OLTP

* Disable index khi load, rebuild sau khi load xong

**Index strategy thực tế:**

\-- Dimension table: index trên natural key để lookup nhanh

CREATE INDEX idx\_dim\_customer\_nk 

ON dim\_customer(customer\_id, is\_current);

\-- Fact table: index trên các cột join với dimension

CREATE BITMAP INDEX idx\_fact\_date\_sk 

ON fact\_transaction(date\_sk);

\-- Bitmap index: phù hợp với cột FK ít giá trị phân biệt

CREATE BITMAP INDEX idx\_fact\_cust\_sk 

ON fact\_transaction(customer\_sk);

\-- Composite index cho query phổ biến

CREATE INDEX idx\_fact\_date\_amount 

ON fact\_transaction(transaction\_date, amount)

LOCAL;  \-- LOCAL \= index partitioned theo cùng partition với table

**Tại sao Bitmap Index trong DWH:**

* FK columns như date\_sk, branch\_sk có ít giá trị phân biệt (365 ngày, 100 chi nhánh)

* Bitmap index cực kỳ efficient cho AND/OR nhiều điều kiện: WHERE branch\_sk \= 5 AND date\_sk \= 20240101

* Không dùng Bitmap cho OLTP: Bitmap lock cả bitmap khi update → deadlock

---

**Q8.**

*"OFSAA yêu cầu thiết kế schema phức tạp cho phân tích lợi nhuận đa chiều. Bạn hiểu cấu trúc dữ liệu của OFSAA như thế nào?"*

💡 **Gợi ý trả lời — từ kinh nghiệm LPBank của bạn:**

OFSAA (Oracle Financial Services Analytical Applications) là platform phân tích tài chính của Oracle, dùng cho:

* **FTP (Funds Transfer Pricing)**: tính lãi suất nội bộ

* **PFT (Profitability Management)**: phân bổ thu nhập và chi phí theo đơn vị kinh doanh

* **TOI**: Thu nhập hoạt động thuần \= Thu nhập lãi \+ Thu nhập phi lãi

* **OPEX**: Chi phí vận hành phân bổ theo allocation rule

**Các bảng OFSAA quan trọng:**

FSI\_D\_ACCOUNT      → Thông tin tài khoản

FSI\_D\_COMMON\_COA   → Chart of Accounts

FSI\_D\_ORG\_UNIT     → Đơn vị tổ chức

FSI\_D\_PRODUCT      → Sản phẩm tài chính

FSI\_D\_GENERAL\_LEDGER → Sổ cái

STG\_LOAN\_CONTRACTS    → Staging: hợp đồng cho vay

STG\_CASA\_ACCOUNTS     → Staging: tài khoản CASA

STG\_TERM\_DEPOSITS     → Staging: tiền gửi có kỳ hạn

**Challenge lớn nhất khi ETL vào OFSAA:**

* Schema OFSAA rất rigid — không thể thêm/sửa cột

* Mapping rule phức tạp: 1 tài khoản nguồn → nhiều bảng OFSAA

* Data quality phải 100%: OFSAA tính toán sai nếu thiếu data hoặc data lỗi

* Khoảng 200 Program chạy theo dependency order rất chặt

---

**🔵 CẤP ĐỘ 3 — Tình huống thực chiến**

---

**Q9.**

*"Bạn nhận yêu cầu: 'Cần thêm trường phone\_number vào dim\_customer đang có 50 triệu rows trong production DWH.' Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời — thao tác DDL trên bảng lớn production:**

\-- BAD: ALTER TABLE trực tiếp → lock bảng 50 triệu rows → downtime dài

ALTER TABLE dim\_customer ADD phone\_number VARCHAR2(20);

\-- → Lock table trong vài chục phút → không thể dùng trong production hours

\-- GOOD: Oracle online DDL

ALTER TABLE dim\_customer ADD phone\_number VARCHAR2(20)

DEFAULT NULL;

\-- Oracle 12c+: DEFAULT NULL column được add ngay lập tức, O(1)

\-- Oracle lưu default value trong data dictionary, không update từng row

\-- Sau đó update dần dần theo batch nhỏ trong off-hours:

BEGIN

  FOR i IN 1..1000 LOOP

    UPDATE dim\_customer 

    SET phone\_number \= get\_phone\_from\_source(customer\_id)

    WHERE phone\_number IS NULL

    AND ROWNUM \<= 10000;

    

    COMMIT;  \-- Commit mỗi 10.000 rows, không hold lock lâu

    

    EXIT WHEN SQL%ROWCOUNT \= 0;

  END LOOP;

END;

**Các bước chuẩn:**

1. Thêm column với DEFAULT NULL — online, không lock

2. Update data trong off-hours theo batch nhỏ có COMMIT giữa chừng

3. Gather stats lại sau khi update xong

4. Thêm Index nếu cần — CREATE INDEX ... ONLINE để không lock

---

**Q10.**

*"Schema DWH NHNN đang có bảng fact\_transaction 2 tỷ rows. Query báo cáo tháng mất 4 tiếng. Bạn thiết kế lại schema như thế nào?"*

💡 **Gợi ý trả lời — đây là bài toán schema redesign thực tế:**

PHÂN TÍCH VẤN ĐỀ:

  2 tỷ rows × full scan \= 4 tiếng

  → Partition Pruning không work? → Kiểm tra partition strategy

  → Thiếu summary table? → Aggregation trên 2 tỷ rows quá chậm

GIẢI PHÁP 1 — Partition tốt hơn:

  Nếu đang partition theo năm → query tháng vẫn scan cả năm

  → Đổi sang partition theo tháng:

  PARTITION BY RANGE (transaction\_date)

  INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))

GIẢI PHÁP 2 — Aggregate table (thường hiệu quả nhất):

  \-- Tạo bảng tổng hợp theo ngày/chi nhánh/loại giao dịch

  CREATE TABLE agg\_transaction\_daily AS

  SELECT 

      TRUNC(transaction\_date) dt,

      branch\_sk,

      transaction\_type\_sk,

      COUNT(\*) transaction\_count,

      SUM(amount) total\_amount,

      AVG(amount) avg\_amount

  FROM fact\_transaction

  GROUP BY TRUNC(transaction\_date), branch\_sk, transaction\_type\_sk;


  \-- Báo cáo tháng query từ agg table:

  SELECT branch\_sk, SUM(total\_amount)

  FROM agg\_transaction\_daily

  WHERE dt BETWEEN '2024-01-01' AND '2024-01-31'

  GROUP BY branch\_sk;

  \-- Từ 2 tỷ rows → vài triệu rows trong agg table → giây

GIẢI PHÁP 3 — Materialized View:

  CREATE MATERIALIZED VIEW mv\_monthly\_summary

  BUILD IMMEDIATE

  REFRESH COMPLETE ON DEMAND

  AS

  SELECT 

      TRUNC(transaction\_date, 'MM') month\_dt,

      branch\_sk,

      SUM(amount) total\_amount,

      COUNT(\*) total\_count

  FROM fact\_transaction

  GROUP BY TRUNC(transaction\_date, 'MM'), branch\_sk;


  \-- ETL refresh MV sau mỗi batch

  EXEC DBMS\_MVIEW.REFRESH('mv\_monthly\_summary', 'C');

**Lưu ý:** Bạn đã làm partition tuning trong NHNN DWH — đây là extension tự nhiên của công việc đó.

---

**Q11.**

*"Khi thiết kế Staging schema, bạn quyết định như thế nào: 1 bảng Staging cho mỗi source table, hay gộp nhiều source vào 1 bảng Staging?"*

💡 **Gợi ý trả lời:**

**1 bảng Staging per source table (approach của bạn ở AML):**

STG\_IPCAS\_TRANSACTION   → tách riêng

STG\_SWIFT\_MESSAGE       → tách riêng

STG\_OSB\_EVENT          → tách riêng

Ưu điểm:

* Debug dễ: lỗi ở đâu biết ngay là source nào

* Rerun độc lập: chỉ rerun SWIFT, không ảnh hưởng IPCAS

* Schema khác nhau giữa các source → không cần ép vào 1 bảng

* Audit trail rõ ràng

Nhược điểm:

* Nhiều bảng hơn → quản lý phức tạp hơn

**Gộp nhiều source vào 1 bảng Staging:**

STG\_ALL\_TRANSACTIONS (source\_system VARCHAR2, ...)

Ưu điểm:

* Ít bảng hơn

* Transform đơn giản nếu schema gần giống nhau

Nhược điểm:

* Schema phải là union của tất cả source → nhiều NULL columns

* Khó debug khi lỗi

**Kết luận:** 1 bảng per source là best practice cho hệ thống enterprise phức tạp như AML với 5+ nguồn khác nhau. Bạn đã làm đúng.

---

**📊 Tổng kết nhóm 8**

| Câu | Chủ đề | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | Star vs Snowflake Schema | ⭐⭐ | NHNN, LPBank |
| Q2 | Fact, Dim, Bridge table | ⭐⭐ | AML Agribank |
| Q3 | Surrogate vs Natural key | ⭐⭐ | AML, DWH |
| Q4 | SCD Type 1/2/3 | ⭐⭐⭐ | AML Agribank |
| Q5 | Staging schema 30+ bảng | ⭐⭐⭐ | AML Agribank |
| Q6 | Partition strategy | ⭐⭐⭐ | NHNN, AML |
| Q7 | Index strategy DWH vs OLTP | ⭐⭐⭐ | NHNN DWH |
| Q8 | OFSAA schema LPBank | ⭐⭐⭐ | LPBank OFSAA |
| Q9 | DDL thêm column 50M rows | ⭐⭐⭐ | NHNN DWH |
| Q10 | Redesign schema 2 tỷ rows | ⭐⭐⭐⭐ | NHNN DWH |
| Q11 | 1 Staging table vs nhiều | ⭐⭐ | AML Agribank |

---

💡 **Lưu ý đặc biệt:** Nhóm này hay bị hỏi kết hợp với nhóm SQL — ví dụ *"Bạn thiết kế schema như vậy, giờ viết query tính tổng giao dịch theo chi nhánh theo tháng."* Hãy chuẩn bị viết SQL ngay trên giấy/whiteboard trong phỏng vấn.

Bạn muốn chuyển sang **nhóm 7: Xử lý sự cố thực tế**, **nhóm 9: Behavioral**, hay **nhóm 10: Domain Knowledge**?

**Nhóm 9: Behavioral & Situational — Câu hỏi chi tiết**

---

Nhóm này thường xuất hiện ở **vòng 2 hoặc cuối buổi phỏng vấn kỹ thuật**, khi interviewer muốn đánh giá con người chứ không chỉ kỹ năng. Công thức trả lời chuẩn là **STAR**: Situation → Task → Action → Result.

---

**🔵 CHỦ ĐỀ 1 — Xử lý áp lực & sự cố**

---

**Q1.**

*"Kể về một lần hệ thống production bị sự cố nghiêm trọng trong ca trực của bạn. Bạn đã làm gì?"*

💡 **Gợi ý trả lời — dùng case DR mất đồng bộ 6 tiếng ở VAECO:**

SITUATION:

  DR Standby PostgreSQL mất đồng bộ 6 tiếng do network outage.

  Khi phục hồi, Standby không thể sync tiếp vì WAL đã bị xóa.

  Hệ thống MRO IT đang phục vụ 1.000+ kỹ thuật viên hàng không.

TASK:

  Phục hồi DR Standby mà không downtime Production

  và không mất dữ liệu.

ACTION:

  → Đầu tiên: xác nhận Primary vẫn healthy, Production không bị ảnh hưởng

  → Phân tích: WAL archive vẫn còn đủ 6 tiếng gap

  → Quyết định: dùng WAL archive thay vì rebuild từ pg\_basebackup

  → Cấu hình restore\_command trên Standby

  → Monitor từng bước replay, xác nhận catch-up hoàn toàn

  → Verify: replication lag về 0

RESULT:

  → Phục hồi trong \~40 phút thay vì 3-4 tiếng nếu rebuild

  → Zero data loss, zero downtime Production

  → Sau đó viết runbook cho case này để team xử lý nhanh hơn lần sau

---

**Q2.**

*"Bạn đã bao giờ làm sai một thứ gì đó trên production và phải xử lý hậu quả chưa? Kể lại."*

💡 **Gợi ý trả lời — đây là câu hỏi về tính trung thực và accountability:**

Đừng nói "chưa bao giờ sai" — không ai tin và nghe rất thiếu tự nhiên. Hãy kể một case thật, quan trọng là thể hiện bạn học được gì.

Ví dụ có thể kể:

SITUATION:

  Trong NHNN DWH, khi thực hiện tuning partition,

  tôi drop một partition tưởng là không còn dùng

  nhưng thực ra vẫn còn data đang được query

  bởi một báo cáo cuối tháng.

TASK:

  Phục hồi data và đảm bảo báo cáo chạy được đúng hạn.

ACTION:

  → Ngay lập tức thông báo cho team lead và stakeholder

  → Xác định data bị mất bằng cách query từ backup

  → Dùng Export/Import data pump restore lại partition đó

  → Test báo cáo chạy đúng kết quả

RESULT:

  → Phục hồi trong 2 tiếng, báo cáo vẫn kịp deadline

  → Học được: trước khi drop partition phải check

    dependency với team báo cáo, không chỉ check ETL

  → Từ đó tôi thêm bước sign-off với team báo cáo

    trước mọi DDL operation trên bảng production

**Điều quan trọng khi trả lời:**

* Nhận trách nhiệm rõ ràng, không đổ lỗi

* Tập trung vào action và lesson learned

* Thể hiện đã có biện pháp phòng ngừa sau đó

---

**Q3.**

*"Kể về một tình huống bạn phải làm việc dưới áp lực deadline rất cao. Bạn xử lý như thế nào?"*

💡 **Gợi ý trả lời — dùng case Go-live VAECO AMOS:**

SITUATION:

  Dự án MRO IT VAECO có deadline Go-live cố định

  do hợp đồng với Vietnam Airlines. Một tuần trước

  Go-live phát hiện batch migrate dữ liệu từ AMASIS

  chạy 4 tiếng — vượt quá batch window cho phép.

TASK:

  Tối ưu batch từ 4 tiếng xuống còn dưới 1 tiếng

  trong vòng 3 ngày, không được delay Go-live.

ACTION:

  → Ngày 1: phân tích execution plan, xác định

    bottleneck là xử lý tuần tự theo từng giao dịch

  → Xác định data có thể chia theo khoảng thời gian

    mà không có dependency giữa các khoảng

  → Ngày 2: implement song song hóa 4 luồng,

    test trên môi trường có data tương đương production

  → Kết quả test: 4 tiếng → 28 phút

  → Ngày 3: review với team lead, sign-off, deploy

RESULT:

  → Go-live đúng hạn

  → Batch chạy 28 phút, thoải mái trong window

  → Case này trở thành template cho các migrate

    tương tự sau đó trong dự án

---

**🔵 CHỦ ĐỀ 2 — Làm việc nhóm & giao tiếp**

---

**Q4.**

*"Kể về một lần bạn phải thuyết phục team hoặc khách hàng chấp nhận giải pháp kỹ thuật của bạn."*

💡 **Gợi ý trả lời — dùng case pg\_repack VAECO:**

SITUATION:

  Backup PostgreSQL VAECO Production mất 3 tiếng 5 phút.

  Manager muốn tăng số parallel jobs (-j) của pg\_dump.

  Tôi phân tích và biết rằng vấn đề không phải ở số

  parallel jobs mà là TOAST table 81GB single-threaded.

TASK:

  Thuyết phục team chấp nhận dùng pg\_repack thay vì

  tăng \-j — một tool họ chưa từng dùng, cần downtime

  trên DR Acceptance để test.

ACTION:

  → Chuẩn bị demo: chạy pg\_dump với \-j 4, \-j 8, \-j 16

    → thời gian gần như không đổi → chứng minh bằng số liệu

  → Giải thích root cause bằng diagram đơn giản:

    pg\_dump parallel theo TABLE, nhưng 1 table đơn

    không thể chia → 81GB TOAST là bottleneck

  → Đề xuất: test pg\_repack trên DR Acceptance trước,

    không đụng Production cho đến khi verify

  → Trình bày risk: pg\_repack cần extra disk space,

    chạy online không lock Production

RESULT:

  → Team đồng ý test

  → DR Acceptance: TOAST 81GB → 4GB

  → Production: backup 3h05 → 15 phút (92%)

  → Manager sau đó reference case này trong báo cáo

    với Vietnam Airlines

---

**Q5.**

*"Kể về một lần bạn không đồng ý với quyết định của tech lead hoặc manager. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời — thể hiện professional disagreement:**

SITUATION:

  Trong dự án LPBank OFSAA, tech lead muốn dùng

  IKM mặc định (row-by-row) để đơn giản, dễ maintain.

  Tôi biết với 200 Program và data lớn, cách này

  sẽ không đảm bảo SLA batch window.

TASK:

  Đưa ra quan điểm khác mà không gây conflict,

  đồng thời có backup plan nếu không được chấp nhận.

ACTION:

  → Không phản đối ngay trong meeting

  → Tự làm benchmark trên môi trường dev:

    IKM row-by-row: 45 phút/Mapping

    IKM bulk insert: 8 phút/Mapping

  → Trình bày kết quả với tech lead riêng trước,

    không public để tránh làm họ mất mặt

  → Đề xuất: dùng bulk insert cho các Mapping lớn,

    row-by-row cho Mapping nhỏ ít quan trọng

  → Compromise: áp dụng cho top 20 Mapping

    chạy lâu nhất trước, xem kết quả

RESULT:

  → Tech lead đồng ý thử với top 20 Mapping

  → Kết quả tốt → áp dụng toàn bộ

  → Học được: dùng data và số liệu để thuyết phục,

    không dùng opinion; và chọn đúng thời điểm

    trình bày để đối phương không phòng thủ

---

**Q6.**

*"Bạn làm việc trong team có developer, BA và DBA cùng lúc. Kể về một lần có conflict và cách bạn giải quyết."*

💡 **Gợi ý trả lời:**

SITUATION:

  Dự án AML Agribank, BA yêu cầu thêm 3 trường

  mới vào Core table 1 tuần trước Go-live.

  Developer muốn thêm ngay. Tôi (DE) lo ngại

  về impact đến các stored procedure và ODI Mapping

  đã được test xong.

TASK:

  Tìm giải pháp dung hòa giữa yêu cầu business

  và rủi ro kỹ thuật, không để conflict leo thang.

ACTION:

  → Yêu cầu meeting 3 bên: BA, developer, DE

  → Tôi liệt kê cụ thể những gì phải thay đổi:

    X stored procedure, Y ODI Mapping, Z test case

  → Ước tính thời gian: 3 ngày dev \+ 2 ngày test

    → không kịp Go-live

  → Đề xuất phân chia:

    Phase 1 (Go-live): giữ nguyên schema hiện tại

    Phase 2 (2 tuần sau Go-live): thêm 3 trường mới,

    data được fill từ nguồn đã có sẵn

  → BA chấp nhận vì business không cần 3 trường đó

    ngay ngày Go-live

RESULT:

  → Go-live đúng hạn, không có rủi ro

  → Phase 2 được thực hiện có kế hoạch, test kỹ

  → Học được: conflict thường giải quyết được khi

    tất cả thấy trade-off rõ ràng bằng số liệu cụ thể

---

**🔵 CHỦ ĐỀ 3 — Tự học & phát triển**

---

**Q7.**

*"Kể về một lần bạn phải học một công nghệ hoàn toàn mới trong thời gian ngắn để giải quyết vấn đề."*

💡 **Gợi ý trả lời — dùng case pg\_repack hoặc WAL sync:**

SITUATION:

  VAECO yêu cầu xây dựng hệ thống WAL sync

  sang DR site. Tôi chưa từng làm WAL Archiving

  và script multi-threading Python trước đó.

TASK:

  Xây dựng hệ thống tự động sync WAL song song

  4 luồng trong vòng 2 tuần.

ACTION:

  → Ngày 1-3: đọc PostgreSQL documentation về

    WAL Archiving, archive\_command, restore\_command

  → Ngày 3-5: test trên môi trường dev với

    single-thread trước, verify correctness

  → Ngày 5-8: nghiên cứu Python threading,

    implement 4 luồng, thêm error handling

  → Ngày 8-12: test với data volume thật,

    monitor lag, fix edge cases

  → Ngày 12-14: code review với senior, deploy

    lên DR Acceptance, verify kết quả

RESULT:

  → Hệ thống hoạt động ổn định, replication lag

    giảm đáng kể so với single-thread

  → Học được cách tiếp cận: theory → small test

    → scale up → production, không nhảy thẳng vào

    implement phức tạp ngay từ đầu

---

**Q8.**

*"DE là lĩnh vực thay đổi nhanh. Bạn tự học và cập nhật kiến thức như thế nào?"*

💡 **Gợi ý trả lời — thực tế và cụ thể, tránh câu trả lời chung chung:**

Đừng nói: *"Tôi đọc blog và xem YouTube."*

Nên nói cụ thể hơn:

Cách tôi học có hệ thống:

1\. LEARN FROM PRODUCTION PROBLEMS:

   Mỗi incident tôi xử lý đều ghi lại root cause

   và solution. Case pg\_repack và DR recovery

   là những thứ tôi học được nhiều nhất — không

   sách giáo khoa nào dạy được chi tiết như vậy.

2\. OFFICIAL DOCUMENTATION:

   PostgreSQL docs và Oracle docs là nguồn

   chính xác nhất. Tôi đọc release notes

   khi có version mới để biết thay đổi gì.

3\. THỰC HÀNH TRÊN LAB:

   Tôi duy trì môi trường PostgreSQL local để

   test các case chưa gặp — ví dụ tôi đã tự

   simulate failover scenario nhiều lần trước

   khi làm trên production.

4\. HIỆN TẠI ĐANG TÌM HIỂU:

   \[Thật thà về những gì đang học thêm —

   ví dụ: Apache Airflow cho orchestration,

   hoặc dbt cho transformation layer\]

---

**Q9.**

*"Điểm yếu của bạn là gì? Bạn đang làm gì để cải thiện?"*

💡 **Gợi ý trả lời — thành thật nhưng không self-sabotage:**

Tránh: *"Tôi làm việc quá chăm chỉ"* → cliché, không ai tin. Tránh: *"Tôi không có điểm yếu"* → thiếu self-awareness.

Câu trả lời tốt — điểm yếu thật nhưng không critical với role DE:

Điểm yếu tôi nhận ra: documentation.

Khi giải quyết vấn đề kỹ thuật, tôi thường

tập trung vào fix và tối ưu, nhưng sau đó

không document lại đầy đủ ngay lập tức.

Kết quả là đôi khi knowledge nằm trong

đầu tôi, không transfer được cho team.

Điều tôi đang làm để cải thiện:

→ Sau mỗi incident: viết post-mortem ngắn

  trong vòng 24 tiếng

→ Trước khi close một task: tự hỏi

  "Nếu người khác cần làm lại việc này,

  họ cần biết gì?"

→ Tôi đã viết runbook cho case WAL recovery

  và pg\_repack sau khi xử lý ở VAECO —

  đây là thói quen tôi đang cố xây dựng

---

**🔵 CHỦ ĐỀ 4 — Định hướng & phù hợp với công ty**

---

**Q10.**

*"Tại sao bạn muốn chuyển sang công ty này? Bạn biết gì về chúng tôi?"*

💡 **Gợi ý cách chuẩn bị — đây là câu hỏi cần research trước:**

TRƯỚC KHI PHỎNG VẤN — cần tìm hiểu:

  → Công ty làm gì? Domain: banking, fintech, retail...

  → Tech stack của họ: dùng cloud nào? Tool nào?

  → Culture: startup hay enterprise?

  → Vị trí DE này cần làm gì cụ thể?

FRAMEWORK TRẢ LỜI:

1\. Lý do cụ thể về công ty/vị trí:

   "Tôi thấy vị trí này làm việc với \[X technology\]

   mà tôi muốn phát triển thêm. Công ty đang

   \[Y project/direction\] phù hợp với background

   banking DE của tôi."

2\. Giá trị bạn mang lại:

   "Với kinh nghiệm ETL cho hệ thống AML và DWH

   banking, tôi có thể đóng góp ngay vào \[Z\]

   mà không cần thời gian ramp-up dài."

3\. Tránh:

   → "Vì muốn tăng lương" (dù là sự thật, đừng nói thẳng)

   → "Công ty cũ không tốt" (luôn nói tích cực về nơi cũ)

---

**Q11.**

*"Bạn thấy mình 3-5 năm nữa sẽ ở đâu trong sự nghiệp DE?"*

💡 **Gợi ý trả lời — thể hiện ambition nhưng realistic:**

Ngắn hạn (1-2 năm):

  Củng cố và mở rộng nền tảng hiện tại:

  → Học thêm orchestration tool như Airflow

    để tự động hóa pipeline tốt hơn

  → Tiếp cận cloud data platform (AWS/GCP)

    vì đây là hướng thị trường đang đi

  → Đi sâu hơn vào data modeling cho

    banking domain mà tôi đang mạnh

Trung hạn (3-5 năm):

  → Muốn đảm nhận vai trò Senior DE hoặc

    Data Architect — thiết kế end-to-end

    data platform thay vì chỉ implement

  → Có thể mentor junior DE dựa trên

    kinh nghiệm thực tế đã tích lũy

  → Đóng góp vào các quyết định kiến trúc

    data ở cấp tổ chức

\[Quan trọng: kết nối với công ty đang apply\]

  "Tôi thấy công ty đang xây dựng \[X\] —

  đây là môi trường tốt để phát triển

  theo hướng đó."

---

**Q12.**

*"Kể về thành tích bạn tự hào nhất trong sự nghiệp DE đến nay."*

💡 **Gợi ý trả lời — đây là cơ hội "sell yourself" tốt nhất:**

Tôi tự hào nhất về case pg\_repack ở VAECO

vì nó thể hiện đầy đủ cách tôi tiếp cận vấn đề.

SITUATION:

  Backup PostgreSQL 328GB mất 3h05 mỗi ngày.

  Ai cũng nghĩ giải pháp là tăng parallel jobs.

GÌ TÔI LÀM KHÁC:

  Thay vì chấp nhận giải pháp obvious, tôi

  đặt câu hỏi: "Tại sao tăng \-j không giúp?"

  → Phân tích sâu hơn → phát hiện root cause

    thật sự là TOAST table 81GB single-threaded

  → Nghiên cứu pg\_repack — tool tôi chưa dùng

  → Test kỹ trên DR Acceptance trước

  → Deploy lên Production chỉ sau khi verify

KẾT QUẢ:

  → Backup 3h05 → 15 phút (giảm 92%)

  → 328GB → 18GB dung lượng

  → Không downtime, không data loss

ĐIỀU TÔI TỰ HÀO NHẤT:

  Không phải con số 92% — mà là mindset:

  không vội fix theo cách obvious, dành thời gian

  hiểu đúng vấn đề, test an toàn trước khi production.

  Đây là cách tôi muốn tiếp cận mọi vấn đề.

---

**📊 Tổng kết nhóm 9**

| Câu | Chủ đề | Dùng case nào |
| :---- | :---- | :---- |
| Q1 | Xử lý sự cố production | DR mất đồng bộ 6 tiếng VAECO |
| Q2 | Sai lầm và lesson learned | Drop partition NHNN |
| Q3 | Áp lực deadline | Go-live VAECO AMOS |
| Q4 | Thuyết phục kỹ thuật | pg\_repack VAECO |
| Q5 | Professional disagreement | IKM LPBank OFSAA |
| Q6 | Team conflict | Schema thay đổi AML |
| Q7 | Tự học công nghệ mới | WAL sync Python |
| Q8 | Cập nhật kiến thức | Các nguồn học cụ thể |
| Q9 | Điểm yếu | Documentation habit |
| Q10 | Tại sao công ty này | Research trước |
| Q11 | Career 3-5 năm | Senior DE / Architect |
| Q12 | Thành tích tự hào nhất | pg\_repack 92% |

---

💡 **3 nguyên tắc vàng cho nhóm câu hỏi này:**

**Cụ thể hơn chung chung:** "Tôi đã giảm backup từ 3h05 xuống 15 phút" mạnh hơn "Tôi đã cải thiện hiệu năng hệ thống."

**Số liệu khi có thể:** Con số tạo credibility — 92%, 4h→30p, 300+ bảng, 1.000+ users.

**Lesson learned luôn ở cuối:** Interviewer không chỉ muốn nghe bạn làm gì, họ muốn biết bạn học được gì và có áp dụng không.

Bạn muốn chuyển sang **nhóm 10: Domain Knowledge (Banking & Aviation)** — nhóm cuối cùng, hay muốn **luyện tập trả lời** một câu cụ thể?

**Nhóm 7: Xử lý sự cố thực tế — Câu hỏi chi tiết**

---

Đây là nhóm câu hỏi **phân biệt rõ nhất** DE có kinh nghiệm thật với DE chỉ làm trên môi trường lý tưởng. Interviewer muốn thấy bạn **suy nghĩ có hệ thống dưới áp lực**, không chỉ biết lý thuyết.

---

**🔵 CHỦ ĐỀ 1 — Sự cố ETL & Data Pipeline**

---

**Q1.**

*"Batch ETL hằng đêm fail lúc 3h sáng. Bạn nhận được alert email. Quy trình xử lý của bạn từ lúc nhận alert đến lúc hệ thống hoạt động bình thường?"*

💡 **Gợi ý trả lời — incident response có hệ thống:**

BƯỚC 1 — TRIAGE (5 phút đầu):

  → Đọc error message trong alert email:

    Job nào fail? Ở step nào? Lỗi gì?

  → Đánh giá severity:

    \- Core table bị ảnh hưởng? → Critical

    \- Chỉ staging fail? → Có thể rerun

    \- Lỗi DQ nhiều? → Data source problem

  → Quyết định: fix ngay hay chờ đến sáng?

    Nếu có báo cáo sáng 8h cần data → fix ngay

BƯỚC 2 — DIAGNOSE (10-15 phút):

  → Check job log:

    SELECT \* FROM etl\_job\_log 

    WHERE batch\_date \= TRUNC(SYSDATE) 

    ORDER BY start\_time;


  → Check error table:

    SELECT error\_type, COUNT(\*), sample error\_message

    FROM etl\_error\_log

    WHERE batch\_id \= :failed\_batch\_id

    GROUP BY error\_type;


  → Check system resources:

    \- Disk còn đủ không?

    \- DB link còn sống không?

    \- Lock/blocking không?


  → Xác định bước cuối cùng thành công là gì

    → Rerun từ bước đó, không chạy lại từ đầu

BƯỚC 3 — FIX & RERUN:

  → Nếu lỗi transient (network, timeout):

    Rerun job ngay

  → Nếu lỗi data (DQ fail nhiều):

    Điều tra nguồn trước khi rerun

  → Nếu lỗi code:

    Fix code, test trên dev, deploy, rerun

BƯỚC 4 — VERIFY:

  → Check row count: staging vs source

  → Check core table: data có đủ không?

  → Chạy reconciliation query

BƯỚC 5 — COMMUNICATE & DOCUMENT:

  → Notify stakeholder: đã fix, data ready lúc X

  → Ghi incident log: nguyên nhân, thời gian,

    action taken, lesson learned

  → Nếu lỗi có thể tái phát: thêm alert rule mới

---

**Q2.**

*"Batch ETL chạy thành công (status \= SUCCESS) nhưng team báo cáo phát hiện số liệu sai. Bạn điều tra như thế nào?"*

💡 **Gợi ý trả lời — đây là case khó hơn batch fail:**

Batch success nhưng data sai → 3 khả năng:

  1\. Transform logic sai

  2\. Source data đã sai từ nguồn

  3\. DQ check không đủ chặt → data lỗi qua lọt

BƯỚC 1 — SCOPE THE PROBLEM:

  → Số liệu nào sai? Bảng nào? Ngày nào?

  → Sai từ khi nào? Hôm nay mới sai hay lâu rồi?

  → Sai theo pattern gì? Chi nhánh cụ thể?

    Loại giao dịch cụ thể? Hay random?

BƯỚC 2 — TRACE NGƯỢC TỪ OUTPUT:

  → Lấy sample bản ghi sai từ Core/báo cáo

  → Trace về Staging: bản ghi đó có trong

    Staging không? Giá trị là bao nhiêu?

  → Trace về Source: source gửi giá trị gì?


  → Xác định lỗi ở tầng nào:

    Source → Staging: lỗi extract hoặc source sai

    Staging → Core:   lỗi transform

    Core → Báo cáo:  lỗi query báo cáo

BƯỚC 3 — KIỂM TRA TRANSFORM LOGIC:

  SELECT s.transaction\_id,

         s.amount AS source\_amount,

         c.amount AS core\_amount,

         s.currency AS source\_currency,

         c.currency AS core\_currency

  FROM stg\_transactions s

  JOIN core\_transactions c 

    ON s.transaction\_id \= c.transaction\_id

    AND s.batch\_id \= :affected\_batch

  WHERE s.amount \!= c.amount;


  → Nếu có chênh lệch: transform logic sai

  → Kiểm tra: có currency conversion không?

    Exchange rate dùng đúng ngày chưa?

BƯỚC 4 — KIỂM TRA SOURCE:

  → Query trực tiếp từ source system

    (nếu còn window)

  → So sánh với Staging

  → Nếu source đã sai: contact source team

BƯỚC 5 — FIX & REPROCESS:

  → Fix transform logic

  → Rerun từ Staging → Core cho ngày bị ảnh hưởng

  → Không cần extract lại nếu Staging đã đúng

---

**Q3.**

*"Bạn phát hiện pipeline ETL đang tạo duplicate records trong Core table. Chưa biết từ khi nào. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời:**

BƯỚC 1 — QUANTIFY:

  \-- Đếm duplicate

  SELECT transaction\_id, COUNT(\*) cnt

  FROM core\_transactions

  GROUP BY transaction\_id

  HAVING COUNT(\*) \> 1

  ORDER BY cnt DESC;


  \-- Kết quả: bao nhiêu bản ghi bị duplicate?

  \-- Từ ngày nào? 

  SELECT MIN(load\_dt), MAX(load\_dt)

  FROM core\_transactions

  WHERE transaction\_id IN (

    SELECT transaction\_id FROM core\_transactions

    GROUP BY transaction\_id HAVING COUNT(\*) \> 1

  );

BƯỚC 2 — ROOT CAUSE:

  Nguyên nhân phổ biến nhất:

  a) Batch chạy 2 lần (retry không check đã chạy)

  b) INSERT thay vì MERGE → không detect existing

  c) Primary key không enforce ở tầng application

  d) Staging bị duplicate → propagate vào Core

  → Kiểm tra job\_log: batch nào chạy 2 lần?

  SELECT batch\_date, COUNT(\*) 

  FROM etl\_job\_log 

  WHERE job\_name \= 'LOAD\_CORE\_TRANSACTIONS'

  GROUP BY batch\_date

  HAVING COUNT(\*) \> 1;

BƯỚC 3 — CLEAN UP:

  \-- Giữ record mới nhất, xóa record cũ hơn

  DELETE FROM core\_transactions

  WHERE rowid NOT IN (

    SELECT MAX(rowid)  \-- hoặc MIN theo business rule

    FROM core\_transactions

    GROUP BY transaction\_id

  );

  COMMIT;


  \-- Verify

  SELECT COUNT(\*) FROM (

    SELECT transaction\_id

    FROM core\_transactions

    GROUP BY transaction\_id

    HAVING COUNT(\*) \> 1

  );

BƯỚC 4 — PREVENT RECURRENCE:

  → Thêm UNIQUE constraint hoặc PRIMARY KEY

  → Đổi INSERT → MERGE trong stored procedure

  → Thêm duplicate check vào DQ layer:

    trước khi load Core, check xem transaction\_id

    đã tồn tại chưa

  → Thêm idempotency check trong job scheduling:

    nếu batch\_date đã có status SUCCESS thì

    không chạy lại

---

**Q4.**

*"Source system thay đổi schema (thêm cột, đổi tên cột, đổi kiểu dữ liệu) mà không thông báo trước. ETL của bạn fail. Xử lý như thế nào và làm thế nào để ngăn chặn trong tương lai?"*

💡 **Gợi ý trả lời:**

IMMEDIATE FIX:

  Trường hợp 1 — Đổi tên cột:

  → ODI Mapping bị lỗi vì column không tồn tại

  → Reverse Model lại trong ODI để update metadata

  → Cập nhật Mapping: đổi source column reference

  → Test và redeploy

  Trường hợp 2 — Đổi kiểu dữ liệu (VARCHAR → NUMBER):

  → Kiểm tra xem Staging column có compatible không

  → Nếu cần: ALTER TABLE stg\_xxx MODIFY column\_name...

  → Kiểm tra transform logic có cần thay đổi không

  Trường hợp 3 — Thêm cột bắt buộc mới:

  → Source gửi thêm data → Staging cần thêm cột

  → Thêm cột vào Staging (DEFAULT NULL)

  → Cập nhật Mapping trong ODI

  → Quyết định: có cần load vào Core không?

PREVENTION — Hệ thống phát hiện schema change:

  \-- Script chạy hằng đêm trước khi ETL:

  \-- So sánh schema hiện tại với schema đã lưu


  CREATE TABLE schema\_snapshot (

      table\_name    VARCHAR2(100),

      column\_name   VARCHAR2(100),

      data\_type     VARCHAR2(50),

      data\_length   NUMBER,

      nullable      VARCHAR2(1),

      snapshot\_date DATE DEFAULT SYSDATE

  );


  \-- Detect change:

  SELECT 'COLUMN\_REMOVED' change\_type,

         s.column\_name, s.data\_type

  FROM schema\_snapshot s

  WHERE s.snapshot\_date \= TRUNC(SYSDATE) \- 1

  AND NOT EXISTS (

    SELECT 1 FROM all\_tab\_columns c

    WHERE c.table\_name \= s.table\_name

    AND c.column\_name \= s.column\_name

  )


  UNION ALL


  SELECT 'TYPE\_CHANGED',

         c.column\_name, 

         c.data\_type || ' (was: ' || s.data\_type || ')'

  FROM all\_tab\_columns c

  JOIN schema\_snapshot s 

    ON c.table\_name \= s.table\_name

    AND c.column\_name \= s.column\_name

    AND s.snapshot\_date \= TRUNC(SYSDATE) \- 1

  WHERE c.data\_type \!= s.data\_type;


  \-- Nếu có thay đổi → alert email TRƯỚC khi chạy ETL

---

**🔵 CHỦ ĐỀ 2 — Sự cố Database & Performance**

---

**Q5.**

*"Lúc 9h sáng, team báo cáo: màn hình ứng dụng AMOS của VAECO load rất chậm, có màn hình mất 2-3 phút. Bình thường chỉ vài giây. Bạn điều tra từ góc độ DBA như thế nào?"*

💡 **Gợi ý trả lời — performance troubleshooting từng bước:**

BƯỚC 1 — CHECK NGAY (2 phút):

  \-- Active sessions đang làm gì?

  SELECT pid, usename, state, 

         wait\_event\_type, wait\_event,

         LEFT(query, 100\) query\_preview,

         now() \- query\_start AS duration

  FROM pg\_stat\_activity

  WHERE state \!= 'idle'

  ORDER BY duration DESC;

  → Có session nào chạy \>30 giây không?

  → Wait event là gì?

    'Lock': có blocking session

    'IO': disk I/O bottleneck

    'CPU': query intensive

BƯỚC 2 — CHECK BLOCKING:

  SELECT 

    pg\_blocking\_pids(pid) AS blocked\_by,

    pid, query, state, wait\_event

  FROM pg\_stat\_activity

  WHERE cardinality(pg\_blocking\_pids(pid)) \> 0;

  → Ai đang block ai?

  → Blocking session đang chạy gì?

  → Có nên kill không?

BƯỚC 3 — CHECK SLOW QUERIES:

  \-- Queries đang chạy lâu nhất

  SELECT pid,

         now() \- query\_start AS runtime,

         wait\_event\_type, wait\_event,

         LEFT(query, 200\) query

  FROM pg\_stat\_activity

  WHERE state \= 'active'

    AND query\_start \< now() \- INTERVAL '30 seconds'

  ORDER BY runtime DESC;

BƯỚC 4 — CHECK SYSTEM RESOURCES (Grafana):

  → CPU: đột biến không?

  → Disk I/O: read/write MB/s cao bất thường?

  → RAM: available memory còn không?

    Nếu RAM thấp → OS swap → slow

  → Connections: gần max\_connections?

BƯỚC 5 — CORRELATE VỚI EVENT:

  → Có batch ETL nào đang chạy không?

  → Có deploy nào sáng nay không?

  → Có autovacuum đang chạy trên bảng lớn không?

    SELECT relname, last\_autovacuum, last\_autoanalyze

    FROM pg\_stat\_user\_tables

    WHERE last\_autovacuum \> now() \- INTERVAL '2 hours';

BƯỚC 6 — FIX THEO NGUYÊN NHÂN:

  Blocking: kill session block nếu hợp lệ

  Slow query: optimize query hoặc add index

  Autovacuum: điều chỉnh schedule, không chạy giờ cao điểm

  Resource: contact infra team

---

**Q6.**

*"Disk I/O của DB server VAECO đột ngột tăng cao bất thường lúc 10h sáng, ứng dụng bắt đầu slow. Không có batch ETL chạy lúc đó. Nguyên nhân có thể là gì?"*

💡 **Gợi ý trả lời — systematic hypothesis:**

HYPOTHESIS 1 — Autovacuum đang chạy:

  → Autovacuum chọn bảng lớn để vacuum

    → đọc/ghi nhiều

  → Check:

    SELECT relname, last\_autovacuum,

           n\_dead\_tup, n\_live\_tup

    FROM pg\_stat\_user\_tables

    WHERE last\_autovacuum \> now() \- INTERVAL '1 hour'

    ORDER BY n\_dead\_tup DESC;

  → Fix tạm: pg\_cancel\_backend(autovacuum\_pid)

  → Fix dài hạn: reschedule autovacuum giờ thấp điểm

HYPOTHESIS 2 — Query không có Index đang chạy:

  → Full scan bảng lớn → nhiều disk read

  → Check pg\_stat\_activity slow queries

  → EXPLAIN ANALYZE để confirm Full Scan

  → Fix: thêm Index, reschedule query

HYPOTHESIS 3 — WAL generation cao:

  → Bulk update/delete gây nhiều WAL

  → Check: pg\_stat\_bgwriter, wal\_buffers\_clean

  → Có developer nào đang chạy migration script?

HYPOTHESIS 4 — Checkpoint bão hòa:

  → Checkpoint xảy ra quá thường → nhiều dirty page write

  → Check: checkpoint\_warning trong log

  → Fix: tăng max\_wal\_size,

         tăng checkpoint\_completion\_target

HYPOTHESIS 5 — Replication lag cao:

  → Primary generate WAL nhiều để catch up Standby

  → Check pg\_stat\_replication

  → Standby có vấn đề gì không?

DIAGNOSIS APPROACH:

  → Correlate I/O spike với pg\_stat\_activity

    tại đúng thời điểm đó

  → Dùng iostat \-x 1 để xem disk patterns:

    sequential read (full scan) hay

    random I/O (index lookup)?

---

**Q7.**

*"Sau khi deploy ODI Mapping mới lên Production LPBank, toàn bộ batch đêm đó fail. Backup plan của bạn là gì và bạn rollback như thế nào?"*

💡 **Gợi ý trả lời:**

PHÒNG NGỪA TRƯỚC KHI DEPLOY:

  → Luôn giữ Scenario version cũ trong ODI

  → Không delete Scenario cũ ngay sau deploy

  → Document: version mới thay đổi gì so với cũ

KHI XẢY RA SỰ CỐ:

  BƯỚC 1 — STOP (30 giây):

    → Dừng tất cả job đang chạy

    → Ngăn không cho job tiếp theo bắt đầu

    → Không làm gì thêm khi chưa rõ nguyên nhân

  BƯỚC 2 — ASSESS (5 phút):

    → Tất cả job fail hay chỉ job liên quan

      đến Mapping mới?

    → Error message là gì?

      \- Column not found → schema mismatch

      \- Constraint violation → data issue

      \- ORA-XXXXX → Oracle error

    → Data ở Core table bị ảnh hưởng không?

      Đã có partial load chưa?

  BƯỚC 3 — ROLLBACK:

    → Trong ODI: re-deploy Scenario version cũ

      (đã giữ lại trước khi deploy mới)

    → Nếu Core table đã bị partial load:

      DELETE FROM core\_xxx 

      WHERE batch\_id \= :failed\_batch\_id;

      COMMIT;

    → Verify: chạy Scenario cũ trên môi trường

      test với data hôm nay trước khi Production

  BƯỚC 4 — RERUN:

    → Chạy lại toàn bộ batch với Scenario cũ

    → Monitor chặt từng bước

    → Notify stakeholder: batch delay X tiếng,

      dự kiến hoàn thành lúc Y

  BƯỚC 5 — ROOT CAUSE:

    → Tại sao Mapping mới fail trên Production

      nhưng không fail trên test?

    → Production data có edge case mà test data không có?

    → Fix Mapping mới, test kỹ hơn với

      production-like data, redeploy lần sau

---

**🔵 CHỦ ĐỀ 3 — Sự cố dữ liệu nghiêm trọng**

---

**Q8.**

*"Bạn phát hiện một stored procedure ETL có bug đã chạy sai trong 7 ngày qua. Core table đang có data sai trong 7 ngày đó. Xử lý thế nào?"*

💡 **Gợi ý trả lời — data recovery scenario:**

BƯỚC 1 — STOP THE BLEEDING:

  → Dừng batch ngay, không cho chạy tiếp

  → Disable job schedule

  → Notify stakeholder: có data issue,

    đang điều tra, chưa dùng data 7 ngày qua

BƯỚC 2 — QUANTIFY DAMAGE:

  → Bug ảnh hưởng bảng nào? Cột nào?

  → Bao nhiêu % records bị sai?

  → Downstream nào đã dùng data sai này?

    Báo cáo nào? Hệ thống nào?

  \-- Sample records bị ảnh hưởng

  SELECT \* FROM core\_transactions

  WHERE load\_dt BETWEEN :bug\_start AND :bug\_end

  AND ROWNUM \<= 100;

BƯỚC 3 — XÁC ĐỊNH ĐÚNG/SAI:

  → Staging vẫn còn data gốc không?

    (Staging thường giữ 7-30 ngày)

  → Nếu còn: so sánh Staging vs Core

    để xác định chính xác records nào sai

  SELECT s.transaction\_id,

         s.amount AS correct\_amount,

         c.amount AS wrong\_amount

  FROM stg\_transactions s

  JOIN core\_transactions c 

    ON s.transaction\_id \= c.transaction\_id

  WHERE s.batch\_date BETWEEN :start AND :end

  AND s.amount \!= c.amount;

BƯỚC 4 — FIX DATA:

  Option A — Nếu Staging còn đầy đủ:

    → Fix stored procedure bug

    → Delete 7 ngày data sai trong Core

    → Rerun batch từ Staging cho 7 ngày đó

    → Reconcile với source để verify

  Option B — Nếu Staging không còn:

    → Extract lại từ source (nếu source còn giữ)

    → Load vào Staging mới

    → Rerun transform với SP đã fix

    

  Option C — Nếu source cũng không còn:

    → Dùng backup: restore Core về snapshot

      trước khi bug xuất hiện

    → Rerun 7 ngày từ đó

    → Tốn thời gian nhất nhưng chắc chắn nhất

BƯỚC 5 — VERIFY:

  → Reconcile số liệu với source

  → Kiểm tra downstream impact:

    báo cáo đã gửi đi có cần re-issue không?

  → Với AML: cần báo cáo ngay với compliance team

BƯỚC 6 — POST-MORTEM:

  → Tại sao bug tồn tại 7 ngày không bị phát hiện?

  → DQ check và reconciliation không đủ?

  → Thêm automated sanity check:

    so sánh aggregate với ngày trước,

    alert nếu chênh lệch \>10%

---

**Q9.**

*"Trong dự án VAECO, bạn đang sync dữ liệu từ Production xuống Test. Lỡ tay sync ngược lại — overwrite Production bằng Test data. Bạn làm gì?"*

💡 **Gợi ý trả lời — worst case scenario:**

BƯỚC 1 — KHÔNG PANIC, ĐÁNH GIÁ NGAY:

  → Production đã bị overwrite bao nhiêu?

  → Sync đã hoàn thành hay đang chạy?

  → Nếu đang chạy: KILL NGAY lập tức

    pg\_terminate\_backend(sync\_pid)

  → Những bảng nào đã bị overwrite?

BƯỚC 2 — ISOLATE:

  → Block tất cả application connections

    để không có thêm data write lên Production

    (data mới sẽ bị mất khi restore)

  → Thông báo team: Production đang bị incident,

    không ai làm gì thêm

BƯỚC 3 — ASSESS BACKUP AVAILABILITY:

  → Backup gần nhất là khi nào?

    (VAECO: backup hằng ngày)

  → Có WAL archive không?

    (Có → có thể PITR đến thời điểm trước sync)

  → Replication lag của Standby là bao nhiêu?

    → Nếu Standby chưa nhận sync → promote Standby\!

BƯỚC 4 — FASTEST RECOVERY — PROMOTE STANDBY:

  → Nếu Standby vẫn còn data Production tốt:

    pg\_ctl promote \-D /standby\_data

  → Redirect app sang Standby (New Primary)

  → RTO: vài phút

  → Đây là lý do phải có Standby\!

BƯỚC 5 — NẾU STANDBY CŨNG BỊ ẢNH HƯỞNG:

  → PITR từ WAL archive:

    restore\_command để replay WAL

    đến thời điểm 1 phút trước khi sync bắt đầu

  → Tốn thời gian hơn nhưng RPO rất tốt

BƯỚC 6 — SAU KHI PHỤC HỒI:

  → Verify data integrity

  → Report full incident

  → Process improvement:

    \- Thêm confirmation prompt khi sync Production

    \- Tạo script riêng cho prod→test và test→prod

      với tên rõ ràng không thể nhầm

    \- Yêu cầu 2 người approve trước khi

      thực hiện data sync Production

BÀI HỌC: Case này nhấn mạnh tại sao HA/DR

quan trọng — không phải chỉ cho hardware failure

mà còn cho human error.

---

**Q10.**

*"Bạn đang thực hiện migration 300+ bảng cho VAECO. Đến bảng thứ 250, phát hiện có 5 bảng đã bị load sai (dữ liệu bị lệch). Bạn dừng lại hay tiếp tục? Xử lý thế nào?"*

💡 **Gợi ý trả lời:**

DỪNG LẠI NGAY — không tiếp tục khi chưa rõ nguyên nhân.

Lý do:

  → 5 bảng sai có thể là pattern — các bảng sau

    có thể sai theo cùng cách

  → Nếu tiếp tục mà bị sai nhiều hơn → 

    phạm vi fix lớn hơn

  → Migration có cutover window → cần quyết định

    nhanh: fix và tiếp tục hay rollback toàn bộ

BƯỚC 1 — PHÂN TÍCH 5 BẢNG SAI:

  → Sai theo pattern gì?

    \- Cùng loại data? (binary, CLOB, date format)

    \- Cùng source table structure?

    \- Chỉ một số record hay tất cả?

  → Nguyên nhân là gì?

    \- Character encoding mismatch DB2→Oracle?

    \- Date format conversion sai?

    \- NULL handling khác nhau giữa DB2 và Oracle?

BƯỚC 2 — QUYẾT ĐỊNH:

  Nếu nguyên nhân rõ ràng, fix được nhanh:

    → Fix transform logic

    → Re-migrate 5 bảng đó

    → Verify 5 bảng và 10 bảng tiếp theo kỹ hơn

    → Tiếp tục với bảng 251

  Nếu nguyên nhân phức tạp, không chắc:

    → Rollback toàn bộ về 0

    → Fix đúng vấn đề

    → Restart migration — tốt hơn

      là đi tiếp với foundation không chắc

BƯỚC 3 — RE-MIGRATE 5 BẢNG:

  → Truncate target table

  → Fix ETL script

  → Re-run với verify bật chặt hơn:

    \- Row count check

    \- Sample data comparison

    \- Checksum trên các cột quan trọng

  → Confirm 5 bảng đúng trước khi đi tiếp

BƯỚC 4 — PREVENT RECURRENCE:

  → Hiểu root cause → apply fix cho

    tất cả bảng còn lại có cùng pattern

  → Thêm automated verification sau mỗi bảng:

    không chỉ row count mà còn checksum

  → Với bảng binary/CLOB: kiểm tra kỹ hơn

BÀI HỌC TỪ VAECO:

  Tôi đã làm reconciliation script

  sau mỗi nhóm 50 bảng — phát hiện sớm

  thay vì đến cuối mới biết.

---

**🔵 CHỦ ĐỀ 4 — Sự cố trong giờ cao điểm**

---

**Q11.**

*"Đúng 8h sáng thứ Hai — giờ cao điểm — DB link từ Oracle ODI đến source system IPCAS bị đứt. Batch ETL đêm qua đang dở. Bạn xử lý thế nào?"*

💡 **Gợi ý trả lời:**

IMMEDIATE (0-5 phút):

  BƯỚC 1 — VERIFY DB LINK:

    SELECT \* FROM dual@ipcas\_dblink;

    → ORA-12541: TNS no listener

    → ORA-12170: Connect timeout

    → Lỗi gì? → Biết hướng fix

  BƯỚC 2 — TRIAGE:

    → Batch dở đến bước nào?

      Staging xong chưa? Hay đang extract?

    → Nếu Staging đã xong trước khi link đứt:

      → Có thể tiếp tục transform từ Staging

        mà không cần source

    → Nếu đang extract dở: 

      → Staging chưa đủ, cần đợi link recover

  BƯỚC 3 — PARALLEL ACTION:

    → Liên hệ team network/DBA source: link đứt do đâu?

    → Ước tính thời gian phục hồi

    → Trong lúc chờ: tiếp tục các job

      không phụ thuộc IPCAS (SWIFT, OSB...)

  BƯỚC 4 — KHI LINK PHỤC HỒI:

    → Test lại: SELECT \* FROM dual@ipcas\_dblink;

    → Rerun extract từ IPCAS, chỉ lấy data

      chưa có trong Staging

    → Dùng incremental: WHERE batch\_date \= :today

      không lấy lại data đã có

    → Tiếp tục pipeline bình thường

  BƯỚC 5 — COMMUNICATE:

    → Báo cáo sáng 8h có thể delay X tiếng

    → Update tiến độ mỗi 30 phút

    → Xác nhận khi data ready

  PREVENTION:

    → Alert rule: check DB link connectivity

      mỗi 5 phút, alert ngay khi fail

    → Staging buffer: sau khi extract xong

      giữ data 7 ngày → khi link đứt vẫn

      có thể process từ Staging có sẵn

---

**Q12.**

*"Interviewer đưa ra tình huống: Production PostgreSQL Primary bị full disk lúc 2h chiều — giờ cao điểm 800 users đang dùng hệ thống. Mọi write đều fail. Bạn có 15 phút để xử lý. Từng bước?"*

💡 **Gợi ý trả lời — time-pressured incident:**

PHÚT 0-2 — ASSESS:

  df \-h                    → disk nào đầy?

  du \-sh /var/lib/postgresql/  → data dir bao nhiêu?

  du \-sh /var/log/           → log bao nhiêu?

  du \-sh /wal\_archive/       → WAL archive bao nhiêu?

PHÚT 2-5 — QUICK WINS (không risk):

  → Xóa WAL archive cũ (đã replicate đến Standby):

    \-- Kiểm tra Standby đã nhận WAL đến đâu

    SELECT restart\_lsn FROM pg\_replication\_slots;

    \-- Xóa WAL đã được consume bởi tất cả Standby

    SELECT pg\_walfile\_name(restart\_lsn) 

    FROM pg\_replication\_slots;

    \-- Xóa WAL cũ hơn checkpoint đó

    

  → Xóa PostgreSQL log cũ:

    find /var/log/postgresql/ \-name "\*.log" 

         \-mtime \+7 \-delete

  → Xóa temp files:

    ls \-lh /tmp/ | sort \-k5 \-rh | head \-20

    → Xóa temp files lớn không cần thiết

PHÚT 5-10 — NẾU CHƯA ĐỦ:

  → Tìm file lớn bất thường:

    find /var/lib/postgresql/ \-size \+1G \\

         \-exec ls \-lh {} \\;

    → Core dump file? Temporary sort file?

    → pg\_dump đang chạy và tạo file lớn?

  → Check table bloat — bảng nào đang phình:

    SELECT relname, pg\_size\_pretty(

      pg\_total\_relation\_size(oid)) size

    FROM pg\_class ORDER BY 

    pg\_total\_relation\_size(oid) DESC LIMIT 10;

PHÚT 10-15 — NẾU VẪN CHƯA ĐỦ:

  → Add storage khẩn cấp:

    Contact infra team: cần thêm disk NGAY

    Hoặc: mount NFS storage tạm thời

    

  → Relocate WAL archive sang storage khác:

    Symlink từ /wal\_archive → /new\_mount/archive

  → CUỐI CÙNG: fail over sang Standby

    Standby còn disk không?

    Nếu có: promote Standby → New Primary

    Cả Primary và Standby đều full → major incident

SAU KHI XỬ LÝ:

  → Root cause: tại sao disk đầy bất ngờ?

  → Alert ở 80% thay vì 95%

  → Auto-delete WAL archive khi đã verified replicated

  → Capacity planning: disk growth rate theo tuần

---

**📊 Tổng kết nhóm 7**

| Câu | Tình huống | Độ khó | Dự án liên quan |
| :---- | :---- | :---- | :---- |
| Q1 | Batch fail 3h sáng | ⭐⭐⭐ | AML, LPBank |
| Q2 | Batch success nhưng data sai | ⭐⭐⭐ | AML, NHNN |
| Q3 | Duplicate records trong Core | ⭐⭐⭐ | AML Agribank |
| Q4 | Source thay đổi schema không báo | ⭐⭐⭐ | Tất cả |
| Q5 | App slow 9h sáng | ⭐⭐⭐ | VAECO |
| Q6 | Disk I/O cao bất thường | ⭐⭐⭐ | VAECO |
| Q7 | Deploy ODI Mapping mới fail | ⭐⭐⭐ | LPBank OFSAA |
| Q8 | Bug SP chạy sai 7 ngày | ⭐⭐⭐⭐ | AML, NHNN |
| Q9 | Lỡ sync ngược Production | ⭐⭐⭐⭐ | VAECO |
| Q10 | Migration dở phát hiện data sai | ⭐⭐⭐ | VAECO AMOS |
| Q11 | DB link đứt giờ cao điểm | ⭐⭐⭐ | AML Agribank |
| Q12 | Production full disk 2h chiều | ⭐⭐⭐⭐ | VAECO |

---

💡 **3 nguyên tắc khi trả lời nhóm này:**

**Không panic visible:** Interviewer muốn thấy bạn calm và systematic dưới áp lực. Bắt đầu bằng "Đầu tiên tôi sẽ assess..." thay vì "Ôi, tôi sẽ..."

**Luôn có communication plan:** Trong mọi incident, bạn phải thông báo cho stakeholder. Không tự xử lý âm thầm rồi báo sau — đây là dấu hiệu của người thiếu kinh nghiệm.

**Prevention \> Cure:** Kết thúc mỗi case bằng "Sau incident này, tôi đã thêm..." — thể hiện bạn không chỉ fix mà còn ngăn tái phát.

Bạn muốn chuyển sang **nhóm 10: Domain Knowledge Banking & Aviation** — nhóm cuối cùng, hay muốn **luyện tập trả lời** bất kỳ câu nào trong toàn bộ 10 nhóm?

**Nhóm 10: Domain Knowledge — Banking & Aviation**

---

Đây là nhóm câu hỏi **ít DE chuẩn bị nhưng lại gây bất ngờ nhất** trong phỏng vấn. Interviewer muốn biết bạn hiểu **tại sao** data tồn tại, không chỉ biết **làm thế nào** để xử lý nó.

---

**🔵 CHỦ ĐỀ 1 — Banking & Financial Data**

---

**Q1.**

*"AML là gì? Tại sao hệ thống AML cần data pipeline ETL phức tạp như vậy? Nếu data ETL bị sai, hậu quả với ngân hàng là gì?"*

💡 **Gợi ý trả lời — bạn đã làm dự án này, cần hiểu sâu hơn pure technical:**

AML (Anti-Money Laundering) — Phòng chống rửa tiền:

Rửa tiền là quá trình tội phạm chuyển tiền bẩn

(từ ma túy, tham nhũng...) thành tiền hợp pháp

thông qua hệ thống tài chính.

Tại sao cần AML system:

  → Yêu cầu pháp lý BẮTBUỘC của NHNN Việt Nam

  → Thông tư 09/2023/TT-NHNN về phòng chống rửa tiền

  → Tiêu chuẩn quốc tế: FATF (Financial Action Task Force)

  → Nếu vi phạm: bị phạt nặng, thậm chí thu hồi

    giấy phép hoạt động

AML system hoạt động thế nào:

  1\. Thu thập data từ tất cả giao dịch

  2\. Phân tích pattern đáng ngờ:

     \- Giao dịch lớn bất thường (\>500 triệu VNĐ)

     \- Nhiều giao dịch nhỏ liên tiếp

       (structuring — chia nhỏ để tránh threshold)

     \- Giao dịch với quốc gia/cá nhân trong

       danh sách đen (sanctions list)

     \- Customer profile thay đổi đột ngột

  3\. Tạo alert cho compliance team review

  4\. Báo cáo STR (Suspicious Transaction Report)

     lên NHNN nếu xác nhận đáng ngờ

Tại sao ETL phức tạp:

  → Nhiều hệ thống nguồn: IPCAS (giao dịch nội địa),

    SWIFT (quốc tế), thẻ, chứng khoán...

  → Data cần realtime hoặc near-realtime

  → Chất lượng data phải 100% — không thể miss

    một giao dịch đáng ngờ

  → Lịch sử dài: AML cần data nhiều năm để

    phát hiện pattern dài hạn

Hậu quả khi data ETL sai:

  Technical: alert không chính xác — 

    false positive (làm phiền khách tốt) hoặc

    false negative (bỏ sót giao dịch thật sự đáng ngờ)

  Legal: báo cáo STR sai → vi phạm pháp lý

  Financial: phạt tiền từ NHNN, mất uy tín

  Systemic: nếu ngân hàng lớn như Agribank bị

    compromise → ảnh hưởng toàn hệ thống tài chính

---

**Q2.**

*"Core banking system là gì? Tại sao ETL từ core banking sang DWH/AML lại phức tạp hơn ETL thông thường?"*

💡 **Gợi ý trả lời:**

Core Banking System (CBS):

  Hệ thống trung tâm xử lý mọi giao dịch ngân hàng:

  → IPCAS: Agribank dùng

  → T24 (Temenos): nhiều ngân hàng Việt Nam

  → Flexcube (Oracle): VCB, Sacombank...

  → SIBS: một số ngân hàng nhỏ

Đặc điểm của Core Banking data:

  → OLTP thuần túy: tối ưu cho transaction processing,

    không tối ưu cho analytics

  → Schema rất phức tạp và normalize cao:

    một "giao dịch" có thể span 10-20 bảng

  → Naming convention khó hiểu:

    tên cột viết tắt: ACCT\_NO, TXN\_DT, AMT\_CCY...

  → Không có documentation đầy đủ

    (vendor giữ bí mật schema)

  → Data volume cực lớn: Agribank hàng triệu

    giao dịch/ngày

  → Không thể query nặng trực tiếp lên CBS

    → sẽ ảnh hưởng performance production

Tại sao ETL từ CBS phức tạp hơn:

  1\. SCHEMA COMPLEXITY:

     Phải join nhiều bảng để có 1 "giao dịch hoàn chỉnh"

     Ví dụ: 

     IPCAS\_TXN\_HDR (header) \+ IPCAS\_TXN\_DTL (detail)

     \+ IPCAS\_ACCT (account) \+ IPCAS\_CUST (customer)

     → Mới ra được record AML đầy đủ

  2\. DB LINK CONSTRAINT:

     Không thể JOIN trực tiếp nhiều bảng qua DB link

     (quá chậm, quá tải CBS)

     → Phải extract từng bảng vào Staging trước,

       sau đó JOIN trong Staging

  3\. CHANGE TRACKING KHÓ:

     CBS thường không có updated\_at timestamp chuẩn

     → Phải dùng sequence number hoặc WAL log

       để detect thay đổi

  4\. TIMING SENSITIVE:

     Giao dịch ngân hàng có T+0, T+1 settlement

     → ETL phải đúng ngày, không thể chậm

     → Cut-off time quan trọng

  5\. VENDOR LOCK-IN:

     Schema CBS thuộc sở hữu vendor

     → Khi vendor update version, schema có thể thay đổi

     → ETL mapping cần review lại

---

**Q3.**

*"SWIFT là gì? Data từ SWIFT message có gì đặc biệt so với data giao dịch nội địa?"*

💡 **Gợi ý trả lời:**

SWIFT (Society for Worldwide Interbank 

       Financial Telecommunication):

  Mạng lưới trao đổi thông tin tài chính quốc tế.

  Kết nối 11.000+ tổ chức tài chính tại 200+ quốc gia.

SWIFT Message Types (MT):

  MT103: Chuyển tiền cá nhân/doanh nghiệp

  MT202: Chuyển tiền giữa ngân hàng

  MT700: Letter of Credit (Thư tín dụng)

  MT940: Sao kê tài khoản

Đặc điểm data SWIFT:

  → Định dạng chuẩn quốc tế, structured text:

    :20:REFERENCE123

    :23B:CRED

    :32A:240115USD50000,

    :50K:/123456789

    NGUYEN VAN A

    :59:/987654321

    JOHN DOE

    :70:PAYMENT FOR INVOICE 001

    :71A:OUR

  → Phức tạp hơn data nội địa vì:

    \- Nhiều field optional, có thể null

    \- Cần parse message format đặc biệt

    \- Currency conversion (nhiều loại tiền)

    \- Beneficiary bank information (BIC/SWIFT code)

    \- Sanctions screening: kiểm tra tên người gửi/nhận

      với danh sách OFAC, EU sanctions

  → AML đặc biệt quan tâm SWIFT vì:

    \- Rửa tiền xuyên quốc gia dùng SWIFT

    \- Kiểm tra BIC code của ngân hàng đối tác:

      có trong danh sách ngân hàng rủi ro cao không?

    \- Kiểm tra quốc gia: Iran, North Korea, Russia...

Khi ETL từ SWIFT vào AML Staging:

  → Parse message format → extract các field cần

  → Map SWIFT BIC code → dim\_bank

  → Map country code → dim\_country với risk level

  → Currency conversion sang VNĐ để so sánh threshold

---

**Q4.**

*"DWH của Ngân hàng Nhà nước khác gì DWH của ngân hàng thương mại? Dữ liệu ở SG4 phục vụ mục đích gì?"*

💡 **Gợi ý trả lời:**

Ngân hàng Nhà nước Việt Nam (NHNN):

  → Cơ quan quản lý nhà nước về tiền tệ và ngân hàng

  → Không kinh doanh với khách hàng thông thường

  → Điều tiết toàn bộ hệ thống tài chính Việt Nam

DWH NHNN (SG4) khác DWH ngân hàng thương mại:

  NGÂN HÀNG THƯƠNG MẠI (Agribank, LPBank...):

  → Data từ 1 ngân hàng

  → Phân tích: lợi nhuận, rủi ro tín dụng,

    hiệu quả chi nhánh

  → User: ban lãnh đạo, phòng kinh doanh

  NHNN (SG4):

  → Aggregate data từ TẤT CẢ ngân hàng thương mại

    (100+ tổ chức tín dụng)

  → Phân tích vĩ mô:

    \- Tổng dư nợ toàn hệ thống

    \- Thanh khoản hệ thống (LCR, NSFR)

    \- Tỷ lệ nợ xấu toàn ngành

    \- Luồng vốn vào/ra nền kinh tế

  → User: lãnh đạo NHNN, phòng thanh tra giám sát

Tại sao ETL phức tạp cho NHNN:

  → Data từ nhiều nguồn với schema KHÁC NHAU:

    mỗi ngân hàng dùng CBS khác nhau

  → Cần chuẩn hóa sang cùng 1 schema NHNN

  → Mã đơn vị/chi nhánh cần mapping cẩn thận

    → đây chính là project bạn làm ở SG4:

    mapping mã mới khi tái cơ cấu tổ chức

  → Confidentiality: data ngân hàng A không được

    lộ cho ngân hàng B

  → Timeliness: NHNN cần data T+1 để

    giám sát hệ thống hàng ngày

---

**Q5.**

*"OFSAA phục vụ mục đích gì trong ngân hàng? Tại sao LPBank cần hệ thống phân tích lợi nhuận đa chiều?"*

💡 **Gợi ý trả lời:**

OFSAA — Oracle Financial Services Analytical Applications:

  Bộ sản phẩm phân tích tài chính của Oracle,

  thiết kế đặc biệt cho banking.

Tại sao ngân hàng cần OFSAA:

  VẤN ĐỀ: Ngân hàng có hàng triệu tài khoản,

  hàng chục nghìn nhân viên, hàng trăm chi nhánh.

  Câu hỏi management cần trả lời:


  → Chi nhánh nào đang lãi? Chi nhánh nào lỗ?

  → Sản phẩm nào (vay mua nhà, vay tiêu dùng...)

    mang lại lợi nhuận cao nhất?

  → Khách hàng nào đang profitable?

  → Chi phí vận hành đang ăn vào lợi nhuận

    ở đâu nhiều nhất?

  Mà Core Banking không trả lời được những câu này

  → OFSAA giải quyết bằng:

  FTP (Funds Transfer Pricing):

  → Tính "giá vốn nội bộ" cho từng khoản vay/tiền gửi

  → Ví dụ: chi nhánh A huy động 100 tỷ với lãi 6%,

    cho vay 80 tỷ với lãi 9%

  → FTP tính: margin thực sự của chi nhánh A là bao nhiêu

    sau khi trừ "chi phí vốn" nội bộ

  PFT (Profitability Management):

  → TOI (Thu nhập hoạt động thuần):

    \= Thu nhập lãi \+ Thu nhập phí \- Chi phí lãi

  → OPEX allocation: phân bổ chi phí IT, nhân sự,

    chi nhánh xuống từng sản phẩm/khách hàng

  → Kết quả: lãi/lỗ thực tế từng đơn vị kinh doanh

Tại sao ETL quan trọng với OFSAA:

  → Tính toán sai do data thiếu/sai → 

    quyết định kinh doanh sai

  → Ví dụ: nếu thiếu 10% giao dịch của chi nhánh X

    → OFSAA nghĩ chi nhánh X lỗ trong khi thực tế lãi

    → Ban lãnh đạo quyết định đóng chi nhánh → sai

---

**🔵 CHỦ ĐỀ 2 — Aviation & MRO Domain**

---

**Q6.**

*"MRO IT là gì? Tại sao một công ty hàng không cần hệ thống quản lý bảo dưỡng phức tạp như AMOS?"*

💡 **Gợi ý trả lời:**

MRO (Maintenance, Repair & Overhaul):

  Bảo dưỡng, sửa chữa và đại tu tàu bay.

  VAECO (Vietnam Aircraft Engineering Company):

  → Công ty con của Vietnam Airlines

  → Chuyên bảo dưỡng toàn bộ đội tàu bay

    của Vietnam Airlines và các hãng khác

  → \~4.000 nhân viên kỹ thuật

AMOS (Aircraft Maintenance & Operations System):

  → ERP system chuyên biệt cho MRO hàng không

  → Của Swiss AviationSoftware (Swiss AS)

  → Được dùng bởi 200+ hãng hàng không toàn cầu

Tại sao MRO cần system phức tạp:

  1\. AN TOÀN LÀ TRÊN HẾT:

     → Mỗi linh kiện trên máy bay có vòng đời

       tính bằng giờ bay hoặc chu kỳ cất/hạ cánh

     → Ví dụ: Turbine blade phải thay sau 

       3.000 flight cycles

     → Nếu không thay đúng hạn → nguy hiểm

     → AMOS track TỪNG linh kiện trên TỪNG máy bay

  2\. REGULATORY COMPLIANCE:

     → CAAV (Cục Hàng không Việt Nam)

     → EASA (European Union Aviation Safety Agency)

     → FAA (US Federal Aviation Administration)

     → Mỗi công việc bảo dưỡng phải có

       maintenance record đầy đủ

     → Audit có thể yêu cầu lịch sử 20+ năm

  3\. COMPLEX SCHEDULING:

     → Máy bay phải vừa bay vừa bảo dưỡng

     → Schedule bảo dưỡng phải không overlap

       với flight schedule

     → Cân bằng: hangar capacity, kỹ thuật viên,

       linh kiện inventory

Data trong AMOS:

  → Aircraft registration (VN-A321, VN-B787...)

  → Component tracking (Part number, serial number)

  → Work Order (lệnh bảo dưỡng)

  → Task Card (công việc cụ thể trong WO)

  → Technician certification (kỹ thuật viên nào

    được phép làm công việc gì)

  → Material consumption (linh kiện nào dùng)

---

**Q7.**

*"Trong dự án VAECO, bạn migrate data từ AMASIS sang AMOS. AMASIS là gì và tại sao migration phức tạp?"*

💡 **Gợi ý trả lời:**

AMASIS (Aircraft Maintenance Advanced System

        for Integrated Solutions):

  → Hệ thống MRO cũ của VAECO

  → Chạy trên DB2 và SQL Server

  → Đã dùng nhiều năm → data history phong phú

    nhưng schema cũ và khó maintain

Tại sao migration phức tạp:

  1\. SCHEMA MISMATCH:

     AMASIS (DB2/SQL Server) → AMOS (Oracle)

     → Data type khác nhau:

       DB2 TIMESTAMP ≠ Oracle DATE

       SQL Server BIT ≠ Oracle NUMBER(1)

       Character encoding khác nhau

     → Tên bảng/cột khác hoàn toàn

       → cần mapping document dày hàng trăm trang

  2\. BUSINESS RULE TRANSFORMATION:

     → AMASIS lưu data theo cách riêng

     → AMOS có data model khác

     → Không thể copy 1:1 → cần transform logic phức tạp

     → Ví dụ: AMASIS 1 Work Order \= nhiều bảng

       → AMOS Work Order \= cấu trúc khác

  3\. DATA QUALITY LEGACY:

     → Data cũ nhiều năm có nhiều inconsistency

     → Giá trị NULL không chuẩn

     → Reference data (Part number, aircraft reg)

       không consistent giữa các bảng

     → Phải clean trước khi migrate

  4\. ZERO DOWNTIME REQUIREMENT:

     → VAECO không thể ngừng bảo dưỡng máy bay

     → Migration phải xảy ra song song với

       hoạt động bình thường

     → Cutover window: cuối tuần, đêm muộn

  5\. VALIDATION CRITICAL:

     → Một linh kiện bị thiếu trong lịch sử →

       có thể gây vấn đề pháp lý nghiêm trọng

     → Mọi record phải được verify 100%

     → Bạn đã migrate 300+ bảng với reconciliation

       check sau từng nhóm

  Đây là lý do 4h → 30 phút quan trọng:

  Migration data lịch sử cần chạy trong weekend

  window → không thể kéo dài 4 tiếng

---

**Q8.**

*"Tại sao hệ thống MRO của VAECO cần HA/DR 4 tầng? Downtime có ảnh hưởng gì đến hoạt động bảo dưỡng máy bay?"*

💡 **Gợi ý trả lời:**

Impact của AMOS downtime theo thời gian:

  0-30 phút:

  → Kỹ thuật viên không in được Task Card

  → Không mở được Work Order mới

  → Nhưng kỹ thuật viên có thể tiếp tục

    công việc đang làm với giấy tờ thủ công

  30 phút \- 2 giờ:

  → Không thể release máy bay sau bảo dưỡng

    (AMOS phải sign off electronically)

  → Máy bay bị hold → delay chuyến bay

  → Vietnam Airlines phải thông báo hành khách

  → Chi phí: compensation, hotel, reputation damage

  2-4 giờ:

  → Tất cả Work Order bị freeze

  → Scheduling bị disrupted

  → Linh kiện không thể issue từ warehouse

    (AMOS quản lý inventory)

  → Chain effect: nhiều máy bay bị affected

  4+ giờ:

  → Emergency procedures phải activate

  → CAAV có thể audit

  → Contractual penalties với airlines khác

    (ngoài Vietnam Airlines, VAECO còn phục vụ

    Vietjet, Bamboo...)

Tại sao cần 4 tầng:

  Tier 1 — Primary DC:

  → Chạy production 24/7

  → 1.000+ users: kỹ thuật viên, supervisors,

    quality engineers, planners

  Tier 2 — Backup DC:

  → HA: failover trong vài phút nếu Primary fail

  → Cùng datacenter hoặc gần → lag thấp

  Tier 3 — Backup DR:

  → DR: bảo vệ khi toàn bộ datacenter chính fail

  → Site khác địa lý

  Tier 4 — DR Standby:

  → Bảo vệ khi cả DR site gặp vấn đề

  → Last resort, đảm bảo luôn có thể recover

  → Aviation safety culture: redundancy là bắt buộc

    Tương tự như máy bay có 2 động cơ,

    hệ thống IT hàng không cũng phải redundant

---

**🔵 CHỦ ĐỀ 3 — Regulatory & Compliance**

---

**Q9.**

*"AML/CFT là gì? Khi làm ETL cho hệ thống AML, bạn phải tuân thủ những quy định gì?"*

💡 **Gợi ý trả lời:**

AML/CFT:

  AML: Anti-Money Laundering — Phòng chống rửa tiền

  CFT: Combating Financing of Terrorism — 

       Chống tài trợ khủng bố

Khung pháp lý:

  → Quốc tế: FATF 40 Recommendations

    (Financial Action Task Force)

  → Việt Nam: Luật Phòng chống rửa tiền 2022

  → NHNN: Thông tư 09/2023/TT-NHNN

Điều này ảnh hưởng đến ETL như thế nào:

  1\. DATA COMPLETENESS BẮT BUỘC:

     → Mọi giao dịch phải được capture

     → Không được phép "bỏ sót" vì lý do kỹ thuật

     → Nếu ETL fail → phải có recovery plan

       để không miss giao dịch nào

  2\. DATA RETENTION:

     → Theo luật: lưu tối thiểu 5-10 năm

     → ETL phải load vào archive layer

     → Không được delete data dù hết partition

  3\. AUDIT TRAIL:

     → Mọi thay đổi data phải có log:

       ai thay đổi, khi nào, từ gì sang gì

     → ETL audit log phải đầy đủ

     → Bạn đã làm: job log, proc log, error table

  4\. DATA ACCURACY:

     → STR (Suspicious Transaction Report) nộp NHNN

       phải dựa trên data chính xác

     → Báo cáo sai → vi phạm pháp lý

     → DQ checks không phải optional mà là requirement

  5\. TIMELINESS:

     → NHNN quy định ngân hàng phải báo cáo STR

       trong vòng 24 giờ kể từ khi phát hiện

     → ETL phải đảm bảo data real-time hoặc T+1

  6\. DATA SECURITY:

     → Data AML cực kỳ nhạy cảm

     → Chỉ authorized personnel được access

     → ETL accounts phải có least privilege

     → Logs không được chứa sensitive data

       (số tài khoản, CMND phải được mask)

---

**Q10.**

*"Khi làm DWH cho NHNN, bạn xử lý data từ nhiều ngân hàng khác nhau. Có những thách thức gì về data governance?"*

💡 **Gợi ý trả lời:**

Data governance challenges tại NHNN DWH:

  1\. DATA CONFIDENTIALITY:

     → Data của Agribank không được để lộ cho Vietcombank

     → Trong DWH, các bảng aggregate phải được

       access control chặt chẽ

     → ETL pipeline không được mix data của

       các ngân hàng theo cách expose individual bank info

     → Row-level security cho từng reporting unit

  2\. DATA STANDARDIZATION:

     → Mỗi ngân hàng dùng CBS khác nhau

     → Mã chi nhánh: Agribank dùng 4 số,

       Vietcombank dùng 3 chữ...

     → Chuẩn hóa về mã NHNN thống nhất

     → Đây chính là project mapping mã mới

       mà bạn đã làm trong SG4

  3\. TIMELINESS INCONSISTENCY:

     → Ngân hàng lớn (BIDV, Vietcombank):

       gửi data T+1 đúng giờ

     → Ngân hàng nhỏ, QTDND (Quỹ tín dụng):

       đôi khi delay hoặc data quality thấp

     → ETL phải handle late-arriving data:

       nhận data ngày D+2, 3... và backfill

  4\. SCHEMA EVOLUTION:

     → NHNN update quy định → ngân hàng phải

       báo cáo thêm trường mới

     → ETL và DWH schema phải thay đổi đồng bộ

     → Coordination với 100+ tổ chức tín dụng

       là thách thức lớn

  5\. DATA QUALITY VARIANCE:

     → Ngân hàng lớn: data quality cao

     → Ngân hàng nhỏ/QTDND: nhiều lỗi format,

       thiếu trường, giá trị không hợp lệ

     → DWH cần DQ rules riêng cho từng nhóm tổ chức

     → Báo cáo DQ feedback cho từng ngân hàng

  LESSON LEARNED từ SG4:

  Việc mapping mã mới không đơn giản là update bảng —

  phải coordinate với team từng đơn vị để confirm

  mapping đúng, vì sai 1 mã → report sai toàn bộ

  số liệu của đơn vị đó.

---

**Q11.**

*"Trong dự án banking, bạn xử lý data nhạy cảm như số tài khoản, CMND, số tiền. Bạn đảm bảo data security trong pipeline ETL như thế nào?"*

💡 **Gợi ý trả lời:**

Data security trong ETL banking:

  1\. DATA MASKING TRONG NON-PROD:

     → Production data không được copy nguyên vẹn

       xuống dev/test environment

     → Script mask trước khi sync:

     

     UPDATE stg\_customer

     SET id\_number \= REGEXP\_REPLACE(id\_number,

                     '.{6}$', '\#\#\#\#\#\#'),

         full\_name  \= 'CUSTOMER\_' || customer\_id,

         phone      \= '09' || LPAD(FLOOR(DBMS\_RANDOM.VALUE(1,99999999)), 8, '0');

  2\. ACCESS CONTROL:

     → ETL service account chỉ có quyền cần thiết:

       \- Read trên source tables

       \- Write trên staging tables

       \- Execute trên specific stored procedures

     → Không dùng DBA account để chạy ETL

     → Audit: log mọi access vào sensitive tables

  3\. ENCRYPTION IN TRANSIT:

     → DB link giữa systems phải dùng

       Oracle Advanced Security (TDE) hoặc SSL

     → SWIFT messages phải được encrypt khi transfer

  4\. LOGGING KHÔNG CHỨA SENSITIVE DATA:

     → Error log: không log giá trị sensitive

     → Đúng: "ERROR: account\_id 123456789 failed DQ"

     → Sai: "ERROR: CMND 012345678 of Nguyen Van A

              with balance 500,000,000 failed"

     → Mask trong log output

  5\. DATA LINEAGE:

     → Biết data đi qua đâu: ai access,

       ai transform, ai có thể đọc

     → Quan trọng cho GDPR-like compliance

  6\. TRONG DỰ ÁN THỰC TẾ CỦA BẠN:

     → VAECO: sync Production → Test phải mask

       aircraft serial numbers và technician info

       không cần thiết cho testing

     → AML: chỉ authorized compliance team

       được thấy full customer info trong report

---

**Q12.**

*"Bạn làm việc ở nhiều domain: banking (AML, DWH, OFSAA) và aviation (MRO). Bạn thấy điểm giống và khác nhau về data engineering trong 2 domain này như thế nào?"*

💡 **Gợi ý trả lời — câu hỏi tổng hợp, thể hiện tư duy rộng:**

ĐIỂM GIỐNG NHAU:

  1\. DATA QUALITY LÀ NON-NEGOTIABLE:

     → Banking: data sai → báo cáo AML sai → vi phạm pháp lý

     → Aviation: data bảo dưỡng sai → máy bay không airworthy

     → Cả hai: DQ checks không phải optional

     → Cả hai: audit trail bắt buộc, data retention dài

  2\. REAL-TIME PRESSURE:

     → Banking: giao dịch cần xử lý T+1 hoặc near real-time

     → Aviation: bảo dưỡng cần scheduling real-time

     → Cả hai: batch window chặt, downtime impact cao

  3\. REGULATORY COMPLIANCE DRIVEN:

     → Banking: NHNN, FATF, AML regulations

     → Aviation: CAAV, EASA, FAA

     → Cả hai: compliance audit có thể xảy ra bất kỳ lúc

     → Cả hai: documentation và traceability bắt buộc

  4\. LEGACY SYSTEM INTEGRATION:

     → Banking: Core banking (IPCAS, T24) schema phức tạp

     → Aviation: AMASIS (DB2) legacy data model

     → Cả hai: không có documentation đầy đủ,

       phải reverse engineer

ĐIỂM KHÁC NHAU:

  1\. DATA VOLUME & VELOCITY:

     → Banking: hàng triệu transactions/ngày,

       volume tăng theo số khách hàng

     → Aviation: ít records hơn (máy bay ít hơn khách hàng),

       nhưng mỗi record phức tạp hơn nhiều

     → Implication: Banking cần partition, bulk load tốt;

       Aviation cần data model phức tạp, component tracking

  2\. REAL-TIME VS BATCH:

     → Banking (AML): cần gần real-time, detect ngay

     → Aviation (MRO): batch là đủ, nhưng accuracy

       quan trọng hơn speed

  3\. NGƯỜI DÙNG DATA:

     → Banking: BI analyst, compliance officer, management

       → cần aggregated, dashboards

     → Aviation: kỹ thuật viên, quality engineers

       → cần operational data, specific aircraft records

  4\. CONSEQUENCE CỦA SAI:

     → Banking: financial loss, regulatory fine

     → Aviation: safety risk — hậu quả nghiêm trọng hơn

  5\. DATA SENSITIVITY:

     → Banking: financial data cực kỳ sensitive (PII, amount)

     → Aviation: kỹ thuật (serial number, maintenance history)

       sensitive hơn về safety, ít PII hơn

BÀI HỌC RÚT RA:

  Cả hai domain dạy tôi một điều quan trọng:

  DE không chỉ là người viết ETL —

  phải hiểu tại sao data tồn tại và

  hậu quả khi data sai.

  Điều đó thay đổi cách tôi thiết kế

  DQ checks và error handling:

  không phải "best effort" mà là "must be correct."

---

**📊 Tổng kết nhóm 10**

| Câu | Chủ đề | Liên quan đến dự án |
| :---- | :---- | :---- |
| Q1 | AML là gì, hậu quả data sai | AML Agribank |
| Q2 | Core banking & ETL complexity | AML, NHNN |
| Q3 | SWIFT message & data đặc thù | AML Agribank |
| Q4 | DWH NHNN vs ngân hàng thương mại | NHNN SG4 |
| Q5 | OFSAA & phân tích lợi nhuận | LPBank OFSAA |
| Q6 | MRO IT & tại sao cần AMOS | VAECO |
| Q7 | AMASIS → AMOS migration | VAECO AMOS |
| Q8 | Tại sao cần HA/DR 4 tầng aviation | VAECO |
| Q9 | AML/CFT regulations & ETL | AML Agribank |
| Q10 | Data governance NHNN DWH | NHNN SG4 |
| Q11 | Data security trong ETL | Tất cả |
| Q12 | Banking vs Aviation so sánh | Tất cả dự án |

---

💡 **Lời khuyên cuối cùng cho toàn bộ 10 nhóm:**

Bạn có một lợi thế **rất hiếm**: kinh nghiệm thực chiến ở cả banking lẫn aviation, cả ETL development lẫn DBA, cả HA/DR lẫn performance tuning. Rất ít ứng viên DE có breadth như vậy.

Trong phỏng vấn, khi được hỏi bất kỳ câu nào, hãy cố gắng kết nối về một **dự án cụ thể** của bạn với **con số thật**. Đó là thứ không ai lấy được của bạn và không AI nào tạo ra được.

Bạn đã hoàn thành cả 10 nhóm câu hỏi\! Bạn muốn **mock interview toàn bộ** với mình đóng vai interviewer, hay muốn **luyện tập trả lời** một câu cụ thể nào đó?

**Câu hỏi DE phổ biến ngoài CV — Phần mở rộng**

Đây là những câu hỏi interviewer hay hỏi để kiểm tra **kiến thức nền tảng DE** mà không cần kinh nghiệm dự án cụ thể — thường xuất hiện ở vòng 1 screening hoặc khi apply công ty có tech stack khác với background của bạn.

---

**🔵 NHÓM A — Modern Data Stack & Cloud**

---

**Q1.**

*"Apache Airflow là gì? Nó giải quyết vấn đề gì mà ODI/Talend không làm được?"*

💡 **Gợi ý trả lời:**

Airflow là platform orchestration pipeline,

dùng Python để define workflow dưới dạng DAG

(Directed Acyclic Graph).

Khác ODI/Talend ở chỗ:

  ODI/Talend:

  → GUI-based, kéo thả

  → Tốt cho enterprise ETL trong Oracle ecosystem

  → Scheduling built-in nhưng hạn chế

  → Khó version control (XML files)

  → Khó test tự động

  Airflow:

  → Code-based (Python) → Git version control dễ

  → Orchestration chuyên biệt:

    retry logic, dependencies, SLA monitoring

  → DAG: visual flow của pipeline

  → Có thể trigger bất kỳ thứ gì:

    Python function, Spark job, SQL, API call...

  → Web UI đẹp để monitor từng task

  → Cloud-native: Google Composer, AWS MWAA

Ví dụ DAG đơn giản:

  from airflow import DAG

  from airflow.operators.python import PythonOperator


  dag \= DAG('etl\_aml', schedule='0 22 \* \* \*')


  extract \= PythonOperator(task\_id='extract',

                           python\_callable=extract\_fn)

  transform \= PythonOperator(task\_id='transform',

                             python\_callable=transform\_fn)

  load \= PythonOperator(task\_id='load',

                        python\_callable=load\_fn)


  extract \>\> transform \>\> load  \# dependency

Khi nào dùng Airflow vs ODI:

  → ODI: Oracle ecosystem, GUI team, ETL heavy

  → Airflow: multi-tech pipeline, code team,

    cần flexible orchestration

---

**Q2.**

*"dbt (data build tool) là gì? Nó thay đổi cách DE làm transformation như thế nào?"*

💡 **Gợi ý trả lời:**

dbt là transformation layer — chỉ làm T trong ELT.

Cách làm cũ (ETL với stored procedure):

  → Viết SQL trong stored procedure Oracle/PG

  → Deploy bằng tay

  → Khó test, khó document

  → Version control thủ công

Cách làm với dbt:

  → Viết SQL SELECT thần (không cần INSERT/UPDATE)

  → dbt tự generate CREATE TABLE/VIEW từ SELECT đó

  → Built-in testing: not\_null, unique, accepted\_values

  → Auto-generate documentation từ schema.yml

  → Git-based: mọi thứ là code, review được

Ví dụ dbt model:

  \-- models/staging/stg\_transactions.sql

  WITH source AS (

      SELECT \* FROM {{ source('ipcas', 'transactions') }}

  ),

  cleaned AS (

      SELECT

          transaction\_id,

          account\_id,

          CAST(amount AS DECIMAL(18,2)) AS amount,

          UPPER(currency) AS currency,

          transaction\_date::DATE AS transaction\_date

      FROM source

      WHERE amount \> 0  \-- DQ filter

        AND transaction\_date IS NOT NULL

  )

  SELECT \* FROM cleaned

  \-- dbt run → tự tạo bảng stg\_transactions

  \-- dbt test → chạy DQ checks

  \-- dbt docs generate → web documentation

Tại sao DE ngày càng cần biết dbt:

  → Nhiều công ty fintech/startup dùng dbt

  → Kết hợp với Airflow: Airflow orchestrate,

    dbt làm transformation

  → Modern stack: Snowflake/BigQuery \+ dbt \+ Airflow

Với background của bạn:

  SQL strong \+ dbt \= tự nhiên

  dbt chỉ là cách viết SQL có cấu trúc hơn

---

**Q3.**

*"Data Lake, Data Warehouse và Data Lakehouse khác nhau thế nào? Công ty bạn nên dùng cái nào?"*

💡 **Gợi ý trả lời:**

DATA WAREHOUSE (bạn đã làm):

  → Structured data, schema-on-write

  → SQL-friendly, performance cao

  → Đắt khi scale

  → Ví dụ: Oracle DWH NHNN, OFSAA LPBank

  → Tốt cho: báo cáo định kỳ, BI, compliance

DATA LAKE:

  → Raw data mọi định dạng: JSON, CSV, images, logs

  → Schema-on-read: đọc đến đâu define schema đến đó

  → Rẻ (object storage: S3, GCS)

  → Dễ trở thành "data swamp" nếu không govern tốt

  → Ví dụ: AWS S3, Azure Data Lake

  → Tốt cho: ML/AI, exploratory analytics, raw logs

DATA LAKEHOUSE (hybrid mới nhất):

  → Kết hợp: lưu trữ rẻ như Lake,

    query performance như Warehouse

  → Open table format: Delta Lake, Apache Iceberg, Hudi

  → ACID transactions trên object storage

  → Ví dụ: Databricks, Apache Spark \+ Iceberg

  → Tốt cho: công ty cần cả BI lẫn ML/AI

Mapping vào thực tế:

  Ngân hàng truyền thống (Agribank, NHNN):

  → Data Warehouse: Oracle, structured, compliance-heavy

  → Khó thay đổi ngay


  Fintech mới (MoMo, VNPay):

  → Lakehouse: Spark \+ Iceberg trên cloud

  → Flexible, scale tốt, support ML


  Doanh nghiệp lớn chuyển đổi số:

  → Hybrid: DWH cho reporting \+ Lake cho raw/ML

---

**Q4.**

*"Apache Spark là gì? Khi nào nên dùng Spark thay vì SQL thuần?"*

💡 **Gợi ý trả lời:**

Spark là distributed computing framework

xử lý data ở quy mô terabyte/petabyte.

Spark vs SQL thuần:

  SQL thuần (bạn đang dùng):

  → Single machine hoặc single DB cluster

  → Tốt cho: vài trăm GB đến vài TB

  → Oracle, PostgreSQL handle tốt với tuning

  → Ít overhead hơn

  Apache Spark:

  → Distributed: chia data ra nhiều nodes,

    xử lý song song thật sự

  → In-memory: nhanh hơn MapReduce 100x

  → Tốt cho: multi-TB đến petabyte

  → PySpark: Python API

  → Spark SQL: viết SQL chạy distributed

Khi nào cần Spark:

  → Data volume vượt quá single DB handle được

  → Cần xử lý unstructured data (JSON, logs, text)

  → ML pipeline: MLlib built-in

  → Real-time streaming: Spark Streaming/Structured Streaming

Ví dụ PySpark đơn giản:

  from pyspark.sql import SparkSession

  from pyspark.sql.functions import col, sum


  spark \= SparkSession.builder.appName("ETL").getOrCreate()


  df \= spark.read.parquet("s3://bucket/transactions/")


  result \= df.filter(col("amount") \> 1000000\) \\

             .groupBy("branch\_id") \\

             .agg(sum("amount").alias("total"))


  result.write.parquet("s3://bucket/output/")

Với background của bạn:

  → Bạn đã biết SQL tốt → PySpark SQL syntax quen ngay

  → Điểm khác: tư duy distributed, lazy evaluation,

    partition strategy trên cluster

---

**🔵 NHÓM B — Streaming & Real-time**

---

**Q5.**

*"Apache Kafka là gì? Streaming data khác batch data như thế nào? Khi nào banking cần streaming?"*

💡 **Gợi ý trả lời:**

Kafka là distributed message streaming platform.

Kiến trúc cơ bản:

  Producer → \[Kafka Topic\] → Consumer


  Topic: như một queue có nhiều partitions

  Partition: đơn vị parallel processing

  Offset: vị trí trong topic, consumer track đã đọc đến đâu

Batch vs Streaming:

  BATCH (bạn đang làm):

  → Xử lý theo lô, định kỳ (hằng đêm, mỗi 4h)

  → Dữ liệu "stale" trong khoảng giữa 2 batch

  → Đơn giản hơn, easier to debug

  → Phù hợp: báo cáo T+1, DWH aggregate

  STREAMING (Kafka):

  → Xử lý từng event khi nó xảy ra

  → Near real-time: latency milliseconds đến giây

  → Phức tạp hơn: out-of-order events,

    exactly-once semantics, watermarks

  → Phù hợp: fraud detection, live dashboard

Khi banking CẦN streaming:

  → Real-time fraud detection:

    Giao dịch xảy ra → 200ms sau đã biết

    có đáng ngờ không → block nếu cần

    (Batch không làm được — giao dịch xong rồi)

  → Real-time account balance:

    Core banking update → Kafka event →

    mobile app hiển thị ngay

  → AML real-time alerting:

    Phát hiện pattern rửa tiền ngay trong ngày

    thay vì T+1

  → Thẻ tín dụng: phát hiện gian lận ngay lập tức

Với background bạn:

  → Dự án AML của bạn dùng batch (hằng đêm và 4h)

  → Nếu Agribank muốn real-time AML → cần Kafka

  → Đây là điểm bạn có thể nói: "Hiện tại pipeline

    của tôi là batch, tôi hiểu hạn chế của nó và

    muốn tìm hiểu thêm về streaming approach"

---

**Q6.**

*"CDC (Change Data Capture) là gì? Tại sao CDC quan trọng hơn timestamp-based incremental load trong một số trường hợp?"*

💡 **Gợi ý trả lời:**

CDC là kỹ thuật capture mọi thay đổi data

(INSERT, UPDATE, DELETE) từ source system

theo thời gian thực.

Cách hoạt động:

  Database write-ahead log (WAL/redo log)

  ghi lại mọi thay đổi trước khi apply.

  CDC tool đọc log này và stream ra ngoài.

  Ví dụ: Debezium (phổ biến nhất)

  PostgreSQL WAL → Debezium → Kafka topic

  Oracle Redo Log → Debezium → Kafka topic

CDC vs Timestamp-based incremental:

  TIMESTAMP-BASED (bạn đang có thể dùng):

  SELECT \* FROM transactions 

  WHERE updated\_at \>= :last\_run\_time


  Vấn đề:

  → Không bắt được DELETE

    (row bị xóa → không còn updated\_at để query)

  → Cần column updated\_at — không phải bảng nào có

  → Clock skew giữa các servers gây miss records

  → Bulk update không update updated\_at → miss

  CDC:

  → Bắt được tất cả: INSERT, UPDATE, DELETE

  → Không cần column đặc biệt trong source

  → Không miss dù clock skew

  → Low latency: near real-time

Ví dụ CDC message từ Debezium:

  {

    "op": "u",              // u=update, c=create, d=delete

    "before": {

      "account\_id": "123",

      "balance": 1000000

    },

    "after": {

      "account\_id": "123", 

      "balance": 1500000   // đã thay đổi

    },

    "ts\_ms": 1704067200000  // timestamp chính xác

  }

Trong AML context:

  → CDC quan trọng: customer risk level bị DELETE

    trong source → với timestamp-based sẽ miss

  → CDC bắt được DELETE → AML biết customer

    bị removed khỏi source vì lý do gì

---

**🔵 NHÓM C — Data Engineering Fundamentals**

---

**Q7.**

*"Slowly Changing Dimension (SCD) loại nào phù hợp nhất cho từng trường hợp sau: địa chỉ khách hàng, tên sản phẩm, tỷ giá hối đoái hàng ngày?"*

💡 **Gợi ý trả lời:**

ĐỊA CHỈ KHÁCH HÀNG → SCD Type 2:

  → Cần lịch sử: giao dịch ngày 01/01/2023

    khi đó khách hàng ở địa chỉ nào?

  → Quan trọng cho: audit, báo cáo theo địa điểm,

    phân tích hành vi theo khu vực

  → AML: địa chỉ thay đổi bất thường → red flag

TÊN SẢN PHẨM → SCD Type 1 hoặc Type 2:

  → Nếu chỉ sửa lỗi chính tả: Type 1 (overwrite)

  → Nếu đổi tên sản phẩm có ý nghĩa business:

    Type 2 — báo cáo cũ vẫn hiện tên cũ

  → Ví dụ: "Vay mua nhà" đổi thành "Home Loan"

    → báo cáo Q1 vẫn hiện "Vay mua nhà"

TỶ GIÁ HỐI ĐOÁI → SCD Type 2 HOẶC bảng riêng:

  → Tỷ giá thay đổi hàng ngày → 365 records/năm

  → SCD Type 2 vẫn work nhưng thường dùng

    bảng dim\_exchange\_rate riêng:

    

    CREATE TABLE dim\_exchange\_rate (

        rate\_date    DATE,

        currency     VARCHAR2(3),

        rate\_to\_vnd  DECIMAL(18,6),

        PRIMARY KEY (rate\_date, currency)

    );

    

    → Join với fact table theo transaction\_date

      để lấy đúng tỷ giá ngày đó

BONUS CASES:

  → Risk level khách hàng: SCD Type 2

    (cần biết risk level tại thời điểm giao dịch)

  → Mã chi nhánh: SCD Type 2

    (lịch sử attribute của chi nhánh)

  → Giá cổ phiếu: bảng time-series riêng

    (quá nhiều thay đổi, không phải SCD)

---

**Q8.**

*"Idempotency trong data pipeline là gì? Làm thế nào để đảm bảo pipeline của bạn idempotent?"*

💡 **Gợi ý trả lời:**

Idempotency: chạy cùng 1 operation nhiều lần

→ kết quả giống như chạy 1 lần.

Tại sao quan trọng:

  → ETL fail giữa chừng → phải rerun

  → Nếu không idempotent: duplicate data sau khi rerun

  → Production incident tệ hơn khi rerun tạo ra thêm vấn đề

Kỹ thuật đảm bảo idempotency:

  1\. TRUNCATE \+ INSERT (đơn giản nhất):

     TRUNCATE TABLE stg\_transactions;

     INSERT INTO stg\_transactions SELECT ...;

     

     → Mỗi lần chạy: xóa hết và load lại

     → Idempotent nhưng chậm với data lớn

  2\. MERGE (upsert):

     MERGE INTO core\_transactions t

     USING stg\_transactions s ON (t.id \= s.id)

     WHEN MATCHED THEN UPDATE SET ...

     WHEN NOT MATCHED THEN INSERT ...;

     

     → Chạy lại: UPDATE thay vì tạo duplicate

     → Bạn đã dùng cho SCD-like tracking trong AML

  3\. BATCH\_ID \+ DELETE trước INSERT:

     \-- Xóa data của batch hiện tại (nếu có từ rerun)

     DELETE FROM core\_transactions 

     WHERE batch\_id \= :current\_batch\_id;

     

     \-- Insert mới

     INSERT INTO core\_transactions ...;

     

     → Idempotent vì DELETE trước đảm bảo

       không có duplicate với cùng batch\_id

  4\. UNIQUE CONSTRAINT:

     → Database enforce không cho duplicate

     → ON CONFLICT DO UPDATE (PostgreSQL)

     → INSERT IGNORE / ON DUPLICATE KEY (MySQL)

  5\. CHECK TRƯỚC KHI INSERT:

     SELECT COUNT(\*) INTO v\_exists

     FROM etl\_job\_log

     WHERE batch\_date \= :run\_date

     AND status \= 'SUCCESS';

     

     IF v\_exists \> 0 THEN

         RAISE 'Batch already completed for this date';

     END IF;

Bạn đã implement:

  → batch\_id trong stored procedure AML

  → Đây là foundation của idempotency

  → Mỗi batch có ID duy nhất → trace và rerun được

---

**Q9.**

*"Data Lineage là gì? Tại sao nó quan trọng với DE trong môi trường banking?"*

💡 **Gợi ý trả lời:**

Data Lineage là khả năng trace dữ liệu:

  → Từ đâu đến? (source)

  → Đi qua những bước nào? (transformation)

  → Ai có thể access? (governance)

  → Data hiện tại được tính từ đâu?

Ví dụ cụ thể:

  Báo cáo AML hiển thị: "Khách hàng X có

  tổng giao dịch đáng ngờ 500 triệu VNĐ"


  Lineage trace ngược:

  OFSAA Report → core\_suspicious\_amount

              ← MERGE từ stg\_transactions

              ← EXTRACT từ IPCAS\_TXN\_HDR

                 \+ IPCAS\_TXN\_DTL

                 \+ SWIFT\_MT103

  \+ Exchange rate từ dim\_exchange\_rate

  \+ Risk rules từ aml\_rule\_config table

Tại sao quan trọng trong banking:

  1\. AUDIT REQUIREMENT:

     NHNN/CAAV audit: "Con số này đến từ đâu?"

     → Không có lineage: không trả lời được

     → Có lineage: trace từng bước trong 30 giây

  2\. IMPACT ANALYSIS:

     Source schema thay đổi:

     "Nếu tôi sửa IPCAS\_TXN\_HDR.amount,

      bảng nào trong DWH bị ảnh hưởng?"

     → Lineage map cho biết ngay

  3\. DEBUG DATA QUALITY:

     "Tại sao tổng amount trong báo cáo

      thấp hơn 10% so với tuần trước?"

     → Trace lineage: tìm transform step bị lỗi

  4\. GDPR/DATA PRIVACY:

     "Dữ liệu khách hàng A đang ở đâu trong hệ thống?"

     → Lineage biết data đã đi qua staging nào,

       ai có thể access

Tools phổ biến:

  → Apache Atlas (open source)

  → DataHub (LinkedIn, open source)

  → Collibra (enterprise)

  → dbt tự động generate lineage từ model

Trong dự án của bạn:

  → Bạn chưa có formal lineage tool

  → Nhưng ETL audit log \+ mapping document

    là manual lineage

  → Đây là điểm có thể cải thiện

---

**Q10.**

*"Schema evolution là gì? Làm thế nào để handle schema evolution trong pipeline ETL mà không break downstream?"*

💡 **Gợi ý trả lời:**

Schema evolution: source/target schema thay đổi

theo thời gian — thêm cột, xóa cột, đổi kiểu.

BACKWARD COMPATIBLE changes (an toàn):

  → Thêm cột mới với DEFAULT NULL

  → Rename cột (thêm alias, giữ cột cũ)

  → Tăng độ dài VARCHAR


  → Pipeline cũ vẫn chạy được

  → Không cần update ngay

BREAKING changes (nguy hiểm):

  → Xóa cột đang dùng trong ETL

  → Đổi kiểu NUMBER → VARCHAR

  → Rename cột không có backward compat

  → Thay đổi semantic: amount đổi từ VNĐ sang USD


  → Pipeline sẽ fail hoặc worse: chạy nhưng cho kết quả sai

Cách handle:

  1\. SCHEMA REGISTRY (với Kafka/Avro):

     → Central place lưu schema version

     → Producer/Consumer negotiate version

     → Không break nếu thay đổi backward compat

     

     // Avro schema example

     {

       "type": "record",

       "name": "Transaction",

       "fields": \[

         {"name": "id", "type": "string"},

         {"name": "amount", "type": "double"},

         {"name": "currency", "type": "string",

          "default": "VND"}  // default → backward compat

       \]

     }

  2\. SCHEMA SNAPSHOT \+ DETECTION (bạn có thể implement):

     → Chụp schema mỗi ngày

     → Alert khi phát hiện thay đổi

     → Stop pipeline trước khi xử lý data bị lỗi

  3\. DEFENSIVE CODING trong ETL:

     \-- Thay vì SELECT \*:

     SELECT transaction\_id,

            account\_id,

            amount,

            currency

     FROM source\_table;

     \-- SELECT \* bắt hết thay đổi, khó trace

     \-- SELECT explicit: dễ biết cột nào đang dùng

  4\. VERSIONING LAYER trong Staging:

     \-- Thêm schema\_version column

     INSERT INTO stg\_transactions (

         ..., schema\_version

     ) VALUES (

         ..., 'v2.1'

     );

     \-- Transform logic có thể handle nhiều version

  5\. COMMUNICATION PROCESS:

     → Yêu cầu source team báo trước 2 tuần

       trước khi thay đổi schema

     → Change freeze trước Go-live

     → Đây là process bạn cần đề xuất trong team

---

**🔵 NHÓM D — System Design**

---

**Q11.**

*"Nếu được thiết kế từ đầu một data platform cho ngân hàng quy mô vừa, bạn sẽ chọn kiến trúc nào? Tại sao?"*

💡 **Gợi ý trả lời — câu hỏi open-ended, không có đáp án duy nhất đúng:**

Tiêu chí đánh giá trước khi chọn:

  → Quy mô: bao nhiêu TB/năm? Bao nhiêu nguồn?

  → Team: bao nhiêu DE? Skill set gì?

  → Budget: on-premise hay cloud?

  → Latency requirement: batch T+1 hay near real-time?

  → Compliance: data phải ở Việt Nam không?

    (Theo quy định NHNN: data tài chính phải onshore)

Với ngân hàng quy mô vừa ở Việt Nam:

  INGESTION LAYER:

  → Oracle/PostgreSQL: dùng DB link \+ ODI (bạn đã biết)

    hoặc Debezium CDC nếu cần near real-time

  → File-based: SFTP → Python script → Staging

  STORAGE LAYER:

  → Staging: Oracle/PostgreSQL (on-premise)

    Lý do: compliance, team đã biết, enterprise support

  → DWH: Oracle (nếu budget) hoặc PostgreSQL (cost-effective)

  → Archive: object storage hoặc cheap disk

  TRANSFORMATION LAYER:

  → PL/SQL Stored Procedures: cho logic phức tạp,

    team đã quen

  → dbt on top: version control, testing, documentation

  → Airflow: orchestration thay thế ODI Scheduler

  SERVING LAYER:

  → Power BI / Tableau connect trực tiếp DWH

  → API layer cho real-time query

  MONITORING:

  → Prometheus \+ Grafana (bạn đã có kinh nghiệm)

  → Custom ETL monitoring dashboard

  ARCHITECTURE:

  Source Systems

      │

      ▼ (DB Link / CDC)

  \[Staging Layer — Oracle/PG\]

      │

      ▼ (dbt / Stored Procedures)

  \[Core DWH — Oracle/PG\]

      │

      ├──► \[Reporting Layer — BI Tool\]

      │

      └──► \[AML System — OFSAA/custom\]

      

  Orchestration: Airflow

  Monitoring: Prometheus \+ Grafana

  CI/CD: Git \+ dbt test

Tại sao không đề xuất cloud ngay:

  → NHNN regulation: data tài chính onshore

  → Cost predictability: on-premise dễ budget hơn

  → Nhưng có thể hybrid sau:

    Archive trên cloud, processing on-premise

---

**Q12.**

*"Tại sao cần tách biệt storage và compute trong modern data platform? Lambda Architecture và Kappa Architecture là gì?"*

💡 **Gợi ý trả lời:**

TÁCH STORAGE VÀ COMPUTE:

  Traditional (bạn đang có):

  → Oracle DB: storage và compute cùng 1 server

  → Scale up: mua server to hơn (expensive)

  → Idle: đêm không có batch → CPU waste

  Modern (cloud native):

  → Storage: S3/GCS (rẻ, unlimited)

  → Compute: Spark cluster (bật khi cần, tắt khi xong)

  → Scale independently: cần nhiều compute → 

    spin up 100 nodes, xong → shut down, trả tiền

    theo giờ

  → Ví dụ: Snowflake, BigQuery, Databricks

Lợi ích:

  → Cost: không trả tiền compute khi không dùng

  → Flexibility: nhiều team dùng cùng storage,

    mỗi team có compute riêng

  → Scale: handle spike mà không mua thêm server

LAMBDA ARCHITECTURE:

  → Có 2 layer xử lý song song:

    Batch layer: xử lý historical data đầy đủ, chậm

    Speed layer: xử lý real-time data mới nhất, nhanh

    Serving layer: merge kết quả từ 2 layer trên

  → Vấn đề: phải maintain 2 codebase

    (batch và streaming) → phức tạp

KAPPA ARCHITECTURE:

  → Đơn giản hóa: chỉ 1 streaming layer

  → Treat everything as stream

  → Batch \= streaming với bounded data

  → Ví dụ: Kafka \+ Flink/Spark Streaming

  → Ưu điểm: 1 codebase duy nhất

  → Nhược điểm: streaming phức tạp hơn batch,

    reprocessing historical data khó hơn

Với banking Việt Nam hiện tại:

  → Hầu hết vẫn dùng Lambda-like:

    Batch ETL (overnight) \+ một số near real-time

  → Kappa: chưa phổ biến, cần mature streaming infra

  → Đây là lý do bạn nên học Kafka/Airflow

    để bridge từ batch sang hybrid approach

---

**🔵 NHÓM E — Câu hỏi tư duy & problem-solving**

---

**Q13.**

*"Bạn được giao thiết kế pipeline ETL mới cho một source system hoàn toàn chưa có documentation. Bạn bắt đầu từ đâu?"*

💡 **Gợi ý trả lời:**

BƯỚC 1 — UNDERSTAND THE BUSINESS FIRST:

  → Hệ thống này làm gì trong business?

  → Data nào là quan trọng nhất?

  → Ai đang dùng data này và dùng như thế nào?

  → Downstream cần gì: báo cáo, ML, compliance?


  Lý do: hiểu business → biết data nào cần,

  không cần lấy hết mọi thứ

BƯỚC 2 — EXPLORE DATABASE SCHEMA:

  \-- Oracle: xem tất cả bảng

  SELECT table\_name, num\_rows

  FROM all\_tables

  WHERE owner \= 'SOURCE\_SCHEMA'

  ORDER BY num\_rows DESC;


  \-- Tìm bảng lớn nhất (thường là transactional)

  \-- Xem foreign key relationships

  SELECT a.table\_name, a.column\_name,

         c.r\_owner, c\_pk.table\_name r\_table

  FROM all\_cons\_columns a

  JOIN all\_constraints c ON a.owner \= c.owner

  JOIN all\_cons\_columns c\_pk ON ...

  WHERE c.constraint\_type \= 'R';

BƯỚC 3 — DATA PROFILING:

  \-- Mỗi bảng quan trọng:

  SELECT COUNT(\*) total\_rows,

         COUNT(DISTINCT key\_col) distinct\_keys,

         MIN(created\_date), MAX(created\_date),

         COUNT(\*) \- COUNT(amount) null\_amount\_count

  FROM source\_table;


  → Hiểu: volume, date range, null percentage,

    cardinality của các key columns

BƯỚC 4 — TRACE DATA FLOW:

  → Interview người dùng hệ thống:

    "Khi tôi tạo một giao dịch, nó đi vào bảng nào?"

  → Follow foreign keys để hiểu relationships

  → Tìm bảng nào update khi business event xảy ra

BƯỚC 5 — BUILD INCREMENTALLY:

  → Extract 1 ngày data trước, verify

  → Viết transform đơn giản nhất trước

  → Extend dần dần khi hiểu hơn

  → Đừng cố build full pipeline ngay lần đầu

BƯỚC 6 — DOCUMENT WHILE EXPLORING:

  → Ghi lại mọi thứ bạn phát hiện

  → Tạo data dictionary cho team

  → Đây là documentation chưa có — bạn tạo ra

---

**Q14.**

*"Nếu bạn phát hiện pipeline ETL đang hoạt động nhưng có thể được cải thiện đáng kể về performance và maintainability, bạn tiếp cận việc refactor như thế nào?"*

💡 **Gợi ý trả lời:**

NGUYÊN TẮC: "If it ain't broke, don't fix it" —

nhưng technical debt sẽ giết bạn từ từ.

BƯỚC 1 — MEASURE TRƯỚC KHI OPTIMIZE:

  → Baseline hiện tại:

    \- Mỗi job mất bao lâu?

    \- Resource usage như thế nào?

    \- Bao nhiêu lần fail/tháng?

    \- Code complexity: số SP, độ dài, comment?

  → Không optimize thứ không phải bottleneck

BƯỚC 2 — PRIORITIZE:

  → Quick wins có impact cao nhất:

    \- Job chậm nhất (đo được) → optimize SQL/index

    \- Job fail nhiều nhất → thêm error handling

    \- Code dài nhất, ít comment nhất → refactor

  → Không refactor tất cả cùng lúc

BƯỚC 3 — REFACTOR AN TOÀN:

  → Không sửa Production trực tiếp

  → Tạo branch/version mới

  → Test kỹ trên dev với data tương đương production

  → A/B test: chạy cả version cũ và mới, so sánh kết quả

  → Deploy từng phần, không big bang

BƯỚC 4 — DOCUMENT CHANGES:

  → Comment tại sao refactor: "Đổi INSERT → MERGE

    để idempotent, tránh duplicate khi rerun"

  → Không chỉ ghi "refactored for performance"

BƯỚC 5 — MONITOR SAU DEPLOY:

  → So sánh duration trước/sau

  → Check không có regression: kết quả vẫn đúng?

  → Rollback plan nếu có vấn đề

Trong thực tế của bạn:

  → Bạn đã làm điều này ở NHNN DWH:

    tối ưu SP, tuning partition/index

  → Key learning: đo trước, fix có mục tiêu,

    không optimize vì "có thể nhanh hơn"

---

**📊 Tổng kết — Câu hỏi ngoài CV**

| Nhóm | Câu | Mức độ ưu tiên |
| :---- | :---- | :---- |
| Modern Stack | Q1 Airflow | ⭐⭐⭐ Hay hỏi nhất |
| Modern Stack | Q2 dbt | ⭐⭐⭐ Fintech hỏi nhiều |
| Modern Stack | Q3 Lake/Warehouse/Lakehouse | ⭐⭐⭐ Conceptual |
| Modern Stack | Q4 Apache Spark | ⭐⭐ Biết cơ bản là đủ |
| Streaming | Q5 Apache Kafka | ⭐⭐⭐ Xu hướng mạnh |
| Streaming | Q6 CDC | ⭐⭐⭐ Banking relevant |
| Fundamentals | Q7 SCD cases | ⭐⭐⭐ Classic DE question |
| Fundamentals | Q8 Idempotency | ⭐⭐⭐ Hay hỏi senior |
| Fundamentals | Q9 Data Lineage | ⭐⭐ Enterprise focus |
| Fundamentals | Q10 Schema Evolution | ⭐⭐⭐ Practical |
| System Design | Q11 Platform design | ⭐⭐ Senior level |
| System Design | Q12 Lambda vs Kappa | ⭐⭐ Architecture |
| Problem Solving | Q13 Undocumented source | ⭐⭐⭐ Common scenario |
| Problem Solving | Q14 Refactor strategy | ⭐⭐ Senior mindset |

---

💡 **Lộ trình học nhanh nhất dựa trên background của bạn:**

Tuần 1-2: **Airflow** — bạn đã biết Python cơ bản, ODI concept tương tự. Cài Airflow local, viết 1 DAG chạy stored procedure của bạn.

Tuần 3-4: **dbt** — bạn SQL rất mạnh, dbt chỉ là SQL có structure. Cài dbt-core với PostgreSQL, viết 3-4 model từ data VAECO.

Tuần 5-6: **Kafka cơ bản** — hiểu concept, không cần thành thạo. Biết giải thích khi nào cần streaming.

Sau 6 tuần: CV của bạn sẽ mạnh hơn đáng kể cho cả công ty truyền thống lẫn fintech.

[image1]: <data:image/png;base64,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>

[image2]: <data:image/png;base64,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>