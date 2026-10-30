shinyServer(function(input, output, session) {
  forsta_flik <- if (nrow(elevhalsa_meta) > 0) elevhalsa_meta$topic[1] else 'Om'
  rdshinyappar::telemetri_server(telemetry, navigation_id = 'flikval', forsta_flik = forsta_flik)

  if (nrow(elevhalsa_meta) == 0) return(invisible(NULL))

  filtrerad_data <- reactive({
    req(input$filter_ar, input$filter_aldersgrupp, input$filter_region)
    df <- elevhalsa_data
    df <- df[df$ar == input$filter_ar, ]
    df <- df[df$aldersgrupp == input$filter_aldersgrupp, ]
    df <- df[df$region == input$filter_region, ]
    if (!is.null(input$filter_kon) && input$filter_kon != 'Alla') {
      df <- df[df$kon == input$filter_kon, ]
    }
    df
  })

  # Samma filter som ovan, men utan regionfiltret - kartan visar alltid
  # alla kommuner samtidigt.
  filtrerad_data_alla_kommuner <- reactive({
    req(input$filter_ar, input$filter_aldersgrupp)
    df <- elevhalsa_data
    df <- df[df$ar == input$filter_ar, ]
    df <- df[df$aldersgrupp == input$filter_aldersgrupp, ]
    if (!is.null(input$filter_kon) && input$filter_kon != 'Alla') {
      df <- df[df$kon == input$filter_kon, ]
    }
    df
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

      vald_rad <- reactive({
        req(input[[val_input]])
        elevhalsa_meta[elevhalsa_meta$kort_id == input[[val_input]], ]
      })

      kort_data <- reactive({
        rad <- vald_rad()
        req(nrow(rad) == 1)
        df <- filtrerad_data()
        df[df$topic == rad$topic & df$variabelnamn == rad$variabelnamn & df$heading == rad$heading, ]
      })

      # Kartans data: en rad per kommun, bara den "positiva" svarsraden
      # (pos_neg == 100) - samma värde som KPI-siffran bygger på.
      kort_data_kommuner <- reactive({
        rad <- vald_rad()
        req(nrow(rad) == 1)
        df <- filtrerad_data_alla_kommuner()
        df <- df[df$topic == rad$topic & df$variabelnamn == rad$variabelnamn & df$heading == rad$heading, ]
        df[!is.na(df$pos_neg) & df$pos_neg == 100, ]
      })

      output[[paste0('kpi_', slug)]] <- renderText({
        df <- kort_data()
        rad_kpi <- df[!is.na(df$pos_neg) & df$pos_neg == 100, ]
        if (nrow(rad_kpi) == 0) return(NULL)
        rad_kpi$andel_visning[1]
      })

      output[[paste0('diagram_', slug)]] <- ggiraph::renderGirafe({
        elevhalsa_rita_diagram(kort_data())
      })

      output[[paste0('karta_', slug)]] <- ggiraph::renderGirafe({
        elevhalsa_rita_karta(kort_data_kommuner(), elevhalsa_kommunkarta)
      })

      output[[paste0('analys_', slug)]] <- renderUI({
        df  <- kort_data()
        txt <- unique(df$analys)
        txt <- txt[!is.na(txt) & nzchar(txt) & txt != 'Lägg till en text här']
        if (length(txt) == 0) return(NULL)
        p(txt[1])
      })
    })
  }
})
