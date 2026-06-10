# BizBize API Servis Dokümantasyonu

Bu doküman mevcut backend servislerinin ne işe yaradığını, URL bilgisini, request örneğini ve response örneğini içerir.

## Genel Bilgiler

- Base URL lokal: `http://127.0.0.1:8080`
- Base URL ağ/tunnel: kendi IP veya Cloudflare Tunnel adresin
- JSON header: `Content-Type: application/json`
- Korumalı servislerde auth header:

```http
Authorization: Bearer <token>
```

Tarih alanları ISO-8601 formatındadır:

```text
2026-06-12T15:30:00Z
```

## Auth Servisleri

### Register

Yeni kullanıcı oluşturur ve kullanıcı için tek aktif auth token döner.

```http
POST /auth/register
Content-Type: application/json
```

Request:

```json
{
  "firstName": "Ali",
  "lastName": "Veli",
  "birthDate": "1998-01-01T00:00:00Z",
  "phoneNumber": "5551112233",
  "email": "ali.veli@example.com",
  "password": "12345678"
}
```

Response `200 OK`:

```json
{
  "token": "AUTH_TOKEN",
  "user": {
    "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "firstName": "Ali",
    "lastName": "Veli",
    "birthDate": "1998-01-01T00:00:00Z",
    "phoneNumber": "5551112233",
    "email": "ali.veli@example.com",
    "department": null,
    "startDate": null,
    "profilePhoto": null,
    "createdAt": "2026-06-10T11:00:00Z"
  }
}
```

Notlar:

- `email` tekildir.
- `password` minimum 8 karakter olmalıdır.
- `MAX_REGISTERED_USERS` tanımlıysa kota dolduğunda kayıt reddedilir.

### Login

Kullanıcı girişi yapar ve tek aktif auth token döner. Aynı kullanıcı tekrar login olursa eski tokenları silinir.

```http
POST /auth/login
Content-Type: application/json
```

Request:

```json
{
  "email": "ali.veli@example.com",
  "password": "12345678"
}
```

Response `200 OK`:

```json
{
  "token": "AUTH_TOKEN",
  "user": {
    "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "firstName": "Ali",
    "lastName": "Veli",
    "birthDate": "1998-01-01T00:00:00Z",
    "phoneNumber": "5551112233",
    "email": "ali.veli@example.com",
    "department": null,
    "startDate": null,
    "profilePhoto": null,
    "createdAt": "2026-06-10T11:00:00Z"
  }
}
```

Hatalar:

- `401 Unauthorized`: e-posta veya şifre hatalı.
- `403 Forbidden`: logout sonrası şifre sıfırlama zorunlu.

### Me

Token sahibi kullanıcının profil bilgisini döner.

```http
GET /auth/me
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
{
  "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "firstName": "Ali",
  "lastName": "Veli",
  "birthDate": "1998-01-01T00:00:00Z",
  "phoneNumber": "5551112233",
  "email": "ali.veli@example.com",
  "department": null,
  "startDate": null,
  "profilePhoto": null,
  "createdAt": "2026-06-10T11:00:00Z"
}
```

### Logout

Kullanıcının aktif tokenını siler ve kullanıcıyı şifre sıfırlama zorunlu durumuna alır.

```http
POST /auth/logout
Authorization: Bearer <token>
```

Request body yoktur.

Response:

```http
204 No Content
```

### Password Reset Request

Şifre sıfırlama tokenı oluşturur. Mail gönderimi yoktur.

```http
POST /auth/password-reset
Content-Type: application/json
```

Request:

```json
{
  "email": "ali.veli@example.com"
}
```

Response `200 OK`:

```json
{
  "message": "Şifre sıfırlama isteği işlendi."
}
```

Notlar:

- Kullanıcı bulunmasa da aynı response döner.
- Reset token 10 dakika geçerlidir.

### Password Reset Confirm

Reset token ile yeni şifre belirler ve logout sonrası login engelini kaldırır.

```http
POST /auth/password-reset/confirm
Content-Type: application/json
```

Request:

```json
{
  "token": "RESET_TOKEN",
  "newPassword": "newPassword123"
}
```

Response:

```http
204 No Content
```

Hatalar:

- `404 Not Found`: token bulunamadı.
- `410 Gone`: token süresi doldu.

## Duyuru Servisleri

