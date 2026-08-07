function copy_file_binary(source_path, target_path)
% Dosyayı ikili modda kopyalar (ağ yolları dahil her yolda çalışır;
% Octave'nin copyfile komutu cmd.exe kullandığı için güvenilmezdir).

source_id = fopen(source_path, "rb");
if source_id < 0
    error("Dosya acilamadi: %s", source_path);
end
target_id = fopen(target_path, "wb");
if target_id < 0
    fclose(source_id);
    error("Dosya yazilamadi: %s", target_path);
end

while ~feof(source_id)
    chunk = fread(source_id, 65536, "uint8");
    if isempty(chunk)
        break;
    end
    fwrite(target_id, chunk, "uint8");
end

fclose(source_id);
fclose(target_id);

end
