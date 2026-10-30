# Koropletkarta över Dalarnas kommuner. Det finns bara data på kommunnivå
# (ingen nivå under), så kartan visar alltid alla 15 kommuner samtidigt -
# den ignorerar alltså region-filtret i sidopanelen, som bara gäller
# stapeldiagrammen.
#
# elevhalsa_data$region antas innehålla kommunnamn (SCB-standard, t.ex.
# "Falun"). Kartlagret från rdgis::hamta_karta() joinas på kommunkod
# (knkod), inte namn, så namnen slås om till kod via
# rdverktyg::hamta_kommunkoder() innan join.

# Hämtar Dalarnas 15 kommunpolygoner en gång (cachas i global.R, precis
# som elevhalsa_data).
elevhalsa_hamta_kommunkarta <- function() {
  tryCatch(
    rdgis::hamta_karta(karttyp = "kommuner", regionkoder = "20"),
    error = function(e) {
      warning("elevhalsa: kunde inte hämta kommunkartan: ", conditionMessage(e), call. = FALSE)
      NULL
    }
  )
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

# Kopplar ett korts kommundata (en rad per kommun) till kommunpolygonerna.
elevhalsa_bygg_kommun_sf <- function(df_kort, kommunkarta) {
  if (is.null(kommunkarta) || nrow(df_kort) == 0) return(NULL)
  df_kort <- df_kort[!is.na(df_kort$kommunkod), ]
  if (nrow(df_kort) == 0) return(NULL)
  dplyr::left_join(kommunkarta, df_kort, by = c("knkod" = "kommunkod"))
}

# Ritar koropletkartan för ett kort med rddiagram::skapa_koropletkarta_ggplot()
# - samma funktion som används i regionens övriga kommunkartor.
elevhalsa_rita_karta <- function(sf_kort, fotnot = NULL) {
  if (is.null(sf_kort) || all(is.na(sf_kort$andel))) {
    return(
      ggplot2::ggplot() + ggplot2::theme_void() +
        ggplot2::labs(title = "Ingen kommundata för valda filter")
    )
  }
  rddiagram::skapa_koropletkarta_ggplot(
    sf_objekt     = sf_kort,
    vardekolumn   = "andel",
    legend_titel  = "Andel (%)",
    karta_caption = fotnot
  )
}
