upup#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "📁 Thêm file vào Git..."
git add .

read -p "📝 Nhập nội dung commit: " message
git commit -m "$message"

echo "☁️ Đẩy lên GitHub..."
git push origin main

echo "✅ Hoàn tất!"
