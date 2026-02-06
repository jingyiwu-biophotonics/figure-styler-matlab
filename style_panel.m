function style_panel(target_fig)
% STYLE_PANEL - Floating UI to tune font-focused figure styling.
%
% Requires:
%   apply_font_profile.m
%   style_profile_load.m
%   style_profile_save.m
%   save_figure.m

    if nargin < 1 || ~ishandle(target_fig) || ~strcmp(get(target_fig, 'Type'), 'figure')
        target_fig = gcf;
    end

    fig = target_fig;
    this_dir = fileparts(mfilename('fullpath'));
    presentation_profile = style_profile_load(fullfile(this_dir, 'default_profile_presentation.json'));
    paper_profile = style_profile_load(fullfile(this_dir, 'default_profile_paper.json'));
    active_profile = presentation_profile;

    font_suggestions = {'Arial','Helvetica','Times New Roman','Calibri','Cambria','Georgia','Verdana'};
    interpreter_options = {'tex'};
    tick_dir_options = {'out','in','both'};

    ui_fig = uifigure('Name', 'Figure Style Panel', 'Position', [100 100 560 860]);
    grid = uigridlayout(ui_fig, [34, 3]);
    grid.RowHeight = repmat({'fit'}, 1, 34);
    grid.ColumnWidth = {'1x', '1x', '1x'};

    uilabel(grid, 'Text', 'Target Figure:', 'FontWeight', 'bold');
    target_fig_edit = uieditfield(grid, 'text', 'Value', get_fig_name(fig), 'Editable', 'off');
    uibutton(grid, 'Text', 'Pick gcf', 'ButtonPushedFcn', @(~,~)set_target(gcf));

    uilabel(grid, 'Text', 'Preset Profile', 'FontWeight', 'bold');
    preset_profile_drop = uidropdown(grid, 'Items', {'presentation','paper'}, 'Value', 'presentation');
    uilabel(grid, 'Text', '');

    uilabel(grid, 'Text', 'Font Name (common)', 'FontWeight', 'bold');
    common_font_drop = uidropdown(grid, 'Items', font_suggestions, 'Editable', 'on', 'Value', active_profile.CommonFontName);
    uilabel(grid, 'Text', '');

    axes_font_size_edit = create_numeric_edit(grid, 'Axes Font Size', active_profile.AxesFontSize, 1);
    label_font_size_edit = create_numeric_edit(grid, 'Label Font Size', active_profile.LabelFontSize, 1);
    title_font_size_edit = create_numeric_edit(grid, 'Title Font Size', active_profile.TitleFontSize, 1);
    sgtitle_font_size_edit = create_numeric_edit(grid, 'SGTitle Font Size', active_profile.SGTitleFontSize, 1);
    legend_font_size_edit = create_numeric_edit(grid, 'Legend Font Size', active_profile.LegendFontSize, 1);

    axes_font_weight_drop = create_weight_drop(grid, 'Axes Font Weight', active_profile.AxesFontWeight);
    label_font_weight_drop = create_weight_drop(grid, 'Label Font Weight', active_profile.LabelFontWeight);
    title_font_weight_drop = create_weight_drop(grid, 'Title Font Weight', active_profile.TitleFontWeight);
    sgtitle_font_weight_drop = create_weight_drop(grid, 'SGTitle Font Weight', active_profile.SGTitleFontWeight);
    legend_font_weight_drop = create_weight_drop(grid, 'Legend Font Weight', active_profile.LegendFontWeight);

    uilabel(grid, 'Text', 'Text Interpreter', 'FontWeight', 'bold');
    text_interpreter_drop = uidropdown(grid, 'Items', interpreter_options, 'Value', normalize_interpreter(active_profile.Interpreter, interpreter_options));
    uilabel(grid, 'Text', '');

    uilabel(grid, 'Text', 'Tick Label Interpreter', 'FontWeight', 'bold');
    tick_interpreter_drop = uidropdown(grid, 'Items', interpreter_options, 'Value', normalize_interpreter(active_profile.TickLabelInterpreter, interpreter_options));
    uilabel(grid, 'Text', '');

    axes_line_width_edit = create_numeric_edit(grid, 'Axes LineWidth', active_profile.AxesLineWidth, 0.1);

    uilabel(grid, 'Text', 'Axes Box', 'FontWeight', 'bold');
    axes_box_drop = uidropdown(grid, 'Items', {'off','on'}, 'Value', active_profile.AxesBox);
    uilabel(grid, 'Text', '');

    uilabel(grid, 'Text', 'Axes Tick Dir', 'FontWeight', 'bold');
    axes_tick_dir_drop = uidropdown(grid, 'Items', tick_dir_options, 'Value', active_profile.AxesTickDir);
    uilabel(grid, 'Text', '');

    figure_width_edit = create_numeric_edit(grid, 'Figure Width (in)', active_profile.FigureWidthInches, 0.5);
    figure_height_edit = create_numeric_edit(grid, 'Figure Height (in)', active_profile.FigureHeightInches, 0.5);
    uilabel(grid, 'Text', 'Apply Figure Size', 'FontWeight', 'bold');
    apply_figure_size_check = uicheckbox(grid, 'Text', '', 'Value', active_profile.ApplyFigureSize);
    uilabel(grid, 'Text', '');

    live_apply_check = uicheckbox(grid, 'Text', 'Live Apply', 'Value', true);
    uibutton(grid, 'Text', 'Apply Now', 'ButtonPushedFcn', @(~,~)apply_current());
    uibutton(grid, 'Text', 'Apply Defaults', 'ButtonPushedFcn', @(~,~)apply_defaults());

    uilabel(grid, 'Text', 'Apply to ALL Figures', 'FontWeight', 'bold');
    uibutton(grid, 'Text', 'Apply to All', 'ButtonPushedFcn', @(~,~)apply_current_to_all());
    uilabel(grid, 'Text', '');

    uilabel(grid, 'Text', 'Style Profile', 'FontWeight', 'bold');
    uibutton(grid, 'Text', 'Load (.json)', 'ButtonPushedFcn', @(~,~)load_profile());
    uibutton(grid, 'Text', 'Save (.json)', 'ButtonPushedFcn', @(~,~)save_profile());

    uilabel(grid, 'Text', 'Save Figure', 'FontWeight', 'bold');
    save_name_edit = uieditfield(grid, 'text', 'Placeholder', 'filename (no ext)');
    format_drop = uidropdown(grid, 'Items', {'png','tif','jpg','pdf','eps','svg','fig'}, 'Value', 'png');
    uilabel(grid, 'Text', 'DPI', 'FontWeight', 'bold');
    dpi_edit = uieditfield(grid, 'numeric', 'Limits', [1 inf], 'Value', 300);
    uibutton(grid, 'Text', 'Save Now', 'ButtonPushedFcn', @(~,~)save_current_figure());

    wire_live(preset_profile_drop);
    wire_live(common_font_drop);
    wire_live(axes_font_size_edit); wire_live(label_font_size_edit); wire_live(title_font_size_edit);
    wire_live(sgtitle_font_size_edit); wire_live(legend_font_size_edit);
    wire_live(axes_font_weight_drop); wire_live(label_font_weight_drop); wire_live(title_font_weight_drop);
    wire_live(sgtitle_font_weight_drop); wire_live(legend_font_weight_drop);
    wire_live(text_interpreter_drop); wire_live(tick_interpreter_drop);
    wire_live(axes_line_width_edit); wire_live(axes_box_drop); wire_live(axes_tick_dir_drop);
    wire_live(figure_width_edit); wire_live(figure_height_edit);
    apply_figure_size_check.ValueChangedFcn = @(~,~)maybe_live_apply();
    preset_profile_drop.ValueChangedFcn = @(~,~)on_preset_change();

    function wire_live(handle_obj)
        handle_obj.ValueChangedFcn = @(~,~)maybe_live_apply();
    end

    function maybe_live_apply()
        if live_apply_check.Value
            apply_current();
        end
    end

    function on_preset_change()
        if strcmp(preset_profile_drop.Value, 'paper')
            active_profile = paper_profile;
        else
            active_profile = presentation_profile;
        end
        reset_ui(active_profile);
        maybe_live_apply();
    end

    function set_target(fig_handle)
        if ~ishandle(fig_handle) || ~strcmp(get(fig_handle, 'Type'), 'figure')
            return;
        end
        fig = fig_handle;
        target_fig_edit.Value = get_fig_name(fig);
        maybe_live_apply();
    end

    function apply_defaults()
        on_preset_change();
    end

    function apply_current()
        if ~ishandle(fig) || ~strcmp(get(fig, 'Type'), 'figure')
            return;
        end
        profile_struct = get_current_profile_struct();
        apply_profile_struct_to_figure(fig, profile_struct);
    end

    function apply_current_to_all()
        all_figs = findall(0, 'Type', 'figure');
        if isempty(all_figs)
            return;
        end
        profile_struct = get_current_profile_struct();
        for single_fig = reshape(all_figs, 1, [])
            if ~ishandle(single_fig)
                continue;
            end
            apply_profile_struct_to_figure(single_fig, profile_struct);
        end
    end

    function apply_profile_struct_to_figure(fig_handle, profile_struct)
        temp_profile_file = [tempname, '.json'];
        try
            style_profile_save(temp_profile_file, profile_struct);
            figure(fig_handle);
            apply_font_profile(temp_profile_file);
        catch me
            uialert(ui_fig, me.message, 'apply_font_profile error');
        end
        if exist(temp_profile_file, 'file') == 2
            delete(temp_profile_file);
        end
    end

    function save_current_figure()
        if ~ishandle(fig) || ~strcmp(get(fig, 'Type'), 'figure')
            uialert(ui_fig, 'No valid figure to save.', 'Save Figure');
            return;
        end
        if isempty(save_name_edit.Value)
            uialert(ui_fig, 'Please provide a base filename (without extension).', 'Save Figure');
            return;
        end
        figure(fig);
        try
            save_figure(save_name_edit.Value, format_drop.Value, dpi_edit.Value);
        catch me
            uialert(ui_fig, me.message, 'Save Figure Error');
        end
    end

    function save_profile()
        profile_struct = get_current_profile_struct();
        [file_name, file_path] = uiputfile({'*.json','JSON file'}, 'Save Style Profile');
        if isequal(file_name, 0)
            return;
        end
        try
            style_profile_save(fullfile(file_path, file_name), profile_struct);
        catch me
            uialert(ui_fig, me.message, 'Save Profile Error');
        end
    end

    function load_profile()
        [file_name, file_path] = uigetfile({'*.json','Style Profile (*.json)'}, 'Load Style Profile');
        if isequal(file_name, 0)
            return;
        end
        try
            loaded_profile = style_profile_load(fullfile(file_path, file_name));
            merged_profile = merge_on_defaults(active_profile, loaded_profile);
            active_profile = merged_profile;
            reset_ui(merged_profile);
            apply_current();
        catch me
            uialert(ui_fig, me.message, 'Load Profile Error');
        end
    end

    function reset_ui(profile_struct)
        if any(strcmpi(profile_struct.CommonFontName, font_suggestions))
            common_font_drop.Value = profile_struct.CommonFontName;
        else
            common_font_drop.Items = font_suggestions;
            common_font_drop.Value = profile_struct.CommonFontName;
        end

        axes_font_size_edit.Value = profile_struct.AxesFontSize;
        label_font_size_edit.Value = profile_struct.LabelFontSize;
        title_font_size_edit.Value = profile_struct.TitleFontSize;
        sgtitle_font_size_edit.Value = profile_struct.SGTitleFontSize;
        legend_font_size_edit.Value = profile_struct.LegendFontSize;

        axes_font_weight_drop.Value = normalize_weight(profile_struct.AxesFontWeight);
        label_font_weight_drop.Value = normalize_weight(profile_struct.LabelFontWeight);
        title_font_weight_drop.Value = normalize_weight(profile_struct.TitleFontWeight);
        sgtitle_font_weight_drop.Value = normalize_weight(profile_struct.SGTitleFontWeight);
        legend_font_weight_drop.Value = normalize_weight(profile_struct.LegendFontWeight);

        text_interpreter_drop.Value = normalize_interpreter(profile_struct.Interpreter, interpreter_options);
        tick_interpreter_drop.Value = normalize_interpreter(profile_struct.TickLabelInterpreter, interpreter_options);
        axes_line_width_edit.Value = profile_struct.AxesLineWidth;
        axes_box_drop.Value = profile_struct.AxesBox;
        axes_tick_dir_drop.Value = profile_struct.AxesTickDir;
        figure_width_edit.Value = profile_struct.FigureWidthInches;
        figure_height_edit.Value = profile_struct.FigureHeightInches;
        apply_figure_size_check.Value = profile_struct.ApplyFigureSize;
    end

    function profile_struct = get_current_profile_struct()
        profile_struct = struct( ...
            'FigureWidthInches', figure_width_edit.Value, ...
            'FigureHeightInches', figure_height_edit.Value, ...
            'FigureUnits', active_profile.FigureUnits, ...
            'ApplyFigureSize', apply_figure_size_check.Value, ...
            'FigureColor', active_profile.FigureColor, ...
            'AxesFontSize', axes_font_size_edit.Value, ...
            'AxesFontWeight', normalize_weight(axes_font_weight_drop.Value), ...
            'LabelFontSize', label_font_size_edit.Value, ...
            'LabelFontWeight', normalize_weight(label_font_weight_drop.Value), ...
            'TitleFontSize', title_font_size_edit.Value, ...
            'TitleFontWeight', normalize_weight(title_font_weight_drop.Value), ...
            'SGTitleFontSize', sgtitle_font_size_edit.Value, ...
            'SGTitleFontWeight', normalize_weight(sgtitle_font_weight_drop.Value), ...
            'LegendFontSize', legend_font_size_edit.Value, ...
            'LegendFontWeight', normalize_weight(legend_font_weight_drop.Value), ...
            'CommonFontName', common_font_drop.Value, ...
            'AxesLineWidth', axes_line_width_edit.Value, ...
            'AxesBox', axes_box_drop.Value, ...
            'AxesTickDir', axes_tick_dir_drop.Value, ...
            'Interpreter', text_interpreter_drop.Value, ...
            'TickLabelInterpreter', tick_interpreter_drop.Value);
    end

    function merged_profile = merge_on_defaults(default_profile, input_profile)
        merged_profile = default_profile;
        default_fields = fieldnames(default_profile);
        for idx = 1:numel(default_fields)
            field_name = default_fields{idx};
            if isfield(input_profile, field_name)
                merged_profile.(field_name) = input_profile.(field_name);
            end
        end
    end

    function edit_handle = create_numeric_edit(parent, label_text, default_value, min_value)
        uilabel(parent, 'Text', label_text, 'FontWeight', 'bold');
        edit_handle = uieditfield(parent, 'numeric', 'Limits', [min_value inf], 'Value', default_value);
        uilabel(parent, 'Text', '');
    end

    function drop_handle = create_weight_drop(parent, label_text, default_value)
        uilabel(parent, 'Text', label_text, 'FontWeight', 'bold');
        drop_handle = uidropdown(parent, 'Items', {'normal','bold'}, 'Value', normalize_weight(default_value));
        uilabel(parent, 'Text', '');
    end

    function weight_value = normalize_weight(raw_weight)
        if strcmpi(raw_weight, 'bold')
            weight_value = 'bold';
        else
            weight_value = 'normal';
        end
    end

    function interpreter_value = normalize_interpreter(raw_interpreter, allowed_values)
        if any(strcmpi(raw_interpreter, allowed_values))
            interpreter_value = char(string(raw_interpreter));
        else
            interpreter_value = allowed_values{1};
        end
    end

    function fig_name = get_fig_name(fig_handle)
        fig_name = get(fig_handle, 'Name');
        if isempty(fig_name)
            fig_name = sprintf('Figure %d', double(fig_handle.Number));
        end
    end
end
