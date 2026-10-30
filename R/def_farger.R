# Färger och interaktiv CSS för ggiraph-diagrammen/kartan. Samma mönster
# som utbildning/R/def_farger.R: läser :root-variablerna ur de delade
# CSS-filerna vid uppstart så att R-renderade grafer och CSS:en delar
# definitioner, med hex-fallback om en variabel/fil skulle saknas.

.las_css_variabler <- function(filer) {
  rader <- unlist(lapply(filer, function(f) {
    if (file.exists(f)) readLines(f, warn = FALSE, encoding = "UTF-8") else character(0)
  }))
  m <- regmatches(
    rader,
    regexec("--([A-Za-z0-9_-]+)[[:space:]]*:[[:space:]]*([^;]+);", rader)
  )
  m <- m[lengths(m) == 3]
  if (!length(m)) return(stats::setNames(character(0), character(0)))
  namn <- vapply(m, `[`, character(1), 2)
  vals <- trimws(vapply(m, `[`, character(1), 3))
  vals <- stats::setNames(vals, namn)
  vals[!duplicated(names(vals), fromLast = TRUE)]
}

.RD_CSS <- .las_css_variabler(c("www/regiondalarna_ruf.css", "www/app.css"))

rd_farg <- function(namn, fallback = "#000000") {
  if (!namn %in% names(.RD_CSS)) return(fallback)
  v <- .RD_CSS[[namn]]
  if (is.null(v) || is.na(v) || !nzchar(v)) fallback else v
}

RD_PRIMARY    <- rd_farg("rd-primary",    "#158daf")
RD_TEXT       <- rd_farg("rd-text",       "#212529")
RD_TEXT_MUTED <- rd_farg("rd-text-muted", "#6c757d")

# Grå platshållarfärg för staplar/kommuner som döljs p.g.a. för få svar
# (se LITET_URVAL_TROSKEL i global.R).
LITET_URVAL_FARG <- "#e1e5e8"

# Könsfärger för det könsuppdelade diagrammet - samma vektor som
# utbildning-appen (rd-kon-kvinnor/rd-kon-man), fast med elevhalsas egna
# könskategorier som namn.
KON_FARGER <- c(
  "Flickor" = rd_farg("rd-kon-kvinnor", "#e2a855"),
  "Pojkar"  = rd_farg("rd-kon-man",     "#459079")
)

# Interaktiv css (ligger i DOM:en, kan använda var(--rd-...) rakt av).
RD_TOOLTIP_CSS <- paste0(
  "background:var(--rd-text);color:#fff;padding:6px 9px;",
  "border-radius:4px;font-family:Poppins,Arial,sans-serif;font-size:12px;"
)
RD_HOVER_CSS       <- "fill:var(--rd-primary-dark);cursor:pointer;"
RD_KARTA_HOVER_CSS <- "filter:brightness(0.88);cursor:pointer;"
# Relativ mörkning istället för en fast färg - för diagram med flera
# fyllnadsfärger i samma legend (t.ex. Könsuppdelat och "Alla svar" i
# R/diagram.R), där RD_HOVER_CSS annars skulle byta ut VILKEN färg som
# helst mot samma mörkblå och göra det svårt att se vilket svarsalternativ
# man pekar på.
RD_HOVER_CSS_FLERFARGAD <- "filter:brightness(0.82);cursor:pointer;"
