# elevhalsa

Detta repository innehåller en Shinyapplikation (`elevhalsa`) för
Samhällsanalys, Region Dalarna.

## Data

Appen läser hela tabellen `folkhalsa.elevhalsa` ur databasen `sekretess`
en gång vid appstart (`elevhalsa_hamta_data()` i `R/data.R`). Databasen
heter `sekretess` av andra, historiska skäl - den här tabellen är inte i
sig hemlig. Siffror som bygger på färre än `LITET_URVAL_TROSKEL` (5) svar
döljs ändå och visas som `< 5`, i linje med regionens övriga
statistikappar (`elevhalsa_maskera_litet_urval()`).

Meny-/kortstrukturen (flikar per `topic`, kort per `variabelnamn`/
`heading`) byggs dynamiskt ur datan - nya frågor/ämnen i tabellen dyker
upp i appen automatiskt, inget behöver hårdkodas i UI:t.

Varje kort har förutom stapeldiagrammet (filtrerat på valt regionfilter)
även en kommunkarta (`R/karta.R`) som alltid visar alla 15 kommuner
samtidigt - datan finns bara på kommunnivå, ingen nivå under, så kartan
lyssnar inte på regionfiltret i sidopanelen. Kartan visar andelen för
den rad per kommun där `pos_neg == 100`, samma värde som KPI-siffran.
Kommunnamnet i `region` kopplas till kommunpolygonerna via kommunkod
(`rdverktyg::hamta_kommunkoder()` + `rdgis::hamta_karta()`).

**Att stämma av när riktig data finns på plats:** de exakta kolumnnamnen
(särskilt stavning/skiftläge på t.ex. svarssorteringskolumnen) antogs
utifrån ett utsnitt av datan - `elevhalsa_std_namn()` matchar oberoende
av skiftläge, men bör dubbelkollas mot verkliga kolumnnamn i databasen.

## Struktur

Appfilerna ligger **direkt i repo-roten** (så att Shiny Server kör appen utan omväg):

- `ui.R`, `server.R`, `global.R`
- `www/` för favicon, logotyp, CSS (`regiondalarna_ruf.css` + `app.css`) och `fonts/`
- `R/` för hjälpfunktioner
- `_dependencies.R` i root listar alla paket appen använder (läses av `renv::dependencies()`, körs aldrig)
- `_publicering_till_server.yml` i root styr vilken Shiny-server som är default för `shinyapp_publicera()`
- `renv.lock` + `renv/` + `.Rprofile` styr paketversioner. Kör `renv::restore()` efter klon.

## Deploy

Sker via GitHub Actions:

- `.github/workflows/deploy.yml` – publicerar vid push till `publicera-publik` eller `publicera-intern`
- `.github/workflows/avpublicera.yml` – tar bort appen från vald server (manuell trigger)

Appmapp på servern: `/srv/shiny-server/elevhalsa`.

Publicera med `rddeploy::shinyapp_publicera("elevhalsa")`.
