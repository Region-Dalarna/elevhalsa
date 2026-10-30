## Globala inställningar för Shinyappen: elevhalsa

# Ladda nödvändiga paket
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(ggiraph)
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(ggnewscale)
library(rdshinyappar)
library(rdverktyg)
library(sf)

# Shiny sourcar normalt R/*.R automatiskt innan global.R, men bara när
# appen startas med runApp()/"Run App" - inte om man kör
# source("global.R") direkt i konsolen för att testa. Sourcar därför R/
# explicit här också, så det fungerar oavsett hur filen körs.
for (elevhalsa_fil in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  source(elevhalsa_fil)
}
rm(elevhalsa_fil)

telemetry <- skapa_telemetry("elevhalsa")

# Allmänna options - TRUE = visa inte R-felmeddelanden i appen,
# FALSE = visa felmeddelanden från R på webben
options(shiny.sanitize.errors = FALSE)

# Gräns för hur få svar en stapel/siffra får bygga på innan den döljs och
# ersätts med LITET_URVAL_ETIKETT. Databasen heter "sekretess" men just
# den här tabellen är inte hemlig i sig - vi håller ändå samma tumregel
# som regionens övriga statistikappar.
LITET_URVAL_TROSKEL <- 5
LITET_URVAL_ETIKETT <- "< 5"

# Fast stapelhöjd (andel-skala 0-100) för de grå platshållarstaplarna, så
# att en dold stapel inte avslöjar sitt riktiga värde genom sin höjd.
LITET_URVAL_PLATSHALLARE <- 3

# Läs in data en gång vid appstart (inte per session/filterval).
elevhalsa_data <- elevhalsa_hamta_data() |>
  elevhalsa_maskera_litet_urval() |>
  elevhalsa_lagg_till_kommunkod()
elevhalsa_meta       <- elevhalsa_bygg_metadata(elevhalsa_data)
elevhalsa_kommunkarta <- elevhalsa_hamta_kommunkarta()

elevhalsa_val_ar          <- sort(unique(elevhalsa_data$ar), decreasing = TRUE)
elevhalsa_val_aldersgrupp <- elevhalsa_ordna_aldersgrupp(elevhalsa_data$aldersgrupp)
elevhalsa_val_region      <- elevhalsa_filterval(elevhalsa_data, "region", "sortering_region")

# Standardval för kommunkartans egna åldersgrupp-väljare, t.ex. "Åk 7"
# istället för den första åldersgruppen i ordningen.
elevhalsa_standardval_aldersgrupp <- elevhalsa_standardval(elevhalsa_val_aldersgrupp)
