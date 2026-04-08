/**
 * Fallback local server: serves `build/web` and proxies `/api` → browserapi (same as Vite).
 * Use when testing a static web build without `flutter run` (e.g. old SDK without web_dev_config).
 *
 *   flutter build web
 *   cd scripts/dev-proxy && npm install && npm start
 *   open http://localhost:9090
 */
import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import path from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.join(__dirname, '../../build/web');
const target = process.env.API_TARGET || 'https://browserapi.eatos.net';

const app = express();

app.use(
  '/api',
  createProxyMiddleware({
    target,
    changeOrigin: true,
    pathRewrite: { '^/api': '' },
    secure: false,
  }),
);

if (!existsSync(path.join(webRoot, 'index.html'))) {
  console.warn('[dev-proxy] Missing build/web/index.html — run: flutter build web');
}

app.use(express.static(webRoot));
app.get('*', (req, res) => {
  res.sendFile(path.join(webRoot, 'index.html'));
});

const port = Number(process.env.PORT || 9090);
app.listen(port, () => {
  console.log(`Dev proxy http://localhost:${port}  (GET app; /api → ${target})`);
});
