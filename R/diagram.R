# Bygger diagrammet för ett kort utifrån redan filtrerad data (en rad per
# svarsalternativ, radar med litet_urval redan borttagna - se server.R).
# Diagrammet byggs med rddiagram::SkapaStapelDiagram(), regionens
# gemensamma diagramfunktion - inte den gamla func_SkapaDiagram.R.
elevhalsa_rita_diagram <- function(df_kort, fotnot = NULL) {
  if (nrow(df_kort) == 0) {
    return(
      ggplot2::ggplot() + ggplot2::theme_void() +
        ggplot2::labs(title = "Inget att visa för valda filter")
    )
  }

  # Ordna svarsalternativen enligt sortering_svar istället för alfabetiskt.
  df_kort$svar_forenklat <- factor(
    df_kort$svar_forenklat,
    levels = unique(df_kort$svar_forenklat[order(df_kort$sortering_svar)])
  )

  rddiagram::SkapaStapelDiagram(
    skickad_df            = df_kort,
    skickad_x_var         = "svar_forenklat",
    skickad_y_var         = "andel",
    diagram_capt          = fotnot,
    manual_y_axis_title   = "procent",
    y_axis_100proc        = TRUE,
    dataetiketter         = TRUE,
    skriv_till_diagramfil = FALSE,
    output_mapp           = tempdir(),
    filnamn_diagram       = "tmp"
  )
}
