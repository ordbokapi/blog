# Ordbok API Utviklingsblogg

Dette er bloggen for Ordbok API. Her vil me leggje ut nyhende og oppdateringar om API-et.

## Korleis starte

Bloggen er skriven i Markdown og brukar [Jekyll](https://jekyllrb.com/) som statisk nettstadgenerator. For å starte bloggen lokalt, kan du fylgje desse stega:

```shell
git clone https://github.com/ordbokapi/blog.git
cd blog
```

Viss du brukar [VS Code](https://code.visualstudio.com/), kan du opne mappa i VS Code med:

```shell
code .
```

Kodelageret har [dev-konteinarar](https://code.visualstudio.com/docs/devcontainers/containers) konfigurerte. Du skal sjå ei melding om at du kan opne mappa i ein dev-konteinar. Dette vil setja opp eit utviklingsmiljø med alle nødvendige avhengnader installerte.

Viss du ikkje brukar VS Code, kan du installere avhengnadene manuelt. Du treng [Ruby](https://www.ruby-lang.org/en/documentation/installation/) og [Bundler](https://bundler.io/) installert.
Etter at du har installert Ruby og Bundler, kan du installere avhengnadene med:

```shell
bundle install
rake postinstall
```

Etter fyrste gong du køyrer `bundle install`, kan du etterpå, i staden for å køyre både `bundle install` og `rake postinstall`, berre køyre:

```shell
rake install
```

Bloggen vil då vera tilgjengeleg på [http://localhost:4000](http://localhost:4000).

## Rake-kommandoar

Bloggen har fleire nyttige Rake-oppgåver for å forenkle utviklinga. Her er dei viktigaste:

### Installasjon og oppsett

- `rake install` — Installerer alle avhengnader og køyrer postinstall-oppgåver (kopierer Bootstrap, lastar ned lunr.js).
- `rake postinstall` — Køyrer berre postinstall-oppgåver (ikkje naudsynt å køyre manuelt om ein køyrer `rake install`).

### Utvikling og bygging

- `rake serve` — Startar Jekyll-sørvaren lokalt med utkast og livereload, tilgjengeleg på [http://localhost:4000](http://localhost:4000).
- `rake build` — Byggjer nettstaden statisk i `_site`-mappa.

### Arbeid med utkast og innlegg

- `rake draft:new -- -t "Tittel på utkast"` — Opprettar eit nytt utkast i `_drafts/` med YAML-frontmatter.
- `rake draft:publish -- -t "Tittel på utkast"` — Publiserer eit utkast til `_posts/` og flyttar eventuelle vedlegg.
- `rake draft:publish -- -a` — Publiserer alle utkast.

### Varsling om nye innlegg

- `rake notify_new_post` — Varslar eksternt API om nytt innlegg (vert bruka under utrulling av nye innlegg i GitHub Actions).

### Nyttig verktøy

- `rake timestamp` — Skriv ut tidsstempel i rett format for innlegg.

## Typisk arbeidsflyt

1. Installer avhengnader: `rake install`
2. Start utviklingssørvar: `rake serve`
3. Lag eit nytt utkast: `rake draft:new -- -t "Tittel på utkast"`
4. Rediger utkastet i `_drafts/`-mappa.
5. Publiser utkastet når det er klart: `rake draft:publish -- -t "Tittel på utkast"`
6. Sjekk inn endringar i Git.
7. Push til GitHub, som vil byggje og publisere bloggen automatisk, og varsle abonnentar om det nye innlegget.

Sjå [Rakefile](Rakefile) for fleire detaljar om kvar oppgåve.

## Lisens

Tekstinnhaldet på bloggen er lisensiert under [Creative Commons Navngivelse-DelPåSammeVilkår 4.0 Internasjonal](https://creativecommons.org/licenses/by-sa/4.0/deed.no), medan koden er lisensiert under [ISC](https://opensource.org/licenses/ISC).

Sjå [LICENCE](LICENCE) for meir informasjon.
