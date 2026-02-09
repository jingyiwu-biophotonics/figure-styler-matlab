# MATLAB Figure Style Toolkit

A lightweight MATLAB toolkit for **consistent figure typography** across projects. It applies a font “profile” to a figure (or all open figures) and supports:

- Two built-in defaults: **paper** and **presentation**
- A small UI panel for quick tweaks and profile management
- JSON-based profiles for reproducibility and sharing
- Safe export helpers for raster (DPI) and vector outputs

---

## Repo contents

- `apply_font_profile.m` — apply a profile to the current figure (or target figure)
- `style_panel.m` — interactive UI panel
- `style_profile_load.m` / `style_profile_save.m` — load/save `.json` profiles
- `save_figure.m` — export helper (raster with DPI; vector formats)
- `figure_gallery_demo.m` — generates example figures to sanity-check styling
- `default_profile_paper.json` — paper profile (smaller fonts; print-oriented)
- `default_profile_presentation.json` — presentation profile (larger fonts; screen-oriented)
- `LICENSE` — MIT license

---

## Quick start

1. Add this folder to your MATLAB path (temporary or permanent):
   ```matlab
   addpath(genpath(pwd))   % if you are in the repo root
   ```

2. Create a figure, then apply the default profile:
   ```matlab
   apply_font_profile()    % default: presentation
   ```

---

## Requirements & compatibility

- **MATLAB R2019b+** is recommended (uses `arguments` blocks in helper functions).
- **`style_panel` requires `uifigure`** (App Designer UI components; available in modern MATLAB releases).
- **`save_figure` uses `exportgraphics` when available** (R2020a+); older versions fall back to `print`/`savefig`.
- **Fonts must be installed locally** on each machine; missing fonts will fall back to system defaults.

---

## Apply a specific profile

You can select a built-in name or point to a JSON file:

```matlab
apply_font_profile()                         % default: presentation
apply_font_profile('presentation')
apply_font_profile('paper')

apply_font_profile('default_profile_paper.json')
apply_font_profile('default_profile_presentation.json')
apply_font_profile('my_custom_profile.json')
```

**Tip:** keep custom profiles under version control with your project to ensure consistent figure appearance across collaborators and machines.

---

## Inline overrides

You can override individual profile settings directly without editing a JSON file.
This is useful when you mostly like a profile but need to tweak a few settings for a specific figure:

```matlab
% Skip figure resizing for one particular figure
apply_font_profile(ApplyFigureSize=false)

% Use the paper profile but make titles bold
apply_font_profile('paper', TitleFontWeight='bold')

% Override multiple settings at once
apply_font_profile('paper', AxesFontSize=12, LabelFontSize=14, AxesLineWidth=1.5)

% Works with any profile + any combination of settings
apply_font_profile('my_custom_profile.json', CommonFontName='Helvetica', ApplyFigureSize=false)
```

All profile fields are supported as overrides:

| Setting | Example value | Description |
|---|---|---|
| `ApplyFigureSize` | `false` | Skip resizing the figure |
| `FigureWidthInches` | `8.0` | Figure width |
| `FigureHeightInches` | `5.0` | Figure height |
| `FigureUnits` | `'inches'` | Units for figure size |
| `FigureColor` | `'w'` | Figure background color |
| `CommonFontName` | `'Helvetica'` | Font for all text elements |
| `AxesFontSize` | `12` | Axes tick-label font size |
| `AxesFontWeight` | `'bold'` | Axes tick-label font weight |
| `LabelFontSize` | `14` | Axis label font size |
| `LabelFontWeight` | `'bold'` | Axis label font weight |
| `TitleFontSize` | `16` | Title font size |
| `TitleFontWeight` | `'bold'` | Title font weight |
| `SGTitleFontSize` | `16` | Subplot group title font size |
| `SGTitleFontWeight` | `'bold'` | Subplot group title font weight |
| `LegendFontSize` | `12` | Legend font size |
| `LegendFontWeight` | `'bold'` | Legend font weight |
| `AxesLineWidth` | `1.5` | Axes border line width |
| `AxesBox` | `'on'` | Show axes box |
| `AxesTickDir` | `'in'` | Tick direction (`'in'` or `'out'`) |
| `Interpreter` | `'latex'` | Text interpreter |
| `TickLabelInterpreter` | `'latex'` | Tick-label interpreter |

> **Note:** The `Name=value` calling syntax requires **MATLAB R2021a+**. On R2019b–R2020b the same overrides work with the traditional syntax: `apply_font_profile('paper', 'TitleFontWeight', 'bold')`.

---

## Use the style UI

```matlab
style_panel()
```

The panel supports:
- switching between **paper** / **presentation** presets
- tweaking font-related settings
- saving/loading profile JSON files
- applying to the current figure or all open figures

---

## Export figures

```matlab
save_figure('my_figure', 'png', 300);  % png/jpg/tif with DPI
save_figure('my_figure', 'pdf');       % vector formats
```

---

## Gallery demo

Generate a small set of figures to validate styling quickly:

```matlab
figure_gallery_demo
figure_gallery_demo('paper')
figure_gallery_demo('presentation')
```

---

## Default profiles

- `default_profile_paper.json`  
  Intended for manuscripts (e.g., double-column layouts): smaller fonts, compact spacing.

- `default_profile_presentation.json`  
  Intended for slides: larger fonts and stronger readability at distance.

---

## Common workflow patterns

### A. Standardize figures in a script
```matlab
% (create plot)
apply_font_profile('paper');
save_figure('fig1', 'pdf');
```

### B. Iterate visually, then lock the profile
1. Run `style_panel()` and tune settings.
2. Save a project-specific profile JSON.
3. Use that JSON in your paper/analysis scripts.

---

## Share checklist (for GitHub + collaborators)

- Keep `default_profile_paper.json` and `default_profile_presentation.json`
  **in the same folder as** `apply_font_profile.m`.
- Commit any project-specific profiles (e.g., `profiles/my_lab_paper.json`).

---

## Contact

- Jingyi Wu — jingyiwu@andrew.cmu.edu

---

## License

Released under the MIT License. See `LICENSE`.
