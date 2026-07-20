# 🚪 Logout Images - صور الخروج

مجموعة من الصور الاحترافية لخيارات الخروج والتحكم بالنظام.

## 📦 محتويات المشروع

| الصورة | الحجم | الصيغة | الاستخدام |
|--------|--------|--------|----------|
| 🔒 `lock.png` | 64x64 px | PNG شفاف | قفل الشاشة |
| 📤 `logout.png` | 64x64 px | PNG شفاف | تسجيل الخروج |
| 🔄 `reboot.png` | 64x64 px | PNG شفاف | إعادة التشغيل |
| 🛑 `shutdown.png` | 64x64 px | PNG شفاف | إيقاف التشغيل |
| 😴 `suspend.png` | 64x64 px | PNG شفاف | تعليق النظام |
| 🔇 `hibernate.png` | 64x64 px | PNG شفاف | وضع السبات |

## ✨ المميزات

- ✅ **حجم موحد**: جميع الصور بحجم 64x64 بكسل
- ✅ **خلفية شفافة**: جميع الصور بصيغة PNG مع خلفية شفافة
- ✅ **جودة عالية**: مناسبة للشاشات عالية الدقة (Retina)
- ✅ **متوافق**: يعمل مع جميع المتصفحات والتطبيقات
- ✅ **احترافي**: تصميم حديث وعصري

## 🎨 الاستخدام

### HTML

```html
<img src="logout.png" alt="تسجيل الخروج" width="64" height="64">
```

### CSS

```css
.logout-btn {
    background-image: url('logout.png');
    width: 64px;
    height: 64px;
    background-size: contain;
    background-repeat: no-repeat;
    background-color: transparent;
}
```

### React

```jsx
import logoutIcon from './logout.png';

export const LogoutButton = () => (
    <img src={logoutIcon} alt="logout" style={{ width: 64, height: 64 }} />
);
```

## 📂 العرض المباشر

افتح `index.html` في المتصفح لرؤية المعاينة الحية لجميع الصور.

## 🔧 المواصفات التقنية

- **الحجم**: 64×64 بكسل
- **الصيغة**: PNG (Portable Network Graphics)
- **الشفافية**: كاملة (RGBA)
- **الألوان**: RGB
- **الدقة**: مناسبة للشاشات عالية الدقة

## 📝 الترخيص

جميع الصور متاحة للاستخدام الحر.

---

**تم الإنشاء بواسطة**: Hussin Chahin  
**التاريخ**: 2026