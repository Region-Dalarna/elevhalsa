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