Duyuru servislerinin tamamı bearer token gerektirir.

Geçerli duyuru türleri:

```text
birthday
gift
event
operational
```

Geçerli RSVP durumları:

```text
attending
notAttending
```

### Duyuru Oluşturma

Duyuru oluşturur. `targetUserIds` boş veya eksikse herkes görür. Doluysa yalnızca hedef kullanıcılar ve oluşturan kişi görür.

```http
POST /announcements
Authorization: Bearer <token>
Content-Type: application/json
```

Request:

```json
{
  "type": "event",
  "title": "After-work buluşması",
  "body": "Cuma 18:30'da çıkış sonrası kahve.",
  "eventDate": "2026-06-12T15:30:00Z",
  "hasRsvp": true,
  "targetUserIds": []
}
```

Hedefli duyuru request örneği:

```json
{
  "type": "operational",
  "title": "Sprint planlama",
  "body": "Mobil ekip sprint planlama toplantısı 10:00'da.",
  "eventDate": "2026-06-13T07:00:00Z",
  "hasRsvp": false,
  "targetUserIds": [
    "11111111-1111-1111-1111-111111111111",
    "22222222-2222-2222-2222-222222222222"
  ]
}
```

Response `200 OK`:

```json
{
  "id": "A2D4BA8B-45D5-4D87-A8F4-EB87F8326B22",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "event",
  "title": "After-work buluşması",
  "body": "Cuma 18:30'da çıkış sonrası kahve.",
  "eventDate": "2026-06-12T15:30:00Z",
  "hasRsvp": true,
  "targetUserIds": [],
  "attendees": [],
  "myRsvpStatus": null,
  "createdAt": "2026-06-10T11:10:00Z"
}
```

Notlar:

- `title` boş olamaz ve en fazla 140 karakterdir.
- `body` boş olamaz.
- `hasRsvp` yalnızca `gift` ve `event` türlerinde `true` olabilir.
- `hasRsvp` verilmezse `gift` ve `event` için otomatik `true`, diğerleri için `false` kabul edilir.

### Duyuru Listeleme

Token sahibi kullanıcının görebileceği duyuruları yeniden eskiye listeler.

```http
GET /announcements
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
[
  {
    "id": "A2D4BA8B-45D5-4D87-A8F4-EB87F8326B22",
    "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "type": "event",
    "title": "After-work buluşması",
    "body": "Cuma 18:30'da çıkış sonrası kahve.",
    "eventDate": "2026-06-12T15:30:00Z",
    "hasRsvp": true,
    "targetUserIds": [],
    "attendees": [
      "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5"
    ],
    "myRsvpStatus": "attending",
    "createdAt": "2026-06-10T11:10:00Z"
  }
]
```

Not:

- `attendees` sadece duyuruyu oluşturan kullanıcıya dolu döner. Diğer kullanıcılara boş array döner.

### Duyuru Listeleme - Türe Göre Filtre

Belirli türdeki görünür duyuruları listeler.

```http
GET /announcements?type=event
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
[
  {
    "id": "A2D4BA8B-45D5-4D87-A8F4-EB87F8326B22",
    "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "type": "event",
    "title": "After-work buluşması",
    "body": "Cuma 18:30'da çıkış sonrası kahve.",
    "eventDate": "2026-06-12T15:30:00Z",
    "hasRsvp": true,
    "targetUserIds": [],
    "attendees": [],
    "myRsvpStatus": null,
    "createdAt": "2026-06-10T11:10:00Z"
  }
]
```

### Duyuru Detay

Görünür bir duyurunun detayını döner.

```http
GET /announcements/:announcementId
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
{
  "id": "A2D4BA8B-45D5-4D87-A8F4-EB87F8326B22",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "event",
  "title": "After-work buluşması",
  "body": "Cuma 18:30'da çıkış sonrası kahve.",
  "eventDate": "2026-06-12T15:30:00Z",
  "hasRsvp": true,
  "targetUserIds": [],
  "attendees": [],
  "myRsvpStatus": null,
  "createdAt": "2026-06-10T11:10:00Z"
}
```

Hatalar:

- `404 Not Found`: duyuru yok veya kullanıcı bu duyuruyu görmeye yetkili değil.

### Duyuru RSVP

Kullanıcının duyuruya katılım durumunu oluşturur veya günceller.

