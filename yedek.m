clear all;
close all;
clc;

pkg load signal;

N = 100000;
fs = 1e6;
t = (0:N-1)' / fs;
A = 1;
f0 = 50e3;

%% Phase-noise RMS değerleri

phase_rms_dut  = 10;
phase_rms_ref1 = 0.02;
phase_rms_ref2 = 0.02;

phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
x_clean = A*cos(2*pi*f0*t);
x_dut = A*cos(2*pi*f0*t + phase_noise_dut);



phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);

x_ref1 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref1);
x_ref2 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref2);


%% Kaynakları görüntüle

number_of_cycles = 5;
number_of_samples = round(number_of_cycles * fs/f0);

index = 1:number_of_samples;

figure;

subplot(2,1,1);
plot(t(index)*1e3, x_clean(index), 'k--', 'LineWidth', 1.5);
hold on;

plot(t(index)*1e3, x_dut(index), 'b', 'LineWidth', 1);
grid on;

xlabel('Zaman [ms]');
ylabel('Genlik');
title('Temiz sinyal ve DUT');
legend('Temiz sinyal', 'DUT');

%%%

subplot(2,1,2);
plot(t(index)*1e3, x_dut(index), 'b', 'LineWidth', 1);
hold on;

plot(t(index)*1e3, x_ref1(index), 'r', 'LineWidth', 1);
grid on;

