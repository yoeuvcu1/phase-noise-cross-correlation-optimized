# MEMORY BANK — Phase Noise Cross-Correlation Projesi

Bu dosya, "phasedetector with cross correlation optimized" projesindeki çalışma oturumları arasında bağlam korumak içindir. Yeni bir oturumda önce burayı oku.

## Proje Özeti

Faz gürültüsü ölçümünün (phase noise) **cross-correlation / cross-PSD** yöntemiyle simülasyonu (GNU Octave). İki bağımsız referans kanalıyla DUT faz gürültüsü ölçülür; referansların kendi gürültüleri iterasyon ortalamasında söner, DUT'unki birikir.

## Klasör Yapısı

```
Octave/  (workspace kökü)
├── CHANGES.md                       ← orijinal vs optimized fark raporu
├── MEMORY_BANK.md                   ← bu dosya
├── phasedetector with cross correlation/          (ORİJİNAL - değiştirme)
└── phasedetector with cross correlation optimized/ (AKTİF - üzerinde çalışılan)
    ├── main.m                       ← giriş noktası (varsayılan config + run_simulation)
    ├── run_simulation.m             ← ana simülasyon akışı
    ├── measure_iteration.m          ← tek iterasyonluk cross-PSD ölçümü (FFT tabanlı)
    ├── generate_phase_noise.m       ← 1/f³ spektrumlu faz gürültüsü üretici
    ├── compute_periodogram.m        ← DUT referans PSD (tek taraflı)
    ├── bin_and_convert.m            ← log-bin + SSB dBc/Hz dönüşümü
    ├── logbin_psd.m                 ← logaritmik binleme (f: geometrik, P: aritmetik ortalama)
    ├── psd_to_ssb.m                 ← L = 10·log10(P/2 + realmin)
    ├── valid_freq_mask.m            ← (f_min, f_max] maske
    ├── remove_dc.m                  ← kolon ortalamasını çıkar
    ├── test_rms_runs.m              ← batch RMS testi (DUT RMS 0.5/0.2, 20 run)
    ├── validate_config.m            ← config alan doğrulama
    └── benchmark_fft.m              ← nfft karşılaştırma (asal vs 2^k) hız ölçümü
```

## Çalıştırma

```matlab
main;                      % tek simülasyon (varsayılan config, çizim açar)
results = main(config);    % özel config ile
test_rms_runs;             % batch RMS testi (uzun sürer: N=1M, 20 run x 2 RMS)
benchmark_fft;             % FFT hız karşılaştırması (hızlı)
```

Gereksinim: Octave `signal` paketi (`pkg load signal`, otomatik yüklenir).

## Önemli Algoritma Notları

- **Cross-PSD (optimized):** `S_cross = fft(c1, nfft) .* conj(fft(c2, nfft)) / (fs·M)`, tek taraflıya çevrilip DC hariç ×2. nfft = `2^nextpow2(2·(N - settling) - 1)` (radix-2). Eski xcorr+ifftshift+fft zincirine eşdeğer, çok daha hızlı.
- **İterasyon döngüsü:** DUT faz gürültüsü bir kez üretilir (`x_dut` sabit); referanslar her iterasyonda yeniden üretilir → korelasyonsuz gürültü söner.
- **Faz detektörü:** `x_dut · x_ref` → LPF (butter, `lpf_cutoff/lpf_order`, katsayılar döngü dışında) → `/K_pd` (`K_pd = A²/2`) → settling atılır → DC atılır.
- **sin(φ) düzeltmesi:** `P = Σ|S_cross|·df`; `σ² = -0.5·ln(1-2P)`; `correction_factor = σ²/P`; `S_corrected = S·correction_factor`.
- **Hata metriği:** cross-PSD ile DUT FFT periodogramı ortak log-frekans ekseninde (200 nokta, interp) karşılaştırılır; `mean_absolute_error_fft_db` = ortalama |Δ| dB. NaN'lar maskelenir.
- **DUT RMS ayarı:** `generate_phase_noise` normalize edip `phase_rms` ile ölçekler; N **çift** olmalı.

## Alınan Kararlar (Karar Günlüğü)

1. **xcorr → doğrudan FFT cross-spektrumu** (2026-08-07): Eşdeğer sonuç, büyük hız kazancı.
2. **nfft → 2'nin kuvveti**: Asal FFT (Bluestein) yavaş; zero-padding yalnız frekansı sıkılaştırır, gücü değiştirmez.
3. **LPF katsayıları döngü dışında**: Butter tasarımı iterasyon başına tekrarlanmaz.
4. **logbin_psd: max → mean**: Yorumla tutarlı gerçek ortalama güç.
5. **Welch bloğu kaldırıldı**: Kullanılmıyordu, sonuç yapısını şişiriyordu.
6. **generate_phase_noise seed davranışı korundu** (per-call seed) — README'de de not edildi; kırılmasına izin verilmedi.
7. **test_rms_runs: N=1M, iter=100** (eskiden N=10k, iter=500): Uzun kanal → daha iyi frekans çözünürlüğü; hız kazancıyla süre dengelendi.

