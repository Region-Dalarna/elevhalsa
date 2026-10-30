# UI-byggare: en flik per topic, med en ämnestext överst (se
# R/amnestexter.R), en listruta för att välja indikator
# (variabelnamn/heading) inom topicen och en gemensam yta som alltid
# visar den valda indikatorn - inte alla staplade under varandra.
# Åldersgrupp är en grupperingsdimension i diagrammen (se R/diagram.R),
# inte ett sidopanelsfilter - bara kommunkartan har en egen
# åldersgrupp-väljare, eftersom en karta bara kan visa en åldersgrupp
# åt gången.

# Gör om en text till ett giltigt, stabilt input/output-id.
elevhalsa_slug <- function(x) gsub("[^A-Za-z0-9]+", "_", x)

# En flik per topic: ämnestext + listruta + den gemensamma kort-ytan.
elevhalsa_bygg_flikar <- function(meta) {
  if (nrow(meta) == 0) return(list())
  lapply(unique(meta$topic), function(tp) {
    slug  <- elevhalsa_slug(tp)
    rader <- meta[meta$topic == tp, ]
    val   <- stats::setNames(rader$kort_id, rader$heading)
    txt   <- elevhalsa_hamta_amnestext(tp)
    tabPanel(
      tp,
      if (length(txt) > 0) {
        tags$div(class = "elevhalsa-amnestext", lapply(txt, function(t) tags$p(shiny::HTML(t))))
      },
      selectInput(paste0("val_", slug), NULL, choices = val, width = "100%"),
      elevhalsa_kort_ui(slug)
    )
  })
}

# Ytan för en flik: KPI-siffra, totalt/könsuppdelat-växlare (som i
# utbildning-appen, gäller Diagram + Alla svarsalternativ) och
# diagram/detalj/karta-flikar - fylls med innehåll för den indikator som
# är vald i flikens listruta. Kommunkartan visar alltid totalt per kommun
# och har en egen åldersgrupp-väljare.
elevhalsa_kort_ui <- function(slug) {
  tags$div(
    class = "elevhalsa-kort",
    tags$div(class = "elevhalsa-kort__kpi", textOutput(paste0("kpi_", slug))),
    shinyWidgets::radioGroupButtons(
      paste0("konval_", slug), label = NULL,
      choices = c("Totalt", "Könsuppdelat"), selected = "Totalt", size = "sm"
    ),
    tabsetPanel(
      type = "pills",
      tabPanel("Diagram", ggiraph::girafeOutput(paste0("diagram_", slug), height = "420px")),
      tabPanel("Alla svarsalternativ", ggiraph::girafeOutput(paste0("detalj_", slug), height = "420px")),
      tabPanel(
        "Kommunkarta",
        selectInput(
          paste0("karta_aldersgrupp_", slug), "Åldersgrupp",
          choices = elevhalsa_val_aldersgrupp, selected = elevhalsa_standardval_aldersgrupp
        ),
        ggiraph::girafeOutput(paste0("karta_", slug), height = "480px")
      )
    )
  )
}

# Föredraget standardval för åldersgrupp (t.ex. kommunkartans
# standardval), t.ex. "Åk 7" - den vanligaste åldersgruppen att titta
# på. Faller tillbaka på det första värdet om inget av mönstren hittas.
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
