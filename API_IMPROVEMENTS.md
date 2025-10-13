# Peningkatan Responsivitas dan Stabilitas API

## 🎯 Masalah yang Diperbaiki

Sebelumnya, aplikasi mengalami beberapa masalah:
1. **Data API tiba-tiba hilang** - User harus login ulang untuk mengambil data
2. **Koneksi tidak stabil** - Tidak ada retry mechanism saat gagal
3. **Timeout tidak ditangani** - Request bisa hang tanpa batas waktu
4. **Token refresh tidak optimal** - Gagal refresh langsung logout
5. **Tidak ada caching** - Data hilang saat koneksi terputus

## ✅ Solusi yang Diimplementasikan

### 1. **API Service Enhancement** (`api_service.dart`)

#### Timeout Handling
- Setiap request memiliki timeout **30 detik**
- Jika timeout, akan otomatis retry hingga **3 kali**
- Delay **2 detik** antar retry untuk memberi waktu koneksi pulih

```dart
static const Duration _timeout = Duration(seconds: 30);
static const int _maxRetries = 3;
static const Duration _retryDelay = Duration(seconds: 2);
```

#### Network Error Handling
- Menangani `SocketException` (tidak ada koneksi internet)
- Menangani `TimeoutException` (request terlalu lama)
- Otomatis retry dengan delay untuk error network

#### Server Error Handling
- Menangani HTTP 5xx (server error)
- Otomatis retry hingga 3 kali
- Memberikan pesan error yang jelas ke user

#### Token Refresh yang Lebih Baik
- Jika token expired (401), otomatis refresh token
- Setelah refresh, request diulang dengan token baru
- Jika refresh gagal, baru minta user login ulang

### 2. **Auth Service Enhancement** (`auth_service.dart`)

#### Smart Token Refresh
- Timeout 15 detik untuk refresh token request
- Jika refresh gagal karena network error, **gunakan token lama** sementara
- Hanya logout jika refresh token benar-benar expired (401)
- Tidak langsung logout jika hanya error network

```dart
// Jika error network, gunakan token lama
final oldToken = await getToken();
if (oldToken != null) {
  print('ℹ️ Menggunakan token lama karena error network');
  return oldToken;
}
```

### 3. **Data Caching System** (`dashboard_screen.dart`)

#### In-Memory Cache
- Menyimpan data terakhir di memory
- Jika API gagal, tampilkan data cache
- User tetap bisa lihat data meski koneksi terputus

#### Persistent Cache (SharedPreferences)
- Menyimpan data ke storage device
- Data tetap ada bahkan setelah app restart
- Load cache saat app dibuka, kemudian fetch data baru

#### Cache Strategy
```
1. App dibuka → Load data dari persistent cache (instant)
2. Tampilkan data cache ke user (tidak perlu tunggu API)
3. Fetch data baru dari API di background
4. Update UI dengan data terbaru
5. Simpan data baru ke cache
```

### 4. **Model Enhancement** (`student_package.dart`)

#### Serialization Support
- Menambahkan method `toJson()` untuk semua model
- Memungkinkan data disimpan ke cache
- Memudahkan konversi data untuk storage

## 📊 Perbandingan Sebelum vs Sesudah

| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| **Timeout** | Tidak ada (bisa hang selamanya) | 30 detik dengan auto retry |
| **Network Error** | Langsung error | Retry 3x dengan delay 2 detik |
| **Token Expired** | Harus login ulang | Auto refresh token |
| **Refresh Token Gagal** | Langsung logout | Gunakan token lama dulu |
| **Data Hilang** | Harus reload/login ulang | Tampilkan data cache |
| **App Restart** | Data hilang semua | Load dari persistent cache |
| **Server Error** | Langsung error | Retry 3x otomatis |

## 🔄 Flow Diagram

### Request Flow dengan Retry Mechanism
```
User Action
    ↓
API Request (Timeout: 30s)
    ↓
    ├─ Success → Return Data → Save to Cache
    ├─ Timeout → Retry (1/3) → Delay 2s → Retry Request
    ├─ Network Error → Retry (2/3) → Delay 2s → Retry Request
    ├─ Server Error (5xx) → Retry (3/3) → Delay 2s → Retry Request
    ├─ Token Expired (401) → Refresh Token → Retry with New Token
    └─ Max Retries → Use Cache Data → Show Warning
```

