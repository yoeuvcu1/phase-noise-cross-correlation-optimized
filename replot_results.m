% replot_results.m
% =====================================================================
% Kaydedilmiş ham verilerden (.mat) grafikleri yeniden çizer.
% Simülasyonu yeniden koşturmaz; ham veriler results/ klasöründen okunur.
%
% Ağ sürücüsü notu ve çalıştırma biçimi run_comparisons.m ile aynıdır:
%   run("O:\phasedetector with cross correlation optimized\replot_results.m")
%   veya CLI'den: octave-cli "O:\...\replot_results.m"
%
% AYARLAR:
%   RESULTS_SUBFOLDER boş ise en son koşu klasörü kullanılır. Belirli bir
%   koşuyu çizmek için zaman damgalı klasör adını yazın, örnek:
%       RESULTS_SUBFOLDER = "20260807_123456_lpf_cutoff";
% =====================================================================

RESULTS_SUBFOLDER = "";
SHOW_FIGURES = true;   % karşılaştırma grafiğini ekranda göster

project_dir = fileparts(mfilename("fullpath"));
mirror_dir = fullfile(tempdir(), "octave_pd_mirror");
prepare_mirror(project_dir, mirror_dir);
cd(mirror_dir);
addpath(mirror_dir);

replot_results_main(RESULTS_SUBFOLDER, SHOW_FIGURES, project_dir);