```http
POST /announcements/:announcementId/rsvp
Authorization: Bearer <token>
Content-Type: application/json
```

Request:

```json
{
  "status": "attending"
}
```

Katılmama request örneği:

```json
{
  "status": "notAttending"
}
```

Response `200 OK`:

```json
{
  "id": "A2D4BA8B-45D5-4D87-A8F4-EB87F8326B22",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "event",
  "title": "After-work buluşması",
  "body": "Cuma 18:30'da çıkış sonrası kahve.",
  "eventDate": "2026-06-12T15:30:00Z",
  "hasRsvp": true,
  "targetUserIds": [],
  "attendees": [],
  "myRsvpStatus": "attending",
  "createdAt": "2026-06-10T11:10:00Z"
}
```

Hatalar:

- `400 Bad Request`: duyuruda RSVP özelliği yok.
- `404 Not Found`: duyuru yok veya kullanıcı bu duyuruyu görmeye yetkili değil.

## Standart Hata Formatı

Vapor hataları genel olarak şu formatta döner:

```json
{
  "error": true,
  "reason": "Hata açıklaması"
}
```

## Anket Servisleri

Anket servislerinin tamamı bearer token gerektirir.

Geçerli anket türleri:

```text
manual
dailyLunch
```

Günlük yemek anketi seçenekleri:

```text
home
outside
order
```

### Manuel Anket Oluşturma

Kullanıcı tarafından manuel anket oluşturur. `targetUserIds` boş veya eksikse herkes görür.

```http
POST /polls
Authorization: Bearer <token>
Content-Type: application/json
```

Request:

```json
{
  "question": "Cuma after-work için nereyi seçelim?",
  "options": [
    "Kahve",
    "Yemek",
    "Bowling"
  ],
  "expiresAt": "2026-06-12T18:00:00Z",
  "targetUserIds": []
}
```

Response `200 OK`:

```json
{
  "id": "52A7475E-D185-4B4F-BB53-0F51B3DFA0A1",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "manual",
  "question": "Cuma after-work için nereyi seçelim?",
  "options": [
    {
      "id": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
      "text": "Kahve",
      "key": null,
      "displayOrder": 0,
      "voteCount": 0
    },
    {
      "id": "0F49A1A1-65FD-4E9F-97CC-86D2C5025786",
      "text": "Yemek",
      "key": null,
      "displayOrder": 1,
      "voteCount": 0
    }
  ],
  "expiresAt": "2026-06-12T18:00:00Z",
  "targetUserIds": [],
  "dayKey": null,
  "isClosed": false,
  "myVoteOptionId": null,
  "createdAt": "2026-06-10T11:20:00Z"
}
```

Notlar:

- `question` boş olamaz.
- `options` en az 2, en fazla 5 eleman içermelidir.
- Seçenekler boş veya tekrarlı olamaz.

### Anket Listeleme

Token sahibi kullanıcının görebileceği anketleri listeler. Bu endpoint çağrıldığında saat 09:00 sonrasıysa günün yemek anketi eksikse oluşturulur.

```http
GET /polls
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
[
  {
    "id": "52A7475E-D185-4B4F-BB53-0F51B3DFA0A1",
    "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "type": "manual",
    "question": "Cuma after-work için nereyi seçelim?",
    "options": [
      {
        "id": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
        "text": "Kahve",
        "key": null,
        "displayOrder": 0,
        "voteCount": 1
      }
    ],
    "expiresAt": "2026-06-12T18:00:00Z",
    "targetUserIds": [],
    "dayKey": null,
    "isClosed": false,
    "myVoteOptionId": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
    "createdAt": "2026-06-10T11:20:00Z"
  }
]
```

### Anket Listeleme - Türe Göre Filtre

Belirli türdeki görünür anketleri listeler.

```http
GET /polls?type=dailyLunch
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
[
  {
    "id": "C6D88359-34E1-4B42-B57D-83DBCA827785",
    "createdByUserId": null,
    "type": "dailyLunch",
    "question": "Bugün öğle yemeği?",
    "options": [
      {
        "id": "B7338C89-C38C-4484-A9A7-3A21EAA92217",
        "text": "Evden getirdim",
        "key": "home",
        "displayOrder": 0,
        "voteCount": 0
      }
    ],
    "expiresAt": "2026-06-10T09:00:00Z",
    "targetUserIds": [],
    "dayKey": "2026-06-10",
    "isClosed": false,
    "myVoteOptionId": null,
    "createdAt": "2026-06-10T06:00:00Z"
  }
]
```

