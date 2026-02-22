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

### For your own project

1. Add an `install.sh` to the root of your repo (for Linux/macOS)
2. Add an `install.ps1` to the root of your repo (for Windows)
3. Tell your users:

```bash
curl -fsSL install.cat/your-username/your-repo | sh
```

Done. No registration, no config, no tokens.

---

## How it works

install.cat runs entirely on **Cloudflare Redirect Rules** — there is no server, no backend, no application code processing requests. The domain uses Cloudflare's edge network with a set of dynamic redirect rules that route requests based on the User-Agent header:

| User-Agent | Redirect target |
|---|---|
| `curl` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.sh` |
| `wget` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.sh` |
| `PowerShell` | `raw.githubusercontent.com/{user}/{repo}/refs/heads/main/install.ps1` |
| Browser (default) | `github.com/{user}/{repo}/` |

The full ruleset:

1. **HTTP → HTTPS** — 301 redirect, ensures all traffic is encrypted
2. **www → root** — 301 redirect, canonical domain normalization
3. **curl → install.sh** — 302 redirect to raw script on GitHub
4. **wget → install.sh** — 302 redirect to raw script on GitHub
5. **PowerShell → install.ps1** — 302 redirect to raw script on GitHub
6. **Browser → GitHub** — 302 redirect to the repo page

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
index.src.html   # Source file — edit this
index.html       # Minified output — auto-generated, do not edit
Makefile         # Dev commands
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
