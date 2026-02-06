# AGENTS.md - install.cat

## Project Structure

```
index.src.html  # Source file (edit this)
index.html      # Minified output (generated, do not edit)
```

## Before Every Commit

**Always minify before committing:**

```bash
minhtml --minify-css --minify-js --output index.html index.src.html
```

### Installing minhtml (Rust)

```bash
cargo install minhtml
```

### Alternative (Node.js, no install needed)

```bash
npx html-minifier-terser --collapse-whitespace --remove-comments --minify-css --minify-js -o index.html index.src.html
```

## Rules

1. **Never edit `index.html` directly** - it's auto-generated
2. **Always edit `index.src.html`** - this is the source of truth
3. **Run minify before every commit** - ensures production is optimized
4. **Commit both files** - source and minified together

## Workflow

1. Edit `index.src.html`
2. Test locally by opening `index.src.html` in browser
3. Run minify command
4. Commit both `index.src.html` and `index.html`
5. Push

## i18n

The page supports 16 languages via auto-detection (covering the 15 most spoken languages globally + Catalan):

- **ar** - Arabic (RTL) - 422M speakers
- **bn** - Bengali - 273M speakers
- **ca** - Catalan (cultural inclusion)
- **de** - German - 134M speakers
- **en** - English (default/fallback) - 1.52B speakers
- **es** - Spanish - 560M speakers
- **fr** - French - 321M speakers
- **hi** - Hindi - 609M speakers
- **id** - Indonesian - 199M speakers
- **ja** - Japanese - 125M speakers
- **mr** - Marathi - 99M speakers
- **pt** - Portuguese - 264M speakers
- **ru** - Russian - 255M speakers
- **sw** - Swahili - 100M speakers
- **ur** - Urdu (RTL) - 232M speakers
- **zh** - Mandarin Chinese - 1.14B speakers

**RTL Support:** Arabic (ar) and Urdu (ur) automatically set `dir="rtl"` on the document root.

All translatable strings use `data-i18n` attributes and are defined in the `translations` object in the `<script>` section.
