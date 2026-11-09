# 🤖 Chỉ Dẫn Dành Cho AI Agent (Agent Instructions & Architecture Guide)

Chào bạn Agent tiếp theo! Đây là dự án **Gas Manager** (Ứng dụng quản lý điểm gas theo ca, hỗ trợ cả nền tảng Web PWA và Ứng dụng iOS Native đóng gói qua Capacitor).

Để duy trì chất lượng dự án và không làm gián đoạn trải nghiệm của người dùng, bạn **PHẢI** đọc kỹ và tuân thủ các nguyên tắc dưới đây:

---

## 📌 1. Quy Tắc Ghi Nhật Ký Bắt Buộc (Changelog Rule)

* **BẮT BUỘC**: Mỗi khi bạn thay đổi, sửa lỗi hoặc thêm tính năng trong dự án, bạn **PHẢI** cập nhật file **`CHANGELOG.md`** ngay tại thư mục gốc trước khi commit.
* Cấu trúc mỗi bản cập nhật trong `CHANGELOG.md` phải có:
  1. Phiên bản & Build number (ví dụ: `[Build 11 (v1.5)] - YYYY-MM-DD`).
  2. Commit SHA và mục tiêu thay đổi.
  3. Chi tiết thay đổi và danh sách file tác động.
  4. Lưu ý kỹ thuật cho Agent sau (những cạm bẫy / gotchas cần tránh).
  5. Câu lệnh `git revert` mẫu để hoàn tác phiên bản đó nếu xảy ra lỗi.

---

## 🏷️ 2. Quy Tắc Cập Nhật Phiên Bản Hiển Thị (UI Versioning Rule)

* **Vị trí hiển thị**: Thẻ `<span class="version-tag">v5.0</span>` nằm cạnh tiêu đề *"Quản lý điểm gas"* trong header của `index.html` (và bản copy `www/index.html`).
* **Quy tắc nâng phiên bản**:
  - **Thay đổi nhỏ / Hotfix CSS / Sửa lỗi hiển thị**: Giữ nguyên version tag (hoặc tăng patch `v5.0.1` nếu cần), chỉ tăng `CURRENT_PROJECT_VERSION` (Build number iOS) và ghi `CHANGELOG.md`.
  - **Thay đổi ĐỦ LỚN** (Thêm tính năng mới, tái cấu trúc logic báo cáo/chi tiêu, đồng bộ typography toàn ứng dụng, thay đổi luồng làm việc quan trọng): **BẮT BUỘC** tăng phiên bản UI lên 1 chấm nhỏ (minor version), ví dụ: `v5.0` ➔ `v5.1` ➔ `v5.2`...
  - Khi tăng số phiên bản trên UI, phải:
    1. Cập nhật đồng thời ở `index.html` và `www/index.html`.
    2. Ghi rõ số phiên bản này vào tiêu đề mục cập nhật trong `CHANGELOG.md`.

---

## 🏗️ 3. Kiến Trúc Dự Án & Luồng Dữ Liệu

1. **Web App**:
   - `index.html`: File ứng dụng chính của toàn bộ giao diện Web.
   - `www/index.html`: Thư mục phân phối web assets cho Capacitor.
   - ⚠️ **QUY TẮC VÀNG**: Bất cứ khi nào sửa `index.html`, bạn **PHẢI đồng bộ sang `www/index.html`** và chạy lệnh `npx cap sync ios`.

2. **iOS Native & Widget**:
   - `ios/App/App`: Xcode project chính của ứng dụng Capacitor.
   - `resources/ios`: Thư mục lưu trữ mã nguồn Native gốc (Info.plist, project.pbxproj, SceneDelegate.swift, NativeLocationManager.swift, GasWidget).
   - Khi tăng build version, phải tăng ở **cả 2 file**:
     - `resources/ios/project.pbxproj` (`CURRENT_PROJECT_VERSION`)
     - `ios/App/App.xcodeproj/project.pbxproj` (`CURRENT_PROJECT_VERSION`)
   - Quy trình CI/CD: `.github/workflows/build-ipa.yml` tự động build khi push vào `main`.

3. **Lưu trữ Cục bộ (LocalStorage)**:
   - `gas_point_records_cache`: Cache dữ liệu điểm gas từ Google Sheets.
   - `gas_shift_expenses`: Danh sách các khoản chi tiêu trong ca (dạng JSON Array các object `{ id, shift, name, amount, note, time, timestamp }`).
   - `money_counts`: Dữ liệu đếm tiền theo ca từ trang `diemtien.html`.
   - `gas_point_recipients`: Danh sách người nhận báo cáo cuối ca.
   - `gas_point_expense_templates`: Các mẫu chi tiêu gợi ý (xăng, ăn uống,...).

4. **Chuẩn hóa Ca làm việc (Shift Normalization)**:
   - Trong dữ liệu Google Sheets, ca có thể lưu dưới dạng `Ca 07-11-2026` hoặc `2026-11-07`.
   - Hàm `getNormalizedShiftKey(shift)` luôn quy chuẩn về `YYYY-MM-DD`.
   - Hàm `getAvailableShiftMap()` đảm bảo gom ca không bao giờ bị trùng lặp.
   - Khi lọc dữ liệu theo ca, **LUÔN** dùng:
     ```javascript
     getNormalizedShiftKey(item.ca) === getNormalizedShiftKey(selectedShift) || item.ca === selectedShift
     ```

5. **Môi Trường Windows & Shell**:
   - Hệ điều hành máy phát triển là Windows, shell mặc định là PowerShell.
   - Khi chạy lệnh Node inline trong PowerShell, tránh escape dấu ngoặc kép phức tạp. Nên ghi ra file script tạm (`.js`), thực thi bằng `node <file>.js`, sau đó xóa file tạm.
   - File `index.html` sử dụng ký tự xuống dòng Windows CRLF (`\r\n`). Khi replace nội dung bằng Node.js, hãy normalize sang `\n`, replace xong ghi lại với `\r\n`.

---

## 🚀 4. Checklist Trước Khi Hoàn Tất Một Task

- [ ] Đã sửa và kiểm tra cú pháp JS trong `index.html`.
- [ ] Nếu là thay đổi đủ lớn: Đã cập nhật thẻ version tag trên header (`<span class="version-tag">vX.X</span>`) trong cả `index.html` và `www/index.html`.
- [ ] Đã copy/đồng bộ chính xác sang `www/index.html`.
- [ ] Đã chạy `npx cap sync ios`.
- [ ] Đã tăng `CURRENT_PROJECT_VERSION` trong cả 2 file `project.pbxproj`.
- [ ] Đã ghi lại nhật ký phiên bản mới vào đầu file `CHANGELOG.md`.
- [ ] Đã commit với commit message rõ ràng và push lên `origin main`.
