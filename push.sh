#!/bin/bash

# Thoát nếu có lỗi
set -e

echo "📁 Thêm file vào Git..."
git add .

message="$1"
if [ -z "$message" ]; then
  read -p "📝 Nhập nội dung commit: " message
fi

if [ -z "$message" ]; then
  message="update vitri.html: dong bo loading va sua loi lap so diem gas"
fi

git commit -m "$message"

echo "☁️ Đẩy lên GitHub..."
git push origin main

echo "✅ Hoàn tất!"
