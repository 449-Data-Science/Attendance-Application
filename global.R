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
source("presentation_helpers.R")
source("hidden_tabs.R")

json_string <- Sys.getenv("GOOGLE_SHEETS_JSON")

if (json_string != "") {
    gs4_auth(path = json_string)
} else {
    gs4_auth(path = "data/api-key.json")
}

database <- paste0(
    "https://docs.google.com/spreadsheets/d/",
    "1hXbsPjKuyHZYW3LuDfqaSVnZSOkykmPnVyEZ2izvgvA/", 
    "edit?usp=sharing")

roster <- paste0(
    "https://docs.google.com/spreadsheets/d/",
    "1cQPqLKTmtBAAgO2a9rRsg2CzREHCtUEYSv8P23XHAwE/",
    "edit?gid=794401063#gid=794401063"
)

raw <- read_sheet(database)
roster <- read_sheet(roster, sheet = 2)
data <- process_data(raw, roster)

summary <- data |>
    group_by(student_ID) |>
    summarize(total = sum(time_spent)) |>
    arrange(desc(total)) |>
    rowwise() |>
    mutate(total_string = hour_min_format(total))