xlabel('Zaman [ms]');
ylabel('Genlik');
title('DUT ve 90° kaydırılmış Ref-1');
legend('DUT', 'Ref-1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FAZ DEDEKTÖRLERİ

% Üst kanal: DUT ile Ref-2
pd_ref2_raw = x_dut .* x_ref2;

% Alt kanal: DUT ile Ref-1
pd_ref1_raw = x_dut .* x_ref1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% LOW-PASS FİLTRELER

lpf_cutoff = 50e3;
lpf_order = 4;

[pd_ref1_lpf, b_lpf, a_lpf] = lowpass_filter(pd_ref1_raw, fs, lpf_cutoff, lpf_order);

[pd_ref2_lpf, ~, ~] = lowpass_filter(pd_ref2_raw, fs, lpf_cutoff, lpf_order);


%% LPF ÇIKIŞINDAN PHASE ERROR ELDE ET

K_pd = A^2 / 2;

phase_error_detected_ref1 = pd_ref1_lpf / K_pd;

phase_error_detected_ref2 = pd_ref2_lpf / K_pd;

%% LOW-PASS ÇIKIŞ GRAFİKLERİ

% IIR filtre başlangıçta sıfır durumundan başladığı için
% ilk 5 ms'yi grafik dışında bırakıyoruz.
settling_samples = round(5e-3 * fs);

% Ham PD çıkışını göstermek için 5 taşıyıcı periyodu
raw_start = settling_samples + 1;
raw_stop = raw_start + number_of_samples - 1;
raw_index = raw_start:raw_stop;

% Filtre çıkışını göstermek için 20 ms
plot_duration = 20e-3;

plot_start = settling_samples + 1;
plot_stop = min(plot_start + round(plot_duration*fs) - 1, N);

lpf_index = plot_start:plot_stop;

figure;

%% Gerçek ham PD çıkışı

subplot(3,1,1);

plot(t(raw_index)*1e3, pd_ref1_raw(raw_index), 'k', 'LineWidth', 1);

grid on;

xlabel('Zaman [ms]');
ylabel('Ham PD çıkışı');

title('PD-1 ham çıkışı: baseband + 2f_0');

%% Gerçek low-pass çıkışları

subplot(3,1,2);

plot(t(lpf_index)*1e3, pd_ref1_lpf(lpf_index), 'b', 'LineWidth', 1);

hold on;

plot(t(lpf_index)*1e3, pd_ref2_lpf(lpf_index), 'r', 'LineWidth', 1);

grid on;

xlabel('Zaman [ms]');
ylabel('LPF çıkışı');

title('Low-pass filtrelenmiş PD çıkışları');

legend('PD-1 LPF', 'PD-2 LPF');

%% Gerçek dedekte edilen phase error

subplot(3,1,3);
plot(t(lpf_index)*1e3, phase_error_detected_ref1(lpf_index), 'b', 'LineWidth', 1);
hold on;

plot(t(lpf_index)*1e3, phase_error_detected_ref2(lpf_index), 'r', 'LineWidth', 1);
grid on;
xlabel('Zaman [ms]');
ylabel('Dedekte edilen faz hatası [rad]');
title('PD + LPF sonucunda dedekte edilen phase error');
legend('DUT - Ref-1', 'DUT - Ref-2');



%% VERİLEN VE DEDEKTE EDİLEN PHASE ERROR KARŞILAŞTIRMASI

% Başlangıçta verdiğimiz gerçek faz farkları
phase_error_given_ref1 = phase_noise_dut - phase_noise_ref1;

phase_error_given_ref2 = phase_noise_dut - phase_noise_ref2;

% Dedektör çıkışı LPF'den geçtiği için adil karşılaştırmada
% verilen faz hatalarını da aynı filtreden geçiriyoruz.
phase_error_given_ref1_lpf = filter( b_lpf, a_lpf, phase_error_given_ref1);

phase_error_given_ref2_lpf = filter(b_lpf, a_lpf, phase_error_given_ref2);

%% Karşılaştırma grafiği

figure;

subplot(2,1,1);

plot(t(lpf_index)*1e3, phase_error_given_ref1_lpf(lpf_index), 'k--', 'LineWidth', 1.5);
hold on;

plot(t(lpf_index)*1e3, phase_error_detected_ref1(lpf_index), 'b', 'LineWidth', 1);
grid on;
xlabel('Zaman [ms]');
ylabel('Faz hatası [rad]');
title('Ref-1 kanalı: verilen ve dedekte edilen phase error');
legend('Verilen phase error', 'Dedekte edilen phase error');

%% Ref-2 kanalı

subplot(2,1,2);

plot(t(lpf_index)*1e3, phase_error_given_ref2_lpf(lpf_index), 'k--', 'LineWidth', 1.5);
hold on;

plot(t(lpf_index)*1e3, phase_error_detected_ref2(lpf_index), 'r', 'LineWidth', 1);
grid on;
xlabel('Zaman [ms]');
ylabel('Faz hatası [rad]');
title('Ref-2 kanalı: verilen ve dedekte edilen phase error');
legend('Verilen phase error', 'Dedekte edilen phase error');

%%%%%%%%%%%%

%% CROSS-CORRELATION

% LPF başlangıç geçişini çıkar
correlation_start = settling_samples + 1;

channel_1 = phase_error_detected_ref1(correlation_start:end);

channel_2 = phase_error_detected_ref2(correlation_start:end);

channel_1 = channel_1 - mean(channel_1);
channel_2 = channel_2 - mean(channel_2);

% İki kanalın doğrudan cross-correlation'ı
[r_cross, lags] = xcorr( channel_1, channel_2, 'biased');

% Lag değerini zamana çevir
lag_time_ms = lags/fs * 1e3;

figure;

plot(lag_time_ms, r_cross, 'b');
grid on;
xlabel('Lag [ms]');
ylabel('Cross-correlation [rad^2]');
title('İki phase-error kanalının cross-correlation sonucu');
xlim([-5 5]);

%% CROSS-CORRELATION'DAN CROSS-PSD

% Sıfır lag değerini dizinin başına taşı
r_cross_ordered = ifftshift(r_cross);

% Wiener-Khinchin ilişkisi
S_cross_two_sided = fft(r_cross_ordered) / fs;

number_of_points = length(S_cross_two_sided);

% xcorr uzunluğu 2N-1 olduğu için tek sayıdır
number_of_positive_points = floor(number_of_points/2) + 1;

S_cross_one_sided = abs( S_cross_two_sided(1:number_of_positive_points));

% DC dışındaki pozitif frekansları ikiyle çarp
S_cross_one_sided(2:end) = 2*S_cross_one_sided(2:end);

f_cross = (0:number_of_positive_points-1)' * fs/number_of_points;

% Phase-noise L(f)
L_cross = 10*log10( 0.5*S_cross_one_sided + realmin);

valid_frequency = f_cross > 0 & f_cross <= lpf_cutoff;

figure;

semilogx( f_cross(valid_frequency), L_cross(valid_frequency), 'b', 'LineWidth', 1.5);

grid on;

xlabel('Offset frekansı [Hz]');
ylabel('L(f) [dBc/Hz]');

title('Cross-correlation ile ölçülen phase noise');


%%%%%%%%%%%%%%%%%%5

%% BULUNAN DUT VE ORİJİNAL DUT KARŞILAŞTIRMASI

% Orijinal DUT noise'unu ölçümdeki aynı LPF'den geçir
phase_noise_dut_compare = filter( b_lpf, a_lpf, phase_noise_dut);

% Filtre başlangıç geçişini çıkar
phase_noise_dut_compare = phase_noise_dut_compare(correlation_start:end);

% Orijinal DUT PSD
nfft_compare = 8192;
window_compare = hann(nfft_compare);

[P_dut_original, f_dut_original] = pwelch(phase_noise_dut_compare, window_compare, 0.5, nfft_compare, fs);

% Phase PSD → SSB phase noise
L_dut_original = ...
    10*log10(P_dut_original/2 + realmin);

valid_original = ...
    f_dut_original > 0 ...
    & f_dut_original <= lpf_cutoff;

valid_cross = ...
    f_cross > 0 ...
    & f_cross <= lpf_cutoff;

%% Karşılaştırma grafiği

figure;

semilogx( ...
    f_dut_original(valid_original), ...
    L_dut_original(valid_original), ...
    'k--', ...
    'LineWidth', 1.5);

hold on;

semilogx( ...
    f_cross(valid_cross), ...
    L_cross(valid_cross), ...
    'b', ...
    'LineWidth', 1.3);

grid on;
xlabel('Offset frekansı [Hz]');
ylabel('L(f) [dBc/Hz]');
title('Orijinal ve cross-correlation ile bulunan DUT phase noise');
legend('Orijinal DUT noise', 'Bulunan DUT noise', 'Location', 'best');