### Token Refresh Flow
```
API Returns 401
    ↓
Get Refresh Token
    ↓
    ├─ Refresh Token Found
    │   ↓
    │   POST /token/refresh/ (Timeout: 15s)
    │   ↓
    │   ├─ Success (200) → Save New Token → Retry Original Request
    │   ├─ Expired (401) → Logout → Redirect to Login
    │   ├─ Network Error → Use Old Token → Continue
    │   └─ Other Error → Use Old Token → Continue
    │
    └─ Refresh Token Not Found → Logout → Redirect to Login
```

### Cache Strategy Flow
```
App Start
    ↓
Load Persistent Cache (SharedPreferences)
    ↓
Display Cached Data (Instant UI)
    ↓
Fetch Fresh Data from API
    ↓
    ├─ Success
    │   ↓
    │   Update UI with Fresh Data
    │   ↓
    │   Save to Memory Cache
    │   ↓
    │   Save to Persistent Cache
    │
    └─ Failed
        ↓
        Keep Showing Cached Data
        ↓
        Show Warning: "Menampilkan data terakhir"
```

## 🛠️ File yang Dimodifikasi

1. **`lib/services/api_service.dart`**
   - Tambah timeout handling
   - Tambah retry mechanism
   - Tambah network error handling
   - Perbaiki token refresh flow

2. **`lib/services/auth_service.dart`**
   - Perbaiki refresh token logic
   - Tambah fallback ke token lama
   - Tambah timeout untuk refresh request

3. **`lib/screens/dashboard_screen.dart`**
   - Tambah in-memory cache
   - Tambah persistent cache (SharedPreferences)
   - Load cache saat app start
   - Save cache setiap data berhasil di-fetch

4. **`lib/models/student_package.dart`**
   - Tambah method `toJson()` untuk serialization
   - Support untuk caching system

## 📝 Logging untuk Debugging

Semua perubahan dilengkapi dengan logging yang informatif:

- ✅ `✅` - Operasi berhasil
- ⚠️ `⚠️` - Warning (menggunakan fallback/cache)
- ❌ `❌` - Error
- 🔄 `🔄` - Proses refresh/retry
- ⏱️ `⏱️` - Timeout
- 🌐 `🌐` - Network error
- 🔴 `🔴` - Server error
- ℹ️ `ℹ️` - Informasi

Contoh log:
```
🔄 Mencoba refresh token...
✅ Token berhasil di-refresh
✅ Loaded 2 cached packages
⚠️ Menggunakan cached next class karena error
⏱️ Request timeout (GET siswa/schedules/week/) - Retry 1/3
```

## 🎯 Manfaat untuk User

1. **Tidak perlu login ulang** - Token otomatis di-refresh
2. **Data tetap terlihat** - Meski koneksi terputus, data cache ditampilkan
3. **Loading lebih cepat** - Cache dimuat instant saat app dibuka
4. **Lebih stabil** - Auto retry saat koneksi tidak stabil
5. **Pengalaman lebih baik** - Tidak ada blank screen atau error mendadak

## 🔒 Keamanan

- Token tetap disimpan dengan aman di `FlutterSecureStorage`
- Cache data tidak mengandung informasi sensitif
- Refresh token hanya digunakan untuk mendapatkan access token baru
- Logout otomatis jika refresh token benar-benar expired

## 🚀 Testing Recommendations

1. **Test dengan koneksi lambat**
   - Aktifkan network throttling
   - Pastikan retry mechanism bekerja

2. **Test dengan koneksi terputus**
   - Matikan internet
   - Pastikan cache data ditampilkan

3. **Test token expiration**
   - Tunggu token expired
   - Pastikan auto refresh bekerja

4. **Test app restart**
   - Tutup dan buka app
   - Pastikan data cache langsung muncul

5. **Test server error**
   - Simulasi server error (5xx)
   - Pastikan retry mechanism bekerja

## 📌 Catatan Penting

- Cache data akan di-update setiap kali berhasil fetch data baru
- Cache tidak memiliki expiry time (selalu valid)
- Jika ingin clear cache, user harus logout
- Retry mechanism tidak berlaku untuk error 4xx (client error) kecuali 401
- Maximum 3 retry untuk setiap request yang gagal

## 🔮 Future Improvements

1. **Cache Expiry** - Tambahkan timestamp dan expiry time untuk cache
2. **Background Sync** - Sync data di background secara periodik
3. **Offline Mode** - Full offline support dengan queue system
4. **Smart Retry** - Exponential backoff untuk retry delay
5. **Network Status Indicator** - Tampilkan status koneksi ke user