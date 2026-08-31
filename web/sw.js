const CACHE_PREFIX = 'unit-converter-shell-';
const workerUrl = new URL(self.location.href);
const buildVersion = workerUrl.searchParams.get('v') || 'unversioned';
const CACHE_NAME = CACHE_PREFIX + buildVersion;

const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './flutter_bootstrap.js',
  './pwa_install_bridge.js',
  './main.dart.js',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/Icon-maskable-192.png',
  './icons/Icon-maskable-512.png',
  './canvaskit/canvaskit.js',
  './canvaskit/canvaskit.wasm',
  './assets/AssetManifest.bin.json',
  './assets/FontManifest.json',
  './assets/fonts/MaterialIcons-Regular.otf',
  './assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  './assets/shaders/ink_sparkle.frag',
  './assets/shaders/stretch_effect.frag',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter(
              (key) => key.startsWith(CACHE_PREFIX) && key !== CACHE_NAME,
            )
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') {
    return;
  }

  const requestUrl = new URL(event.request.url);
  if (
    requestUrl.origin !== self.location.origin ||
    requestUrl.pathname.startsWith('/__/') ||
    event.request.headers.has('range')
  ) {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then(async (response) => {
        if (response.ok && response.type === 'basic') {
          const cache = await caches.open(CACHE_NAME);
          await cache.put(event.request, response.clone());
        }
        return response;
      })
      .catch(async () => {
        const cache = await caches.open(CACHE_NAME);
        const cached = await cache.match(event.request);
        if (cached) {
          return cached;
        }
        if (event.request.mode === 'navigate') {
          return cache.match('./index.html');
        }
        throw new Error('Offline resource unavailable: ' + event.request.url);
      }),
  );
});
