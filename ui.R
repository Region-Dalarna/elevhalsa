source('global.R')

shinyUI(
  fluidPage(
    title = 'elevhalsa',
    tags$head(
      tags$link(rel = 'icon', type = 'image/x-icon', href = 'favicon.ico'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'regiondalarna_ruf.css'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'app.css'),
      rdshinyappar::telemetri_ui(telemetry)
    ),

    # ---- Header (matchar .rd-header i regiondalarna_ruf.css) --------------
    tags$div(
      class = 'rd-header',
      tags$div(class = 'rd-header__title', 'Elevhälsa'),
      tags$a(
        class  = 'rd-header__right',
        href   = 'https://www.regiondalarna.se',
        target = '_blank',
        tags$img(src = 'logo_liggande_fri_vit.png', alt = 'Region Dalarna')
      )
    ),

    # ---- Innehåll -----------------------------------------------------------
    if (nrow(elevhalsa_meta) == 0) {
      tags$div(
        class = 'elevhalsa-tom',
        h3('Ingen data ännu'),
        p('Tabellen folkhalsa.elevhalsa i databasen sekretess innehåller inget just nu.')
      )
    } else {
      sidebarLayout(
        sidebarPanel(
          selectInput('filter_ar', 'År', choices = elevhalsa_val_ar),
          selectInput('filter_aldersgrupp', 'Åldersgrupp', choices = elevhalsa_val_aldersgrupp,
                     selected = elevhalsa_standardval_aldersgrupp),
          selectInput('filter_region', 'Region', choices = elevhalsa_val_region)
        ),
        mainPanel(
          do.call(tabsetPanel, c(
            list(id = 'flikval'),
            elevhalsa_bygg_flikar(elevhalsa_meta),
            list(tabPanel('Om', p('Beskriv applikationen här.')))
          ))
        )
      )
    },

    # ---- Footer (matchar .rd-footer i regiondalarna_ruf.css) --------------
    tags$div(
      class = 'rd-footer',
      'Samhällsanalys, Region Dalarna · ',
      tags$a(
        href = 'mailto:samhallsanalys@regiondalarna.se',
        'samhallsanalys@regiondalarna.se'
      )
    )
  )
)
