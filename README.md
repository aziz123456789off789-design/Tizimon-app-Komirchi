# Do‘kon

Flutter’da yozilgan, o‘zbek tilidagi do‘kon boshqaruv ilovasi. Telefon uchun pastki navigatsiya, kompyuter uchun yon menyu va alohida savat paneli bor.

## Bo‘limlar

- **Sotuv:** nom/shtrix-kod orqali qidiruv, kategoriya, savat, chegirma, naqd/karta/nasiya, chek va sotuvlar tarixi.
- **Ombor:** mahsulot qo‘shish va tahrirlash, tannarx/sotuv narxi, qoldiq, kirim va kam qoldiq chegarasi.
- **Kassa:** naqd va karta balanslari, kirim-chiqim, barcha pul harakatlari.
- **Mijozlar:** mijoz qo‘shish, qidirish, xarid tarixi, qarz va qisman/to‘liq qarz to‘lovi.

Ilova bo‘sh hisob bilan ochiladi. “Namuna ma’lumotlarini yuklash” tugmasi mahsulotlar va ikkita namuna mijoz qo‘shadi; soxta tushum qo‘shilmaydi.

## Ishga tushirish

Flutter stable va tegishli platforma vositalari kerak. Ushbu loyihada Flutter SDK `.tools/flutter` ichida ham mavjud.

```powershell
.\.tools\flutter\bin\flutter.bat pub get
.\.tools\flutter\bin\flutter.bat run -d chrome --web-port 8080
```

Android SDK, Java va qurilma/emulyator sozlangach:

```powershell
.\.tools\flutter\bin\flutter.bat run -d <android-device-id>
.\build-apk.ps1
```

APK `release/Dokon-1.0.0.apk` fayliga chiqariladi. Android 7.0 (API 24) yoki yangi tizim kerak. APK alohida release kaliti bilan imzolanadi. Kelajakdagi yangilanishlar uchun `.tools/keys/dokon-release.jks` va `android/key.properties` fayllarini xavfsiz saqlang; ular Git’ga kiritilmaydi. Android qurilma/emulyatorida jonli sinov alohida bajarilishi kerak.

Windows uchun Visual Studio’ning “Desktop development with C++” komponenti zarur:

```powershell
.\.tools\flutter\bin\flutter.bat run -d windows
```

## Tekshiruv

```powershell
.\.tools\flutter\bin\flutter.bat analyze
.\.tools\flutter\bin\flutter.bat test
.\.tools\flutter\bin\flutter.bat build web --release
```

## Saqlash va hisoblash

Android/Windows ma’lumotlari ilovaning application-support papkasidagi `dokon.json` faylida saqlanadi. Yangilanish avval vaqtinchalik faylga yoziladi; eski holat `dokon.json.backup` fayliga nusxalanadi. Saqlash muvaffaqiyatsiz bo‘lsa, ekrandagi hisob yangilanmaydi.

Brauzer versiyasi shu brauzer/origin localStorage xotirasidan foydalanadi. Doim bir xil manzil va portda oching; sayt ma’lumotlarini o‘chirish mahalliy hisobni ham o‘chiradi. Bu bir qurilma uchun boshlang‘ich versiya; server sinxronlash, xodimlar loginlari, fiskal chek va printer integratsiyasi hali yo‘q.

Summalar butun so‘mda, mahsulotlar butun donada hisoblanadi. Nasiya savdosi mijoz qarzini oshiradi; kassa faqat pul kelib tushganda o‘zgaradi. Omborga kirim mahsulot sonini oshiradi; xarajat Kassa bo‘limida alohida qayd etiladi. Naqd va karta hisoblarida manfiy balansga yo‘l qo‘yilmaydi. Chekni nusxalash mumkin; u fiskal chek emas.

Saqlash uchun Flutter’ning [path_provider](https://pub.dev/packages/path_provider) va brauzer uchun [web](https://pub.dev/packages/web) paketlaridan foydalaniladi.
