# 📜 Lịch Sử Phiên Bản & Nhật Ký Thay Đổi (Changelog & Decision Log)

Tài liệu này là **Single Source of Truth (Nguồn chân lý duy nhất)** ghi lại chi tiết toàn bộ lịch sử phát triển, cập nhật tính năng, mã commit, lưu ý kỹ thuật và hướng dẫn khôi phục (revert/rollback) cho dự án **Gas Manager (Web & iOS Native App)**.

> [!IMPORTANT]
> **QUY TẮC BẮT BUỘC DÀNH CHO CÁC AGENT / DEVELOPER SAU NÀY:**
> 1. Mỗi khi thực hiện bất kỳ thay đổi nào (dù lớn hay nhỏ) liên quan đến Web (`index.html`), Capacitor, hoặc mã nguồn Native iOS, **BẮT BUỘC** phải thêm một mục phiên bản mới lên đầu file này trước khi commit.
> 2. Luôn đồng bộ đồng thời giữa file gốc `index.html` và `www/index.html`, sau đó chạy `npx cap sync ios`.
> 3. Tăng build version (`CURRENT_PROJECT_VERSION`) tại cả hai file `resources/ios/project.pbxproj` và `ios/App/App.xcodeproj/project.pbxproj`.
> 4. Ghi rõ commit hash và lệnh `git revert` để người dùng hoặc agent khác có thể hoàn tác ngay lập tức khi phát sinh sự cố.
> 5. **Quy tắc Version Tag giao diện Web (`index.html`)**: Khi có cập nhật/thay đổi đủ lớn (tính năng mới quan trọng, thay đổi lớn về logic hoặc giao diện), **PHẢI** cập nhật thẻ `<span class="version-tag">` ở tiêu đề `index.html` và `www/index.html` tăng thêm 1 chấm nhỏ (ví dụ: `v5.0` ➔ `v5.1` ➔ `v5.2`...).
> 6. **Quy tắc Giữ nguyên Phạm vi Chức năng & Xác nhận khi có ảnh hưởng liên đới (Scope Preservation & Impact Confirmation Rule)**: Mỗi khi người dùng yêu cầu thay đổi hoặc sửa lỗi một tính năng/giao diện cụ thể, TẤT CẢ các chức năng khác không được đề cập trong yêu cầu **BẮT BUỘC PHẢI GIỮ NGUYÊN 100%**, tuyệt đối không tự ý thay đổi, tái cấu trúc (refactor) hay xóa bỏ. Nếu việc sửa chữa bắt buộc phải can thiệp hoặc có nguy cơ ảnh hưởng tới bất kỳ chức năng liên quan nào khác, **BẮT BUỘC PHẢI DỪNG LẠI, HỎI Ý KIẾN VÀ ĐƯỢC NGƯỜI DÙNG XÁC NHẬN (CONFIRM)** trước khi tiến hành viết code hay chỉnh sửa.

---

## 📑 Danh mục phiên bản

