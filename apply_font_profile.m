function apply_font_profile(profile_file)
% APPLY_FONT_PROFILE Apply a JSON font profile to the current figure.
%
% Usage:
%   apply_font_profile()
%   apply_font_profile('default_profile_presentation.json')
%   apply_font_profile('default_profile_paper.json')
%   apply_font_profile('my_profile.json')
%   apply_font_profile('presentation')
%   apply_font_profile('paper')

    this_dir = fileparts(mfilename('fullpath'));
    default_presentation_profile = fullfile(this_dir, 'default_profile_presentation.json');

    if nargin < 1 || isempty(profile_file)
        resolved_profile_file = default_presentation_profile;
    else
        resolved_profile_file = resolve_profile_file(profile_file, this_dir);
    end

    default_profile_struct = style_profile_load(default_presentation_profile);
    input_profile_struct = style_profile_load(resolved_profile_file);
    merged_profile_struct = merge_profile(default_profile_struct, input_profile_struct);

    apply_profile_to_current_figure(merged_profile_struct);
end

function resolved_profile_file = resolve_profile_file(profile_file, this_dir)
    profile_name = char(string(profile_file));
    profile_key = lower(strtrim(profile_name));

    if strcmp(profile_key, 'presentation')
        resolved_profile_file = fullfile(this_dir, 'default_profile_presentation.json');
        return;
    end

    if strcmp(profile_key, 'paper')
        resolved_profile_file = fullfile(this_dir, 'default_profile_paper.json');
        return;
    end

    [~,~,profile_extension] = fileparts(profile_name);
    if isempty(profile_extension)
        profile_name = [profile_name, '.json'];
    end

    if exist(profile_name, 'file') == 2
        resolved_profile_file = profile_name;
        return;
    end

    profile_in_this_dir = fullfile(this_dir, profile_name);
    if exist(profile_in_this_dir, 'file') == 2
        resolved_profile_file = profile_in_this_dir;
        return;
    end

    error('apply_font_profile:profile_not_found', ...
        'Profile file not found: %s', profile_name);
end

function merged_profile = merge_profile(default_profile, input_profile)
    merged_profile = default_profile;
    default_fields = fieldnames(default_profile);
    for idx = 1:numel(default_fields)
        field_name = default_fields{idx};
        if isfield(input_profile, field_name)
            merged_profile.(field_name) = input_profile.(field_name);
        end
    end
end

