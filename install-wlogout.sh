#!/bin/bash

# Wlogout Icons Installer
# سكربت تثبيت الصور لـ wlogout

echo "================================"
echo "🚪 Wlogout Icons Installer"
echo "مثبّت صور wlogout"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Wlogout config directory
WLOGOUT_DIR="$HOME/.config/wlogout"
ICONS_DIR="$WLOGOUT_DIR/icons"

echo -e "${BLUE}📋 خطوات التثبيت:${NC}"
echo ""

# Step 1: Create directories
echo -e "${BLUE}1️⃣  إنشاء المجلدات...${NC}"
if [ ! -d "$WLOGOUT_DIR" ]; then
    mkdir -p "$WLOGOUT_DIR"
    echo -e "${GREEN}✅ تم إنشاء $WLOGOUT_DIR${NC}"
else
    echo -e "${YELLOW}⚠️  $WLOGOUT_DIR موجود بالفعل${NC}"
fi

if [ ! -d "$ICONS_DIR" ]; then
    mkdir -p "$ICONS_DIR"
    echo -e "${GREEN}✅ تم إنشاء $ICONS_DIR${NC}"
else
    echo -e "${YELLOW}⚠️  $ICONS_DIR موجود بالفعل${NC}"
fi

echo ""

# Step 2: Copy icons
echo -e "${BLUE}2️⃣  نسخ الصور...${NC}"

ICONS=("logout.png" "shutdown.png" "reboot.png" "suspend.png" "hibernate.png" "lock.png")

for icon in "${ICONS[@]}"; do
    if [ -f "$(dirname "$0")/$icon" ]; then
        cp "$(dirname "$0")/$icon" "$ICONS_DIR/"
        echo -e "${GREEN}✅ تم نسخ $icon${NC}"
    else
        echo -e "${YELLOW}⚠️  لم يتم العثور على $icon${NC}"
    fi
done

echo ""

# Step 3: Copy configuration files
echo -e "${BLUE}3️⃣  نسخ ملفات الإعدادات...${NC}"

if [ -f "$(dirname "$0")/wlogout-layout.json" ]; then
    cp "$(dirname "$0")/wlogout-layout.json" "$WLOGOUT_DIR/layout"
    echo -e "${GREEN}✅ تم نسخ layout${NC}"
fi

if [ -f "$(dirname "$0")/wlogout-style.css" ]; then
    cp "$(dirname "$0")/wlogout-style.css" "$WLOGOUT_DIR/style.css"
    echo -e "${GREEN}✅ تم نسخ style.css${NC}"
fi

echo ""

# Step 4: Verify installation
echo -e "${BLUE}4️⃣  التحقق من التثبيت...${NC}"

if [ -d "$ICONS_DIR" ] && [ "$(ls -1 $ICONS_DIR/*.png 2>/dev/null | wc -l)" -gt 0 ]; then
    ICON_COUNT=$(ls -1 $ICONS_DIR/*.png 2>/dev/null | wc -l)
    echo -e "${GREEN}✅ تم تثبيت $ICON_COUNT صورة بنجاح${NC}"
else
    echo -e "${RED}❌ فشل التثبيت${NC}"
    exit 1
fi

echo ""

# Step 5: Show paths
echo -e "${BLUE}📂 المسارات:${NC}"
echo "    Icons: $ICONS_DIR"
echo "    Config: $WLOGOUT_DIR"
echo ""

# Step 6: Show next steps
echo -e "${YELLOW}📌 الخطوات التالية:${NC}"
echo "    1. فتح wlogout:"
echo "       ${GREEN}wlogout${NC}"
echo ""
echo "    2. أو أضفه لـ Hyprland:"
echo "       ${GREEN}echo 'bind = SUPER, X, exec, wlogout' >> ~/.config/hypr/hyprland.conf${NC}"
echo ""
echo "    3. أعد تحميل Hyprland:"
echo "       ${GREEN}hyprctl reload${NC}"
echo ""

echo -e "${GREEN}✨ تم التثبيت بنجاح!${NC}"
echo ""