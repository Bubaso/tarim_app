{{flutter_js}}
{{flutter_build_config}}

// PWA (Progressive Web App) offline support configuration.
// By explicitly configuring the serviceWorkerSettings, we ensure that
// flutter_service_worker.js is registered correctly and caches all assets
// for offline usage.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
