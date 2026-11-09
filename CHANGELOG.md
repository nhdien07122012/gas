# 📜 Lịch Sử Phiên Bản & Nhật Ký Thay Đổi (Changelog & Decision Log)

Tài liệu này là **Single Source of Truth (Nguồn chân lý duy nhất)** ghi lại chi tiết toàn bộ lịch sử phát triển, cập nhật tính năng, mã commit, lưu ý kỹ thuật và hướng dẫn khôi phục (revert/rollback) cho dự án **Gas Manager (Web & iOS Native App)**.

> [!IMPORTANT]
> **QUY TẮC BẮT BUỘC DÀNH CHO CÁC AGENT / DEVELOPER SAU NÀY:**
> 1. Mỗi khi thực hiện bất kỳ thay đổi nào (dù lớn hay nhỏ) liên quan đến Web (`index.html`), Capacitor, hoặc mã nguồn Native iOS, **BẮT BUỘC** phải thêm một mục phiên bản mới lên đầu file này trước khi commit.
> 2. Luôn đồng bộ đồng thời giữa file gốc `index.html` và `www/index.html`, sau đó chạy `npx cap sync ios`.
> 3. Tăng build version (`CURRENT_PROJECT_VERSION`) tại cả hai file `resources/ios/project.pbxproj` và `ios/App/App.xcodeproj/project.pbxproj`.
> 4. Ghi rõ commit hash và lệnh `git revert` để người dùng hoặc agent khác có thể hoàn tác ngay lập tức khi phát sinh sự cố.
> 5. **Quy tắc Version Tag giao diện Web (`index.html`)**: Khi có cập nhật/thay đổi đủ lớn (tính năng mới quan trọng, thay đổi lớn về logic hoặc giao diện), **PHẢI** cập nhật thẻ `<span class="version-tag">` ở tiêu đề `index.html` và `www/index.html` tăng thêm 1 chấm nhỏ (ví dụ: `v5.0` ➔ `v5.1` ➔ `v5.2`...).

---

## 📑 Danh mục phiên bản

