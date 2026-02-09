function apply_default_profile(profile_file, options)
% APPLY_DEFAULT_PROFILE  Set MATLAB session-wide figure defaults from a JSON profile.
%
% Loads a font/style profile and applies it as global defaults via the
% graphics root object (groot).  Every figure created after this call
% inherits these settings automatically.
%
% Usage:
%   apply_default_profile()                                 % default: presentation
%   apply_default_profile('presentation')
%   apply_default_profile('paper')
%   apply_default_profile('my_profile.json')
%
%   % With inline overrides (R2021a+ name=value syntax):
%   apply_default_profile('paper', AxesFontSize=12)
%   apply_default_profile('presentation', CommonFontName='Helvetica')
%
% Intended for use in startup.m so that your preferred style is active
% every time MATLAB launches.  See README.md for setup instructions.
%
% Note:  Figure-size properties (FigureWidthInches, FigureHeightInches,
%        ApplyFigureSize) and sgtitle properties (SGTitleFontSize,
%        SGTitleFontWeight) are intentionally NOT applied here.  Setting a
%        global default figure size overrides MATLAB's automatic figure
%        placement, and sgtitle has no groot defaults.  Use
%        apply_font_profile() to control these on individual figures.
%
% See also: apply_font_profile, style_panel

    arguments
        profile_file string = ""
        options.FigureColor
        options.AxesFontSize
        options.AxesFontWeight
        options.LabelFontSize
        options.LabelFontWeight
        options.TitleFontSize
        options.TitleFontWeight
        options.LegendFontSize
        options.LegendFontWeight
        options.CommonFontName
        options.AxesLineWidth
        options.AxesBox
        options.AxesTickDir
        options.Interpreter
        options.TickLabelInterpreter
    end

    % ----- Resolve & merge profile (same logic as apply_font_profile) -----
    this_dir = fileparts(mfilename('fullpath'));
    default_presentation_profile = fullfile(this_dir, 'default_profile_presentation.json');

    if profile_file == ""
        resolved_profile_file = default_presentation_profile;
    else
        resolved_profile_file = resolve_profile_file(profile_file, this_dir);
    end

    default_profile_struct = style_profile_load(default_presentation_profile);
    input_profile_struct   = style_profile_load(resolved_profile_file);
    p = merge_profile(default_profile_struct, input_profile_struct);

    % Apply name-value overrides on top of the merged profile
    override_fields = fieldnames(options);
    for idx = 1:numel(override_fields)
        p.(override_fields{idx}) = options.(override_fields{idx});
    end

    % ----- Apply to groot ------------------------------------------------

    % Figure defaults
    try, set(groot, 'DefaultFigureColor', p.FigureColor); end

    % Common font name
    font_name = '';
    if isfield(p, 'CommonFontName'), font_name = p.CommonFontName; end

    % Axes defaults
    try, set(groot, 'DefaultAxesFontSize',   p.AxesFontSize);   end
    try, set(groot, 'DefaultAxesFontWeight', p.AxesFontWeight); end
    if ~isempty(font_name)
        try, set(groot, 'DefaultAxesFontName', font_name); end
    end
    try, set(groot, 'DefaultAxesLineWidth', p.AxesLineWidth); end
    try, set(groot, 'DefaultAxesBox',       p.AxesBox);       end
    try, set(groot, 'DefaultAxesTickDir',   p.AxesTickDir);   end
    try, set(groot, 'DefaultAxesTickLabelInterpreter', p.TickLabelInterpreter); end

    % Label/Title scaling (MATLAB uses multipliers relative to AxesFontSize)
    try, set(groot, 'DefaultAxesLabelFontSizeMultiplier', p.LabelFontSize / p.AxesFontSize); end
    try, set(groot, 'DefaultAxesTitleFontSizeMultiplier', p.TitleFontSize / p.AxesFontSize); end
    try, set(groot, 'DefaultAxesTitleFontWeight', p.TitleFontWeight); end

    % Text defaults (covers annotations and standalone text objects)
    if ~isempty(font_name)
        try, set(groot, 'DefaultTextFontName', font_name); end
    end
    try, set(groot, 'DefaultTextFontSize',   p.LegendFontSize);   end
    try, set(groot, 'DefaultTextFontWeight', p.LegendFontWeight); end
    try, set(groot, 'DefaultTextInterpreter', p.Interpreter); end

    % Legend defaults
    if ~isempty(font_name)
        try, set(groot, 'DefaultLegendFontName', font_name); end
    end
    try, set(groot, 'DefaultLegendFontSize',   p.LegendFontSize);   end
    try, set(groot, 'DefaultLegendFontWeight', p.LegendFontWeight); end
    try, set(groot, 'DefaultLegendInterpreter', p.Interpreter); end

    % Colorbar defaults
    try, set(groot, 'DefaultColorbarBox', 'off'); end
    try, set(groot, 'DefaultColorbarTickLabelInterpreter', p.TickLabelInterpreter); end

end

%% ---- Local helpers (same logic as apply_font_profile) ------------------

function resolved_profile_file = resolve_profile_file(profile_file, this_dir)
    profile_name = char(string(profile_file));
    profile_key  = lower(strtrim(profile_name));

    if strcmp(profile_key, 'presentation')
        resolved_profile_file = fullfile(this_dir, 'default_profile_presentation.json');
        return;
    end

    if strcmp(profile_key, 'paper')
        resolved_profile_file = fullfile(this_dir, 'default_profile_paper.json');
        return;
    end

    [~, ~, profile_extension] = fileparts(profile_name);
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

    error('apply_default_profile:profile_not_found', ...
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
