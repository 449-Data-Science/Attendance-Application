library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinycssloaders)
library(shiny.fluent)
library(shiny.pwa)
library(bslib)

library(tidyverse)
library(lubridate)
library(googlesheets4)
library(data.table)
library(ggplot2)
library(plotly)

source("helper_functions.R")


json_string <- Sys.getenv("GOOGLE_SHEETS_JSON")

if (json_string != "") {
    gs4_auth(path = json_string)
} else {
    gs4_auth(path = "data/api-key.json")
}


sheet_link <- paste0(
    "https://docs.google.com/spreadsheets/d/",
    "1hXbsPjKuyHZYW3LuDfqaSVnZSOkykmPnVyEZ2izvgvA/", 
    "edit?usp=sharing")
raw <- read_sheet(sheet_link)

data <- process_data(raw)

summary <- data |>
    group_by(student_ID) |>
    summarize(total = sum(time_spent)) |>
    arrange(desc(total)) |>
    mutate(total_string = hour_min_format(total))

