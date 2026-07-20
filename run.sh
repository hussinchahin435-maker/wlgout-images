#!/bin/bash

# Logout Images Project - Script Runner
# سكربت تشغيل مشروع صور الخروج

echo "================================"
echo "🚪 Logout Images Project"
echo "مشروع صور الخروج"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if port is provided
PORT=${1:-8000}

echo -e "${BLUE}📋 خيارات التشغيل:${NC}"
echo "1. تشغيل خادم محلي (Local Server)"
echo "2. فتح الملف مباشرة (Open File)"
echo "3. عرض المساعدة (Help)"
echo ""

echo -e "${YELLOW}🖥️  نظام التشغيل: Linux (Fedora)${NC}"
echo ""

# Function to start server
start_server() {
    echo -e "${GREEN}✅ جاري تشغيل الخادم على المنفذ ${PORT}...${NC}"
    echo -e "${BLUE}📌 اضغط Ctrl+C للإيقاف${NC}"
    echo ""
    
    # Check if Python is available
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}🐍 استخدام Python 3${NC}"
        cd "$(dirname "$0")"
        python3 -m http.server $PORT
    elif command -v python &> /dev/null; then
        echo -e "${GREEN}🐍 استخدام Python 2${NC}"
        cd "$(dirname "$0")"
        python -m SimpleHTTPServer $PORT
    elif command -v php &> /dev/null; then
        echo -e "${GREEN}🐘 استخدام PHP${NC}"
        cd "$(dirname "$0")"
        php -S localhost:$PORT
    elif command -v node &> /dev/null; then
        echo -e "${GREEN}⬢ استخدام Node.js (http-server)${NC}"
        cd "$(dirname "$0")"
        if command -v http-server &> /dev/null; then
            http-server -p $PORT
        else
            echo -e "${YELLOW}⚠️  http-server غير مثبت. تثبيت...${NC}"
            npm install -g http-server
            http-server -p $PORT
        fi
    else
        echo -e "${RED}❌ لم يتم العثور على خادم متاح${NC}"
        echo "الرجاء تثبيت Python أو PHP أو Node.js"
        exit 1
    fi
}

# Function to open file
open_file() {
    FILE="$(dirname "$0")/index.html"
    
    if [ ! -f "$FILE" ]; then
        echo -e "${RED}❌ الملف index.html غير موجود${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ جاري فتح الملف...${NC}"
    
    if command -v xdg-open &> /dev/null; then
        xdg-open "$FILE"
    elif command -v gnome-open &> /dev/null; then
        gnome-open "$FILE"
    elif command -v firefox &> /dev/null; then
        firefox "$FILE"
    else
        echo -e "${YELLOW}⚠️  لم يتمكن من فتح الملف تلقائياً${NC}"
        echo "الملف في: $FILE"
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}📖 دليل الاستخدام:${NC}"
    echo ""
    echo "    ./run.sh              - تشغيل خادم محلي على المنفذ 8000"
    echo "    ./run.sh 3000         - تشغيل خادم محلي على المنفذ 3000"
    echo "    ./run.sh open         - فتح الملف مباشرة"
    echo "    ./run.sh help         - عرض هذه الرسالة"
    echo ""
    echo -e "${GREEN}✨ المميزات:${NC}"
    echo "    - دعم Python و PHP و Node.js"
    echo "    - فتح الملفات تلقائياً"
    echo "    - منفذ قابل للتخصيص"
    echo "    - محسّن لـ Linux/Fedora"
    echo ""
}

# Make script executable
chmod +x "$0" 2>/dev/null

# Main logic
if [ "$1" == "open" ]; then
    open_file
elif [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
elif [ -z "$1" ] || [[ $1 =~ ^[0-9]+$ ]]; then
    start_server
else
    echo -e "${RED}❌ خيار غير صحيح: $1${NC}"
    echo ""
    show_help
    exit 1
fi