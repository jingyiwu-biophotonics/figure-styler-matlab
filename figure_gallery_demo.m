function figure_gallery_demo(profile_file)
% FIGURE_GALLERY_DEMO Generate a small gallery of figures.
%
% Usage:
%   figure_gallery_demo()
%   figure_gallery_demo('paper')
%   figure_gallery_demo('presentation')
%   figure_gallery_demo('default_profile_paper.json')
%   figure_gallery_demo('default_profile_presentation.json')
%
% The demo also shows inline overrides on some figures. See the source
% for examples of apply_font_profile(..., Name=value) usage.

    this_dir = fileparts(mfilename('fullpath'));

    if nargin < 1 || isempty(profile_file)
        resolved_profile_file = fullfile(this_dir, 'default_profile_presentation.json');
    else
        resolved_profile_file = resolve_profile_file(profile_file, this_dir);
    end

    rng(1);

    fig_lines = figure('Name', 'Gallery: Lines');
    x_data = linspace(0, 2*pi, 400);
    plot(x_data, sin(x_data), 'DisplayName', 'sin(x)');
    hold on;
    plot(x_data, cos(x_data), 'DisplayName', 'cos(x)');
    xlabel('x (rad)');
    ylabel('Amplitude');
    title('Line Plot');
    text(pi, 0, 'text() sample', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    legend('Location', 'best');
    grid on;
    figure(fig_lines);
    apply_font_profile(resolved_profile_file);

    fig_scatter = figure('Name', 'Gallery: Scatter');
    n_points = 120;
    x_one = randn(n_points,1);
    y_one = randn(n_points,1) + 0.5;
    x_two = randn(n_points,1) + 2;
    y_two = randn(n_points,1) - 0.5;
    scatter(x_one, y_one, 36, 'filled', 'DisplayName', 'Group A');
    hold on;
    scatter(x_two, y_two, 36, 'filled', 'DisplayName', 'Group B');
    xlabel('Feature 1');
    ylabel('Feature 2');
    title('Scatter Plot');
    legend('Location', 'best');
    grid on;
    figure(fig_scatter);
    % Override: bold titles, use Times New Roman
    apply_font_profile(resolved_profile_file, TitleFontWeight='bold', CommonFontName='Times New Roman');

    fig_image = figure('Name', 'Gallery: Image');
    imagesc(peaks(200));
    axis image;
    colorbar;
    title('Image with Colorbar');
    figure(fig_image);
    apply_font_profile(resolved_profile_file);

    fig_subplot = figure('Name', 'Gallery: Subplot');
    subplot(2,2,1);
    bar([0.2 0.4 0.8 0.6]);
    title('Bar');

    subplot(2,2,2);
    histogram(randn(500,1));
    title('Histogram');

    subplot(2,2,3);
    x_err = 1:6;
    y_err = [1.2 1.5 1.1 1.9 1.4 1.7];
    err_val = 0.15 * ones(size(y_err));
    errorbar(x_err, y_err, err_val, 'o-');
    title('Errorbar');

    subplot(2,2,4);
    semilogy(logspace(0,2,50), logspace(-2,1,50));
    title('Semilogy');

    sgtitle('Subplot Layout');
    figure(fig_subplot);
    % Override: skip figure resizing, use bold sgtitle
    apply_font_profile(resolved_profile_file, ApplyFigureSize=false, SGTitleFontWeight='bold');
end

function resolved_profile_file = resolve_profile_file(profile_file, this_dir)
    profile_name = char(string(profile_file));
    profile_key = lower(strtrim(profile_name));

    if strcmp(profile_key, 'paper')
        resolved_profile_file = fullfile(this_dir, 'default_profile_paper.json');
        return;
    end

    if strcmp(profile_key, 'presentation')
        resolved_profile_file = fullfile(this_dir, 'default_profile_presentation.json');
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

    error('figure_gallery_demo:profile_not_found', ...
        'Profile file not found: %s', profile_name);
end
