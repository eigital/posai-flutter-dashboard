# eo_dashboard_flutter

eatOS dashboard (Flutter Web + mobile targets).

## Local web + API (recommended)

The app calls the API under **`/api`** (same as the React Vite app). Flutter’s dev server reads **`web_dev_config.yaml`** and proxies `/api` → `https://browserapi.eatos.net/` with the `/api` prefix stripped.

**Dev URL (default in this repo):** `http://127.0.0.1:53300` — see `web_dev_config.yaml` for `host` / `port`.

1. From this folder: `flutter pub get`
2. Run: `flutter run -d chrome` or `flutter run -d edge`
3. Login uses `POST /user/login` and `GET /settings` via the proxy.

**Override API base URL** (e.g. staging): pass a full origin including `/api`:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://browserapi.eatos.net/api
```

Without `--dart-define`, **web** uses `${Uri.base.origin}/api` (works with the dev proxy). **Non-web** defaults to `https://browserapi.eatos.net` (see `lib/config/api_config.dart`).

### Windows: dev server bind errors (`SocketException`, errno 10013)

If `flutter run` fails with **Failed to bind** on the configured port:

1. Check another process is not using the port: `netstat -ano | findstr :53300` (adjust port if you changed it).
2. **Excluded port ranges** (Hyper-V / WSL / Docker): open **Administrator** PowerShell and run:
   `netsh interface ipv4 show excludedportrange protocol=tcp`  
   Pick a `server.port` in `web_dev_config.yaml` that does **not** fall inside any listed range, then fully restart `flutter run` (not only hot restart).
3. To expose the dev server on your LAN, set `server.host` to `0.0.0.0` in `web_dev_config.yaml` if your network policy allows it.

## Fallback: static build + Node proxy

If your SDK cannot use `web_dev_config.yaml`, build the web app and use **`scripts/dev-proxy`** (serves `build/web` and proxies `/api` the same way):

```bash
flutter build web
cd scripts/dev-proxy
npm install
npm start
```

Open `http://localhost:9090`. Optional: `API_TARGET=https://other-host.example npm start`

## Tests

```bash
dart analyze lib test
flutter test
```
