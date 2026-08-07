function plot_single_run(results, out_png, show_figure)
% Tek bir simülasyon koşusunun Cross-PSD ve DUT FFT eğrilerini çizer ve
% PNG olarak kaydeder.

try
    fig = figure("visible", "off");
catch
    fig = figure;
end
ax = axes(fig);

semilogx(ax, results.cross.frequency_binned, ...
    results.cross.phase_noise_binned, ...
    "b", "LineWidth", 2, ...
    "DisplayName", sprintf("Cross-PSD (log-binned, %d iter)", ...
    results.config.number_of_iterations));
hold(ax, "on");
semilogx(ax, results.dut_fft.frequency_binned, ...
    results.dut_fft.phase_noise_binned, ...
    "r--", "LineWidth", 2, ...
    "DisplayName", "Original DUT Noise - FFT (log-binned)");
grid(ax, "on");
xlabel(ax, "Offset Frequency (Hz)");
ylabel(ax, "Phase Noise (dBc/Hz)");
title(ax, "Cross-PSD and Original DUT Noise");
legend(ax, "location", "northeast");

save_figure_to_png(fig, out_png, show_figure);

end
