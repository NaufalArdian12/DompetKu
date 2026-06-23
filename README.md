# Dompetku

Dompetku adalah aplikasi pencatatan keuangan personal berbasis SwiftUI. Aplikasi ini membantu mencatat pemasukan dan pengeluaran, memantau saldo, mengelola dompet atau rekening, melihat analisis kategori, dan mengekspor riwayat transaksi.

## Fitur

- Dashboard saldo, pemasukan, dan pengeluaran.
- Form tambah transaksi dengan input nominal cepat dan tampilan biru.
- Riwayat transaksi dengan pencarian dan filter.
- Analisis distribusi kategori menggunakan Swift Charts.
- Pengelolaan dompet atau rekening.
- Pengelolaan kategori transaksi kustom.
- Transaksi berulang dengan frekuensi harian, mingguan, bulanan, atau tahunan.
- Anggaran bulanan.
- Ekspor riwayat transaksi ke CSV.
- App lock menggunakan Face ID, Touch ID, atau passcode perangkat.
- Penyimpanan lokal menggunakan SwiftData.

## Tech Stack

- Swift 5.9
- SwiftUI
- SwiftData
- Swift Charts
- LocalAuthentication
- iOS 17+
- Xcode project generated/configured via XcodeGen `project.yml`

## Requirements

- macOS dengan Xcode yang mendukung iOS 17 atau lebih baru.
- iOS Simulator atau perangkat iPhone.
- XcodeGen opsional, hanya dibutuhkan jika ingin membuat ulang `Dompetku.xcodeproj` dari `project.yml`.

## Menjalankan Aplikasi

Clone atau buka folder project ini, lalu buka project Xcode:

```bash
open Dompetku.xcodeproj
```

Pilih scheme `Dompetku`, lalu jalankan di simulator atau perangkat iPhone.

Jika ingin regenerate project dari `project.yml`:

```bash
xcodegen generate
open Dompetku.xcodeproj
```

## Build Dari Terminal

Build untuk iOS Simulator generic:

```bash
xcodebuild -scheme Dompetku -destination "generic/platform=iOS Simulator" -configuration Debug build
```

Build ke simulator tertentu, sesuaikan nama simulator yang tersedia di mesin:

```bash
xcodebuild -scheme Dompetku -destination "platform=iOS Simulator,name=iPhone 17e" -configuration Debug build
```

## Struktur Project

```text
App/
  App.swift                         Entry point, SwiftData container, app lock, seed data
  Models/                           SwiftData models dan app lock manager
  Views/                            Screen utama aplikasi
  Components/                       Komponen UI reusable
  Theme/                            Warna, gradient, icon, dan style shared
  Extensions/                       Helper extension
Package.swift                       Swift Package manifest
project.yml                         Konfigurasi XcodeGen
Dompetku.xcodeproj                  Xcode project
```

## Data Lokal

Dompetku menyimpan data transaksi, kategori, dompet, dan transaksi berulang secara lokal dengan SwiftData. Saat container pertama kali dibuat, aplikasi melakukan seed untuk kategori default dan dompet default.

Jika fitur app lock diaktifkan, aplikasi akan meminta autentikasi perangkat saat dibuka kembali setelah masuk background.

## Catatan Pengembangan

- Bundle identifier default: `com.ngulik.dompetku`.
- Orientasi dikonfigurasi portrait melalui `project.yml`.
- `NSFaceIDUsageDescription` sudah disiapkan di konfigurasi project.
- Dark mode saat ini belum menjadi fokus utama karena UI aplikasi dipaksa ke light style di `ContentView`.
