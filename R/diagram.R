# Stapeldiagram för ett kort (en rad per svarsalternativ, redan filtrerad
# på år/åldersgrupp/kön/region - se server.R). Byggt med ren ggplot2 +
# ggiraph, enligt samma mönster som utbildning/R/func_diagram.R.
#
# Svar med för få individer (litet_urval, se R/data.R) ritas inte med sitt
# riktiga värde - de får en grå, fast platshållarstapel
# (LITET_URVAL_PLATSHALLARE) med "< 5" i tooltipen, så man ser att
# kategorin finns men inte hur stor den är.

# Gemensamt, avskalat tema - delas av diagram och karta.
elevhalsa_tema <- function() {
  ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      panel.grid.major.y    = ggplot2::element_blank(),
      panel.grid.minor      = ggplot2::element_blank(),
      axis.title.y          = ggplot2::element_blank(),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.caption = ggplot2::element_text(size = 8, color = RD_TEXT_MUTED, hjust = 0,
                                           margin = ggplot2::margin(t = 8)),
      plot.margin  = ggplot2::margin(6, 12, 5, 5)
    )
}

# Standardiserad girafe-inkapsling (hover/tooltip/verktygsfält), samma
# mönster som utbildning/R/func_diagram.R:.girafe_std().
elevhalsa_girafe <- function(g, width_svg = 7, height_svg = 4.5) {
  ggiraph::girafe(
    ggobj = g, width_svg = width_svg, height_svg = height_svg,
    options = list(
      ggiraph::opts_hover(css = RD_HOVER_CSS),
      ggiraph::opts_tooltip(css = RD_TOOLTIP_CSS),
      ggiraph::opts_sizing(rescale = TRUE, width = 1),
      ggiraph::opts_toolbar(saveaspng = TRUE, hidden = c("lasso_select", "lasso_deselect"))
    )
  )
}

# Tom platshållarplot (ingen data för valda filter).
elevhalsa_tom_plot <- function(meddelande) {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = meddelande, color = RD_TEXT_MUTED, size = 4) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(20, 20, 20, 20))
}

