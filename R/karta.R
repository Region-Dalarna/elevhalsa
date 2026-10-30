# Koropletkarta över Dalarnas kommuner. Det finns bara data på kommunnivå
# (ingen nivå under), så kartan visar alltid alla 15 kommuner samtidigt -
# den ignorerar alltså region-filtret i sidopanelen, som bara gäller
# stapeldiagrammen.
#
# Hämtningen följer samma mönster som utbildning/R/func_karta.R och
# digidel/R/karta_digidel.R: läs karta.kommun_scb direkt via dplyr/dbplyr
# (inte rdgis), gör om till sf med rdshinyappar::df_till_sf().
#
# elevhalsa_data$region antas innehålla kommunnamn (SCB-standard, t.ex.
# "Falun"). Kartlagrets knkod/knnamn döps om till kommunkod/kommunnamn och
# elevhalsa_data$region slås om till kommunkod (se elevhalsa_lagg_till_kommunkod()
# nedan) via rdverktyg::hamta_kommunkoder(), så joinen sker på kod - robustare
# än att lita på att stavningen av kommunnamnet är identisk på båda håll.

# Hämtar Dalarnas 15 kommunpolygoner en gång (cachas i global.R, precis
# som elevhalsa_data).
elevhalsa_hamta_kommunkarta <- function() {
  tryCatch({
    con <- rdshinyappar::shiny_uppkoppling_las("geodata")
    if (is.null(con)) stop("kunde inte koppla upp mot geodata-databasen")
    on.exit(DBI::dbDisconnect(con), add = TRUE)

    dplyr::tbl(con, dbplyr::in_schema("karta", "kommun_scb")) |>
      dplyr::filter(substr(.data$knkod, 1, 2) == "20") |>
      dplyr::collect() |>
      rdshinyappar::df_till_sf() |>
      dplyr::rename(kommunkod = "knkod", kommunnamn = "knnamn") |>
      dplyr::mutate(kommunkod = as.character(.data$kommunkod)) |>
      sf::st_transform(crs = 3006)
  }, error = function(e) {
    warning("elevhalsa: kunde inte hämta kommunkartan: ", conditionMessage(e), call. = FALSE)
    NULL
  })
}

# Lägger till en kommunkod-kolumn i elevhalsa_data utifrån kommunnamnet i
# region. NA för rader som inte är en enskild kommun (t.ex. "Dalarna" totalt) -
# de rader utesluts automatiskt ur kartan längre fram.
elevhalsa_lagg_till_kommunkod <- function(df) {
  lookup <- tryCatch(rdverktyg::hamta_kommunkoder(lanskod = "20"), error = function(e) NULL)
  if (is.null(lookup)) {
    df$kommunkod <- NA_character_
    return(df)
  }
  df$kommunkod <- lookup$regionkod[match(df$region, lookup$region)]
  df
}

# Ritar koropletkartan för ett kort (df_kort: en rad per kommun, bara
# pos_neg == 100-raden - se server.R). Kommuner med för få svar grånas och
# får "< 5" i tooltipen istället för att visa sitt riktiga värde.
elevhalsa_rita_karta <- function(df_kort, kommunkarta) {
  if (is.null(kommunkarta) || nrow(df_kort) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Ingen kommundata för valda filter"), width_svg = 6, height_svg = 6))
  }

  sf_kort <- dplyr::left_join(kommunkarta, df_kort, by = "kommunkod")
  sf_kort$dold        <- !is.na(sf_kort$litet_urval) & sf_kort$litet_urval
  sf_kort$andel_karta <- ifelse(sf_kort$dold, NA_real_, sf_kort$andel)
  sf_kort$tooltip <- paste0(
    "<b>", sf_kort$kommunnamn, "</b><br/>Andel: ",
    dplyr::case_when(
      sf_kort$dold         ~ LITET_URVAL_ETIKETT,
      is.na(sf_kort$andel) ~ "Ingen data",
      TRUE                 ~ paste0(round(sf_kort$andel), " %")
    )
  )

  g <- ggplot2::ggplot(sf_kort) +
    ggiraph::geom_sf_interactive(
      ggplot2::aes(fill = .data$andel_karta, tooltip = .data$tooltip, data_id = .data$kommunkod),
      color = "#ffffff", linewidth = 0.4
    ) +
    ggplot2::scale_fill_gradient(
      low = "#eaf4f7", high = RD_PRIMARY, na.value = LITET_URVAL_FARG,
      name = "Andel (%)", limits = c(0, 100)
    ) +
    ggplot2::theme_void(base_size = 11) +
    ggplot2::theme(legend.position = "right")

  elevhalsa_girafe(g, width_svg = 6, height_svg = 6)
}
