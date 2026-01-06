# AGENTS.md - install.cat

## Project Structure

```
index.src.html  # Source file (edit this)
index.html      # Minified output (generated, do not edit)
```

## Before Every Commit

**Always minify before committing:**

```bash
npx html-minifier-terser --collapse-whitespace --remove-comments --minify-css --minify-js -o index.html index.src.html
```

Or shorter:

```bash
npx html-minifier-terser -c -r --minify-css --minify-js -o index.html index.src.html
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

The page supports 3 languages via auto-detection:
- English (default/fallback)
- Portuguese (pt-BR)
- Catalan (ca)

All translatable strings use `data-i18n` attributes and are defined in the `translations` object in the `<script>` section.
