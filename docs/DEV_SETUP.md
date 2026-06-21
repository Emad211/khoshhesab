# راه‌اندازیِ توسعه — خوش‌حساب

> **وضعیت:** ✅ Flutter نصب شد و کد **وارسی شد** — `pub get` + `build_runner` + `flutter analyze` (بدونِ ایراد) + `flutter test` (**۸/۸ سبز**). برای ساختِ APK روی اندروید هنوز به **Android SDK** نیاز است (Java 17 ✅).
>
> ⚠️ **مهم (درسِ آموخته):** Flutter را در مسیرِ **بدونِ فاصله** نصب کن (این پروژه: `C:\Users\Public\flutter`). مسیرِ دارای فاصله مثل `C:\Users\Emad Karimi\flutter` باعثِ شکستِ ساختِ **native-assets** (`sqlite3`) هنگامِ `flutter test`/دسکتاپ می‌شود.

## ۱) نصبِ پیش‌نیازها
- **Flutter SDK** (کانال stable): <https://docs.flutter.dev/get-started/install/windows> — سپس `flutter\bin` را به PATH اضافه کن.
- **Android SDK** (از Android Studio یا cmdline-tools).
- بررسی: `flutter doctor`

## ۲) ساختِ داربستِ پلتفرم (پوشهٔ android/)
الان فقط `lib/`، `pubspec.yaml`، `test/`، `analysis_options.yaml` را داریم. فایل‌های پلتفرم را تولید کن (این کار `lib/` و `pubspec.yaml`ِ موجود را پاک نمی‌کند):

```powershell
cd "C:\Users\Emad Karimi\Desktop\khoshhesab"
flutter create . --platforms=android --project-name khosh_hesab --org ir.khoshhesab
```

## ۳) وابستگی‌ها و تولیدِ کد
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # تولیدِ database.g.dart (drift)
```

## ۴) اجرا، تست، آنالیز
```powershell
flutter run            # روی شبیه‌ساز/دستگاهِ اندروید
flutter test           # تست‌های Money و تاریخِ شمسی
flutter analyze        # بررسیِ لینت/نوع
```

## نکته‌ها
- `test/money_test.dart` و `test/jalali_test.dart` به `build_runner` نیاز ندارند و باید بلافاصله بعد از `pub get` سبز شوند.
- خودِ اپ تا قبل از `build_runner` کامپایل نمی‌شود (به `database.g.dart` وابسته است).
- ساختِ APK برای کافه‌بازار: `flutter build apk --release` (یا `--split-per-abi` برای کاهشِ حجم — ADR-0001).

## نقشهٔ بعدی (دورِ ۲)
نرمال‌سازیِ دسته‌ها (`categories`) · datePickerِ شمسی · صفحهٔ گزارش/نمودار با `fl_chart` · پشتیبان‌گیری/بازیابیِ فایلی. جزئیات در [`ROADMAP.md`](ROADMAP.md).
