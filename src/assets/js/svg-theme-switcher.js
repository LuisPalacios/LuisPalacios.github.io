// SVG Theme Switcher - Cambia automáticamente SVGs por versiones -dark.svg
document.addEventListener("DOMContentLoaded", function () {

  // Función para obtener el tema actual
  function getCurrentTheme() {
    return localStorage.getItem("pref-theme") === "dark";
  }

    // Función para verificar si existe la versión dark del SVG
  async function checkDarkVersion(originalSrc) {
    console.log(`🔎 Checking dark version for: ${originalSrc}`);

    const urlsToTry = [];

    // Generar diferentes variantes de URL para intentar
    if (originalSrc.startsWith('http')) {
      const url = new URL(originalSrc);

      // 1. URL absoluta con mismo protocolo
      urlsToTry.push(originalSrc.replace(/\.svg$/, "-dark.svg"));

      // 2. URL absoluta con https (si era http)
      if (url.protocol === 'http:') {
        const httpsUrl = originalSrc.replace('http://', 'https://').replace(/\.svg$/, "-dark.svg");
        urlsToTry.push(httpsUrl);
      }

      // 3. Ruta relativa
      urlsToTry.push(url.pathname.replace(/\.svg$/, "-dark.svg"));

    } else {
      // URL relativa
      urlsToTry.push(originalSrc.replace(/\.svg$/, "-dark.svg"));
    }

    // Intentar cada URL hasta encontrar una que funcione
    for (const [index, urlToTry] of urlsToTry.entries()) {
      try {
        console.log(`🔍 Attempt ${index + 1}: ${urlToTry}`);
        const response = await fetch(urlToTry, { method: "HEAD" });
        if (response.ok) {
          console.log(`✅ Found dark version at: ${urlToTry}`);
          return urlToTry;
        } else {
          console.log(`❌ Not found (${response.status}): ${urlToTry}`);
        }
      } catch (error) {
        console.log(`💥 Error with ${urlToTry}: ${error.message}`);
      }
    }

    console.log(`❌ No dark version found for: ${originalSrc}`);
    return null;
  }

    // Función para procesar una imagen específica
  async function processImage(img, isDark) {
    const src = img.getAttribute("src");
    if (!src || !src.endsWith(".svg")) return;

    // Solo procesar SVGs que están en img/posts/ (cualquier forma de la ruta)
    if (!src.includes("img/posts/")) return;

    // Guardar src original si no existe
    if (!img.dataset.originalSrc) {
      img.dataset.originalSrc = src;
    }

    console.log(`🔄 Processing SVG: ${src}, isDark: ${isDark}`);
    console.log(`📍 Original src stored: ${img.dataset.originalSrc}`);
    console.log(`🌐 Current location: ${window.location.href}`);

    if (isDark) {
      // Cambiar a versión dark
      const darkSrc = await checkDarkVersion(img.dataset.originalSrc);
      if (darkSrc) {
        console.log(`🌙 Changing to dark version: ${darkSrc}`);
        img.setAttribute("src", darkSrc);
      } else {
        console.log(`❌ Dark version not found for: ${img.dataset.originalSrc}`);
        console.log(`🔍 Attempted dark URL would be: ${img.dataset.originalSrc.replace(/\.svg$/, "-dark.svg")}`);
      }
    } else {
      // Restaurar versión original
      console.log(`☀️ Restoring original: ${img.dataset.originalSrc}`);
      img.setAttribute("src", img.dataset.originalSrc);
    }
  }

    // Función para procesar elementos con background-image
  async function processBackgroundImage(element, isDark) {
    const style = window.getComputedStyle(element);
    const bgImage = style.backgroundImage;

    if (!bgImage || !bgImage.includes(".svg")) return;

    // Solo procesar background SVGs que están en img/posts/ (cualquier forma)
    if (!bgImage.includes("img/posts/")) return;

    // Extraer URL del background-image
    const urlMatch = bgImage.match(/url\(["']?([^"')]+)["']?\)/);
    if (!urlMatch) return;

    const originalSrc = urlMatch[1];

    if (!element.dataset.originalBgSrc) {
      element.dataset.originalBgSrc = originalSrc;
    }

    console.log(`🔄 Processing background SVG: ${originalSrc}, isDark: ${isDark}`);

    if (isDark) {
      const darkSrc = await checkDarkVersion(element.dataset.originalBgSrc);
      if (darkSrc) {
        console.log(`🌙 Changing background to dark version: ${darkSrc}`);
        element.style.backgroundImage = `url(${darkSrc})`;
      }
    } else {
      console.log(`☀️ Restoring original background: ${element.dataset.originalBgSrc}`);
      element.style.backgroundImage = `url(${element.dataset.originalBgSrc})`;
    }
  }

      // Función para procesar todas las imágenes SVG
  async function processAllImages(isDark) {
    console.log(`🎨 Processing all images - Theme: ${isDark ? 'dark' : 'light'}`);

    // Buscar imágenes SVG de diferentes formas
    const allSvgImages = document.querySelectorAll("img[src$='.svg']");
    const postsImages = [];

    // Filtrar manualmente las que contienen img/posts
    allSvgImages.forEach(img => {
      if (img.src.includes('img/posts')) {
        postsImages.push(img);
      }
    });

    console.log(`📊 Total SVG images found: ${allSvgImages.length}`);
    console.log(`📊 img/posts SVG images found: ${postsImages.length}`);

    // Mostrar todas las URLs de SVG para debugging
    allSvgImages.forEach((img, index) => {
      const isPostsImage = img.src.includes('img/posts');
      console.log(`🖼️ SVG ${index + 1}: ${img.src} ${isPostsImage ? '✅' : '❌'}`);
    });

    // Procesar cada imagen que contenga img/posts
    for (const img of postsImages) {
      console.log(`⚙️ Processing: ${img.src}`);
      await processImage(img, isDark);
    }

    // Procesar elementos con background-image
    const allElements = document.querySelectorAll("*");
    for (const element of allElements) {
      await processBackgroundImage(element, isDark);
    }
  }

    // Función principal para aplicar tema
  function applyTheme() {
    const isDark = getCurrentTheme();
    const bodyClass = document.body.className;
    const localStorageTheme = localStorage.getItem("pref-theme");

    console.log(`🎯 Applying theme: ${isDark ? 'dark' : 'light'}`);
    console.log(`📋 Body classes: ${bodyClass}`);
    console.log(`💾 localStorage pref-theme: ${localStorageTheme}`);
    console.log(`🌙 Body has .dark class: ${document.body.classList.contains('dark')}`);

    // Pequeño delay para asegurar que el DOM está listo
    setTimeout(() => {
      processAllImages(isDark);
    }, 50);
  }

  // Función para interceptar clics del botón de tema
  function interceptThemeButton() {
    const themeButton = document.getElementById("theme-toggle");
    if (themeButton) {
      themeButton.addEventListener("click", function() {
        // Delay para que localStorage se actualice primero
        setTimeout(() => {
          applyTheme();
        }, 100);
      });
    }
  }

  // Observador para detectar cambios en el body (tema)
  const bodyObserver = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        // El tema cambió
        setTimeout(() => {
          applyTheme();
        }, 50);
      }
    });
  });

  // Observador para nuevas imágenes añadidas al DOM
  const domObserver = new MutationObserver(function(mutations) {
    let hasNewImages = false;

    mutations.forEach(function(mutation) {
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) { // Element node
            // Verificar si es una imagen SVG o contiene imágenes SVG
            if ((node.tagName === 'IMG' && node.src && node.src.endsWith('.svg') && node.src.includes('/img/posts/')) ||
                (node.querySelectorAll && node.querySelectorAll('img[src*="/img/posts/"][src$=".svg"]').length > 0)) {
              hasNewImages = true;
            }
          }
        });
      }
    });

    if (hasNewImages) {
      const isDark = getCurrentTheme();
      setTimeout(() => processAllImages(isDark), 100);
    }
  });

    // Función global para debugging manual
  window.debugSvgSwitcher = function() {
    console.log("🐛 Manual debug execution");
    applyTheme();
  };

  window.forceDarkSvg = function() {
    console.log("🌙 Forcing dark theme for SVGs");
    processAllImages(true);
  };

  window.forceLightSvg = function() {
    console.log("☀️ Forcing light theme for SVGs");
    processAllImages(false);
  };

  // Inicialización
  console.log("🚀 SVG Theme Switcher initialized");
  console.log("🛠️ Debug functions available: debugSvgSwitcher(), forceDarkSvg(), forceLightSvg()");

  // Aplicar tema inicial
  applyTheme();

  // Configurar interceptor de botón de tema
  interceptThemeButton();

  // Iniciar observadores
  bodyObserver.observe(document.body, {
    attributes: true,
    attributeFilter: ['class']
  });

  domObserver.observe(document.body, {
    childList: true,
    subtree: true
  });

  // También aplicar después de que se carguen todas las imágenes
  window.addEventListener('load', function() {
    setTimeout(() => {
      applyTheme();
    }, 100);
  });

  // Escuchar cambios de almacenamiento local (por si acaso)
  window.addEventListener('storage', function(e) {
    if (e.key === 'pref-theme') {
      applyTheme();
    }
  });

});