# AGENTS.md - install.cat

## Project Structure

```
index.src.html    # Main page source (edit this)
index.html        # Minified output (generated, do not edit)
android.src.html  # Android APK redirect page source (edit this)
android.html      # Minified output (generated, do not edit)
ios.src.html      # iOS IPA/App Store redirect page source (edit this)
ios.html          # Minified output (generated, do not edit)
```

## Rules

1. **Never edit `index.html`, `android.html` or `ios.html` directly** - they are auto-generated
2. **Always edit `*.src.html` files** - these are the source of truth
3. A git pre-commit hook automatically runs `minhtml` and stages minified outputs when source files are committed
4. **Commit both files** - source and minified together (handled by the hook)

## Cloudflare Redirect Rules

The domain routing is powered by Cloudflare Dynamic Redirect Rules. Credentials are in env vars `CLOUDFLARE_EMAIL` and `CLOUDFLARE_API_KEY`.

- **Zone ID:** `d39b2dade9417846bb9e925faa7d538d`
- **Ruleset ID:** `cc9d76824011470daafff070470b34c5`
- **Phase:** `http_request_dynamic_redirect`

### List current rules

```bash
curl -s "https://api.cloudflare.com/client/v4/zones/d39b2dade9417846bb9e925faa7d538d/rulesets/cc9d76824011470daafff070470b34c5" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" | jq '.result.rules[] | {id, description, expression}'
```

### Update rules

To add or modify rules, send a PUT with **all** rules (existing + new). The API replaces the entire ruleset. Include `id` for existing rules to preserve them; omit `id` for new ones.

```bash
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/d39b2dade9417846bb9e925faa7d538d/rulesets/cc9d76824011470daafff070470b34c5" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" \
  -d @/tmp/cf-rules.json
```

Write the full rules array to `/tmp/cf-rules.json` first. Format:

```json
{
  "rules": [
    {
      "id": "existing-rule-id",
      "action": "redirect",
      "expression": "(expression here)",
      "description": "Rule description",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(...)"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(new rule expression)",
      "description": "New rule",
      "enabled": true,
      "action_parameters": { "..." : "..." }
    }
  ]
}
```

**Important:** Rule order matters. Rules are evaluated top-to-bottom; the browser fallback rule (catch-all) must always be last.

## i18n

The page supports 17 languages via auto-detection (covering the 15 most spoken languages globally + Catalan + Korean):

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
- **ko** - Korean - 82M speakers
- **mr** - Marathi - 99M speakers
- **pt** - Portuguese - 264M speakers
- **ru** - Russian - 255M speakers
- **sw** - Swahili - 100M speakers
- **ur** - Urdu (RTL) - 232M speakers
- **zh** - Mandarin Chinese - 1.14B speakers

**RTL Support:** Arabic (ar) and Urdu (ur) automatically set `dir="rtl"` on the document root.

All translatable strings use `data-i18n` attributes and are defined in the `translations` object in the `<script>` section.
