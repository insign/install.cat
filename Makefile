.PHONY: dev open build watch

# Minify all source files to production
build:
	minhtml --minify-css --minify-js --output index.html index.src.html
	minhtml --minify-css --minify-js --output android.html android.src.html
	minhtml --minify-css --minify-js --output ios.html ios.src.html

# Serve locally and watch for changes
dev:
	@echo "Serving at http://localhost:8080/index.src.html"
	@echo "Watching *.src.html for changes..."
	@python3 -m http.server 8080 &
	@sleep 1 && xdg-open http://localhost:8080/index.src.html &
	@while true; do inotifywait -qe modify index.src.html android.src.html ios.src.html 2>/dev/null || fswatch -1 index.src.html android.src.html ios.src.html 2>/dev/null || sleep 2; \
		minhtml --minify-css --minify-js --output index.html index.src.html && echo "[ok] index.html updated"; \
		minhtml --minify-css --minify-js --output android.html android.src.html && echo "[ok] android.html updated"; \
		minhtml --minify-css --minify-js --output ios.html ios.src.html && echo "[ok] ios.html updated"; done

# Open in browser
open:
	xdg-open http://localhost:8080/index.src.html

# Watch and rebuild (no server)
watch:
	@while true; do inotifywait -qe modify index.src.html android.src.html ios.src.html 2>/dev/null || fswatch -1 index.src.html android.src.html ios.src.html 2>/dev/null || sleep 2; \
		minhtml --minify-css --minify-js --output index.html index.src.html && echo "[ok] index.html updated"; \
		minhtml --minify-css --minify-js --output android.html android.src.html && echo "[ok] android.html updated"; \
		minhtml --minify-css --minify-js --output ios.html ios.src.html && echo "[ok] ios.html updated"; done
