# Hämtning och förberedelse av elevhälsodata.
#
# Databasen heter "sekretess" men den här specifika tabellen är INTE
# hemlig i sig - den ligger där av andra, historiska skäl. Vi tillämpar
# ändå samma nedre gräns för hur få svar en stapel/siffra får bygga på
# som regionens övriga statistikappar, se LITET_URVAL_TROSKEL i global.R.

# Hämtar hela tabellen folkhalsa.elevhalsa. Returnerar en tom (men rätt
# strukturerad) data.frame om uppkopplingen eller tabellen saknar data, så
# att appen går att starta innan data finns på plats i databasen.
elevhalsa_hamta_data <- function() {
  con <- rdshinyappar::shiny_uppkoppling_las(db_name = "sekretess", db_user = "shiny_las_sekretess")
  if (is.null(con)) {
    warning(
      "elevhalsa: kunde inte koppla upp mot databasen 'sekretess' som shiny_las_sekretess. ",
      "Lösenordet måste sparas lokalt med rdshinyappar::shiny_set_password('shiny_las_sekretess').",
      call. = FALSE
    )
    return(elevhalsa_tom_data())
  }
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  df <- tryCatch(
    DBI::dbGetQuery(con, "SELECT * FROM folkhalsa.elevhalsa"),
    error = function(e) NULL
  )
  if (is.null(df) || nrow(df) == 0) {
    warning("elevhalsa: folkhalsa.elevhalsa innehåller ingen data (ännu).", call. = FALSE)
    return(elevhalsa_tom_data())
  }

  elevhalsa_std_namn(df)
}

# Kolumnnamnen i databasen kan skilja sig något i skiftläge/stavning mot vad
# som antogs när appen byggdes (särskilt de med å/ä/ö) - matcha oberoende
# av skiftläge och byt till interna, ASCII-säkra namn.
elevhalsa_std_namn <- function(df) {
  alias <- list(
    ar               = "year",
    aldersgrupp      = "agegroup",
    region           = "region",
    kalla            = "source",
    kon              = c("kön", "kon"),
    fraga            = c("frågeformulering", "fragaformulering"),
    svar             = "response_klartext",
    antal            = "antal",
    andel            = "andel",
    grupp_n          = "group_count",
    svar_forenklat   = "response_klartext_tu",
    pos_neg          = "pos_neg",
    heading          = "heading",
    variabelnamn     = "variabelnamn",
    analys           = "analys",
    topic            = "topic",
    sortering_svar   = c("sorteringsvar", "orteringssvar"),
    sortering_region = "sorteringregion"
  )
  namn_lower <- tolower(names(df))
  for (nytt in names(alias)) {
    traff <- which(namn_lower %in% alias[[nytt]])
    if (length(traff) == 1) names(df)[traff] <- nytt
  }
  df
}

elevhalsa_tom_data <- function() {
  tibble::tibble(
    ar = character(), aldersgrupp = character(), region = character(),
    kalla = character(), kon = character(), fraga = character(),
    svar = character(), antal = numeric(), andel = numeric(),
    grupp_n = numeric(), svar_forenklat = character(), pos_neg = numeric(),
    heading = character(), variabelnamn = character(), analys = character(),
    topic = character(), sortering_svar = numeric(), sortering_region = numeric()
  )
}

# Döljer siffror som bygger på för få svar. Lägger till `litet_urval`
# (logisk flagga, används för att utesluta staplar i diagrammet) och
# `andel_visning` (text för KPI-siffror/tabeller).
elevhalsa_maskera_litet_urval <- function(df, troskel = LITET_URVAL_TROSKEL,
                                          etikett = LITET_URVAL_ETIKETT) {
  df$litet_urval <- !is.na(df$grupp_n) & df$grupp_n < troskel
  df$andel_visning <- ifelse(
    df$litet_urval, etikett,
    ifelse(is.na(df$andel), "-", paste0(round(df$andel), " %"))
  )
  df
}
