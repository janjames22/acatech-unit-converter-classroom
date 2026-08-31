{{flutter_js}}
{{flutter_build_config}}

// Flutter's generated service worker is deprecated. Register the app-owned
// worker here and call the Flutter loader without serviceWorkerSettings so the
// generated cleanup worker can never replace sw.js.
const serviceWorkerVersion = {{flutter_service_worker_version}};
const localPreviewHosts = new Set([
  'localhost',
  '127.0.0.1',
  '::1',
  '[::1]',
]);
const enableLocalServiceWorker =
  new URLSearchParams(window.location.search).get('enable-sw') === '1';
const isLocalPreview = localPreviewHosts.has(window.location.hostname);
const shouldRegisterServiceWorker =
  'serviceWorker' in navigator &&
  window.isSecureContext &&
  (!isLocalPreview || enableLocalServiceWorker);

if (shouldRegisterServiceWorker) {
  const versionQuery =
    serviceWorkerVersion == null
      ? ''
      : '?v=' + encodeURIComponent(serviceWorkerVersion);
  navigator.serviceWorker
    .register('sw.js' + versionQuery, { scope: './' })
    .catch((error) => {
      console.warn('Unit Converter service worker registration failed.', error);
    });
}

_flutter.loader.load();
