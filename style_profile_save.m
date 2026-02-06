function style_profile_save(filename, style)
% STYLE_PROFILE_SAVE - Save style struct to JSON file.
% Example:
%   S = struct('AxesFontSize',14,'AxesFontWeight','normal', ...);
%   style_profile_save('my_style.json', S);

    arguments
        filename (1,1) string
        style (1,1) struct
    end

    [~,~,ext] = fileparts(filename);
    if ~strcmpi(ext, '.json')
        error('style_profile_save:UnsupportedExtension', ...
            'Unsupported style file extension: %s (use .json)', ext);
    end

    txt = jsonencode(style, 'PrettyPrint', true);
    fid = fopen(filename,'w');
    assert(fid>0, 'Cannot open file for writing: %s', filename);
    cleaner = onCleanup(@() fclose(fid));
    fwrite(fid, txt, 'char');
end
