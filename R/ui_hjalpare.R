# UI-byggare: en flik per topic, med en listruta för att välja indikator
# (variabelnamn/heading) inom topicen och en gemensam yta som alltid visar
# den valda indikatorn - inte alla staplade under varandra.

# Gör om en text till ett giltigt, stabilt input/output-id.
elevhalsa_slug <- function(x) gsub("[^A-Za-z0-9]+", "_", x)

# En flik per topic: listruta + den gemensamma kort-ytan för den fliken.
elevhalsa_bygg_flikar <- function(meta) {
  if (nrow(meta) == 0) return(list())
  lapply(unique(meta$topic), function(tp) {
    slug  <- elevhalsa_slug(tp)
    rader <- meta[meta$topic == tp, ]
    val   <- stats::setNames(rader$kort_id, rader$heading)
    tabPanel(
      tp,
      selectInput(paste0("val_", slug), NULL, choices = val, width = "100%"),
      elevhalsa_kort_ui(slug)
    )
  })
}

# Ytan för en flik: KPI-siffra, diagram/karta-växlare och (om ifylld)
# analystext - fylls med innehåll för den indikator som är vald i
# flikens listruta. Diagrammet har en egen totalt/könsuppdelat-växlare
# (som i utbildning-appen); kartan visar alltid totalt per kommun.
elevhalsa_kort_ui <- function(slug) {
  tags$div(
    class = "elevhalsa-kort",
    tags$div(class = "elevhalsa-kort__kpi", textOutput(paste0("kpi_", slug))),
    tabsetPanel(
      type = "pills",
      tabPanel(
        "Diagram",
        shinyWidgets::radioGroupButtons(
          paste0("konval_", slug), label = NULL,
          choices = c("Totalt", "Könsuppdelat"), selected = "Totalt", size = "sm"
        ),
        ggiraph::girafeOutput(paste0("diagram_", slug), height = "420px")
      ),
      tabPanel("Kommunkarta", ggiraph::girafeOutput(paste0("karta_", slug), height = "480px"))
    ),
    uiOutput(paste0("analys_", slug))
  )
}

# Föredraget standardval för åldersgrupp-filtret vid appstart, t.ex.
# "Årskurs 7" - den vanligaste åldersgruppen att titta på, så appen visar
# data direkt istället för den (alfabetiskt) första åldersgruppen. Faller
# tillbaka på det första värdet om inget av mönstren hittas.
elevhalsa_standardval <- function(val, monster = "(?i)^(årskurs|åk)\\s*7$") {
  if (length(val) == 0) return(val)
  traff <- grep(monster, val, perl = TRUE, value = TRUE)
  if (length(traff) > 0) traff[1] else val[1]
}

# Sorterade, unika filtreringsval ur den inlästa datan. `sortering_kolumn`
# används om man vill sortera på t.ex. SorteringRegion istället för
# alfabetiskt.
elevhalsa_filterval <- function(df, kolumn, sortering_kolumn = NULL) {
  if (nrow(df) == 0) return(character())
  if (is.null(sortering_kolumn)) {
    return(sort(unique(df[[kolumn]])))
  }
  unika <- unique(df[, c(kolumn, sortering_kolumn)])
  unika <- unika[order(unika[[sortering_kolumn]]), ]
  unika[[kolumn]]
}
