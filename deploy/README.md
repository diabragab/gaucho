# gaucho في المتصفح

اللعبة تشتغل على أندرويد سحابي (redroid) جنب السيرفر، والشاشة تتبث للمتصفح عن طريق ws-scrcpy.
أي حد معاه اللينك وكلمة السر يقدر يلعب من الكمبيوتر أو الموبايل من غير ما ينزّل حاجة.

```
المتصفح ──https──▶ caddy (كلمة سر) ──▶ ws-scrcpy ──adb──▶ redroid (اللعبة)
                                          │                    │ adb reverse
                                          └──── نفس الشبكة ────┴──▶ gaucho server :8020 :5816 :9528
```

## المطلوب

- سيرفر لينكس **ARM64** (الكلاينت arm64 بس). اختيارات كويسة:
  - Oracle Cloud Free Tier، Ampere A1 (لحد 4 أنوية و24 جيجا رام ببلاش)
  - Hetzner CAX21 أو أعلى
- 4 جيجا رام على الأقل (8 أحسن)، و15 جيجا مساحة فاضية (اللعبة بتنزّل حوالي 2 جيجا أول مرة).
- Ubuntu 22.04 أو 24.04.
- ملف `Gaucho.apk` (اللينك في الـ README الرئيسي)، النسخة اللي بتشاور على `127.0.0.1` زي ما هي.

## التشغيل

```bash
git clone https://github.com/diabragab/gaucho && cd gaucho
sudo ./deploy/setup.sh                 # من غير دومين: http على بورت 80
sudo ./deploy/setup.sh play.example.com # بدومين: https تلقائي
./deploy/install-apk.sh Gaucho.apk
```

بعد كده افتح عنوان السيرفر في المتصفح، اكتب اسم المستخدم وكلمة السر، اختار الجهاز `redroid:5555`
واضغط **H264 Converter**. افتح اللعبة من الشاشة واستنى التحميل الأول.

افتح في الفايروول بورت 80 و443 بس. بورتات اللعبة (8020، 5816، 9528) مش محتاجة تتفتح للنت،
لأن اللعبة والسيرفر على نفس الجهاز.

## أوامر مفيدة

```bash
cd deploy
docker compose logs -f gaucho      # لوج السيرفر
docker compose restart redroid     # إعادة تشغيل الأندرويد
docker compose down                # إيقاف كله (الداتا محفوظة في volumes)
CQ2_GM=اسم_الشخصية docker compose up -d   # تفعيل GM
```

## مشاكل معروفة

- **binder مش بيتحمّل**: بعض كيرنلات Oracle المعدلة مفيهاش الموديول. ركّب الكيرنل العادي
  `sudo apt install linux-generic` واعمل ريستارت.
- **اللعبة بطيئة**: redroid بيرسم بالـ CPU. قلل الدقة في `docker-compose.yml`
  (مثلًا 960x540) أو زوّد الأنوية.
- **لاعب واحد في نفس الوقت**: كل نسخة redroid جهاز واحد. عشان أكتر من لاعب، ضيف خدمات redroid تانية
  بأسماء مختلفة (`redroid2`...) وهتظهر في نفس صفحة ws-scrcpy بعد `adb connect`.
