# 🐱 install.cat

**Install any CLI tool with one command.** No package managers, no setup — just curl and go.

```bash
curl -fsSL install.cat/user/repo | sh
```

That's it. Your users don't need to remember raw GitHub URLs, add `https://`, or type `.sh`. It just works.

---

## Usage

### Linux & macOS

```bash
curl -fsSL install.cat/verseles/xpm | sh
```

Or with wget:

```bash
wget -O- install.cat/verseles/xpm | sh
```

### Windows (PowerShell)

```powershell
irm install.cat/verseles/xpm | iex
```

### Android

Just open `install.cat/user/repo` in your Android browser — the APK from the latest GitHub release is downloaded automatically, matched to your device architecture.

### iOS

Open `install.cat/user/repo` on an iPhone or iPad — if an IPA is found in the latest release, you'll see download instructions with sideload info (AltStore/Sideloadly). You can also use `ios.txt` to redirect to the App Store or TestFlight.

### For your own project

1. Add an `install.sh` to the root of your repo (for Linux/macOS)
2. Add an `install.ps1` to the root of your repo (for Windows)
3. For Android: publish APKs in your GitHub releases (naming convention: `{repo}-android-{arch}.apk`, or any `.apk`). Priority chain: `android.html` → `android.txt` → APK in releases → GitHub repo page.
4. For iOS: publish IPAs in your GitHub releases, or add an `ios.txt` with an App Store/TestFlight URL. Priority chain: `ios.html` → `ios.txt` → IPA in releases → GitHub repo page.
5. Tell your users:

```bash
curl -fsSL install.cat/your-username/your-repo | sh
```

Done. No registration, no config, no tokens.

#### Custom redirect files (`android.txt` / `ios.txt`)

Add a plain text file to your repo root containing a single URL on the first line. The user will be redirected there automatically:

```
# android.txt — redirect to Google Play
https://play.google.com/store/apps/details?id=com.example.app

# ios.txt — redirect to App Store
https://apps.apple.com/app/example/id123456789
```

Works with any URL: Google Play, F-Droid, App Store, TestFlight, direct downloads, etc.

---

## How it works

install.cat runs entirely on **Cloudflare Redirect Rules** — there is no server, no backend, no application code processing requests. The domain uses Cloudflare's edge network with a set of dynamic redirect rules that route requests based on the User-Agent header:

| User-Agent | Redirect target |
|---|---|
| `curl` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.sh` |
| `wget` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.sh` |
| `PowerShell` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.ps1` |
| `Android` | `install.cat/android.html?gh={user}/{repo}` (detects arch, finds APK) |
| `iPhone` / `iPad` | `install.cat/ios.html?gh={user}/{repo}` (App Store / IPA sideload) |
| Browser (default) | `github.com/{user}/{repo}/` |

The full ruleset:

1. **HTTP → HTTPS** — 301 redirect, ensures all traffic is encrypted
2. **www → root** — 301 redirect, canonical domain normalization
3. **curl → install.sh** — 302 redirect to raw script on GitHub
4. **wget → install.sh** — 302 redirect to raw script on GitHub
5. **PowerShell → install.ps1** — 302 redirect to raw script on GitHub
6. **iOS → ios.html** — 302 redirect to iOS app finder page
7. **Android → android.html** — 302 redirect to APK finder page
8. **Browser → GitHub** — 302 redirect to the repo page

### Self-hosting: create the rules yourself

Want to run your own install domain? You just need a Cloudflare zone. Set your env vars:

```bash
export CLOUDFLARE_EMAIL="you@example.com"
export CLOUDFLARE_API_KEY="your-global-api-key"
export ZONE_ID="your-zone-id"
```

First, create the ruleset:

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/rulesets" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
  "name": "default",
  "kind": "zone",
  "phase": "http_request_dynamic_redirect",
  "rules": [
    {
      "action": "redirect",
      "expression": "(http.request.full_uri wildcard r\"http://*\")",
      "description": "HTTP to HTTPS",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 301,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"http://*\", r\"https://${1}\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.request.full_uri wildcard r\"https://www.*\")",
      "description": "WWW to root",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 301,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://www.*\", r\"https://${1}\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.user_agent contains \"curl\" and http.request.uri wildcard r\"/*/*\")",
      "description": "curl → install.sh",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://YOURDOMAIN.COM/*/*\", r\"https://raw.githubusercontent.com/${1}/${2}/refs/heads/main/install.sh\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.user_agent contains \"Wget\" and http.request.uri wildcard r\"/*/*\")",
      "description": "wget → install.sh",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://YOURDOMAIN.COM/*/*\", r\"https://raw.githubusercontent.com/${1}/${2}/refs/heads/main/install.sh\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.user_agent contains \"PowerShell\" and http.request.uri wildcard r\"/*/*\")",
      "description": "PowerShell → install.ps1",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://YOURDOMAIN.COM/*/*\", r\"https://raw.githubusercontent.com/${1}/${2}/refs/heads/main/install.ps1\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.user_agent contains \"iPhone\" or http.user_agent contains \"iPad\") and http.request.uri wildcard r\"/*/*\"",
      "description": "iOS → ios.html",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": false,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://YOURDOMAIN.COM/*/*\", r\"https://YOURDOMAIN.COM/ios.html?gh=${1}/${2}\")"
          }
        }
      }
    },
    {
      "action": "redirect",
      "expression": "(http.request.uri wildcard r\"/*/*\")",
      "description": "Browser → GitHub repo",
      "enabled": true,
      "action_parameters": {
        "from_value": {
          "preserve_query_string": true,
          "status_code": 302,
          "target_url": {
            "expression": "wildcard_replace(http.request.full_uri, r\"https://YOURDOMAIN.COM/*/*\", r\"https://github.com/${1}/${2}/\")"
          }
        }
      }
    }
  ]
}'
```

