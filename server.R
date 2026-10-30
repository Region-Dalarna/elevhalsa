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

  # Ett set med output$-renderare per kort (topic + variabelnamn + heading).
  # local() behövs så att varje iteration fångar sin egen kort_id/tp/vb/hd -
  # annars skulle alla renderare dela den sista radens värden.
  for (i in seq_len(nrow(elevhalsa_meta))) {
    local({
      rad     <- elevhalsa_meta[i, ]
      kort_id <- rad$kort_id
      tp      <- rad$topic
      vb      <- rad$variabelnamn
      hd      <- rad$heading

      kort_data <- reactive({
        df <- filtrerad_data()
        df[df$topic == tp & df$variabelnamn == vb & df$heading == hd, ]
      })

      output[[paste0('rubrik_', kort_id)]] <- renderUI(h4(hd))

      output[[paste0('kpi_', kort_id)]] <- renderText({
        df <- kort_data()
        rad_kpi <- df[!is.na(df$pos_neg) & df$pos_neg == 100, ]
        if (nrow(rad_kpi) == 0) return(NULL)
        rad_kpi$andel_visning[1]
      })

      output[[paste0('diagram_', kort_id)]] <- renderPlot({
        df <- kort_data()
        fotnot <- if (any(df$litet_urval)) {
          paste0('Stapel saknas vid färre än ', LITET_URVAL_TROSKEL, ' svar.')
        } else {
          NULL
        }
        elevhalsa_rita_diagram(df[!df$litet_urval, ], fotnot = fotnot)
      })

      output[[paste0('analys_', kort_id)]] <- renderUI({
        df  <- kort_data()
        txt <- unique(df$analys)
        txt <- txt[!is.na(txt) & nzchar(txt) & txt != 'Lägg till en text här']
        if (length(txt) == 0) return(NULL)
        p(txt[1])
      })
    })
  }
})
