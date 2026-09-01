(function initializePwaInstallBridge() {
  'use strict';

  if (window.unitConverterPwaInstallBridge) {
    return;
  }

  let deferredPrompt = null;
  let installed = isStandalone();
  const listeners = new Set();

  function isStandalone() {
    const displayModeStandalone =
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(display-mode: standalone)').matches;
    return displayModeStandalone || navigator.standalone === true;
  }

  function isIos() {
    const userAgent = navigator.userAgent || '';
    const classicIos = /iPad|iPhone|iPod/.test(userAgent);
    const ipadDesktopMode =
      navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1;
    return classicIos || ipadDesktopMode;
  }

  function notify(eventName) {
    for (const listener of Array.from(listeners)) {
      try {
        listener(eventName);
      } catch (_) {
        // A Dart listener may have been disposed between event dispatches.
      }
    }
  }

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
    notify('promptAvailable');
  });

  window.addEventListener('appinstalled', () => {
    deferredPrompt = null;
    installed = true;
    notify('installed');
  });

  const bridge = {
    getSnapshot() {
      return {
        installed: installed || isStandalone(),
        ios: isIos(),
        canPrompt: deferredPrompt !== null,
      };
    },

    subscribe(listener) {
      listeners.add(listener);
    },

    unsubscribe(listener) {
      listeners.delete(listener);
    },

    async promptInstall() {
      const promptEvent = deferredPrompt;
      if (!promptEvent) {
        return { outcome: 'unavailable' };
      }

      // BeforeInstallPromptEvent.prompt() is one-shot. Clear our reference
      // before awaiting so repeated UI taps cannot display it twice.
      deferredPrompt = null;
      try {
        const promptResult = await promptEvent.prompt();
        const choice =
          promptResult && promptResult.outcome
            ? promptResult
            : await promptEvent.userChoice;
        const outcome =
          choice && choice.outcome === 'accepted'
            ? 'accepted'
            : choice && choice.outcome === 'dismissed'
              ? 'dismissed'
              : 'unavailable';
        if (outcome === 'accepted') {
          installed = true;
        }
        return { outcome };
      } catch (_) {
        return { outcome: 'unavailable' };
      }
    },
  };

  Object.defineProperty(window, 'unitConverterPwaInstallBridge', {
    configurable: false,
    enumerable: false,
    writable: false,
    value: Object.freeze(bridge),
  });
})();
