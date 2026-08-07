function prepare_mirror(project_dir, mirror_dir)
% Projedeki tüm .m dosyalarını yerel yansıma klasörüne kopyalar.
% Octave ağ sürücülerindeki .m dosyalarını güvenilir yükleyemediği için
% simülasyon işlevleri bu yerel klasörden çalıştırılır.

if exist(mirror_dir, "dir")
    rmdir(mirror_dir, "s");
end
mkdir(mirror_dir);

project_entries = dir(project_dir);
for entry_index = 1:numel(project_entries)
    entry = project_entries(entry_index);
    if entry.isdir
        continue;
    end
    if length(entry.name) < 3
        continue;
    end
    if ~strcmp(entry.name(end-1:end), ".m")
        continue;
    end
    source_path = fullfile(project_dir, entry.name);
    target_path = fullfile(mirror_dir, entry.name);
    copy_file_binary(source_path, target_path);
end

end
