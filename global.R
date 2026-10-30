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

source("helpers/helper_functions.R")
source("helpers/graphs_and_stats.R")
source("helpers/presentation_helpers.R")
source("helpers/hidden_tabs.R")

json_string <- Sys.getenv("GOOGLE_SHEETS_JSON")
password <- Sys.getenv("login_password")

if (json_string != "") {
    gs4_auth(path = json_string)
} else {
    gs4_auth(path = "data/api-key.json")
}

if (password != "") {
    correct_password = password
} else {
    correct_password = "biscuit" # You're logged into RStudio, no need for password
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
roster <- read_sheet(roster, sheet = 2) |>
    select(!`Column 1`)

# Adding hard-coded roles for [STLs + Design Lead] and UL
upper_leadership <- c(269481, 177018, 193630, 170036)
lower_leadership <- c(
    197479, 140925, 173269, 195479, 199659, 213943, 
    10002020, 194228, 10033365, 10051416
)

roster[roster$`MCPS Student ID` %in% upper_leadership, "Team Status"] = "UL"
roster[roster$`MCPS Student ID` %in% lower_leadership, "Team Status"] = "STL"
# End hard-coding

data <- process_data(raw, roster)