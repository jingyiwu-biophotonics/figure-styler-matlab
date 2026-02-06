function style = style_profile_load(filename)
% STYLE_PROFILE_LOAD - Load style struct from JSON file.

    arguments
        filename (1,1) string
    end

    [~,~,ext] = fileparts(filename);
    if ~strcmpi(ext, '.json')
        error('style_profile_load:UnsupportedExtension', ...
            'Unsupported style file extension: %s (use .json)', ext);
    end

    fid = fopen(filename,'r');
    assert(fid>0, 'Cannot open file for reading: %s', filename);
    cleaner = onCleanup(@() fclose(fid));
    raw = fread(fid, '*char')';
    style = jsondecode(raw);
end