> Replace `YOURDOMAIN.COM` with your actual domain in all three places.

To list existing rules:

```bash
# First, find your ruleset ID
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/rulesets" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" | jq '.result[] | select(.phase == "http_request_dynamic_redirect") | .id'

# Then inspect the rules
RULESET_ID="the-id-from-above"
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/rulesets/$RULESET_ID" \
  -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" | jq '.result.rules[] | {description, expression}'
```

### Why this matters

- **Zero downtime** — There is no server to crash. Cloudflare's edge network handles everything. As long as Cloudflare is up, install.cat is up.
- **Zero maintenance** — No dependencies, no runtime, no database, no containers. Nothing to update or patch.
- **Global performance** — Requests are processed at Cloudflare's nearest edge node, not routed to a single origin server.
- **Zero cost** — Redirect Rules are included in Cloudflare's free plan.

The landing page (`index.html`) is a static file served via Cloudflare Pages / GitHub Pages. It's purely informational — the actual install routing is handled entirely at the DNS/edge layer.

---

## Landing page

The landing page at [install.cat](https://install.cat) includes:

- Live example with syntax-highlighted commands
- **curl/wget toggle** to switch between tools
- Command generator — paste any GitHub URL or `user/repo` and get ready-to-copy install commands
- Auto-detected language (17 languages supported, including RTL for Arabic and Urdu)

---

## Development

### Project structure

```
index.src.html     # Main page source — edit this
index.html         # Minified output — auto-generated, do not edit
android.src.html   # Android APK redirect page source — edit this
android.html       # Minified output — auto-generated, do not edit
ios.src.html       # iOS IPA/App Store redirect page source — edit this
ios.html           # Minified output — auto-generated, do not edit
Makefile           # Dev commands
```

### Prerequisites

Install [minhtml](https://github.com/nickel-org/minhtml) (Rust):

```bash
cargo install minhtml
```

For file watching (Linux):

```bash
# Arch
sudo pacman -S inotify-tools

# Debian/Ubuntu
sudo apt install inotify-tools
```

### Commands

```bash
make dev     # Start local server + watch + open browser
make build   # Minify index.src.html → index.html
make watch   # Watch for changes and rebuild (no server)
make open    # Open in browser
```

### Workflow

1. Edit `index.src.html`
2. Run `make dev` to preview locally
3. Commit — a git pre-commit hook automatically runs `minhtml` and stages `index.html`

> **Never edit `index.html` directly.** It is regenerated on every commit.

### Alternative minifier (Node.js, no install)

```bash
npx html-minifier-terser --collapse-whitespace --remove-comments --minify-css --minify-js -o index.html index.src.html
```

---

## License

MIT

---

Made with ❤️ by [@insign](https://github.com/insign)