elevhalsa_rita_diagram <- function(df_kort) {
  if (nrow(df_kort) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Inget att visa för valda filter")))
  }

  d <- df_kort
  d$svar_forenklat <- factor(
    d$svar_forenklat,
    levels = unique(d$svar_forenklat[order(d$sortering_svar)])
  )
  d$varde <- ifelse(d$litet_urval, LITET_URVAL_PLATSHALLARE, d$andel)
  d$fyll  <- ifelse(d$litet_urval, LITET_URVAL_FARG, RD_PRIMARY)
  d$tooltip <- paste0(
    "<b>", d$svar_forenklat, "</b><br/>Andel: ",
    ifelse(d$litet_urval, LITET_URVAL_ETIKETT, paste0(round(d$andel), " %"))
  )
  d$data_id <- as.character(d$svar_forenklat)

  g <- ggplot2::ggplot(d, ggplot2::aes(x = .data$svar_forenklat, y = .data$varde)) +
    ggiraph::geom_col_interactive(
      ggplot2::aes(tooltip = .data$tooltip, data_id = .data$data_id, fill = .data$fyll),
      width = 0.65
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_y_continuous(limits = c(0, 100), expand = ggplot2::expansion(mult = c(0, 0.06))) +
    ggplot2::labs(
      x = NULL, y = "Andel (%)",
      caption = if (any(d$litet_urval)) {
        paste0("Grå staplar: färre än ", LITET_URVAL_TROSKEL, " svar (exakt andel visas inte).")
      } else {
        NULL
      }
    ) +
    elevhalsa_tema()

  elevhalsa_girafe(g)
}

# Slår ihop ett korts data (en rad per kön/svarsalternativ, för EN
# kommun/region) till en totalsiffra över båda könen - en rad per
# svarsalternativ. Använder en befintlig "Totalt"-rad i datan om den
# finns, annars summeras antal över Flickor/Pojkar och andelen räknas om
# (grupp_n hämtas en gång per kön innan summeringen, eftersom samma
# grupp_n annars skulle räknas flera gånger - en gång per svarsalternativ).
elevhalsa_summera_totalt <- function(df_kort) {
  if (nrow(df_kort) == 0) return(df_kort)
  if ("Totalt" %in% df_kort$kon) {
    return(df_kort[df_kort$kon == "Totalt", ])
  }

  grupp_n_per_kon <- unique(df_kort[, c("kon", "grupp_n")])
  grupp_n_tot <- sum(grupp_n_per_kon$grupp_n, na.rm = TRUE)

  tot <- df_kort |>
    dplyr::group_by(dplyr::across(dplyr::any_of(c(
      "svar_forenklat", "sortering_svar", "pos_neg", "heading",
      "variabelnamn", "topic", "ar", "aldersgrupp", "region", "kommunkod"
    )))) |>
    dplyr::summarise(antal = sum(.data$antal, na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(
      kon     = "Totalt",
      grupp_n = grupp_n_tot,
      # grupp_n_tot är ett skalärt värde (samma för alla rader här) - ifelse()
      # med ett skalärt villkor returnerar bara EN rad och skulle göra att
      # alla rader fick samma andel, så ett vanligt if/else används istället.
      andel   = if (grupp_n_tot > 0) 100 * .data$antal / grupp_n_tot else NA_real_
    )

  elevhalsa_maskera_litet_urval(tot)
}

# Könsuppdelat stapeldiagram: Flickor/Pojkar sida vid sida per
# svarsalternativ. Staplas INTE (till skillnad från utbildning-appens
# antalsdiagram) - andelar är inte additiva, så en stapel på 175 % vore
# missvisande. Dolda värden (för få svar) får en egen grå kategori i
# samma färgskala, så legenden visar "Flickor", "Pojkar" och
# "Färre än 5" tillsammans.
elevhalsa_rita_diagram_kon <- function(df_kort) {
  d <- df_kort[df_kort$kon %in% names(KON_FARGER), ]
  if (nrow(d) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Inget att visa för valda filter")))
  }

  d$svar_forenklat <- factor(
    d$svar_forenklat,
    levels = unique(d$svar_forenklat[order(d$sortering_svar)])
  )
  dold_namn <- paste0("Färre än ", LITET_URVAL_TROSKEL)
  d$varde <- ifelse(d$litet_urval, LITET_URVAL_PLATSHALLARE, d$andel)
  d$fyll  <- ifelse(d$litet_urval, dold_namn, d$kon)
  d$tooltip <- paste0(
    "<b>", d$svar_forenklat, "</b><br/>", d$kon, ": ",
    ifelse(d$litet_urval, LITET_URVAL_ETIKETT, paste0(round(d$andel), " %"))
  )
  d$data_id <- paste(d$svar_forenklat, d$kon, sep = "_")

  g <- ggplot2::ggplot(d, ggplot2::aes(x = .data$svar_forenklat, y = .data$varde, group = .data$kon)) +
    ggiraph::geom_col_interactive(
      ggplot2::aes(tooltip = .data$tooltip, data_id = .data$data_id, fill = .data$fyll),
      position = ggplot2::position_dodge2(width = 0.75, padding = 0.1)
    ) +
    ggplot2::scale_fill_manual(
      values = c(KON_FARGER, stats::setNames(LITET_URVAL_FARG, dold_namn)),
      breaks = c(names(KON_FARGER), if (any(d$litet_urval)) dold_namn),
      name = NULL
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 100), expand = ggplot2::expansion(mult = c(0, 0.06))) +
    ggplot2::labs(
      x = NULL, y = "Andel (%)",
      caption = if (any(d$litet_urval)) {
        paste0("Färre än ", LITET_URVAL_TROSKEL, " svar: exakt andel visas inte.")
      } else {
        NULL
      }
    ) +
    elevhalsa_tema() +
    ggplot2::theme(legend.position = "top")

  elevhalsa_girafe(g)
}
