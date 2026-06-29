# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Uygulamayı çalıştır
flutter run

# Belirli bir platform için çalıştır
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d ios           # iOS Simulator

# Analiz ve linting
flutter analyze

# Testleri çalıştır
flutter test

# Tek test dosyası
flutter test test/widget_test.dart

# Bağımlılıkları güncelle
flutter pub get
```

## Mimari

Uygulama, state management paketi kullanmadan sade `StatefulWidget` yaklaşımıyla yazılmıştır. Navigasyon `NavShell` içindeki `IndexedStack` ile yönetilir; sekme geçişlerinde widget'lar yeniden kurulmaz.

```
lib/
├── main.dart              # Giriş noktası, sistem UI ayarları
├── app.dart               # MaterialApp kurulumu, tema bağlantısı
├── core/
│   ├── math_engine.dart   # Tüm matematik hesaplama motoru
│   └── theme.dart         # AppColors + AppTheme (yalnızca dark tema)
├── shared/
│   └── nav_shell.dart     # BottomNavigationBar + IndexedStack
└── features/
    ├── home/              # Ana sayfa (özellik kartları)
    ├── calculator/        # Bilimsel hesap makinesi
    ├── graph/             # Fonksiyon grafiği çizici
    │   └── function_painter.dart  # CustomPainter tabanlı çizim
    ├── geometry/          # Geometri hesaplamaları
    └── stats/             # İstatistik hesaplamaları
```

### MathEngine (`lib/core/math_engine.dart`)

Tüm ekranların ortak hesaplama noktası. `math_expressions` paketi üzerinde çalışır.
- `evaluate(String)` → hesap makinesi için string sonuç döner
- `evaluateForGraph(String, double x)` → grafik için `double?` döner (geçersizse `null`)
- `_preprocess()` ile örtük çarpım (`2x`, `3sin(x)`) ve Unicode semboller (`×`, `÷`, `π`) dönüştürülür
- `pi` ve `e` sabitleri her değerlendirmede context'e bağlanır

### FunctionPainter (`lib/features/graph/function_painter.dart`)

`CustomPainter` kullanır. Koordinat dönüşümü `mathToScreen` / `screenToMathX/Y` metodlarıyla yapılır. Asimptot tespiti için ardışık Y değerleri arasındaki sıçrama izlenir; süreksizlik tespit edildiğinde mevcut `Path` kapatılır, yenisi açılır. Her fonksiyon iki katmanlı çizilir: blur glow + keskin çizgi.

### Tema

`AppColors` sınıfı tüm renkleri içerir; `AppTheme.darkTheme` Material 3 dark temasını özelleştirir. Renk sistemi `Inter` fontu + mor-cyan-pembe aksanlı koyu arka plan üzerine kuruludur. Grafik eğrileri için `AppColors.graphPalette` kullanılır.

## Bağımlılıklar

| Paket | Amaç |
|---|---|
| `math_expressions` | İnfix ifade ayrıştırma ve değerlendirme |
| `google_fonts` | Inter font ailesi |
| `cupertino_icons` | iOS ikonları |
