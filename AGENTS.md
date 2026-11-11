# 🤖 Gas Manager - Agent Project Rules & Instructions

Tài liệu này là quy chuẩn bắt buộc dành cho mọi AI Agent và Developer làm việc trong dự án **Gas Manager**.

---

## 🛡️ 1. QUY TẮC BẢO TOÀN PHẠM VI & XÁC NHẬN KHI CÓ ẢNH HƯỞNG LIÊN ĐỚI (Scope Preservation & Impact Confirmation Rule)

> [!CAUTION]
> **QUY TẮC SỐ 1 BẮT BUỘC TUÂN THỦ:**
> 1. **Giữ nguyên 100% các chức năng không được đề cập**:
>    - Mỗi khi người dùng yêu cầu thay đổi hoặc sửa lỗi một tính năng, thành phần hoặc giao diện cụ thể: Agent **CHỈ ĐƯỢC PHÉP** can thiệp đúng vào phạm vi được yêu cầu.
>    - Mọi tính năng, giao diện, cấu trúc dữ liệu, luồng tính toán khác KHÔNG được đề cập trong yêu cầu **BẮT BUỘC PHẢI GIỮ NGUYÊN HOÀN TOÀN**, tuyệt đối không tự ý thay đổi, tái cấu trúc (refactor), xóa bỏ hay sửa đổi cách hoạt động vốn có.
> 2. **Phải hỏi ý kiến người dùng trước nếu có ảnh hưởng liên quan**:
>    - Nếu việc thực hiện yêu cầu bắt buộc phải can thiệp, tác động hoặc có nguy cơ làm thay đổi bất kỳ chức năng liên quan nào khác: **BẮT BUỘC PHẢI DỪNG LẠI, NÊU RÕ VÀ HỎI Ý KIẾN NGƯỜI DÙNG** trước khi viết code hay chỉnh sửa.
>    - Chỉ thực hiện phần tác động liên đới khi người dùng đã xem xét và đồng ý.
> 3. **Kiểm tra hồi quy nghiêm ngặt**:
>    - Tuyệt đối không xóa bỏ các hàm dùng chung (như hàm theme, định dạng tiền, chuẩn hóa ca...) mà các file hoặc sự kiện khác đang sử dụng.

---

## 📌 2. QUY TẮC CẬP NHẬT CHANGELOG (Changelog Rule)
- Mỗi khi thực hiện bất kỳ thay đổi nào (dù lớn hay nhỏ), **BẮT BUỘC** phải thêm một mục phiên bản mới lên đầu file `CHANGELOG.md` trước khi commit.
- Mỗi bản cập nhật phải ghi rõ: Phiên bản & Build number, Commit SHA, mục tiêu thay đổi, chi tiết kỹ thuật và lệnh `git revert` mẫu.

---

## 🏷️ 3. QUY TẮC CẬP NHẬT PHIÊN BẢN HIỂN THỊ (UI Versioning Rule)
- Khi có thay đổi ĐỦ LỚN (tính năng mới quan trọng, thay đổi lớn về logic hoặc giao diện): **BẮT BUỘC** tăng phiên bản tại thẻ `<span class="version-tag">` trên header của `index.html` và `www/index.html` lên 1 chấm nhỏ (ví dụ: `v5.0` ➔ `v5.1` ➔ `v5.2`...).
- Với các lỗi nhỏ, hotfix CSS: Giữ nguyên version tag trên UI, chỉ tăng Build version iOS và ghi `CHANGELOG.md`.

---

## 🔄 4. QUY TẮC ĐỒNG BỘ NỀN TẢNG (Sync & iOS Native Rule)
1. **Đồng bộ Web & Capacitor**:
   - Khi sửa bất kỳ trang Web nào (`index.html`, `diemtien.html`, `vitri.html`, `tinhluong.html`, `tinhgascon.html`, `dudoandiemgas.html`, `clipboard.html`), **BẮT BUỘC phải đồng bộ bản copy sang thư mục `www/`**.
   - Sau khi đồng bộ `www/`, **BẮT BUỘC chạy `npx cap sync ios`**.
2. **Build version iOS**:
   - Khi tăng build version, phải tăng ở cả 2 file:
     - `resources/ios/project.pbxproj` (`CURRENT_PROJECT_VERSION`)
     - `ios/App/App.xcodeproj/project.pbxproj` (`CURRENT_PROJECT_VERSION`)
3. **Môi trường Windows & PowerShell**:
   - Khi chạy script Node trong PowerShell, tránh escape ký tự phức tạp, nên viết file script tạm (`.js`), thực thi bằng `node <file>.js` rồi xóa.

---

## 🚀 5. CHECKLIST TRƯỚC KHI HOÀN TẤT MỖI TASK
- [ ] **Bảo toàn phạm vi**: Các chức năng không được đề cập đều được giữ nguyên 100%, không bị ảnh hưởng ngoài ý muốn.
- [ ] Nếu có chức năng liên đới bị tác động: Đã hỏi ý kiến và được người dùng đồng ý trước khi làm.
- [ ] Đã kiểm tra cú pháp JS, tag HTML và DOM event không bị crash.
- [ ] Đã đồng bộ sang thư mục `www/`.
- [ ] Đã chạy `npx cap sync ios`.
- [ ] Đã tăng `CURRENT_PROJECT_VERSION` trong cả 2 file `project.pbxproj`.
- [ ] Đã ghi nhật ký vào `CHANGELOG.md`.
- [ ] Đã commit và push lên `origin main`.
