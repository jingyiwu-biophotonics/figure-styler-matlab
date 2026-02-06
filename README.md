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