## Dikkat / Bilinen Noktalar

- `generate_phase_noise` zaman bazlı seed kullandığı için aynı config ile aynı run'ı birebir tekrarlamaz (istatistiksel test için istenen davranış).
- `lowpass_filter.m` optimize klasörde **yok**; butter+filter artık `run_simulation` içinde.
- Orijinal klasördeki `results.dut_welch.*` çıktıları optimized'ta mevcut değil.
- `N <= settling_samples` ve tek N durumlarında hata verilir (dokümante edildi).
- Çalışma dizini, her iki klasörü ve kökteki yardımcı `*.m` dosyalarını içeren `Octave/` köküdür (AWGN, pinknoise vb. bağımsız araçlar).

## Yapılacaklar / Açık Sorular

- [ ] `benchmark_fft` ile hız kazancını sayısal olarak kaydet (örn. bu dosyaya bir satır: "≈Xx hızlanma").
- [ ] Cross-PSD ile DUT FFT hata metriğinin düşük RMS'lerde (ör. 0.05 rad) davranışı doğrulandı mı?
- [ ] İstenirse `run_simulation`'a Welch karşılaştırması geri eklenebilir (kaldırıldı).

## Karşılaştırma Koşu Çerçevesi (2026-08-07)

Farklı parametre verileriyle simülasyonu koşturup karşılaştıran ve **ham veriyi kalıcı kaydeden** çerçeve. Optimized klasörüne eklenen dosyalar:

```
run_comparisons.m        → giriş betiği (yerel yansıma kurar, koşuyu başlatır)
run_comparisons_main.m   → DEFAULT PARAMETRELER + tarama listeleri + koşu mantığı
replot_results.m         → ham veriden grafikleri yeniden çizen giriş betiği
replot_results_main.m    → raw .mat dosyalarını yükleyip yeniden çizer
plot_sweep_results.m     → tarama değerlerini üst üste çizen karşılaştırma grafiği
plot_single_run.m        → tek koşu grafiği (cross-PSD + DUT FFT)
save_figure_to_png.m     → PNG kaydı (qt/GUI'de); CLI'de atlar ve uyarır
make_file_suffix.m       → değerden dosya adı eki üretir (0.05 → "0p05")
```

Çalıştırma: `run("O:\phasedetector with cross correlation optimized\run_comparisons.m")`. Grafikleri sonradan çizmek için aynı şekilde `replot_results.m`.

Çıktı düzeni: `results/<yyyymmdd_HHMMSS>_<tarama>/` altında `raw/run_NN_<tarama>_<deger>.mat` (tam sonuç yapısı), `plots/*.png`, `summary.mat`, `summary.csv`. Ham veri hem tekrar hesaplama hem tekrar çizim için yeterlidir (config dahil saklanır).

### Taramalar (run_comparisons_main.m "KOŞULACAK TARAMALAR" bölümü)

- Sabitler: `N=100000` (test; gerçek simde 1M), `fs`, `A`, `f0`, `settling_samples`, `lpf_order`.
- `lpf_cutoff` = [5k, 10k, 25k, 50k] Hz; `rms_dut` = [0.05, 0.1, 0.2, 0.5, 1.0] (ref'ler sabit); `rms_ref` = [0.01, 0.02, 0.05, 0.1, 0.2] (ref1 = ref2, DUT sabit); `iterations` = [1, 5, 10, 25, 50, 100]; `log_bins` = [10, 25, 50, 100, 200]. Orijinal değer her listede vardır ve grafikte "(orig)" işaretlenir.

### Ağ sürücüsü kısıtları (neden yansıma var?)

- Octave, `\\kutu\...` (SMB) üzerindeki `.m` dosyalarını **yükleyemez** (loadpath/fcache ağ sürücüsünde bozuk; `exist` tam yolla çalışır, isim bazlı arama çalışmaz). Giriş betiği bu yüzden `.m` dosyalarını `tempdir()/octave_pd_mirror` klasörüne kopyalayıp simülasyonu oradan koşar; ham veri doğrudan ağdaki `results/` klasörüne yazılır (save/load/fopen ağ yolunda sorunsuz).
- Octave'nin `copyfile`'ı cmd.exe kullandığından UNC/boşluklu yollarda güvenilmezdir; kopyalama fopen ile yapılır.
- PNG üretimi qt toolkit (Octave GUI) gerektirir; CLI'de (fltk) pencere açmadan çizim yapılamadığı için PNG'ler atlanır, `replot_results` GUI'den çizilir.
- Proje klasörü `O:` sürücüsü olarak da haritalanmıştır (`net use O: \\kutu\users\staj\92010866\Desktop\Octave /persistent:yes`).

### Karar günlüğü ekleri

8. **Yerel yansıma (mirror) mimarisi** (2026-08-07): Ağ sürücüsünden .m yüklenemediği için giriş betikleri yerelden koşar.
9. **CLI'de PNG yok, GUI'de replot** (2026-08-07): fltk görünür pencere ister; kullanıcıyı pencere yağmuruna tutmamak için PNG yalnız qt ile.
