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

Menyn byggs dynamiskt ur datan: en flik per `topic`, med en listruta i
varje flik för att välja indikator (`variabelnamn`/`heading`) - bara den
valda indikatorn visas, inte alla staplade under varandra. Nya
frågor/ämnen i tabellen dyker upp i appen automatiskt, inget behöver
hårdkodas i UI:t.

Varje flik har två vyer: **Diagram** (med en inbyggd
Sammanfattning/Alla svar-växlare - headline-andelen `pos_neg == 100`
respektive alla ursprungliga svarsalternativ, 100 %-staplat) och
**Karta** (`R/karta.R`), som alltid visar alla 15 kommuner samtidigt -
datan finns bara på kommunnivå, ingen nivå under, så kartan lyssnar inte
på regionfiltret i sidopanelen, och har en egen åldersgrupp-väljare (en
karta kan bara visa en åldersgrupp åt gången). Kommunnamnet i `region`
kopplas till kommunpolygonerna via kommunkod
(`rdverktyg::hamta_kommunkoder()`). Klick-markering i diagrammen är
avstängd (`opts_selection(type = "none")`) - bara mouseover-tooltip
används, ingen korsfiltrering.

Åldersgrupp är INTE ett filter längre - den visas som
grupperingsdimension på x-axeln i diagrammen (Förskoleklass/Åk 4/Åk 7/
År 1 gymnasiet sida vid sida), ordnad pedagogiskt istället för
alfabetiskt (`ALDERSGRUPP_ORDNING`/`elevhalsa_ordna_aldersgrupp()` i
R/data.R). Inspirerat av den tidigare Power BI-rapporten, som visade
årskurserna sida vid sida istället för som ett filter som döljer de
andra.

Ämnestexten ("Kort om frågeområdet") ligger i sidopanelen (inte inline
ovanför diagrammen, så de får huvudytan för sig själva), reaktiv mot
vilken flik som är aktiv (`output$sidopanel_amnestext` i server.R).
Innehållet är redaktionellt från Samhällsanalys, hårdkodat i
`R/amnestexter.R` (inte läst ur `analys`-kolumnen i databasen, som bara
innehöll platshållartext).

Diagram och karta är ren `ggplot2` + `ggiraph` (`geom_col_interactive`/
`geom_sf_interactive`), enligt samma mönster som `utbildning`
(`R/func_diagram.R`, `R/func_karta.R`) och `digidel`
(`R/karta_digidel.R`) - inte `rddiagram`. Kommunpolygonerna hämtas direkt
med `dplyr`/`dbplyr` mot `karta.kommun_scb` och görs om till `sf` med
`rdshinyappar::df_till_sf()`, samma mönster som i de apparna. Svar/kommuner
med för få individer (`litet_urval`) ritas som gråa platshållare med
`< 5` i tooltipen istället för att visa sitt riktiga värde.

Diagrammet har en Totalt/Könsuppdelat-växlare (`R/diagram.R`), som i
`utbildning`-appen - men till skillnad från den appens antalsdiagram
visas könen sida vid sida (dodge), inte staplade, eftersom andelar inte
är additiva. "Totalt" plockar bara ut den befintliga `kon == "Totalt"`-
raden (`elevhalsa_summera_totalt()`) - andelar räknas aldrig om eller
summeras fram i appen, alla andelar är redan färdigberäknade i
databasen. Kön är inte längre ett sidopanelsfilter - det styrs per
diagram.

**Undantag från "inga andelar beräknas":** vissa frågor levererar
headline-andelen (`pos_neg == 100`) uppdelad på flera råa
svarsalternativ istället för en enda färdig rad (t.ex. "3-4 dagar",
"5-6 dagar" och "Varje dag" som alla räknas som "minst tre dagar i
veckan"). Utan summering skulle sammanfattningsstapeln bara visa en
bråkdel av rätt andel. `elevhalsa_summera_headline()` i `R/diagram.R`
adderar därför ihop redan färdigberäknade procenttal inom samma grupp
(åldersgrupp, ev. + kön/region) - det är addition av befintliga tal,
inte en ny statistisk beräkning från råa antal. Användaren godkände
detta undantag uttryckligen (2026-10-30) efter att ha sett att
diagrammet annars visade flera synliga segment istället för en tydlig
andel.

Kommunkartans egna åldersgrupp-väljare väljer "Åk 7" som standard om det
finns i datan (`elevhalsa_standardval()` i `R/ui_hjalpare.R`).

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
