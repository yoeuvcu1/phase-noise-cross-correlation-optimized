function plot_sweep_results(sweep_name, values, run_results, label_fmt, ...
    default_value, out_png, show_figure)
% Bir taramadaki tüm koşuları tek grafikte üst üste çizer ve PNG olarak
% kaydeder. Her değer için Cross-PSD (düz çizgi) ve DUT FFT (kesikli
% çizgi) eğrileri aynı renkle çizilir.
%
% values:       tarama değerleri vektörü
% run_results:  her elemanı bir koşu sonucu olan cell dizi
% label_fmt:    değerden etiket üreten sprintf biçimi (tek %d/%g alır)
% default_value: orijinal parametre değeri (legend'de "(orig)" işaretlenir)

number_of_values = numel(values);
color_map = lines(max(number_of_values, 7));

try
    fig = figure("visible", "off");
catch
    fig = figure;
end
ax = axes(fig);

for value_index = 1:number_of_values
    current_results = run_results{value_index};
    current_label = sprintf(label_fmt, values(value_index));
    if values(value_index) == default_value
        current_label = [current_label, " (orig)"];
    end
    current_color = color_map(value_index, :);

    semilogx(ax, current_results.cross.frequency_binned, ...
        current_results.cross.phase_noise_binned, ...
        "-", "Color", current_color, "LineWidth", 2, ...
        "DisplayName", sprintf("Cross-PSD %s", current_label));
    hold(ax, "on");
    semilogx(ax, current_results.dut_fft.frequency_binned, ...
        current_results.dut_fft.phase_noise_binned, ...
        "--", "Color", current_color, "LineWidth", 1.5, ...
        "DisplayName", sprintf("DUT FFT %s", current_label));
end

grid(ax, "on");
xlabel(ax, "Offset Frequency (Hz)");
ylabel(ax, "Phase Noise (dBc/Hz)");
title(ax, sprintf("%s comparison", sweep_name));
legend(ax, "location", "northeast", "FontSize", 8);

save_figure_to_png(fig, out_png, show_figure);

end
