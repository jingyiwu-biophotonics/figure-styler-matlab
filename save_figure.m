function save_figure(fig_name, format, dpi)
% SAVE_FIGURE - Safely saves the current figure with overwrite protection (no style changes).
%
% Inputs:
%   fig_name : base name without extension (e.g., 'results_plot')
%   format   : 'png' | 'jpg' | 'tif' | 'pdf' | 'eps' | 'svg' | 'fig'
%   dpi      : numeric DPI for raster formats (png/jpg/tif). Optional for vector.
%
% Behavior:
%   - If file exists, prompt to Overwrite / Save as Copy / Cancel.
%   - Uses exportgraphics (if available) for robust modern export; falls back to print/savefig.
%   - Does NOT modify the figure (no resizing, no style changes).

    if nargin < 2 || isempty(format), format = 'png'; end
    if nargin < 3 || isempty(dpi),    dpi    = 300;   end

    filename = [fig_name, '.', format];
    if exist(filename, 'file')
        choice = questdlg([filename, ' already exists. What would you like to do?'], ...
                          'File Exists', 'Overwrite', 'Save as Copy', 'Cancel', 'Cancel');
        switch choice
            case 'Overwrite'
                do_save(filename, format, dpi);
                fprintf('File "%s" has been overwritten.\n', filename);
            case 'Save as Copy'
                [p,n,e] = fileparts(filename);
                copy_idx = 1;
                new_filename = fullfile(p, sprintf('%s_copy%d%s', n, copy_idx, e));
                while exist(new_filename, 'file')
                    copy_idx = copy_idx + 1;
                    new_filename = fullfile(p, sprintf('%s_copy%d%s', n, copy_idx, e));
                end
                do_save(new_filename, format, dpi);
                fprintf('File saved as "%s".\n', new_filename);
            otherwise
                disp('Figure save operation canceled.');
        end
    else
        do_save(filename, format, dpi);
        fprintf('File "%s" has been saved.\n', filename);
    end
end

function do_save(filename, format, dpi)
    fig = gcf; %#ok<GCF>
    format = lower(format);

    % MATLAB-native .fig
    if strcmp(format, 'fig')
        savefig(fig, filename);
        return;
    end

    % Try exportgraphics if available (R2020a+), then fall back
    use_exportgraphics = exist('exportgraphics','file') == 2;

    isRaster = any(strcmp(format, {'png','jpg','jpeg','tif','tiff'}));
    isVector = any(strcmp(format, {'pdf','eps','svg'}));

    try
        if use_exportgraphics
            if isRaster
                exportgraphics(fig, filename, 'Resolution', dpi);
            elseif isVector
                % DPI not required for true vector; exportgraphics writes vector data
                exportgraphics(fig, filename);
            else
                % Fallback to print for unknowns
                print(fig, filename, ['-d', format], ['-r', num2str(dpi)]);
            end
        else
            % Legacy fallback
            if isVector
                print(fig, filename, ['-d', format]); % vector device (dpi ignored)
            else
                print(fig, filename, ['-d', format], ['-r', num2str(dpi)]);
            end
        end
    catch ME
        warning('save_figure:ExportFailed', 'Export failed with exportgraphics/print. Error: %s', ME.message);
        rethrow(ME);
    end
end
