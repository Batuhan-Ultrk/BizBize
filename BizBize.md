# Gereksinim Analizi — OfficeLore

> **Hackathon:** GİB Mobil Hackathon 2026
> **Tema:** Corporate Playground & Social Fun
> **Platform:** iOS / Android (Mobil)
> **Versiyon:** v0.1 — MVP
> **Tarih:** Haziran 2026

---

## İçindekiler

1. [Proje Bilgileri](#1-proje-bilgileri)
2. [Problem Tanımı](#2-problem-tanımı)
3. [Kullanıcı Hikayeleri](#3-kullanıcı-hikayeleri)
4. [Kapsam](#4-kapsam)
5. [Fonksiyonel Gereksinimler](#5-fonksiyonel-gereksinimler)
6. [Kabul Kriterleri](#6-kabul-kriterleri)
7. [Ekran / Akış](#7-ekran--akış)
8. [Veri Alanları](#8-veri-alanları)

---

## 1. Proje Bilgileri

| Alan | Bilgi |
|---|---|
| **Proje Adı** | OfficeLore |
| **Takım** | GİB Mobil Ekibi |
| **Hackathon Teması** | Corporate Playground & Social Fun |
| **Platform** | iOS / Android |
| **Proje Tanımı** | Şirket içi iletişimi güçlendiren; oyunlaştırılmış çalışan tanıma sistemi, günlük anketler ve kurumsal duyuruları tek platformda birleştiren sosyal mobil uygulama |

---

## 2. Problem Tanımı

**Problem:** Aynı ekipte çalışan kişiler birbirini yeterince tanıyamamakta, günlük koordinasyon (öğle yemeği, etkinlik organizasyonu vb.) dağınık kanallar üzerinden yürütülmekte ve şirket içi sosyal bağ zayıflamaktadır.

**Hedef Kullanıcı:** Şirketin mobil geliştirme ekibi çalışanları (kapalı, sabit kullanıcı kitlesi).

**Amaç:** Çalışanların birbirini daha iyi tanımasını, günlük sosyal koordinasyonu kolaylaştırmasını ve ofis yaşamını eğlenceli hale getirmesini sağlayan; oyunlaştırma mekanikleriyle (puan, rozet, liderlik tablosu) katılımı artıran bir mobil uygulama geliştirmek.

---

## 3. Kullanıcı Hikayeleri

**H-01 — Günün Gizemli Çalışanı**
Bir çalışan olarak, her gün yayınlanan ipuçlarını takip ederek o günün gizemli çalışanını tahmin etmek istiyorum; çünkü ekip arkadaşlarımı daha iyi tanımak ve eğlenceli bir rekabet ortamında puan kazanmak istiyorum.

**H-02 — Yemek Anketi**
Bir çalışan olarak, her sabah otomatik gelen yemek anketine oy vermek istiyorum; çünkü öğle yemeğini ekiple koordine etmek için her gün ayrıca mesaj atmak zorunda kalmak istemiyorum.

**H-03 — Anket Oluşturma**
Bir çalışan olarak, ekibime hızlıca anket açmak istiyorum; çünkü after-work etkinliği veya ortak karar gerektiren konularda herkesin görüşünü tek bir yerden toplamak istiyorum.

**H-04 — Duyuru Oluşturma**
Bir çalışan olarak, ekip arkadaşlarımı seçerek hedefli duyuru göndermek istiyorum; çünkü herkesi ilgilendirmeyen konularda gereksiz bildirim oluşturmak istemiyorum.

**H-05 — Doğum Günü Bildirimi**
Bir çalışan olarak, ekip arkadaşımın doğum günü geldiğinde otomatik bildirim almak istiyorum; çünkü doğum günlerini takip etmek ve kutlamayı kaçırmamak istiyorum.

**H-06 — Profil Görüntüleme**
Bir çalışan olarak, ekip arkadaşlarımın profil bilgilerini (telefon, doğum tarihi, departman) uygulama üzerinden görmek istiyorum; çünkü iletişim bilgilerini farklı sistemlerde aramak zorunda kalmak istemiyorum.

**H-07 — Sosyallik Rozeti**
Bir çalışan olarak, ay boyunca duyuru ve anketlere aktif katılım gösterdiğimde otomatik olarak Ayın Sosyali rozetini kazanmak istiyorum; çünkü sosyal katkımın tanınmasını istiyorum.

---

## 4. Kapsam

### Dahil

- Kullanıcı kayıt ve oturum yönetimi (süresiz token, logout → şifre sıfırlama zorunluluğu)
- Günün Gizemli Çalışanı — ipuçlu tahmin oyunu
- Günlük otomatik yemek anketi (09:00 açılış / 12:00 kapanış)
- Kullanıcı tarafından oluşturulan anketler (hedef kişi seçimi ile)
- Duyuru akışı — 4 tür (doğum günü, hediye, etkinlik, operasyonel), hedef kişi seçimi ile
- Doğum günü otomasyonu — sahibine kutlama, diğerlerine hatırlatma bildirimi
- Puan sistemi ve haftalık liderlik tablosu
- Kalıcı rozetler: Dedektif, Sosyal Kelebek, Takım Oyuncusu
- Aylık rozet: Ayın Sosyali (eşiği geçen tüm kullanıcılara)
- Ekip dizini — tüm kullanıcıların aranabilir listesi
- Kullanıcı profil sayfası — bilgilerin diğer kullanıcılara görünürlüğü
- Push bildirimleri (iOS ve Android)

### Hariç

- Ayrı admin / HR rolü ve paneli
- Departman bazlı liderlik tablosu
- Çalışan vs. çalışan özel tahmin modu
- Rozet seviyelendirme sistemi (bronz / gümüş / altın)
- Çalışan analizleri ve raporlama dashboard'u
- Uygulama içi chat veya yorum sistemi
- Alan bazlı profil gizlilik ayarları

---

## 5. Fonksiyonel Gereksinimler

### 5.1 Kimlik Doğrulama ve Oturum Yönetimi

- Sistem, kayıt sırasında ad, soyad, doğum tarihi, telefon numarası, e-posta ve şifre alanlarının tamamını zorunlu tutar.
- Sistem, backend kotası dolduğunda yeni kayıt isteğini reddeder ve kullanıcıya hata mesajı gösterir.
- Sistem, başarılı girişte kullanıcıya süresiz token üretir ve cihazda güvenli depolar.
- Uygulama, geçerli token varken açıldığında kullanıcıyı doğrudan ana sayfaya yönlendirir.
- Kullanıcı logout olduğunda sistem token'ı geçersiz kılar ve şifre sıfırlama ekranını açar.
- Sistem, şifre sıfırlama bağlantısını kayıtlı e-posta adresine gönderir.

### 5.2 Günün Gizemli Çalışanı

- Sistem her gün 00:00'da tüm kullanıcılar arasından rastgele bir kişiyi seçer.
- Sistem, tüm kullanıcılar en az bir kez seçilmeden aynı kişiyi tekrar seçmez.
- Sistem seçilen kişinin kimliğini gün içinde gizli tutar.
- Sistem her gün en az 3, en fazla 5 ipucunu sıralı ve belirli aralıklarla (varsayılan 60 dk) yayınlar.
- Kullanıcı, 4 seçenekli listeden günde yalnızca bir kez tahmin gönderebilir.
- Tahmin gönderildikten sonra değiştirilemez.
- Sistem doğru tahmini yapan kullanıcıya +100 puan, günün ilk doğru tahminine +150 puan ekler.
- Sistem gün sonunda gizemli çalışanın kimliğini tüm kullanıcılara açıklar.

### 5.3 Günlük Otomatik Yemek Anketi

- Sistem her gün 09:00'da sabit yemek anketini tüm kullanıcılara otomatik gönderir.
- Anket sorusu ve seçenekleri sabittir: "Bugün öğle yemeği?" — Evden getirdim / Dışarıda yiyeceğim / Ofise yemek isteyelim.
- Sistem anketi 12:00'da otomatik kapatır; bu saatten sonra oy gönderilemez.
- Sonuçlar kapanış sonrasında da tüm kullanıcılara görünür kalır.
- Uygulama yemek anketini feed'de "Günün Yemek Anketi" başlığıyla sabitlenmiş kart olarak gösterir.
- Yemek anketine katılım +10 puan kazandırır.

### 5.4 Kullanıcı Tarafından Oluşturulan Anketler

- Her çalışan soru metni, 2–5 seçenek, opsiyonel süre ve hedef kitle içeren anket oluşturabilir.
- Hedef kitle seçimi "Herkes" veya kullanıcı listesinden checklist ile çoklu seçim şeklinde yapılır.
- Birden fazla soru tek bir akışa zincirleme eklenebilir.
- Sistem yeni anket yayınlandığında hedef kullanıcılara push bildirimi gönderir.
- Oy gönderildikten sonra değiştirilemez; kullanıcı oy sonrasında canlı sonuçları görebilir.
- Sonuçlar gerçek zamanlı güncellenir; süreli anketlerde geri sayım göstergesi görünür.
- Ankete katılım +10 puan kazandırır.

### 5.5 Duyurular

- Her çalışan duyuru oluşturabilir; tür olarak doğum günü, hediye organizasyonu, etkinlik veya operasyonel seçilebilir.
- Duyuru oluşturulurken hedef kitle "Herkes" veya checklist ile seçilen belirli kullanıcılar olarak belirlenir.
- Katılım butonu yalnızca hediye ve etkinlik türlerinde eklenir; kullanıcı "Katıl" veya "Katılma" seçer.
- Katılan kullanıcı listesi duyuruyu oluşturan kişi tarafından görüntülenebilir.
- Etkinliğe katılım +30 puan, duyuru okunması +5 puan kazandırır.
- Sistem her çalışanın doğum tarihini takip eder; ilgili günde 09:00'da doğum günü duyurusu oluşturur ve iki ayrı bildirim gönderir: doğum günü sahibine kutlama, diğer tüm kullanıcılara hatırlatma.

### 5.6 Puan Sistemi

- Sistem aşağıdaki tabloya göre puan ekler; aynı içerik için puan bir kez verilir.

| Eylem | Puan |
|---|---|
| Doğru tahmin | +100 |
| Günün ilk doğru tahmini | +150 |
| Ankete katılma (manuel veya yemek) | +10 |
| Duyuru okuma | +5 |
| Etkinliğe katılma | +30 |

- Puanlar azalmaz; puan geçmişi kullanıcı profilinden görüntülenebilir.
- Liderlik tablosu her Pazartesi 00:00'da sıfırlanır; toplam puan kalıcıdır.

### 5.7 Rozet Sistemi

**Kalıcı Rozetler** — kümülatif eşiğe ulaşıldığında bir kez verilir:

| Rozet | Koşul |
|---|---|
| Dedektif | 10 doğru tahmin |
| Sosyal Kelebek | 20 ankete katılım |
| Takım Oyuncusu | 10 etkinliğe katılım |

**Aylık Rozet — Ayın Sosyali:**

- Sistem her ayın son günü 23:59'da aylık etkileşim puanını hesaplar.
- Etkileşim hesabı: anket oyu +1, anket oluşturma +2, duyuru okuma +1, duyuruya RSVP +2, duyuru oluşturma +2.
- Belirlenen eşiği (varsayılan: 30) aşan tüm kullanıcılar rozeti alır; tek kişiyle sınırlı değildir.
- Rozet kazanıldığı ay damgasıyla profilde görünür; aynı kullanıcı her ay kazanabilir.
- Rozet kazanıldığında push bildirimi ve uygulama içi bildirim gönderilir.

### 5.8 Haftalık Liderlik Tablosu

- İlk 10 kullanıcı haftalık puana göre sıralanır.
- Kullanıcı ilk 10'da olmasa bile kendi sıralamasını tablonun altında görür.

### 5.9 Ekip Dizini ve Profil Görüntüleme

- Uygulama tüm kayıtlı kullanıcıları ad/soyad ile aranabilir ve sıralanabilir dizinde listeler.
- Her kullanıcının profil sayfasında ad-soyad, departman, doğum tarihi, telefon numarası, e-posta, rozetler ve puan özeti diğer tüm kullanıcılara görünürdür.
- Kullanıcı kendi profilinde departman, başlangıç tarihi ve profil fotoğrafını düzenleyebilir.

---

## 6. Kabul Kriterleri

### KK-01 — Kayıt Formu

- **Given** kullanıcı kayıt ekranındadır
- **When** zorunlu alanlardan herhangi birini boş bırakarak kaydet'e basar
- **Then** ilgili alan kırmızı hata mesajıyla işaretlenir ve kayıt tamamlanmaz

---

### KK-02 — Süresiz Token

- **Given** kullanıcı giriş yapmış ve uygulamayı kapatmıştır
- **When** cihazda logout yapmadan uygulamayı yeniden açar
- **Then** giriş ekranı gösterilmez; doğrudan ana sayfaya yönlendirilir

---

### KK-03 — Logout → Şifre Sıfırlama

- **Given** kullanıcı oturum açık haldeyken logout işlemi yapar
- **When** logout tamamlanır
- **Then** token geçersiz kılınır ve şifre sıfırlama ekranı açılır; kullanıcı şifresini sıfırlamadan giriş yapamaz

---

### KK-04 — Günlük Gizemli Çalışan Seçimi

- **Given** gün 00:00'ı geçmiştir
- **When** sistem otomatik çalışır
- **Then** daha önce seçilmemiş bir kullanıcı seçilir; daha önce seçilmiş kullanıcı yoksa tüm liste sıfırlanarak yeni döngü başlar

---

### KK-05 — Tahmin Hakkı

- **Given** kullanıcı bugün zaten tahmin göndermiştir
- **When** tekrar tahmin göndermeye çalışır
- **Then** tahmin butonu pasif görünür ve "Bugünkü tahmininizi kullandınız" mesajı gösterilir

---

### KK-06 — Yemek Anketi Kapanışı

- **Given** saat 12:00'ı geçmiştir
- **When** kullanıcı yemek anketinde oy göndermeye çalışır
- **Then** oy işlemi reddedilir; anket "Kapandı" etiketiyle gösterilir, sonuçlar görünür kalır

---

### KK-07 — Anket Hedef Kitle

- **Given** kullanıcı yeni anket oluştururken belirli kişileri checklist ile seçmiştir
- **When** anketi yayınlar
- **Then** yalnızca seçilen kullanıcılar push bildirimi alır ve anketi feed'inde görür; diğer kullanıcılar göremez

---

### KK-08 — Duyuru Hedef Kitle

- **Given** kullanıcı duyuru oluştururken belirli kişileri checklist ile seçmiştir
- **When** duyuruyu yayınlar
- **Then** yalnızca seçilen kullanıcılar push bildirimi alır ve duyuruyu görür

---

### KK-09 — Doğum Günü Bildirimi

- **Given** sistemde kayıtlı bir kullanıcının doğum tarihi bugündür
- **When** saat 09:00 olur
- **Then** doğum günü sahibi "Bugün senin doğum günün!" içerikli bildirim alır; diğer tüm kullanıcılar "[Ad Soyad]'ın bugün doğum günü!" içerikli bildirim alır

---

### KK-10 — Ayın Sosyali Rozeti

- **Given** ayın son günü 23:59 gelmiştir
- **When** sistem aylık etkileşim hesabını çalıştırır
- **Then** belirlenen eşiği (30 puan) aşan tüm kullanıcıların profiline o aya ait Ayın Sosyali rozeti eklenir; push bildirimi gönderilir; eşiği geçen ikinci bir kullanıcı olması birincinin rozetini etkilemez

---

### KK-11 — Profil Görünürlüğü

- **Given** kullanıcı A, kullanıcı B'nin profil sayfasını açmıştır
- **When** profil sayfası yüklenir
- **Then** kullanıcı B'nin doğum tarihi, telefon numarası, e-posta adresi, departman, rozetler ve puan bilgisi ekranda görünür

---

## 7. Ekran / Akış

### 7.1 Kimlik Doğrulama Akışı

```
Başlangıç: Uygulama açılır
    │
    ├── [Token geçerli] ──────────────────────────► Ana Sayfa
    │
    └── [Token yok / geçersiz]
            │
            ├── Giriş Ekranı
            │       ├── [Başarılı] ──────────────► Ana Sayfa
            │       └── [Logout sonrası] ────────► Şifre Sıfırlama Ekranı
            │                                           └── [E-posta gönderildi] ► Giriş Ekranı
            └── Kayıt Ekranı
                    └── [Tüm alanlar geçerli] ───► Ana Sayfa
```

### 7.2 Günün Gizemli Çalışanı Akışı

```
Başlangıç: Ana Sayfa — Gizemli Çalışan Kartı
    │
    ├── İpuçları Listesi
    │       ├── Açık ipuçları görünür
    │       └── Kilitli ipuçları gri gösterilir (zaman sayacı ile)
    │
    ├── Tahmin Ekranı
    │       ├── [Tahmin yapılmamış] → 4 seçenekli liste → Onayla
    │       │       ├── [Doğru] → Tebrik ekranı + puan bildirimi
    │       │       └── [Yanlış] → Sonuç ekranı
    │       └── [Tahmin yapılmış] → Salt okunur durum mesajı
    │
    └── Kimlik Açıklanma Ekranı (gün sonu)
            └── Çalışanın adı, fotoğrafı ve günlük özet kartı
```

### 7.3 Yemek Anketi Akışı

```
Başlangıç: Ana Sayfa — Günün Yemek Anketi Kartı (sabitlenmiş)
    │
    ├── [Saat < 12:00 ve oy kullanılmamış]
    │       └── 3 seçenek → Oy Gönder → Canlı Sonuç Ekranı
    │
    ├── [Saat < 12:00 ve oy kullanılmış]
    │       └── Salt okunur — Canlı sonuçlar gösterilir
    │
    └── [Saat ≥ 12:00]
            └── "Kapandı" etiketi — Nihai sonuçlar gösterilir
```

### 7.4 Anket Oluşturma Akışı

```
Başlangıç: Anketler sekmesi → Yeni Anket butonu
    │
    ├── Soru metni girişi
    ├── Seçenek ekleme (min 2 / maks 5)
    ├── Süre belirleme (opsiyonel)
    ├── Hedef kitle seçimi
    │       ├── Herkes
    │       └── Kullanıcı listesi (checklist — çoklu seçim)
    │
    └── Yayınla → Push bildirimi gönderilir → Anket feed'de aktif
```

### 7.5 Duyuru Oluşturma Akışı

```
Başlangıç: Duyurular sekmesi → Yeni Duyuru butonu
    │
    ├── Tür seçimi (doğum günü / hediye / etkinlik / operasyonel)
    ├── Başlık ve açıklama girişi
    ├── Tarih/saat (opsiyonel)
    ├── Katılım butonu (hediye ve etkinlik türünde opsiyonel)
    ├── Hedef kitle seçimi
    │       ├── Herkes
    │       └── Kullanıcı listesi (checklist — çoklu seçim)
    │
    └── Yayınla → Push bildirimi gönderilir → Duyuru feed'de aktif
```

### 7.6 Ana Ekranlar Özeti

```
Bottom Navigation
    ├── Ana Sayfa (Feed)
    │       ├── Günün Yemek Anketi kartı (sabitlenmiş, üstte)
    │       ├── Günün Gizemli Çalışanı kartı
    │       ├── Aktif anketler
    │       └── Son duyurular
    │
    ├── Anketler
    │       ├── Aktif anketler listesi
    │       ├── Arşiv
    │       └── Yeni Anket butonu
    │
    ├── Duyurular
    │       ├── Akış listesi (tür bazlı filtreleme)
    │       └── Yeni Duyuru butonu
    │
    ├── Liderlik
    │       ├── Haftalık sıralama (ilk 10)
    │       └── Kendi sıram göstergesi
    │
    └── Profil / Ekip
            ├── Kendi Profil Sayfası
            │       ├── Rozetler ve puan özeti
            │       ├── Puan geçmişi
            │       └── Düzenlenebilir alanlar
            └── Ekip Dizini
                    ├── Aranabilir kullanıcı listesi
                    └── Kullanıcı Profil Detay Ekranı
                            ├── Ad, soyad, departman, fotoğraf
                            ├── Doğum tarihi, telefon, e-posta
                            └── Rozetler ve puan özeti
```

---

## 8. Veri Alanları

### 8.1 User (Kullanıcı)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| firstName | String | Zorunlu | Kullanıcı (kayıt) |
| lastName | String | Zorunlu | Kullanıcı (kayıt) |
| birthDate | Date (GG/AA/YYYY) | Zorunlu | Kullanıcı (kayıt) |
| phoneNumber | String | Zorunlu | Kullanıcı (kayıt) |
| email | String (eşsiz) | Zorunlu | Kullanıcı (kayıt) |
| passwordHash | String | Zorunlu | Sistem |
| authToken | String | Zorunlu | Sistem (giriş sonrası) |
| department | String | Opsiyonel | Kullanıcı (profil) |
| startDate | Date | Opsiyonel | Kullanıcı (profil) |
| profilePhoto | URL | Opsiyonel | Kullanıcı (profil) |
| hints | Hint[] | Opsiyonel | Kullanıcı (profil) |
| createdAt | DateTime | Zorunlu | Sistem |

### 8.2 Hint (İpucu)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| userId | UUID | Zorunlu | Sistem |
| type | Enum (seniority / department / habit / yesno) | Zorunlu | Kullanıcı |
| text | String | Zorunlu | Kullanıcı |
| revealOrder | Integer | Zorunlu | Kullanıcı |

### 8.3 DailyChallenge (Günlük Tahmin)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| date | Date | Zorunlu | Sistem |
| selectedUserId | UUID | Zorunlu | Sistem (rastgele seçim) |
| revealedAt | DateTime | Zorunlu | Sistem |

### 8.4 Guess (Tahmin)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| challengeId | UUID | Zorunlu | Sistem |
| userId | UUID | Zorunlu | Sistem |
| guessedUserId | UUID | Zorunlu | Kullanıcı |
| isCorrect | Boolean | Zorunlu | Sistem |
| isFirstCorrect | Boolean | Zorunlu | Sistem |
| timestamp | DateTime | Zorunlu | Sistem |

### 8.5 Poll (Anket)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| createdByUserId | UUID | Zorunlu | Sistem |
| question | String | Zorunlu | Kullanıcı |
| options | PollOption[] | Zorunlu (min 2, maks 5) | Kullanıcı |
| expiresAt | DateTime | Opsiyonel | Kullanıcı |
| targetUserIds | UUID[] | Opsiyonel | Kullanıcı (boş = herkes) |
| createdAt | DateTime | Zorunlu | Sistem |

### 8.6 PollOption (Anket Seçeneği)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| pollId | UUID | Zorunlu | Sistem |
| text | String | Zorunlu | Kullanıcı |
| voteCount | Integer | Zorunlu | Sistem |

### 8.7 DailyLunchPoll (Yemek Anketi)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| date | Date | Zorunlu | Sistem |
| closesAt | DateTime (12:00) | Zorunlu | Sistem |

### 8.8 LunchVote (Yemek Anketi Oyu)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| pollId | UUID | Zorunlu | Sistem |
| userId | UUID | Zorunlu | Sistem |
| option | Enum (home / outside / order) | Zorunlu | Kullanıcı |
| timestamp | DateTime | Zorunlu | Sistem |

### 8.9 Announcement (Duyuru)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| createdByUserId | UUID | Zorunlu | Sistem |
| type | Enum (birthday / gift / event / operational) | Zorunlu | Kullanıcı / Sistem |
| title | String | Zorunlu | Kullanıcı / Sistem |
| body | String | Zorunlu | Kullanıcı / Sistem |
| eventDate | DateTime | Opsiyonel | Kullanıcı |
| hasRsvp | Boolean | Zorunlu | Kullanıcı |
| targetUserIds | UUID[] | Opsiyonel | Kullanıcı (boş = herkes) |
| attendees | UUID[] | Zorunlu | Sistem |
| createdAt | DateTime | Zorunlu | Sistem |

### 8.10 UserScore (Puan ve Rozet)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| userId | UUID | Zorunlu | Sistem |
| weeklyPoints | Integer | Zorunlu | Sistem |
| totalPoints | Integer | Zorunlu | Sistem |
| monthlyEngagementScore | Integer | Zorunlu | Sistem (ay sonu sıfırlanır) |
| badges | Badge[] | Zorunlu | Sistem |
| scoreHistory | ScoreEvent[] | Zorunlu | Sistem |

### 8.11 Badge (Rozet)

| Alan Adı | Tip | Zorunluluk | Kaynak |
|---|---|---|---|
| id | UUID | Zorunlu | Sistem |
| userId | UUID | Zorunlu | Sistem |
| type | Enum (detective / social_butterfly / team_player / monthly_social) | Zorunlu | Sistem |
| earnedAt | DateTime | Zorunlu | Sistem |
| periodLabel | String | Opsiyonel | Sistem (yalnızca monthly_social — örn. "Mayıs 2026") |