### Anket Detay

Görünür bir anketin detayını döner.

```http
GET /polls/:pollId
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
{
  "id": "52A7475E-D185-4B4F-BB53-0F51B3DFA0A1",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "manual",
  "question": "Cuma after-work için nereyi seçelim?",
  "options": [
    {
      "id": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
      "text": "Kahve",
      "key": null,
      "displayOrder": 0,
      "voteCount": 1
    }
  ],
  "expiresAt": "2026-06-12T18:00:00Z",
  "targetUserIds": [],
  "dayKey": null,
  "isClosed": false,
  "myVoteOptionId": null,
  "createdAt": "2026-06-10T11:20:00Z"
}
```

Hatalar:

- `404 Not Found`: anket yok veya kullanıcı bu anketi görmeye yetkili değil.

### Ankete Oy Verme

Kullanıcının ankete bir kez oy vermesini sağlar.

```http
POST /polls/:pollId/vote
Authorization: Bearer <token>
Content-Type: application/json
```

Request:

```json
{
  "optionId": "4DC95120-0858-427B-A976-CBE5A7A5EE73"
}
```

Response `200 OK`:

```json
{
  "id": "52A7475E-D185-4B4F-BB53-0F51B3DFA0A1",
  "createdByUserId": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
  "type": "manual",
  "question": "Cuma after-work için nereyi seçelim?",
  "options": [
    {
      "id": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
      "text": "Kahve",
      "key": null,
      "displayOrder": 0,
      "voteCount": 1
    }
  ],
  "expiresAt": "2026-06-12T18:00:00Z",
  "targetUserIds": [],
  "dayKey": null,
  "isClosed": false,
  "myVoteOptionId": "4DC95120-0858-427B-A976-CBE5A7A5EE73",
  "createdAt": "2026-06-10T11:20:00Z"
}
```

Hatalar:

- `400 Bad Request`: anket kapalı veya seçenek geçersiz.
- `409 Conflict`: kullanıcı bu ankete daha önce oy verdi.

### Günlük Yemek Anketi Detay

Günün yemek anketini döner. Saat 09:00 sonrası çağrılırsa ve anket yoksa otomatik oluşturulur. 09:00 öncesi anket henüz açılmaz.

```http
GET /polls/daily-lunch
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
{
  "id": "C6D88359-34E1-4B42-B57D-83DBCA827785",
  "createdByUserId": null,
  "type": "dailyLunch",
  "question": "Bugün öğle yemeği?",
  "options": [
    {
      "id": "B7338C89-C38C-4484-A9A7-3A21EAA92217",
      "text": "Evden getirdim",
      "key": "home",
      "displayOrder": 0,
      "voteCount": 0
    },
    {
      "id": "4F3F8DC9-4D73-42A5-83EB-68B9EC62F58D",
      "text": "Dışarıda yiyeceğim",
      "key": "outside",
      "displayOrder": 1,
      "voteCount": 0
    },
    {
      "id": "477E178D-8FBA-49CA-9B86-E9CA14E39AA7",
      "text": "Ofise yemek isteyelim",
      "key": "order",
      "displayOrder": 2,
      "voteCount": 0
    }
  ],
  "expiresAt": "2026-06-10T09:00:00Z",
  "targetUserIds": [],
  "dayKey": "2026-06-10",
  "isClosed": false,
  "myVoteOptionId": null,
  "createdAt": "2026-06-10T06:00:00Z"
}
```

Hatalar:

- `404 Not Found`: günlük yemek anketi henüz açılmadı.

### Günlük Yemek Anketine Oy Verme

Günün yemek anketine sabit seçeneklerden biriyle oy verir.

```http
POST /polls/daily-lunch/vote
Authorization: Bearer <token>
Content-Type: application/json
```

Request:

```json
{
  "option": "home"
}
```

Diğer seçenekler:

```json
{
  "option": "outside"
}
```

```json
{
  "option": "order"
}
```

Response `200 OK`:

