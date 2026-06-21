# ADR-0006 — گزارش و نمودار + نرمال‌سازیِ دسته‌ها

- **Status:** Accepted
- **تاریخ:** ۱۴۰۵/۰۳/۳۱
- **حاضرانِ حلقه:** `orchestrator` (جمع‌بندی)، `data-architect`، `ui-ux-designer`، `principal-architect`؛ کیفیت: `test-engineer` + `qa-tester`.
- **DECISION_LOG مرتبط:** مدخلِ #۰۰۶.

---

## Context

دورِ ۲ سه کار دارد: (۱) نرمال‌سازیِ دستهٔ متنی به یک جدولِ `categories`؛ (۲) انتخابگرِ تاریخِ شمسی در فرمِ ثبت (پیش‌تر `occurredAt` همیشه «اکنون» بود)؛ (۳) صفحهٔ گزارش/نمودار با `fl_chart` — تمایزِ اصلیِ «نمودارِ خوب». چالشِ کلیدی: گزارش باید بر **ماهِ شمسی** گروه‌بندی شود، اما `occurredAt` میلادی و SQLite تقویمِ شمسی ندارد.

## Decision

1. **نرمال‌سازیِ دسته‌ها (additive):** جدولِ `Categories(id, name, kind, isArchived, createdAt)` با `UNIQUE(name, kind)`. ستونِ nullable `categoryId` (FK → `categories.id`, `ON DELETE SET NULL`) به `transactions` افزوده شد؛ **ستونِ متنیِ `category` دست‌نخورده** به‌عنوان snapshot/fallback می‌ماند (ADR-0003، فقط-additive). حذفِ دسته فقط با **آرشیو** (soft-delete) تا FK نشکند. `PRAGMA foreign_keys = ON` در `beforeOpen`.

2. **مهاجرتِ `schemaVersion` ۱→۲** فقط-additive و idempotent، در هر دو مسیرِ `onCreate` و `onUpgrade`: ساختِ جدول + افزودنِ ستون + ایندکسِ `(occurred_at, category_id)` + seedِ دسته‌های پیش‌فرض (`insertOrIgnore`) + backfillِ غیرمخربِ `categoryId` از روی متن. روی **کپیِ** DB تست می‌شود.

3. **گروه‌بندیِ ماهِ شمسی با بازهٔ میلادیِ پارامتری (نه `strftime`):** value-objectِ خالصِ `JalaliMonth` مرزِ یک ماهِ شمسی را به دو `DateTime` میلادی (`[start, end)`) تبدیل می‌کند؛ لایهٔ application این بازه را به کوئری می‌دهد. این تنها مرجعِ گروه‌بندیِ زمانی است (ADR-0005).

4. **تجمیع در SQL (DAOِ drift)، نه in-memory:** `SUM(amountRial)` با `GROUP BY categoryId` روی بازهٔ ماه — هم‌خط با rationaleِ ADR-0003 (drift دقیقاً به‌خاطرِ کوئریِ تجمیعیِ گزارش انتخاب شد). نگاشتِ نتیجه به `CategorySlice` در ریپازیتوری؛ SQL در `database.dart` می‌ماند.

5. **UI:** `MainShell` دو-تبه (خانه/گزارش) + FAB؛ انتخابگرِ دسته = `ChoiceChip` فیلترشده بر نوع؛ انتخابگرِ تاریخِ شمسیِ بدونِ‌وابستگی (دیالوگِ سه‌منتخابی با `shamsi_date`)؛ صفحهٔ گزارش = انتخابگرِ ماهِ شمسی + سه کارتِ خلاصه + **نمودارِ دایره‌ایِ تفکیکِ هزینه**.

## Consequences

**مثبت**
- گزارشِ تجمیعیِ درست و ایندکس‌دار؛ نمودارِ دایره‌ای = تمایزِ بصری در برابرِ رقیب.
- مهاجرتِ امنِ بدونِ ازدست‌رفتنِ داده؛ سازگاریِ عقب‌رو با رکوردهای قدیمی (fallbackِ متن).
- مرزِ ماهِ شمسی دقیق (نه تقریبِ میلادی).

**منفی / هزینه**
- نگه‌داریِ هم‌زمانِ `categoryId` (کانونی) و `category` (snapshot) تا حذفِ آیندهٔ ستونِ متنی (خارج از این دامنه).
- وابستگیِ FK نیازمندِ `PRAGMA foreign_keys = ON` در هر اتصال.

## Alternatives Considered

| گزینه | چرا رد شد |
|-------|-----------|
| تجمیعِ in-memory در دامنه | rationaleِ ADR-0003 و «نمودار نباید لگ بزند» را نقض می‌کند؛ تنها در صورتِ کندیِ پروفایل‌شده بازنگری می‌شود. |
| `strftime` برای ماه | ماهِ میلادی می‌دهد نه شمسی — نادرست. |
| `kind` nullable روی categories | قیدِ `UNIQUE(name, kind)` و فیلترِ چیپ را بی‌معنا می‌کند. |
| حذفِ سختِ دسته (CASCADE) | تراکنشِ مالی را پاک می‌کند — خطرناک؛ به‌جایش soft-delete + SET NULL. |
| دو نمودار (پای + روند) از همین حالا | سادگی را قربانی می‌کند؛ نمودارِ روند به دورِ بعد موکول شد. |
