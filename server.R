shinyServer(function(input, output, session) {
  forsta_flik <- if (nrow(elevhalsa_meta) > 0) elevhalsa_ordna_topic(elevhalsa_meta$topic)[1] else 'Om'
  rdshinyappar::telemetri_server(telemetry, navigation_id = 'flikval', forsta_flik = forsta_flik)

  if (nrow(elevhalsa_meta) == 0) return(invisible(NULL))

  # Ämnestexten i sidopanelen följer vilken flik som är aktiv. Hopfälld
  # som standard (<details>) - texten tar annars för mycket plats och blir
  # mer framträdande än diagrammen den ska komplettera.
  output$sidopanel_amnestext <- renderUI({
    txt <- elevhalsa_hamta_amnestext(input$flikval)
    if (length(txt) == 0) return(NULL)
    tags$details(
      class = 'elevhalsa-amnestext',
      tags$summary('Kort om frågeområdet'),
      lapply(txt, function(t) tags$p(shiny::HTML(t)))
    )
  })

  # Bas-filter: år + region. Åldersgrupp visas som grupperingsdimension i
  # diagrammen (inte ett filter) - kön styrs per diagram (Totalt/
  # Könsuppdelat-växlaren).
  filtrerad_data <- reactive({
    req(input$filter_ar, input$filter_region)
    df <- elevhalsa_data
    df <- df[df$ar == input$filter_ar, ]
    df[df$region == input$filter_region, ]
  })

  # Samma filter som ovan, men utan regionfiltret - kartan visar alltid
  # alla kommuner samtidigt.
  filtrerad_data_alla_kommuner <- reactive({
    req(input$filter_ar)
    elevhalsa_data[elevhalsa_data$ar == input$filter_ar, ]
  })

  # Ett set med output$-renderare per topic/flik - inte per indikator.
  # Varje flik har en egen listruta (val_<slug>) som styr vilken indikator
  # som visas i flikens gemensamma kort-yta. local() behövs så att varje
  # iteration fångar sin egen topic/slug - annars skulle alla renderare
  # dela den sista topicens värden.
  for (tp in unique(elevhalsa_meta$topic)) {
    local({
      tp_lokal  <- tp
      slug      <- elevhalsa_slug(tp_lokal)
      val_input <- paste0('val_', slug)
      kon_input <- paste0('konval_', slug)
      vy_input  <- paste0('vyval_', slug)
      karta_aldersgrupp_input <- paste0('karta_aldersgrupp_', slug)

      vald_rad <- reactive({
        req(input[[val_input]])
        elevhalsa_meta[elevhalsa_meta$kort_id == input[[val_input]], ]
      })

      # Alla åldersgrupper och båda könen, för vald indikator + region.
      kort_data <- reactive({
        rad <- vald_rad()
        req(nrow(rad) == 1)
        df <- filtrerad_data()
        df[df$topic == rad$topic & df$variabelnamn == rad$variabelnamn & df$heading == rad$heading, ]
      })

      # Totalt över båda könen (alla åldersgrupper) - används av den
      # förenklade "Totalt"-vyn.
      kort_data_totalt <- reactive(elevhalsa_summera_totalt(kort_data()))

      # Kartans data: en rad per kommun, för den åldersgrupp som är vald i
      # kartflikens egen väljare - totalt över båda könen, summerad andel
      # av de "positiva" svarsraderna (pos_neg == 100, se
      # elevhalsa_summera_headline() i R/diagram.R).
      kort_data_kommuner <- reactive({
        rad <- vald_rad()
        req(nrow(rad) == 1, input[[karta_aldersgrupp_input]])
        df <- filtrerad_data_alla_kommuner()
        df <- df[df$topic == rad$topic & df$variabelnamn == rad$variabelnamn & df$heading == rad$heading &
                   df$aldersgrupp == input[[karta_aldersgrupp_input]], ]
        df <- elevhalsa_summera_totalt(df)
        df <- df[!is.na(df$pos_neg) & df$pos_neg == 100, ]
        elevhalsa_summera_headline(df, "region")
      })

      output[[paste0('rubrik_', slug)]] <- renderUI({
        rad <- vald_rad()
        req(nrow(rad) == 1)
        h4(rad$heading)
      })

      output[[paste0('diagram_', slug)]] <- ggiraph::renderGirafe({
        konsuppdelat <- identical(input[[kon_input]], 'Könsuppdelat')
        if (identical(input[[vy_input]], 'Alla svar')) {
          elevhalsa_rita_detalj(kort_data(), konsuppdelat)
        } else if (konsuppdelat) {
          elevhalsa_rita_diagram_kon(kort_data())
        } else {
          elevhalsa_rita_diagram(kort_data_totalt())
        }
      })

      output[[paste0('karta_', slug)]] <- ggiraph::renderGirafe({
        elevhalsa_rita_karta(kort_data_kommuner(), elevhalsa_kommunkarta)
      })
    })
  }
})