function apply_profile_to_current_figure(style_profile)
    fig = gcf;

    if style_profile.ApplyFigureSize
        try
            old_units = get(fig, 'Units');
            set(fig, 'Units', style_profile.FigureUnits);
            position = get(fig, 'Position');
            position(3) = style_profile.FigureWidthInches;
            position(4) = style_profile.FigureHeightInches;
            set(fig, 'Position', position);
            set(fig, 'PaperUnits', 'inches');
            set(fig, 'PaperPositionMode', 'manual');
            set(fig, 'PaperPosition', [0 0 style_profile.FigureWidthInches style_profile.FigureHeightInches]);
            set(fig, 'PaperSize', [style_profile.FigureWidthInches style_profile.FigureHeightInches]);
            set(fig, 'Units', old_units);
        catch
        end
    end

    if ~isempty(style_profile.FigureColor)
        try
            set(fig, 'Color', style_profile.FigureColor);
        catch
        end
    end

    if ~isempty(style_profile.CommonFontName)
        style_profile.AxesFontName = style_profile.CommonFontName;
        style_profile.LabelFontName = style_profile.CommonFontName;
        style_profile.TitleFontName = style_profile.CommonFontName;
        style_profile.SGTitleFontName = style_profile.CommonFontName;
        style_profile.LegendFontName = style_profile.CommonFontName;
    end

    text_handles = findall(fig, 'Type', 'text');
    if ~isempty(text_handles)
        for single_text = text_handles'
            try
                text_tag = get(single_text, 'Tag');
            catch
                text_tag = '';
            end

            if any(strcmpi(text_tag, {'Title','XLabel','YLabel','ZLabel','Legend','Colorbar','suptitle','subplottext'}))
                try
                    set(single_text, 'Interpreter', style_profile.Interpreter);
                catch
                end
                continue;
            end

            try
                set(single_text, 'FontSize', style_profile.LegendFontSize, ...
                                 'FontWeight', style_profile.LegendFontWeight, ...
                                 'FontName', style_profile.LegendFontName, ...
                                 'Interpreter', style_profile.Interpreter);
            catch
            end
        end
    end

    ax = findall(fig, 'Type', 'axes');
    if ~isempty(ax)
        set(ax, 'FontSize', style_profile.AxesFontSize, ...
                'FontWeight', style_profile.AxesFontWeight, ...
                'FontName', style_profile.AxesFontName, ...
                'LineWidth', style_profile.AxesLineWidth, ...
                'Box', style_profile.AxesBox, ...
                'TickDir', style_profile.AxesTickDir);

        if isprop(ax(1), 'TickLabelInterpreter')
            set(ax, 'TickLabelInterpreter', style_profile.TickLabelInterpreter);
        end

        for single_ax = ax'
            if isgraphics(single_ax.XLabel)
                set(single_ax.XLabel, 'FontSize', style_profile.LabelFontSize, ...
                                     'FontWeight', style_profile.LabelFontWeight, ...
                                     'FontName', style_profile.LabelFontName, ...
                                     'Interpreter', style_profile.Interpreter);
            end
            if isgraphics(single_ax.YLabel)
                set(single_ax.YLabel, 'FontSize', style_profile.LabelFontSize, ...
                                     'FontWeight', style_profile.LabelFontWeight, ...
                                     'FontName', style_profile.LabelFontName, ...
                                     'Interpreter', style_profile.Interpreter);
            end
            if isprop(single_ax, 'ZLabel') && isgraphics(single_ax.ZLabel)
                set(single_ax.ZLabel, 'FontSize', style_profile.LabelFontSize, ...
                                     'FontWeight', style_profile.LabelFontWeight, ...
                                     'FontName', style_profile.LabelFontName, ...
                                     'Interpreter', style_profile.Interpreter);
            end
            if isgraphics(single_ax.Title)
                set(single_ax.Title, 'FontSize', style_profile.TitleFontSize, ...
                                     'FontWeight', style_profile.TitleFontWeight, ...
                                     'FontName', style_profile.TitleFontName, ...
                                     'Interpreter', style_profile.Interpreter);
            end
        end
    end

    legend_handles = findobj(fig, 'Type', 'legend');
    if ~isempty(legend_handles)
        set(legend_handles, 'FontSize', style_profile.LegendFontSize, ...
                            'FontWeight', style_profile.LegendFontWeight, ...
                            'FontName', style_profile.LegendFontName, ...
                            'Interpreter', style_profile.Interpreter);
    end

    subplot_title_handles = findobj(fig, 'Type', 'subplottext');
    if ~isempty(subplot_title_handles)
        set(subplot_title_handles, 'FontSize', style_profile.SGTitleFontSize, ...
                                   'FontWeight', style_profile.SGTitleFontWeight, ...
                                   'FontName', style_profile.SGTitleFontName, ...
                                   'Interpreter', style_profile.Interpreter);
    end

    suptitle_handles = findall(fig, 'Tag', 'suptitle');
    if ~isempty(suptitle_handles)
        try
            set(suptitle_handles, 'FontSize', style_profile.SGTitleFontSize, ...
                                  'FontWeight', style_profile.SGTitleFontWeight, ...
                                  'FontName', style_profile.SGTitleFontName, ...
                                  'Interpreter', style_profile.Interpreter);
        catch
        end
    end

    colorbar_handles = findobj(fig, 'Type', 'ColorBar');
    if ~isempty(colorbar_handles)
        try
            set(colorbar_handles, 'FontSize', style_profile.AxesFontSize, ...
                                  'FontWeight', style_profile.AxesFontWeight, ...
                                  'FontName', style_profile.AxesFontName, ...
                                  'LineWidth', style_profile.AxesLineWidth);
            if isprop(colorbar_handles(1), 'TickLabelInterpreter')
                set(colorbar_handles, 'TickLabelInterpreter', style_profile.TickLabelInterpreter);
            end
            if isprop(colorbar_handles(1), 'Label')
                colorbar_labels = [colorbar_handles.Label];
                if ~isempty(colorbar_labels) && all(isgraphics(colorbar_labels))
                    set(colorbar_labels, 'FontSize', style_profile.LabelFontSize, ...
                                         'FontWeight', style_profile.LabelFontWeight, ...
                                         'FontName', style_profile.LabelFontName, ...
                                         'Interpreter', style_profile.Interpreter);
                end
            end
        catch
        end
    end

end
