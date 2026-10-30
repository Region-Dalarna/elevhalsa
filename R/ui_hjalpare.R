# UI-byggare: ett "kort" per variabelnamn/heading, och en flik per topic.

# Ett enskilt kort: rubrik, KPI-siffra, diagram och (om ifylld) analystext.
elevhalsa_kort_ui <- function(kort_id) {
  tags$div(
    class = "elevhalsa-kort",
    uiOutput(paste0("rubrik_", kort_id)),
    tags$div(class = "elevhalsa-kort__kpi", textOutput(paste0("kpi_", kort_id))),
    plotOutput(paste0("diagram_", kort_id), height = "320px"),
    uiOutput(paste0("analys_", kort_id))
  )
}

# En flik per topic, med alla kort som hör till den topicen.
elevhalsa_bygg_flikar <- function(meta) {
  if (nrow(meta) == 0) return(list())
  lapply(unique(meta$topic), function(tp) {
    rader <- meta[meta$topic == tp, ]
    tabPanel(tp, lapply(rader$kort_id, elevhalsa_kort_ui))
  })
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