- [Build 13 (v1.5 / UI v5.1) - Thêm quy tắc Version Tag & Nâng phiên bản giao diện v5.1](#build-13-v15--ui-v51---2026-11-09)
- [Build 12 (v1.5) - Sửa lỗi giao diện iPhone: Status bar header & Tràn tọa độ GPS](#build-12-v15---2026-11-09)
- [Build 11 (v1.5) - Đồng bộ & tăng kích thước font chữ toàn ứng dụng](#build-11-v15---2026-11-09)
- [Build 10 (v1.5) - Cập nhật số tiền giao trong Báo cáo là Tổng doanh thu ca](#build-10-v15---2026-11-08)
- [Build 9 (v1.5) - Hoàn trả nút Xuất data & Định dạng dấu chấm phần ngàn](#build-9-v15---2026-11-08)
- [Build 8 (v1.5) - Chuẩn hóa mã ca, giải quyết triệt để lỗi trùng ca & Báo cáo](#build-8-v15---2026-11-07)
- [Build 7 (v1.5) - Quản lý chi tiêu trong ca & Tự động khấu trừ vào Báo cáo](#build-7-v15---2026-11-07)
- [Build 6 (v1.5) - Khắc phục GPS trên iPhone bằng CoreLocation Native Bridge](#build-6-v15---2026-11-07)
- [Build 5 (v1.4) - Phóng to Doanh thu Widget 2x2 & Ẩn số giao dịch](#build-5-v14---2026-11-06)
- [Build 4 (v1.3) - Tối ưu bố cục chống tràn chữ Widget 2x2 & 4x2](#build-4-v13---2026-11-06)
- [Build 3 (v1.2) - Thiết kế lại Widget doanh thu vòng tròn tiến độ](#build-3-v12---2026-11-06)

---

## [Build 13 (v1.5 / UI v5.1)] - 2026-11-09
- **Commit SHA**: `537dbbf`
- **Mục tiêu**: Bổ sung quy tắc quản lý phiên bản hiển thị (`version-tag`) vào tài liệu hướng dẫn Agent và nâng phiên bản giao diện chính `index.html` từ `v5.0` lên `v5.1` đánh dấu chuỗi cải tiến lớn (Quản lý chi tiêu ca, Chuẩn hóa báo cáo doanh thu, Đồng bộ font size toàn ứng dụng và Tối ưu Safe Area iPhone).

### 🔄 Chi tiết thay đổi
- **Bổ sung Quy Tắc Version Tag vào `AGENT_INSTRUCTIONS.md` & `CHANGELOG.md`**:
  - Quy định bắt buộc: Mỗi khi dự án có cập nhật/thay đổi đủ lớn, Agent phải nâng số phiên bản tại thẻ `<span class="version-tag">` trên trang chính `index.html` (và `www/index.html`) tăng thêm 1 chấm nhỏ (`v5.0` ➔ `v5.1` ➔ `v5.2`...).
  - Bổ sung bước kiểm tra vào Checklist hoàn tất task của Agent.
- **Nâng phiên bản giao diện chính**:
  - `index.html`: `<span class="version-tag">v5.0</span>` ➔ `<span class="version-tag">v5.1</span>`.
  - `www/index.html`: `<span class="version-tag">v5.0</span>` ➔ `<span class="version-tag">v5.1</span>`.
- **Files tác động**:
  - `AGENT_INSTRUCTIONS.md`
  - `CHANGELOG.md`
  - `index.html` & `www/index.html`
  - `resources/ios/project.pbxproj` (Build 13)
  - `ios/App/App.xcodeproj/project.pbxproj` (Build 13)
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 12 (v1.5)] - 2026-11-09
- **Commit SHA**: `06cbb10`
- **Mục tiêu**: Sửa lỗi hiển thị giao diện trên iPhone cho trang `tinhgascon.html` (header đè status bar/Dynamic Island) và `vitri.html` (tràn tọa độ GPS ra ngoài thẻ & placeholder bị cắt), đồng thời tối ưu safe area cho `dudoandiemgas.html`.

### 🔄 Chi tiết thay đổi
- **`tinhgascon.html` & `dudoandiemgas.html`**:
  - Thêm `padding-top: env(safe-area-inset-top, 0px);` vào `.app-header` (sticky top: 0). Nền kính mờ (glassmorphism) phủ kín khu vực status bar, đẩy thanh điều hướng, nút menu `[=]`, tiêu đề trang và nút công cụ xuống dưới Dynamic Island / tai thỏ, không còn bị giờ hệ thống và icon pin/wifi đè lên.
  - Thêm safe-area-inset-top vào `.sidebar-header` (`padding: calc(1.25rem + env(safe-area-inset-top, 0px)) 1.25rem 1rem;`) giúp menu trượt không bị che khuất nút đóng và tiêu đề trên iPhone.
  - Thêm safe-area-inset-bottom vào `.container` (`padding-bottom: calc(2.5rem + env(safe-area-inset-bottom, 0px));`) tránh che lấp nút bấm bởi thanh gạt Home Indicator của iOS.
- **`vitri.html`**:
  - Bổ sung `flex-wrap: wrap; gap: 6px;` vào `.card-details` để badge tọa độ GPS tự động xuống dòng gọn gàng khi màn hình hẹp thay vì tràn viền.
  - Thêm `max-width: 100%; box-sizing: border-box; overflow: hidden; text-overflow: ellipsis;` và `font-size: 11.5px;` vào `.badge-gps` cùng `overflow: hidden;` cho `.location-card`, đảm bảo tọa độ GPS hiển thị đầy đủ, không bao giờ bị cắt số hay tràn ra ngoài thẻ.
  - Rút gọn placeholder ô tìm kiếm thành `Tìm tên điểm, địa chỉ, ghi chú...` hiển thị trọn vẹn, không bị cụt trên màn hình điện thoại.
- **Files tác động**:
  - `tinhgascon.html` & `www/tinhgascon.html`
  - `dudoandiemgas.html` & `www/dudoandiemgas.html`
  - `vitri.html` & `www/vitri.html`
  - `resources/ios/project.pbxproj` (Build 12)
  - `ios/App/App.xcodeproj/project.pbxproj` (Build 12)
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 11 (v1.5)] - 2026-11-09
- **Commit SHA**: `54834c2`
- **Mục tiêu**: Đồng bộ và tăng kích thước font chữ cho 9 màn hình chức năng (4 modal trong index.html và 5 trang độc lập) theo chuẩn trực quan của trang chính.

### 🔄 Chi tiết thay đổi
- **Hệ thống Typography chuẩn hóa**:
  - Ô nhập liệu (Input/Select): Đồng bộ `font-size: 16px !important;` với chiều cao 44px - 46px chống tự động phóng to trên iOS Safari.
  - Tên điểm gas / Tiêu đề thẻ: Nâng lên `15.5px - 16px` (Font-weight: 700).
  - Số tiền / Doanh thu / Lương: Nâng lên `16px` (Font-weight: 700).
  - Nhãn trường (Label) & Nút bấm (Button): Nâng lên `14.5px - 15px`, chiều cao nút tối thiểu 44px.
  - Địa chỉ / Ghi chú / Thời gian: Nâng từ mức quá nhỏ (`10.5px - 12px`) lên `13.5px`.
- **4 Modal trong `index.html`**:
  - `#out-of-hours-modal`: Tăng font mô tả (15px), nhãn và nút bấm footer (15px, cao 44px).
  - `#queue-modal`: Tên điểm (15.5px), tiền (16px), địa chỉ (13.5px), status bar (14.5px).
  - `#batch-status-modal`: Tóm tắt (15.5px), mô tả (14.5px), nút bấm (15px).
  - `#quick-view-modal`: Tên điểm (15.5px), địa chỉ (13.5px), tiền (16px), tổng kết (16.5px).
- **5 Trang chức năng riêng biệt**:
  - `vitri.html`: Nâng card-title lên 16px, địa chỉ lên 13.5px, subtitle 13.5px.
  - `tinhluong.html`: Nâng label lên 14.5px, input 16px (cao 44px), nút bấm 15px (cao 44px), bảng ca 14px (th/td).
  - `tinhgascon.html`: Nâng label lên 14.5px, input 16px, kết quả lên 1.25rem (20px).
  - `dudoandiemgas.html`: Nâng bảng lên 14px - 14.5px, ô tìm kiếm 16px (cao 44px), nút tạo báo cáo 14.5px.
  - `clipboard.html`: Nâng text nội dung lên 15px, badge & time lên 13.5px, ô tìm kiếm & lọc 16px.
- **Files tác động**:
  - `index.html`, `vitri.html`, `tinhluong.html`, `tinhgascon.html`, `dudoandiemgas.html`, `clipboard.html`.
  - Toàn bộ thư mục `www/` và tài nguyên iOS Native (`project.pbxproj` Build 11).

### ⚠️ Lưu ý kỹ thuật cho Agent sau
- Toàn bộ ô nhập liệu `input, select` trên web di động nên duy trì tối thiểu `16px` để tránh tính năng tự động phóng to (auto-zoom) khó chịu của trình duyệt Safari trên iPhone.
- Các nút bấm thao tác trên di động nên duy trì `min-height: 44px` để đạt chuẩn ngón tay người dùng (Apple Human Interface Guidelines).

### ⏪ Hướng dẫn Revert (Nếu có lỗi)
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 10 (v1.5)] - 2026-11-08
- **Commit SHA**: `d8c4feb`
- **Mục tiêu**: Điều chỉnh số tiền trong cú pháp Báo cáo cuối ca thành **Tổng doanh thu ca** theo thói quen bàn giao tiền mặt thực tế.

### 🔄 Chi tiết thay đổi
- **Logic Báo cáo**:
  - Cú pháp cũ (Build 9): `Giao [Người nhận] [Tiền thực nộp] (Trừ [khoản chi])`
  - Cú pháp mới (Build 10): `Giao [Người nhận] [Tổng doanh thu ca] (Trừ [khoản chi])`
  - *Ví dụ*: `Giao Phương 6.605.000 (Trừ xăng 65.000)` (thay vì `6.540.000`).
  - Khi ca không có chi tiêu: `Giao Phương 6.605.000`.
- **Files tác động**:
  - `index.html`: Cập nhật `generateReport()` dòng gán `reportContent`.
  - `www/index.html`: Đồng bộ web assets.
  - `resources/ios/project.pbxproj` & `ios/App/App.xcodeproj/project.pbxproj`: Tăng `CURRENT_PROJECT_VERSION = 10`.

### ⚠️ Lưu ý kỹ thuật cho Agent sau
- Số tiền nộp thực tế sau khi trừ chi tiêu (`netDueAmount = totalRevenue - totalExpense`) vẫn được tính toán và hiển thị đầy đủ trong bảng đối soát của modal để người dùng kiểm tra tiền đếm thực tế có khớp hay không.
- Chỉ có nội dung văn bản sao chép ra clipboard để gửi tin nhắn là hiển thị Tổng doanh thu ca ở đầu câu để bên nhận dễ đối soát.

### ⏪ Hướng dẫn Revert (Nếu có lỗi)
```bash
git revert d8c4feb --no-edit
git push origin main
```

---

## [Build 9 (v1.5)] - 2026-11-08
- **Commit SHA**: `b333576`
- **Mục tiêu**: Hoàn trả nút "Xuất data" về vị trí Thao tác nhanh (Quick Actions), định dạng dấu chấm phần ngàn cho dữ liệu xuất và rút gọn cú pháp báo cáo.

### 🔄 Chi tiết thay đổi
- **Quick Actions Grid**:
  - Đổi nút `.btn-chitieu` ở màn hình chính trở lại thành `.btn-primary` gọi `exportToText()` ("Xuất data").
  - Tính năng "Chi tiêu ca" vẫn hoạt động đầy đủ qua Sidebar menu và bên trong modal Báo cáo cuối ca.
- **Biểu mẫu Xuất data (`exportToText`)**:
  - Định dạng doanh thu từng điểm gas bằng `formatNumber(item.so_tien)` (`470000` -> `470.000`).
  - Áp dụng đồng thời cho file `.txt` tải về và clipboard.
- **Files tác động**:
  - `index.html`, `www/index.html`, `project.pbxproj` (Build 9).

### ⏪ Hướng dẫn Revert
```bash
git revert b333576 --no-edit
git push origin main
```

---

## [Build 8 (v1.5)] - 2026-11-07
- **Commit SHA**: `99ac837`
- **Mục tiêu**: Sửa lỗi logic xuất hiện 2 ca trùng tên trong menu chọn ca khiến không thể lấy dữ liệu doanh thu báo cáo; loại bỏ chữ "chi tiêu" trong báo cáo.

### 🔄 Chi tiết thay đổi
- **Nguyên nhân gốc**:
  - Trong Google Sheets, `item.ca` lưu chuỗi ngày hiển thị `Ca 07-11-2026`.
  - Trong khi đó `currentShift` từ `getCurrentShift()` lại trả về mã ISO `2026-11-07`.
  - Khi thêm cả hai vào `new Set()`, dropdown có 2 lựa chọn cùng nhãn `Ca 07-11-2026` nhưng khác `value`. Khi chọn dòng có value `2026-11-07`, hàm `item.ca === selectedShift` trả về rỗng.
- **Giải pháp triển khai**:
  - Tạo hàm `getNormalizedShiftKey(shift)` để quy chuẩn tất cả về mã ngày chuẩn `YYYY-MM-DD`.
  - Tạo hàm `getAvailableShiftMap()` tổng hợp ca từ dữ liệu bảng tính, ca hiện tại, danh sách chi tiêu và kết quả đếm tiền; gộp trùng lặp 100%.
  - Bộ lọc đối soát 2 chiều: `getNormalizedShiftKey(item.ca) === getNormalizedShiftKey(selectedShift) || item.ca === selectedShift`.
  - Bỏ chữ "chi tiêu" trong báo cáo, chỉ giữ `- Trừ <khoản chi>`.
- **Files tác động**:
  - `index.html`, `www/index.html`, `project.pbxproj` (Build 8).

### ⚠️ Lưu ý kỹ thuật cho Agent sau
- **TUYỆT ĐỐI KHÔNG** lọc dữ liệu ca bằng `item.ca === selectedShift` đơn thuần. Luôn dùng `getNormalizedShiftKey()` để đảm bảo tương thích 100% giữa dữ liệu cũ và mới.

### ⏪ Hướng dẫn Revert
```bash
git revert 99ac837 --no-edit
git push origin main
```

---

## [Build 7 (v1.5)] - 2026-11-07
- **Commit SHA**: `cab0932`
- **Mục tiêu**: Bổ sung tính năng "Quản lý chi tiêu trong ca" trên Sidebar/Quick Actions và tự động khấu trừ vào Báo cáo cuối ca.

### 🔄 Chi tiết thay đổi
- **Lưu trữ độc lập**: Dùng key `gas_shift_expenses` trong `localStorage` (không can thiệp Google Sheets API).
- **Giao diện**:
  - Thêm mục "Quản lý chi tiêu ca" vào Sidebar kèm badge tổng chi.
  - Thêm modal `#expense-modal`: chọn ca, thẻ tổng chi, form nhập nhanh (tự điền `000` khi nhập số tắt), danh sách xóa từng khoản chi.
- **Khấu trừ Báo cáo cuối ca**:
  - Tự động nạp danh sách chi tiêu đã lưu của ca.
  - Công thức: `netDueAmount = totalRevenue - totalExpense`.
  - Bảng đối soát tiền mặt: so sánh tiền đếm thực tế với số tiền thực nộp.
- **Files tác động**:
  - `index.html`, `www/index.html`, `project.pbxproj` (Build 7).

### ⏪ Hướng dẫn Revert
```bash
git revert cab0932 --no-edit
git push origin main
```

---

## [Build 6 (v1.5)] - 2026-11-07
- **Commit SHA**: `d6d7679`, `a34b54e`, `61e0001`
- **Mục tiêu**: Sửa lỗi iPhone không lấy được tọa độ GPS khi bấm lưu điểm gas; bổ sung native CoreLocation bridge.

### 🔄 Chi tiết thay đổi
- **Nguyên nhân**: `navigator.geolocation` trong WKWebView trên iOS bị sandbox chặn hoặc treo khi không có quyền rõ ràng trong `Info.plist`.
- **Giải pháp**:
  - Tạo `NativeLocationManager.swift` sử dụng `CLLocationManager` trực tiếp từ Swift.
  - Thêm quyền `NSLocationWhenInUseUsageDescription` và `NSLocationAlwaysAndWhenInUseUsageDescription` vào `Info.plist`.
  - Bridge qua `window.webkit.messageHandlers.nativeLocation.postMessage()`.
  - Cung cấp fallback 3 tầng trong `saveLocation()`: Native Bridge -> Geolocation Web API -> Manual/Default.
  - Ổn định cấu hình WidgetBundle (`GasQuickActionsWidget` & `GasShiftWidget`).
- **Files tác động**:
  - `resources/ios/Info.plist`, `resources/ios/SceneDelegate.swift`, `resources/ios/GasWidget/GasWidget.swift`, `index.html`.

### ⏪ Hướng dẫn Revert
```bash
git revert 61e0001 a34b54e d6d7679 --no-edit
git push origin main
```

---

## [Build 5 (v1.4)] - 2026-11-06
- **Commit SHA**: `be12b70`
- **Mục tiêu**: Widget 2x2 (Small): Phóng to số tiền doanh thu lên cỡ 36pt bold cho vừa trọn khung, bỏ hiển thị số điểm và bỏ dòng chữ "Doanh thu ca".

### 🔄 Chi tiết thay đổi
- Sửa view `SmallShiftWidgetView` trong `GasWidget.swift`.

### ⏪ Hướng dẫn Revert
```bash
git revert be12b70 --no-edit
git push origin main
```

---

## 🛠️ Hướng dẫn Khôi phục Phiên bản (Rollback Cheatsheet)

Khi cần đưa ứng dụng về một bản build cũ cụ thể trong trường hợp khẩn cấp:

1. **Xem lại lịch sử commit**:
   ```bash
   git log --oneline -n 10
   ```

2. **Revert một commit cụ thể (Khuyên dùng - an toàn cho remote branch)**:
   ```bash
   git revert <COMMIT_SHA> --no-edit
   git push origin main
   ```

3. **Reset cứng về một commit cũ (Thận trọng - xóa lịch sử sau commit đó)**:
   ```bash
   git reset --hard <COMMIT_SHA>
   git push origin main --force
   ```

4. **Kiểm tra trạng thái GitHub Actions**:
   Sau khi push, GitHub Actions sẽ tự động biên dịch lại file `.ipa` tương ứng với mã nguồn vừa hoàn tác.
