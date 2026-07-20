#!/bin/bash

# Logout Images Project - Hyprland Optimized Runner
# سكربت تشغيل مشروع صور الخروج محسّن لـ Hyprland

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
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

PORT=${1:-8000}

echo -e "${PURPLE}🪟 Hyprland Window Manager Detected${NC}"
echo -e "${BLUE}📋 خيارات التشغيل:${NC}"
echo "1. تشغيل خادم Python"
echo "2. تشغيل مع Node.js"
echo "3. فتح في المتصفح"
echo "4. عرض الملفات"
echo ""

# Function to start with Python
start_python() {
    echo -e "${GREEN}✅ تشغيل Python Server على المنفذ ${PORT}...${NC}"
    echo -e "${BLUE}📌 اضغط Ctrl+C للإيقاف${NC}"
    echo ""
    cd "$(dirname "$0")"
    python3 -m http.server $PORT
}

# Function to start with Node.js
start_node() {
    echo -e "${GREEN}✅ تشغيل Node.js Server على المنفذ ${PORT}...${NC}"
    echo -e "${BLUE}📌 اضغط Ctrl+C للإيقاف${NC}"
    echo ""
    cd "$(dirname "$0")"
    
    if command -v http-server &> /dev/null; then
        http-server -p $PORT
    else
        echo -e "${YELLOW}⚠️  http-server غير مثبت${NC}"
        echo "تثبيت..."
        npm install -g http-server
        http-server -p $PORT
    fi
}

# Function to open in browser using Hyprland
open_browser() {
    echo -e "${GREEN}✅ فتح المتصفح في نافذة جديدة...${NC}"
    echo ""
    
    # Check for available browsers
    BROWSER=""
    if command -v firefox &> /dev/null; then
        BROWSER="firefox"
    elif command -v google-chrome &> /dev/null; then
        BROWSER="google-chrome"
    elif command -v chromium &> /dev/null; then
        BROWSER="chromium"
    elif command -v librewolf &> /dev/null; then
        BROWSER="librewolf"
    else
        BROWSER="xdg-open"
    fi
    
    echo -e "${PURPLE}🪟 فتح مع: $BROWSER${NC}"
    
    # Launch in new workspace (Hyprland specific)
    if command -v hyprctl &> /dev/null; then
        hyprctl dispatch exec "$BROWSER http://localhost:$PORT"
        echo -e "${GREEN}✅ تم الفتح في نافذة Hyprland${NC}"
    else
        $BROWSER http://localhost:$PORT &
        echo -e "${GREEN}✅ تم الفتح${NC}"
    fi
}

# Function to show files
show_files() {
    echo -e "${PURPLE}📂 محتوى المشروع:${NC}"
    echo ""
    
    # Tree-like output
    if command -v tree &> /dev/null; then
        tree -L 2
    else
        echo -e "${BLUE}الملفات:${NC}"
        ls -lh
        echo ""
        echo -e "${BLUE}المجلدات:${NC}"
        du -sh */ 2>/dev/null || echo "لا توجد مجلدات"
    fi
    echo ""
}

# Function to show status
show_status() {
    echo -e "${PURPLE}📊 حالة المشروع:${NC}"
    echo ""
    echo -e "${GREEN}✓ الملفات:${NC}"
    ls -1 *.{html,css,json,sh,png} 2>/dev/null | wc -l
    echo " ملف"
    echo ""
    echo -e "${GREEN}✓ الصور:${NC}"
    ls -1 *.png 2>/dev/null | wc -l
    echo " صورة"
    echo ""
    echo -e "${GREEN}✓ حجم المشروع:${NC}"
    du -sh . | cut -f1
    echo ""
}

# Function to show help
show_help() {
    echo -e "${PURPLE}📖 دليل الاستخدام:${NC}"
    echo ""
    echo -e "${BLUE}الأوامر الأساسية:${NC}"
    echo "    ./hyprland-run.sh python       - تشغيل Python Server"
    echo "    ./hyprland-run.sh node         - تشغيل Node.js Server"
    echo "    ./hyprland-run.sh 3000         - منفذ مخصص"
    echo "    ./hyprland-run.sh open         - فتح المتصفح"
    echo "    ./hyprland-run.sh files        - عرض الملفات"
    echo "    ./hyprland-run.sh status       - حالة المشروع"
    echo "    ./hyprland-run.sh help         - هذه الرسالة"
    echo ""
    echo -e "${BLUE}أمثلة:${NC}"
    echo "    ./hyprland-run.sh python"
    echo "    ./hyprland-run.sh node 5000"
    echo "    ./hyprland-run.sh open"
    echo ""
    echo -e "${YELLOW}ملاحظات:${NC}"
    echo "    - محسّن لـ Hyprland tiling WM"
    echo "    - يفتح المتصفح في نافذة Hyprland"
    echo "    - دعم كامل لـ Fedora"
    echo ""
}

# Make script executable
chmod +x "$0" 2>/dev/null

# Main logic
case "$1" in
    python)
        start_python
        ;;
    node)
        start_node
        ;;
    open)
        open_browser
        ;;
    files)
        show_files
        ;;
    status)
        show_status
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        if [[ $1 =~ ^[0-9]+$ ]]; then
            PORT=$1
            start_python
        else
            echo -e "${RED}❌ خيار غير صحيح: $1${NC}"
            echo ""
            show_help
            exit 1
        fi
        ;;
esac