```json
{
  "id": "C6D88359-34E1-4B42-B57D-83DBCA827785",
  "createdByUserId": null,
  "type": "dailyLunch",
  "question": "Bugün öğle yemeği?",
  "options": [
    {
      "id": "B7338C89-C38C-4484-A9A7-3A21EAA92217",
      "text": "Evden getirdim",
      "key": "home",
      "displayOrder": 0,
      "voteCount": 1
    }
  ],
  "expiresAt": "2026-06-10T09:00:00Z",
  "targetUserIds": [],
  "dayKey": "2026-06-10",
  "isClosed": false,
  "myVoteOptionId": "B7338C89-C38C-4484-A9A7-3A21EAA92217",
  "createdAt": "2026-06-10T06:00:00Z"
}
```

Hatalar:

- `400 Bad Request`: anket kapalı.
- `404 Not Found`: günlük yemek anketi henüz açılmadı veya seçenek bulunamadı.
- `409 Conflict`: kullanıcı bu ankete daha önce oy verdi.

## Gizemli Çalışan Servisleri

### Daily Challenge (Gizemli Çalışan) Endpoints

- **GET `/challenges`** – Günün gizemli çalışanını ve mevcut aday havuzunu listeler.
  ```http
  GET /challenges
  Authorization: Bearer <token>
  ```
  **Response (`200 OK`)**
  ```json
  {
    "id": "<challenge-id>",
    "question": "Gizemli çalışan kim?",
    "options": ["Ali", "Ayşe", "Mehmet"],
    "hintCount": 2,
    "expiresAt": "2026-06-12T23:59:59Z"
  }
  ```

- **GET `/challenges/{id}`** – Belirli bir challenge detayını döner.
- **POST `/challenges/{id}/guess`** – Tahmin gönderir, puan kazandırır.
  ```http
  POST /challenges/{id}/guess
  Authorization: Bearer <token>
  Content-Type: application/json
  ```
  ```json
  {
    "guess": "Ayşe"
  }
  ```
  **Response (`200 OK`)**
  ```json
  {
    "correct": true,
    "earnedPoints": 10,
    "badgeAwarded": "gizemli-employee"
  }
  ```
- **POST `/challenges/{id}/hint`** – İpucu talep eder, puan harcar.

## Liderlik Tablosu Servisi

- **GET `/leaderboard`** – Kullanıcıların puan ve rozet sıralamasını döner.
  ```http
  GET /leaderboard
  Authorization: Bearer <token>
  ```
  **Response (`200 OK`)**
  ```json
  [
    {"rank":1,"userId":"...","score":150,"badges":["gizemli-employee"]},
    {"rank":2,"userId":"...","score":120,"badges":[]}
  ]
  ```

## Kullanıcı Profili Servisi

- **GET `/users/{id}`** – Kullanıcı profil bilgilerini getirir.
  ```http
  GET /users/{id}
  Authorization: Bearer <token>
  ```
  **Response (`200 OK`)**
  ```json
  {
    "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "firstName": "Ali",
    "lastName": "Veli",
    "birthDate": "1998-01-01T00:00:00Z",
    "phoneNumber": "5551112233",
    "email": "ali.veli@example.com",
    "department": "Mühendislik",
    "startDate": "2024-01-01T00:00:00Z",
    "profilePhoto": "https://example.com/photo.jpg",
    "createdAt": "2026-06-10T11:00:00Z",
    "weeklyPoints": 150,
    "totalPoints": 450,
    "badges": [],
    "scoreHistory": [],
    "hints": []
  }
  ```

- **PATCH `/auth/me`** – Oturum açmış kullanıcının kendi profil bilgilerini (departman, işe başlama tarihi, profil fotoğrafı) günceller.
  ```http
  PATCH /auth/me
  Authorization: Bearer <token>
  Content-Type: application/json
  ```
  Request Body:
  ```json
  {
    "department": "Mühendislik",
    "startDate": "2024-01-01T00:00:00Z",
    "profilePhoto": "https://example.com/photo.jpg"
  }
  ```
  **Response (`200 OK`)**
  ```json
  {
    "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "firstName": "Ali",
    "lastName": "Veli",
    "birthDate": "1998-01-01T00:00:00Z",
    "phoneNumber": "5551112233",
    "email": "ali.veli@example.com",
    "department": "Mühendislik",
    "startDate": "2024-01-01T00:00:00Z",
    "profilePhoto": "https://example.com/photo.jpg",
    "createdAt": "2026-06-10T11:00:00Z"
  }
  ```

