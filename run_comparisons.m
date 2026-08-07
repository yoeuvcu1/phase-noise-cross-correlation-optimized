% run_comparisons.m
% =====================================================================
% Simülasyon karşılaştırma koşu betiği (giriş noktası).
%
% Proje klasörü bir ağ paylaşımında (\\kutu\...) olduğu için Octave
% buradan .m dosyalarını güvenilir şekilde yükleyemez. Bu nedenle
% betik önce tüm .m dosyalarını yerel bir klasöre kopyalar, simülasyonu
% oradan koşar ve sonuçları (ham veri + grafik) doğrudan projedeki
% results/ klasörüne yazar.
%
% NASIL ÇALIŞTIRILIR (cwd nerede olursa olsun):
%   Octave komut satırından:
%       run("O:\phasedetector with cross correlation optimized\run_comparisons.m")
%   Veya CLI'den:
%       octave-cli "O:\...\run_comparisons.m"
%
% AYARLAR:
%   Simülasyon parametreleri ve tarama değerleri run_comparisons_main.m
%   dosyasındaki "DEFAULT PARAMETRELER" ve "KOŞULACAK TARAMALAR"
%   bölümlerinden düzenlenir. Aşağıdaki SHOW_FIGURES yalnızca ekran
%   gösterimini denetler; PNG kaydı her durumda yapılır.
% =====================================================================

SHOW_FIGURES = true;   % karşılaştırma grafiklerini ekranda göster

project_dir = fileparts(mfilename("fullpath"));
mirror_dir = fullfile(tempdir(), "octave_pd_mirror");
prepare_mirror(project_dir, mirror_dir);
cd(mirror_dir);
addpath(mirror_dir);

run_comparisons_main(SHOW_FIGURES, project_dir);

fprintf("\nHazir. Sonuclar: %s\n", fullfile(project_dir, "results"));
