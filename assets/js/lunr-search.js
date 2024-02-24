document.addEventListener('DOMContentLoaded', async () => {
  const lunrDocuments = await fetch('/search_index.json').then((response) =>
    response.json()
  );

  if (!lunrDocuments) {
    return;
  }

  const index = lunr(function () {
    this.ref('id');
    this.field('title');
    this.field('body');

    lunrDocuments.forEach((doc) => this.add(doc));
  });

  document.querySelectorAll('.lunr-search-group').forEach((group) => {
    const form = group.querySelector('.lunr-search-form');
    const input = group.querySelector('.lunr-search');
    const resultsElement = group.querySelector('.lunr-search-results');

    if (!form || !input || !resultsElement) {
      console.warn('Missing form, input or results element');
      console.warn('form', form, 'input', input, 'results', resultsElement);
      return;
    }

    form.addEventListener('submit', (event) => {
      event.preventDefault();
      const searchTerm = input.value;
      displaySearchResults(searchTerm);
    });

    let timeout;

    input.addEventListener('input', (event) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        const searchTerm = event.target.value;
        displaySearchResults(searchTerm);
      }, 300);
    });

    const displaySearchResults = (term) => {
      resultsElement.style.display = 'block';
      resultsElement.innerHTML = '<div class="list-group"></div>';

      if (term) {
        const results = index.search(term);
        let resultsHTML = `<p class="mb-1">Treff for '${term}'</p><div class="list-group">`;

        if (results.length > 0) {
          results.forEach(({ ref }) => {
            const { url, title, body } = lunrDocuments[ref];
            const summary = `${body.substring(0, 160)}...`;
            resultsHTML += `
            <a href="${url}" class="list-group-item list-group-item-action" aria-current="true">
              <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1">${title}</h5> <!-- Changed to h5 for better semantic use and Bootstrap styling -->
              </div>
              <p class="mb-1">${summary}</p>
              <small>${url}</small>
            </a>`;
          });
        } else {
          resultsHTML += '<p class="list-group-item">Ingen treff</p>';
        }

        resultsHTML += '</div>';
        resultsElement.innerHTML = resultsHTML;
      }
    };

    document.addEventListener('click', (event) => {
      if (!group.contains(event.target)) {
        resultsElement.style.display = 'none';
      }
    });
  });
});
