# BizBize 🚀

BizBize, şirket içi etkileşimi, bağlılığı ve ekip içi iletişimi artırmak amacıyla geliştirilmiş modern bir sosyal ağ ve etkileşim platformudur. Bu depo, tüm ekosistemin (Backend, iOS ve Web) bir arada bulunduğu bir monorepo yapısına sahiptir.

---

## 📁 Proje Yapısı

```text
.
├── server/  # Swift Vapor Backend API
├── web/     # Web Arayüzü (Gelecek Planı)
└── ios/     # Swift / SwiftUI iOS Mobil Uygulaması
```

---

## 🛠️ Kullanılan Teknolojiler

### Backend (`server/`)
* **Framework:** Swift Vapor 4
* **Veritabanı:** PostgreSQL (Fluent ORM yardımıyla)
* **Zamanlanmış Görevler:** Async/Await destekli entegre `RepeatedTask`
* **Test:** XCTest ile uçtan uca senaryolar

### Mobile (`ios/`)
* **Arayüz & Dil:** SwiftUI & Swift

---

## 🌟 Öne Çıkan Özellikler ve Çalışma Mantığı

### 👤 1. Kimlik Doğrulama & Oturum Yönetimi
* Şifre korumalı kayıt ve giriş akışı.
* Cihazlar için süresiz oturum token'ları.
* Güvenli çıkış yapıldıktan sonra zorunlu şifre sıfırlama mekanizması.

### 🕵️ 2. Günün Gizemli Çalışanı (Daily Challenge)
* **Otomatik Seçim:** Sistem her gece 00:00'da tüm çalışanlar arasından daha önce seçilmemiş yeni birini gizemli çalışan olarak belirler.
* **Aday Havuzu:** Tüm çalışanlar seçilmeden hiçbir çalışan ikinci kez seçilmez. Havuz tükendiğinde döngü kendini sıfırlar.
* **Dinamik İpuçları:** Sistem, kullanıcının kendi tanımladığı özel ipuçlarını veya eksik kalması halinde sistemin otomatik ürettiği departman, işe başlama yılı, doğum ayı veya harf filtresi gibi yedek ipuçlarını (3 ila 5 adet) 60 dakikalık aralıklarla açar.
* **Tahmin & Puan:** Kullanıcılar 4 seçenekli şıklardan günde sadece bir kez tahminde bulunabilir. Doğru tahmine **+100 puan**, günün ilk doğru tahmine ise **+150 puan** verilir.

### 📊 3. Anketler & Yemek Anketi
* **Günün Yemek Anketi:** Her sabah 09:00'da otomatik yayınlanır, 12:00'de oylamaya kapanır. Katılım **+10 puan** kazandırır.
* **Kullanıcı Anketleri:** Çoklu seçenekli, hedef kitlesi özelleştirilebilir anketler oluşturulabilir.

### 🏆 4. Liderlik Tablosu & Rozet Sistemi
* Haftalık puan durumu her Pazartesi sıfırlanır.
* Genel puan sıralaması kalıcıdır.
* **Rozetler:** 
  * *Kalıcı Rozetler:* Toplam puan barajları aşıldıkça otomatik verilir.
  * *Aylık Rozetler:* Ay boyunca sosyal etkileşim puanı 30 ve üzeri olan kullanıcılara ayın ilk günü `monthlySocial` rozeti verilir.

### 🏠 5. Anasayfa & Çalışan Rehberi (Yeni!)
* **Dashboard Bilgisi:** Aktif anket, görünür duyuru sayısı ve bugün doğum günü olan çalışanların sayısını tek endpoint'te toplar.
* **Rehber:** Tüm çalışanların aranabilir ve departmana göre filtrelenebilir listesidir.

---

## 🚀 Başlangıç

### Backend Çalıştırma

1. **Gereksinimler:**
   * macOS / Linux işletim sistemi
   * Swift 5.9+ compiler
   * Çalışır durumda PostgreSQL veritabanı

2. **Çevre Değişkenleri (Environment Variables):**
   Gerekli veritabanı bağlantı bilgilerini tanımlayın:
   ```bash
   export DATABASE_URL="postgres://username:password@localhost:5432/bizbize_db"
   ```

3. **Veritabanı Migrasyonları ve Çalıştırma:**
   ```bash
   cd server
   swift run App migrate
   swift run App
   ```

4. **Testleri Koşturma:**
   ```bash
   cd server
   swift test
   ```

---

## 📄 API Dokümantasyonu

API endpoints detayları, istek gövdesi ve dönüş tipleri örnekleri için **[server/API.md](file:///Users/batuhanuluturk/Desktop/Hackaton/server/API.md)** dosyasını inceleyebilirsiniz.