- [Build 21 (v1.5 / UI v5.5) - Khắc phục hiển thị tổng chi tiêu ca trên Widget iOS](#build-21-v15--ui-v55---2026-11-12)
- [Build 20 (v1.5 / UI v5.5) - Sửa lỗi chèn Statusbar iPhone & Khắc phục tải dữ liệu dự đoán](#build-20-v15--ui-v55---2026-11-10)
- [Build 19 (v1.5 / UI v5.5) - Sửa lỗi giao diện trang Dự đoán điểm gas trên Dark Mode & Tràn nút Sao chép](#build-19-v15--ui-v55---2026-11-10)
- [Build 18 (v1.5 / UI v5.5) - Đồng bộ thanh Menubar & Sidebar Drawer trên 7 trang](#build-18-v15--ui-v55---2026-11-10)
- [Build 17 (v1.5 / UI v5.4) - Vị trí thông báo dưới Notch iPhone & Hiệu ứng Pull-to-Refresh từ tai thỏ](#build-17-v15--ui-v54---2026-11-10)
- [Build 16 (v1.5 / UI v5.3) - Sửa lỗi chuỗi ngày ca & Khắc phục hiển thị số tiền chi tiêu Widget](#build-16-v15--ui-v53---2026-11-10)
- [Build 15 (v1.5 / UI v5.3) - Nút tròn Chi tiêu ca trên Widget & Sửa lỗi lệch ngày ca](#build-15-v15--ui-v53---2026-11-10)
- [Build 14 (v1.5 / UI v5.2) - Chọn nhanh & Quản lý khoản chi đã lưu trong LocalStorage](#build-14-v15--ui-v52---2026-11-09)
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

## [Build 21 (v1.5 / UI v5.5)] - 2026-11-12
- **Commit SHA**: `e0af36c`
- **Mục tiêu**: Khắc phục triệt để lỗi vòng tròn chi tiêu trên Widget iOS (4x2) vẫn hiển thị `0 đ CHI TIÊU` mặc dù trong ca đã phát sinh các khoản chi tiêu; bảo toàn 100% tất cả các tính năng khác theo Quy tắc 1.

### 🔄 Chi tiết thay đổi
1. **Khắc phục lỗi đăng ký Native Bridge (`gasWidgetBridge`) trong `SceneDelegate.swift`**:
   - Trước đây `bridgeVC.webView?.configuration.userContentController.add(self, name: "gasWidgetBridge")` được gọi ngay sau khi khởi tạo `CAPBridgeViewController()` khi `webView` chưa được nạp (là `nil`), khiến WebKit không thể đăng ký handler và bridge bị bỏ qua trong im lặng.
   - Bổ sung `bridgeVC.loadViewIfNeeded()` và `_ = bridgeVC.view` để đảm bảo `webView` đã được khởi tạo trước khi thêm handler.
   - Tách hàm chuẩn hóa `setupBridgeHandlers(for:)` gỡ bỏ handler cũ nếu có và tái đăng ký trong cả `scene(_:willConnectTo:options:)` và `sceneDidBecomeActive(_:)`.
   - Bổ sung lưu trữ chi tiết: `widget_shiftKey`, `widget_expenseTotal_\(shiftKey)`, `widget_expenseFormatted_\(shiftKey)`, và dictionary `widget_expensesByShift` vào cả Shared App Group `group.com.vnpost.gasmanager` và Standard UserDefaults.

2. **Cải tiến `syncWidgetData()` trong `index.html`**:
   - Thu thập toàn bộ bản đồ chi tiêu `expensesByShift` theo từng mã ngày ca chuẩn hóa (`yyyy-MM-dd`).
   - Cung cấp cơ chế tự động fallback thông minh: nếu `activeShift` đang là `all` hoặc chưa chọn trên màn hình chính, hệ thống tự động đối chiếu ca hiện tại từ `getCurrentShift()` hoặc ca gần nhất có chi tiêu để lấy đúng tổng số tiền đã chi.
   - Đóng gói gửi cả `expensesByShift` sang native bridge.
   - Thêm cơ chế tự động gửi lại (retry 300ms và 1000ms) phòng trường hợp webview tải xong trước khi native bridge hoàn tất khởi tạo.
   - Kích hoạt đồng bộ `syncWidgetData()` ngay khi mở ứng dụng trong sự kiện `DOMContentLoaded`.

3. **Nâng cấp khớp dữ liệu chi tiêu trong `GasWidget.swift`**:
   - Khi chạy ở chế độ cache nhanh (`loadLocalCache()`): đọc và đối chiếu chính xác số tiền chi tiêu từ `widget_data.json`, `widget_expenseTotal_\(shiftKey)`, `widget_expensesByShift`, hoặc fallback ca mới nhất.
   - Khi chạy Live Timeline qua Google Apps Script (`fetchRemoteData()`): sau khi phân tích được ngày ca mới nhất (`latestKey`), đối chiếu trực tiếp khoản chi tương ứng của ca đó trong `expensesByShift` hoặc cache theo ca, bảo đảm không bao giờ bị ghi đè thành 0 khi lấy doanh thu live.
   - Tinh chỉnh `formatCompactCurrency`: hiển thị rõ ràng số tiền nhỏ dưới 1.000 đ dạng `xx đ` thay vì bị làm tròn về `0k`.

4. **Đồng bộ nền tảng**:
   - Đồng bộ `index.html` sang `www/index.html`.
   - Đồng bộ `SceneDelegate.swift` và `GasWidget.swift` sang `resources/ios/`.
   - Tăng `CURRENT_PROJECT_VERSION` lên **21** tại cả `resources/ios/project.pbxproj` và `ios/App/App.xcodeproj/project.pbxproj`.
   - Chạy `npx cap sync ios`.

### ⏪ Lệnh hoàn tác nhanh (Revert command)
```bash
git revert e0af36c --no-edit
npm run sync
```

---

## [Build 20 (v1.5 / UI v5.5)] - 2026-11-10
- **Commit SHA**: `1b9b621`
- **Mục tiêu**: Khắc phục triệt để lỗi Header chèn lên statusbar trên iPhone 13 Pro và sửa lỗi JavaScript crash (`ReferenceError: updateThemeUI is not defined`) khiến dữ liệu dự đoán không tải được trên trang `dudoandiemgas.html` (đồng thời bảo vệ trang `tinhgascon.html`).

### 🔄 Chi tiết thay đổi
1. **Khắc phục lỗi dữ liệu dự đoán không load được (`ReferenceError: updateThemeUI is not defined`)**:
   - Khi dọn dẹp các hàm cũ ở Build 19, hàm `updateThemeUI()` bị xóa nhưng vẫn còn lời gọi ở sự kiện `DOMContentLoaded`. Lỗi uncaught exception này làm ngừng toàn bộ tiến trình JavaScript, khiến hàm `loadData()` không bao giờ được gọi và các event listener cho nút "Tải lại", nút lọc, tìm kiếm không được gắn.
   - Đã khai báo hàm alias an toàn `function updateThemeUI() { applySavedTheme(); }` và chuẩn hóa sự kiện `DOMContentLoaded` gọi trực tiếp `applySavedTheme()`. Kết quả: dữ liệu 895 bản ghi điểm gas từ Google Apps Script tải về và phân tích chu kỳ mượt mà 100%.

2. **Khắc phục lỗi Header chèn đè lên Status Bar (đồng hồ, tai thỏ, cột sóng, pin) trên iPhone**:
   - Khôi phục cấu trúc Container Card chuẩn của hệ thống: bọc Header và nội dung bên trong `<div class="container">`.
   - Khôi phục `body { padding: calc(8px + env(safe-area-inset-top, 0px)) ... !important; }` trên mobile.
   - Nhờ đó trên iPhone 13 Pro (tai thỏ 47px), khối giao diện bắt đầu tại Y = 55px (cách mép dưới status bar một khoảng đệm an toàn 8px). Không còn bất kỳ sự chồng lấn nào giữa nút Menu / Home / Tiêu đề với đồng hồ hay biểu tượng pin/sóng.

3. **Tối ưu hiển thị nút "Sao chép đang lọc" không tràn viền thẻ**:
   - Cân chỉnh kích thước font chữ nút 13px và padding gọn gàng `0 0.45rem`, bọc nhãn chữ `<span>` với cơ chế ellipsis, đảm bảo chữ hiển thị trọn vẹn, sắc nét trong thẻ card.

---

## [Build 19 (v1.5 / UI v5.5)] - 2026-11-10
- **Commit SHA**: `ef5ccc1`
- **Mục tiêu**: Khắc phục triệt để các lỗi hiển thị giao diện trên trang Dự đoán điểm gas (`dudoandiemgas.html`) và Tính tiền gas còn lại (`tinhgascon.html`) khi chạy trên iPhone (đặc biệt trong Chế độ tối / Dark Mode).

### 🔄 Chi tiết thay đổi
1. **Sửa lỗi nút Menu & nút Home bị trắng tinh trong Chế độ tối (Dark Mode)**:
   - Bổ sung biến CSS `--bg-tertiary: #1e293b`, `--bg-subtle: #1e293b`, `--border-card: #334155`, `--text-main: #f8fafc` cho cả `html.dark` lẫn `[data-theme="dark"]` trong `dudoandiemgas.html` và `tinhgascon.html`.
   - Thiết lập CSS trực tiếp cho `.menu-toggle` và `.header-home-btn` trong Dark Mode (`background: #1e293b !important; border-color: #334155 !important; color: #f8fafc !important`), đảm bảo không còn tình trạng nút trắng icon trắng.

2. **Khôi phục bố cục Dashboard chuẩn tràn mép (Full-bleed Header) & bỏ khung lồng kép**:
   - Tách `<header class="app-header">` ra ngoài `<main class="container">`, đưa Header lên sát mép trên với `padding-top: calc(12px + env(safe-area-inset-top, 0px))`, nền mờ glass blur và cố định (`sticky`).
   - Xóa bỏ lớp bọc `.container-content` và đưa `.container` về dạng khung Dashboard trong suốt (`background: transparent; border: none; box-shadow: none`), giải phóng 32px bề ngang màn hình iPhone 13 Pro bị bóp nghẹt trước đó.

3. **Sửa lỗi tràn viền thẻ và cụt chữ nút "Sao chép đang lọc" (`#copy-all-btn`)**:
   - Điều chỉnh CSS grid 2 cột của `.report-actions`: thêm `min-width: 0`, `font-size: 13.5px`, `padding: 0 0.5rem`.
   - Bọc nội dung nút trong thẻ `<span>` với `overflow: hidden; text-overflow: ellipsis; white-space: nowrap`.
   - Nhờ bề ngang được mở rộng kết hợp kích thước nút tối ưu, chữ "Sao chép đang lọc" hiển thị đầy đủ, đẹp mắt và không còn tràn mép thẻ.

4. **Đồng bộ cơ chế đổi giao diện Sáng / Tối (Theme Toggle) & Khôi phục Toast Notification**:
   - Loại bỏ các hàm toggle theme cũ trùng lặp, chuẩn hóa `applySavedTheme()` và `toggleTheme()` đồng bộ cả class `.dark` và thuộc tính `data-theme`.
   - Khôi phục container `#toast` và chuyển sang dạng Floating Pill bo tròn nổi dưới notch tai thỏ iPhone 13 Pro (`top: max(16px, calc(env(safe-area-inset-top, 0px) + 12px))`).

---

## [Build 18 (v1.5 / UI v5.5)] - 2026-11-10
- **Commit SHA**: `b540497`
- **Mục tiêu**: Đồng bộ toàn bộ thanh Menubar (Header) và Sidebar Drawer trên tất cả 7 trang chức năng của ứng dụng theo thiết kế chuẩn nhận diện thương hiệu VNPost của trang `index.html`, loại bỏ hoàn toàn sự rời rạc và lỗi notch iPhone.

### 🔄 Chi tiết thay đổi
1. **Thanh Menubar (Header trên cùng) đồng bộ 100% trên cả 7 trang (`index.html`, `diemtien.html`, `vitri.html`, `tinhluong.html`, `tinhgascon.html`, `dudoandiemgas.html`, `clipboard.html`)**:
   - Chuyển toàn bộ header các trang con sang `.app-header` phong cách VNPost: nền thẻ đồng nhất `var(--bg-card)`, viền dưới `var(--border-card)`, căn giữa hoàn hảo.
   - Bên trái: Nút Hamburger card `menu-toggle` (40x40px, bo góc 10px) kích hoạt Sidebar Drawer và hỗ trợ chạm rung phản hồi (`vibrateShort`).
   - Ở giữa: Khối thương hiệu `.brand` với tiêu đề chính `.brand-title` màu xanh VNPost (`#005ba6`), font Be Vietnam Pro đậm nét, kèm phụ đề mô tả rõ ràng.
   - Bên phải: Nút quay về trang chủ `header-home-btn` (icon Home 40x40px) tiện lợi, giúp người dùng chuyển về `index.html` trong 1 chạm.
   - Đưa Header trong `tinhgascon.html` và `dudoandiemgas.html` vào trong container card có safe-area padding, chấm dứt triệt để lỗi notch tai thỏ iPhone 13 Pro đè cắt vào tiêu đề và các nút bấm.

2. **Thanh Sidebar Drawer dùng chung thống nhất với 16 danh mục chức năng**:
   - Tất cả các trang đều sở hữu cùng một Sidebar Drawer với đúng 16 mục chức năng, cùng icon Heroicons, cùng thứ tự:
     1. 🏠 **Quản lý điểm gas** (Trang chủ)
     2. 💵 **Đếm tiền** (`diemtien.html`)
     3. 💳 **Quản lý chi tiêu ca** (`index.html?action=expense`)
     4. ➕ **Thêm điểm ngoài ca** (`index.html?action=outofhours`)
     5. 🔄 **Hàng đợi đồng bộ** (`index.html?action=queue`)
     6. 📋 **Chuyển tất cả chưa nộp** (`index.html?action=batchstatus`)
     7. 📍 **Quản lý vị trí** (`vitri.html`)
     8. 💼 **Tính công & lương** (`tinhluong.html`)
     9. 👁️ **Xem nhanh điểm (ca)** (`index.html?action=quickview`)
     10. 🧪 **Tính tiền gas còn lại** (`tinhgascon.html`)
     11. 📈 **Dự đoán điểm gas** (`dudoandiemgas.html`)
     12. 📋 **Lưu Clipboard** (`clipboard.html`)
     13. 📤 **Xuất data của ca** (`index.html?action=export`)
     14. 🌙/☀️ **Chế độ sáng / tối** (Đồng bộ `gas_theme` giữa tất cả các trang)
     15. ❓ **Trợ giúp**
     16. ✕ **Đóng**
   - Đánh dấu `class="sidebar-item active"` tại đúng trang hiện tại của người dùng.
   - Thêm cơ chế điều hướng thông minh qua query parameters `?action=...` trên `index.html` cho các tính năng modal (chi tiêu, ngoài ca, hàng đợi, chuyển trạng thái hàng loạt, xem nhanh, xuất data, trợ giúp).

3. **Cử chỉ vuốt mép trái (Edge Swipe) & Dark Mode đồng bộ**:
   - Tích hợp cử chỉ vuốt mép màn hình (Edge Swipe Gestures) mở / đóng menu mượt mà 60fps trên toàn bộ 7 trang.
   - Đồng bộ toàn diện Dark Mode/Light Mode/Tự động theo hệ thống qua khóa `gas_theme`.

4. **Nâng cấp phiên bản**:
   - Cập nhật UI tag từ `v5.4` lên `v5.5` trên `index.html`.
   - Nâng `CURRENT_PROJECT_VERSION` từ 17 lên 18 trong Xcode project (`project.pbxproj`).
   - Đồng bộ toàn bộ mã nguồn sang thư mục `www/` và chạy `npx cap sync ios`.


## [Build 17 (v1.5 / UI v5.4)] - 2026-11-10
- **Commit SHA**: `6b95c24`
- **Mục tiêu**: Điều chỉnh vị trí thông báo Toast nằm hoàn toàn dưới tai thỏ (Notch) iPhone 13 Pro (chống che khuất status bar / giờ / pin), thiết kế lại hiệu ứng Pull-to-Refresh dạng khoang Notch Expansion (Dynamic Island pill) kéo mượt mà từ tai thỏ ra, nâng UI lên `v5.4`.

### 🔄 Chi tiết thay đổi
- **Điều chỉnh vị trí thông báo Toast dưới Notch iPhone (`env(safe-area-inset-top)`)**:
  - Khắc phục triệt để lỗi thông báo bị tai thỏ che mất và đè lên thanh đồng hồ (`15:24`) / biểu tượng pin.
  - Chuyển `top: 20px` cố định thành `top: max(16px, calc(env(safe-area-inset-top, 0px) + 12px))`. Trên iPhone 13 Pro (tai thỏ 47px), thông báo sẽ nổi tại tọa độ 59px, nằm hoàn toàn bên dưới tai thỏ.
  - Nâng cấp giao diện Toast dạng Frosted Glassmorphism (viền mờ, bo góc pill, đổ bóng sâu 3D, hiệu ứng rơi đàn hồi Spring nhẹ từ dưới tai thỏ).
  - Tự động ngắt dòng thông minh (`white-space: normal`) cho các thông báo dài như cảnh báo "Ngoài ca làm việc", không còn bị cắt đuôi chữ.
  - Đồng bộ vị trí hiển thị chuẩn trên toàn bộ các trang: `index.html`, `clipboard.html`, `tinhluong.html`, `vitri.html`.
- **Thiết kế hiệu ứng Pull-to-Refresh dạng Notch Expansion (kéo từ tai thỏ ra)**:
  - Tái thiết kế toàn diện trải nghiệm kéo làm mới thành một viên nang đen nhung (Obsidian Capsule) kéo giãn tự nhiên từ tai thỏ xuống.
  - Vòng tiến trình tròn SVG dạng Apple Watch Activity Ring (`stroke-dashoffset`) tự động lấp đầy từ 0% đến 100% theo khoảng cách tay kéo.
  - Mũi tên đảo chiều linh hoạt, kèm rung phản hồi xúc giác nhẹ (Haptic feedback `vibrateShort()`) và viền xanh ngọc bích khi đạt ngưỡng kích hoạt ("Thả để làm mới").
  - Khi thả tay: Icon chuyển thành vòng xoay Spinner mượt mà, gọi trực tiếp hàm nạp dữ liệu không chớp trắng màn hình (`taiDuLieu()`), hiển thị trạng thái "Đã cập nhật!" trước khi thụt êm ái trở lại tai thỏ.
- **Nâng phiên bản hiển thị**:
  - `index.html` & `www/index.html`: `<span class="version-tag">v5.3</span>` ➔ `<span class="version-tag">v5.4</span>`.
  - `project.pbxproj`: Nâng `CURRENT_PROJECT_VERSION` lên `17`.
- **Files tác động**:
  - `index.html` & `www/index.html`
  - `clipboard.html`
  - `tinhluong.html`
  - `vitri.html`
  - `resources/ios/project.pbxproj` & `ios/App/App.xcodeproj/project.pbxproj` (Build 17)
  - `CHANGELOG.md`
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 16 (v1.5 / UI v5.3)] - 2026-11-10
- **Commit SHA**: `ef2d099`
- **Mục tiêu**: Sửa triệt để lỗi hiển thị ngày ca (`Ca (df.str...`) trên 2 widget, khắc phục lỗi vòng tròn chi tiêu hiển thị 0 đ bằng cấu hình App Group Entitlements & bộ đệm đồng bộ file JSON hai chiều.

### 🔄 Chi tiết thay đổi
- **Khắc phục lỗi cú pháp nội suy chuỗi Swift hiển thị ngày ca trên Widget**:
  - Sửa lỗi thiếu ký tự gạch chéo `\` trong hàm `formatShiftDisplayFromDate` khiến tên ca bị in nguyên bản chuỗi mã nguồn `Ca (df.string(from: date))` thay vì ngày ca thực tế `Ca 09-11`.
  - Cả 2 Widget (Widget Tổng quan 4x2 và Widget Thao tác nhanh 4x2) giờ đây hiển thị ngày ca chuẩn xác 100% dạng `Ca dd-MM` theo giờ Việt Nam.
- **Khắc phục lỗi vòng tròn chi tiêu hiển thị 0 đ (Thiếu số tiền đã chi)**:
  - **Bổ sung App Group Entitlements (`com.apple.security.application-groups`)**: Tạo file `App.entitlements` và `GasWidget.entitlements` với App Group `group.com.vnpost.gasmanager`, liên kết vào `CODE_SIGN_ENTITLEMENTS` trong `project.pbxproj` cho cả target App và GasWidgetExtension.
  - **Tích hợp Ad-hoc Codesign trong GitHub Actions**: Workflow đóng gói tự động ký ad-hoc với entitlements để các công cụ cài đặt (TrollStore, AltStore, Esign) tự động cấp quyền Shared Container giữa App và Widget.
  - **Bộ đệm đồng bộ đa tầng qua File JSON dùng chung (`widget_data.json`)**: Bên cạnh `UserDefaults`, `SceneDelegate.swift` lưu trực tiếp bản sao dữ liệu sang `widget_data.json` trong thư mục Shared App Group; `GasWidget.swift` đọc ưu tiên từ file này, đảm bảo Widget luôn lấy được số tiền chi tiêu thực tế ngay cả khi UserDefaults bị phân mảnh sandbox.
  - **Sửa hàm `syncWidgetData()` và tự động đồng bộ khi thao tác chi tiêu**: Bổ sung xử lý khi `stats` chưa được truyền (tự động tính từ dữ liệu hiện có), gọi `syncWidgetData()` ngay khi thêm, xóa hoặc xóa hết chi tiêu trong `saveAllStoredExpenses()`.
- **Files tác động**:
  - `index.html` & `www/index.html`
  - `ios/App/App/SceneDelegate.swift` & `resources/ios/SceneDelegate.swift`
  - `ios/App/GasWidget/GasWidget.swift` & `resources/ios/GasWidget/GasWidget.swift`
  - `resources/ios/App.entitlements` & `ios/App/App/App.entitlements`
  - `resources/ios/GasWidget/GasWidget.entitlements` & `ios/App/GasWidget/GasWidget.entitlements`
  - `resources/ios/project.pbxproj` & `ios/App/App.xcodeproj/project.pbxproj` (Build 16)
  - `.github/workflows/build-ipa.yml`
  - `CHANGELOG.md`
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 15 (v1.5 / UI v5.3)] - 2026-11-10
- **Commit SHA**: `f5667b6`
- **Mục tiêu**: Chuyển đổi vòng tròn % trên iOS Widget thành Nút tròn Chi tiêu ca (hiện số tiền đã chi & bấm vào mở ngay modal Chi tiêu), sửa triệt để lỗi lệch ngày ca trên Widget theo múi giờ Việt Nam, nâng UI lên `v5.3`.

### 🔄 Chi tiết thay đổi
- **Nút tròn Chi tiêu ca (`GasExpenseCircleButton`) trên Widget 4x2**:
  - Thay thế phần vòng tròn `% ĐÃ THU` bằng nút tròn viền Cam Hổ phách (Amber `#f59e0b`) đồng bộ nhận diện nút Chi tiêu ca trong app.
  - Hiển thị số tiền chi tiêu thực tế của ca (ví dụ `-62.000` hoặc `-62k`, nếu chưa chi hiện `0 đ`) kèm nhãn `CHI TIÊU`.
  - Tích hợp Deep Link `gasmanager://expense`: Chạm vào nút tròn trên màn hình chính sẽ tự động mở ứng dụng và bật ngay modal "Quản lý chi tiêu trong ca".
- **Khắc phục triệt để lỗi lệch ngày ca trên Widget (`Ca 08-11` ➔ `Ca 09-11`)**:
  - Dữ liệu Google Sheets xuất chuỗi UTC (`2026-11-08T17:00:00.000Z`). Widget trước đây chỉ cắt 10 ký tự đầu nên hiển thị `Ca 08-11`.
  - Đã tích hợp bộ phân tích `ISO8601DateFormatter` và quy chuẩn múi giờ Việt Nam (`Asia/Ho_Chi_Minh` - GMT+7) vào `GasWidget.swift`.
  - Chuẩn hóa nhóm bản ghi theo khóa ca `yyyy-MM-dd` theo giờ Việt Nam, đảm bảo ngày ca trên Widget luôn khớp 100% với Web App.
- **Đồng bộ hai chiều dữ liệu chi tiêu qua Shared App Group (`group.com.vnpost.gasmanager`)**:
  - `index.html`: Cập nhật `syncWidgetData()` tính tổng chi tiêu thực tế của ca hiện tại và đồng bộ sang native bridge `gasWidgetBridge`.
  - `SceneDelegate.swift`: Lưu `widget_expenseTotal` và `widget_expenseFormatted`, đồng thời bắt URL Scheme `gasmanager://expense` gọi `window.quickActionExpense()`.
- **Nâng phiên bản hiển thị**:
  - `index.html` & `www/index.html`: `<span class="version-tag">v5.2</span>` ➔ `<span class="version-tag">v5.3</span>`.
- **Files tác động**:
  - `index.html` & `www/index.html`
  - `ios/App/App/SceneDelegate.swift` & `resources/ios/SceneDelegate.swift`
  - `ios/App/GasWidget/GasWidget.swift` & `resources/ios/GasWidget/GasWidget.swift`
  - `resources/ios/project.pbxproj` (Build 15)
  - `ios/App/App.xcodeproj/project.pbxproj` (Build 15)
  - `CHANGELOG.md`
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

---

## [Build 14 (v1.5 / UI v5.2)] - 2026-11-09
- **Commit SHA**: `cb7db31`
- **Mục tiêu**: Bổ sung cơ chế chọn nhanh và quản lý các khoản chi đã lưu trong LocalStorage cho modal "Quản lý chi tiêu trong ca" và "Báo cáo cuối ca", nâng phiên bản giao diện lên `v5.2`.

### 🔄 Chi tiết thay đổi
- **Giao diện Quick Chips & Quản lý mẫu khoản chi đã lưu (`gas_point_expense_templates`)**:
  - Bổ sung thanh gợi ý khoản chi mẫu dạng thẻ (Quick Chips) một chạm ngay dưới tiêu đề: `[ ⛽ Xăng ]`, `[ 🍚 Ăn uống ]`, `[ 🅿️ Gửi xe ]`... Bấm vào chip sẽ tự động điền tên vào ô nhập và focus ngay sang ô số tiền.
  - Hỗ trợ nút `[+ Thêm mẫu]` để lưu nhanh khoản chi mẫu mới vào `localStorage`.
  - Hỗ trợ nút `[×]` trên từng thẻ để người dùng có thể xóa bỏ các mẫu chi tiêu không còn dùng khỏi `localStorage`.
  - Highlight trực quan thẻ chip đang được chọn khi người dùng gõ tên khớp trong ô nhập liệu.
- **Sửa lỗi Datalist không đồng bộ trong modal Chi tiêu**:
  - Hàm `updateExpenseTemplatesDatalist()` cập nhật đồng thời cả `#global-expense-templates` (Chi tiêu ca) và `#expense-templates-list` (Báo cáo).
  - Tự động lưu tên khoản chi mới vào `localStorage` khi bấm nút "Thêm", giúp các lần sau luôn có sẵn trong danh sách chọn nhanh.
- **Nâng phiên bản hiển thị UI theo quy tắc**:
  - `index.html` & `www/index.html`: `<span class="version-tag">v5.1</span>` ➔ `<span class="version-tag">v5.2</span>`.
- **Files tác động**:
  - `index.html` & `www/index.html`
  - `CHANGELOG.md`
  - `resources/ios/project.pbxproj` (Build 14)
  - `ios/App/App.xcodeproj/project.pbxproj` (Build 14)
  - `ios/App/App/public/*` (`npx cap sync ios`)

### ⏪ Hướng dẫn Revert nếu cần
```bash
git revert HEAD --no-edit
git push origin main
```

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
