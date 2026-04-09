/**
 * Cloudflare Worker — static Flutter web SPA + Supabase Edge Function proxy.
 *
 * Routes:
 *   OPTIONS /supabase-fn/*  → CORS preflight (200)
 *   ANY     /supabase-fn/*  → proxy to Supabase Edge Functions (adds CORS headers)
 *   ANY     /*              → serve static Flutter web assets from build/web
 *
 * This lets the Flutter web app call Supabase Edge Functions via same-origin
 * requests (/supabase-fn/...) instead of cross-origin (supabase.co), eliminating
 * CORS errors without modifying the Edge Functions themselves.
 *
 * To add a new Edge Function call from Flutter, just call:
 *   /supabase-fn/<function-name>
 * No changes needed here.
 */

const SUPABASE_FUNCTIONS_URL = 'https://fmaapwiagvixhfjdbwdn.supabase.co/functions/v1';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Max-Age': '86400',
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.startsWith('/supabase-fn/')) {
      // Handle CORS preflight
      if (request.method === 'OPTIONS') {
        return new Response(null, { status: 204, headers: CORS_HEADERS });
      }

      // Strip /supabase-fn/ prefix and forward to Supabase
      const fnPath = url.pathname.slice('/supabase-fn/'.length);
      const target = `${SUPABASE_FUNCTIONS_URL}/${fnPath}${url.search}`;

      const upstreamRequest = new Request(target, {
        method: request.method,
        headers: request.headers,
        body: request.body,
      });

      const upstreamResponse = await fetch(upstreamRequest);

      // Merge CORS headers into the upstream response
      const responseHeaders = new Headers(upstreamResponse.headers);
      for (const [key, value] of Object.entries(CORS_HEADERS)) {
        responseHeaders.set(key, value);
      }

      return new Response(upstreamResponse.body, {
        status: upstreamResponse.status,
        statusText: upstreamResponse.statusText,
        headers: responseHeaders,
      });
    }

    // All other requests → serve static Flutter web assets
    return env.ASSETS.fetch(request);
  },
};