- **POST `/auth/me/hints`** – Kullanıcının kendisi hakkında 3 ila 5 adet ipucunu/sorusunu kaydetmesini sağlar.
  ```http
  POST /auth/me/hints
  Authorization: Bearer <token>
  Content-Type: application/json
  ```
  Request Body:
  ```json
  {
    "hints": [
      {
        "type": "habit",
        "text": "Her gün en az 3 fincan filtre kahve içerim.",
        "revealOrder": 1
      },
      {
        "type": "seniority",
        "text": "Şirketteki en eski 5 yazılımcıdan biriyim.",
        "revealOrder": 2
      },
      {
        "type": "yesno",
        "text": "Kedi sahibiyim.",
        "revealOrder": 3
      }
    ]
  }
  ```
  **Response (`204 No Content`)**


## Rozet Servisi

- **GET `/badges`** – Sistemdeki tüm rozetleri listeler.
- **GET `/badges/{id}`** – Rozet detayını verir.

## Puan Servisi

- **GET `/scores/{userId}`** – Kullanıcının toplam puanını ve puan hareket geçmişini döner.
  ```http
  GET /scores/{userId}
  Authorization: Bearer <token>
  ```
  **Response (`200 OK`)**
  ```json
  {
    "totalScore": 150,
    "events": [
      {"source":"poll","points":5,"date":"2026-06-10T12:00:00Z"},
      {"source":"challenge","points":10,"date":"2026-06-11T09:30:00Z"}
    ]
  }
  ```

## Anasayfa Servisleri

Anasayfa servislerinin tamamı bearer token gerektirir.

### Anasayfa Bilgi Getir (Dashboard)

Anasayfa için özet bilgileri döner: bugün doğum günü olan çalışan sayısı, aktif anket sayısı ve görünür duyuru sayısı.

```http
GET /home/dashboard
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
{
  "birthdayCount": 2,
  "activePollCount": 3,
  "announcementCount": 5,
  "upcomingBirthdays": [
    {
      "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
      "firstName": "Ali",
      "lastName": "Veli",
      "birthDate": "1998-06-10T00:00:00Z",
      "profilePhoto": null
    }
  ]
}
```

Notlar:

- `birthdayCount`: Bugün doğum günü olan kullanıcı sayısı (ay ve gün eşleşmesi).
- `activePollCount`: Süresi dolmamış ve token sahibi kullanıcının görebildiği anket sayısı.
- `announcementCount`: Token sahibi kullanıcının görebildiği toplam duyuru sayısı.
- `upcomingBirthdays`: Bugün doğum günü olan kullanıcıların listesi.

## Çalışan Rehberi Servisi

### Çalışan Listeleme

Tüm çalışanları ada göre sıralı listeler. İsim, soyisim, e-posta ile arama ve departman filtresi destekler.

```http
GET /home/employees
Authorization: Bearer <token>
```

Filtre parametreleri (query string):

| Parametre    | Tip    | Açıklama                                      |
|-------------|--------|-----------------------------------------------|
| `search`    | String | İsim, soyisim veya e-posta içinde arama yapar |
| `department`| String | Departmana göre filtreler                      |

Örnek filtreli istek:

```http
GET /home/employees?search=Ali&department=Mühendislik
Authorization: Bearer <token>
```

Request body yoktur.

Response `200 OK`:

```json
[
  {
    "id": "1F8469B1-A45D-4E88-B3B0-6D85BB4754F5",
    "firstName": "Ali",
    "lastName": "Veli",
    "email": "ali.veli@example.com",
    "department": "Mühendislik",
    "profilePhoto": null,
    "birthDate": "1998-01-01T00:00:00Z"
  },
  {
    "id": "2A3B4C5D-6E7F-8A9B-0C1D-2E3F4A5B6C7D",
    "firstName": "Ayşe",
    "lastName": "Yılmaz",
    "email": "ayse.yilmaz@example.com",
    "department": "Mühendislik",
    "profilePhoto": "https://example.com/photo.jpg",
    "birthDate": "1995-03-15T00:00:00Z"
  }
]
```

Notlar:

- Sonuçlar ada göre alfabetik sıralıdır (firstName ASC, lastName ASC).
- `search` parametresi büyük/küçük harf duyarsızdır (ilike).
- Filtre uygulanmazsa tüm çalışanlar döner.
