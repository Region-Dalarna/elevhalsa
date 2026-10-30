# Diagram för ett kort. Byggt med ren ggplot2 + ggiraph, enligt samma
# mönster som utbildning/R/func_diagram.R.
#
# Åldersgrupp är en grupperingsdimension på x-axeln (inte ett filter) -
# alla åldersgrupper visas sida vid sida, som i originalrapporten.
#
# Svar med för få individer (litet_urval, se R/data.R) ritas inte med sitt
# riktiga värde i den förenklade vyn - de får en grå, fast
# platshållarstapel (LITET_URVAL_PLATSHALLARE) med "< 5" i tooltipen, så
# man ser att kategorin finns men inte hur stor den är.

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
# mönster som utbildning/R/func_diagram.R:.girafe_std(). Klick-markering
# är avstängd (opts_selection "none") - vi använder den inte till något
# (ingen korsfiltrering), så den skulle bara vara en förvirrande
# kvardröjande effekt om den stod på som ggiraphs standard.
elevhalsa_girafe <- function(g, width_svg = 7, height_svg = 4.5) {
  ggiraph::girafe(
    ggobj = g, width_svg = width_svg, height_svg = height_svg,
    options = list(
      ggiraph::opts_hover(css = RD_HOVER_CSS),
      ggiraph::opts_tooltip(css = RD_TOOLTIP_CSS),
      ggiraph::opts_selection(type = "none"),
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

# Ordnar åldersgrupp som factor enligt ALDERSGRUPP_ORDNING (se R/data.R).
elevhalsa_aldersgrupp_factor <- function(x) {
  factor(x, levels = elevhalsa_ordna_aldersgrupp(x))
}

# Plockar ut totalraden (kon == "Totalt") ur ett korts data. Andelar
# räknas INTE om eller summeras fram här - alla andelar i elevhalsa_data
# är redan färdigberäknade i databasen, så funktionen filtrerar bara.
# Ger en tom data.frame om ingen Totalt-rad finns för den här kombinationen.
elevhalsa_summera_totalt <- function(df_kort) {
  df_kort[df_kort$kon == "Totalt", ]
}

# ---- Förenklad vy: en stapel per åldersgrupp, baserat på "headline"- ------
# raden (pos_neg == 100) för vald indikator.

elevhalsa_rita_diagram <- function(df_totalt) {
  d <- df_totalt[!is.na(df_totalt$pos_neg) & df_totalt$pos_neg == 100, ]
  if (nrow(d) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Inget att visa för valda filter")))
  }

  d$aldersgrupp <- elevhalsa_aldersgrupp_factor(d$aldersgrupp)
  d$varde <- ifelse(d$litet_urval, LITET_URVAL_PLATSHALLARE, d$andel)
  d$fyll  <- ifelse(d$litet_urval, LITET_URVAL_FARG, RD_PRIMARY)
  d$tooltip <- paste0(
    "<b>", d$aldersgrupp, "</b><br/>Andel: ",
    ifelse(d$litet_urval, LITET_URVAL_ETIKETT, paste0(round(d$andel), " %"))
  )
  d$data_id <- as.character(d$aldersgrupp)

  g <- ggplot2::ggplot(d, ggplot2::aes(x = .data$aldersgrupp, y = .data$varde)) +
    ggiraph::geom_col_interactive(
      ggplot2::aes(tooltip = .data$tooltip, data_id = .data$data_id, fill = .data$fyll),
      width = 0.6
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

# Könsuppdelad variant: Flickor/Pojkar sida vid sida per åldersgrupp.
# Staplas INTE (till skillnad från utbildning-appens antalsdiagram) -
# andelar är inte additiva, så en stapel på 175 % vore missvisande. Dolda
# värden (för få svar) får en egen grå kategori i samma färgskala, så
# legenden visar "Flickor", "Pojkar" och "Färre än 5" tillsammans.
elevhalsa_rita_diagram_kon <- function(df_kort) {
  d <- df_kort[df_kort$kon %in% names(KON_FARGER) & !is.na(df_kort$pos_neg) & df_kort$pos_neg == 100, ]
  if (nrow(d) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Inget att visa för valda filter")))
  }

  d$aldersgrupp <- elevhalsa_aldersgrupp_factor(d$aldersgrupp)
  dold_namn <- paste0("Färre än ", LITET_URVAL_TROSKEL)
  d$varde <- ifelse(d$litet_urval, LITET_URVAL_PLATSHALLARE, d$andel)
  d$fyll  <- ifelse(d$litet_urval, dold_namn, d$kon)
  d$tooltip <- paste0(
    "<b>", d$aldersgrupp, "</b><br/>", d$kon, ": ",
    ifelse(d$litet_urval, LITET_URVAL_ETIKETT, paste0(round(d$andel), " %"))
  )
  d$data_id <- paste(d$aldersgrupp, d$kon, sep = "_")

  g <- ggplot2::ggplot(d, ggplot2::aes(x = .data$aldersgrupp, y = .data$varde, group = .data$kon)) +
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

# ---- Detaljerad vy: alla ursprungliga svarsalternativ, 100%-staplat ------
# per åldersgrupp - som originalrapportens detaljerade diagram. Till
# skillnad från den förenklade vyn (som bygger på response_klartext_tu och
# behöver en färdig "headline"-rad) behöver den här INGEN hopslagning:
# `svar` (response_klartext) är redan en fullständig uppdelning som
# summerar till 100 % per åldersgrupp/kön, så staplingen är bara en
# visualisering av redan färdiga andelar - ingen beräkning.
#
# Förenkling jämfört med originalrapporten: där fick Flickor/Pojkar varsin
# färgskala (orange/grön-nyanser). Här delar båda könen samma färgskala
# (RD-grön) och skiljs åt med ett facet-stripe-namn istället - ggplot2 har
# inget enkelt sätt att ge varje facet-panel en egen fyllnadsskala.
#
# OBS: ingen litet_urval-maskering här ännu - en dold understapel skulle
# göra att hela stapeln inte längre summerar till 100 %, vilket kräver mer
# eftertanke än det här första utkastet. Följ upp om små urval dyker upp
# bland de råa svarsalternativen.
elevhalsa_farg_ramp <- function(n, bas) {
  if (n <= 1) return(bas)
  grDevices::colorRampPalette(c("#f2f2f2", bas))(n)
}

elevhalsa_rita_detalj <- function(df_kort, konsuppdelat) {
  kon_vill <- if (konsuppdelat) names(KON_FARGER) else "Totalt"
  d <- df_kort[df_kort$kon %in% kon_vill, ]
  if (nrow(d) == 0) {
    return(elevhalsa_girafe(elevhalsa_tom_plot("Inget att visa för valda filter"), width_svg = 8, height_svg = 5))
  }

  d$aldersgrupp <- elevhalsa_aldersgrupp_factor(d$aldersgrupp)
  svar_niva <- unique(d$svar[order(d$sortering_svar)])
  d$svar <- factor(d$svar, levels = svar_niva)
  d$tooltip <- paste0(
    "<b>", d$aldersgrupp, if (konsuppdelat) paste0(" · ", d$kon) else "", "</b><br/>",
    d$svar, ": ", round(d$andel), " %"
  )
  d$data_id <- paste(d$aldersgrupp, d$kon, d$svar, sep = "_")

  # Legenden ligger till höger (vertikal lista) istället för under
  # diagrammet - en horisontell legend får inte plats när det finns många
  # eller långa svarsalternativ (de radbryts här också, så långa texter
  # inte tvingar fram en orimligt bred legendkolumn).
  etiketter <- vapply(svar_niva, function(x) paste(strwrap(x, width = 22), collapse = "\n"), character(1))

  g <- ggplot2::ggplot(d, ggplot2::aes(x = .data$aldersgrupp, y = .data$andel, fill = .data$svar)) +
    ggiraph::geom_col_interactive(
      ggplot2::aes(tooltip = .data$tooltip, data_id = .data$data_id),
      position = "stack", width = 0.6
    ) +
    ggplot2::scale_fill_manual(
      values = elevhalsa_farg_ramp(length(svar_niva), RD_PRIMARY),
      labels = etiketter, name = NULL
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 100), expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::labs(x = NULL, y = "Andel (%)") +
    elevhalsa_tema() +
    ggplot2::theme(legend.position = "right", legend.text = ggplot2::element_text(size = 9))

  if (konsuppdelat) g <- g + ggplot2::facet_wrap(~ kon)

  elevhalsa_girafe(g, width_svg = 9, height_svg = 5)
}
