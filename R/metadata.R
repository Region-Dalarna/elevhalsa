# En rad per "kort" (topic + variabelnamn + heading), oberoende av vilka
# filter som är valda - används för att bygga flikar/kort i ui.R innan
# datan filtreras server-side.
elevhalsa_bygg_metadata <- function(df) {
  kolumner <- c("topic", "variabelnamn", "heading")
  if (nrow(df) == 0) {
    meta <- df[0, kolumner]
  } else {
    meta <- unique(df[, kolumner])
    meta <- meta[order(meta$topic, meta$variabelnamn), ]
  }
  meta$kort_id <- make.unique(gsub(
    "[^A-Za-z0-9]+", "_",
    paste(meta$topic, meta$variabelnamn, meta$heading)
  ))
  meta
}
