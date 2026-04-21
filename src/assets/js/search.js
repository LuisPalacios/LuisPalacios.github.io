document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('searchInput');
    const searchResults = document.getElementById('customSearchResults');

    // Verificar si los elementos existen antes de continuar
    if (!searchInput || !searchResults) {
        return; // Salir si no estamos en la página de búsqueda
    }

    let fuse, items = [];
    const searchSection = document.querySelector('.search[data-search-index]');
    const searchIndexUrl = searchSection ? searchSection.dataset.searchIndex : '/index.json';

    fetch(searchIndexUrl)
        .then(res => res.json())
        .then(json => {
            items = json;
            fuse = new Fuse(items, {
                keys: [
                    { name: 'title', weight: 0.5 },
                    { name: 'summary', weight: 0.3 },
                    { name: 'tags', weight: 0.2 },
                    { name: 'categories', weight: 0.2 }
                ],
                includeScore: true,
                threshold: 0.4
            });
        })
        .catch(error => {
            console.error('Error loading search index:', error);
        });

    function doSearch() {
        const query = searchInput.value.trim();
        if (!query || !fuse) {
            searchResults.innerHTML = '';
            return;
        }

        const results = fuse.search(query);
        searchResults.innerHTML = results.map(result => {
            const item = result.item;
            const coverImage = item.cover?.image ? `<img src="${item.cover.image}" class="search-thumb">` : '';

            return `
                <li class="search-item">
                    <a href="${item.permalink}">
                        <div class="search-card-layout">
                            ${coverImage}
                            <div class="search-card-body">
                                <div class="search-item-title">${item.title}</div>
                                <div class="search-item-url"><i>${item.permalink}</i></div>
                                <div class="search-item-summary">${truncate(item.summary, 160)}</div>
                            </div>
                        </div>
                    </a>
                </li>
            `;
        }).join('');
    }

    searchInput.addEventListener('input', doSearch);
    searchInput.addEventListener('keyup', doSearch);
    searchInput.addEventListener('compositionend', doSearch);

    function truncate(str, max) {
        return str.length > max ? str.slice(0, max) + '…' : str;
    }
});
