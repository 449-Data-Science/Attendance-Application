addResourcePath("assets", "www")

ui <- navbarPage(
    title = "Attendance Application",
    theme = bs_theme(
        version = 5, 
        preset = "flatly", 
        bg = "#FFEFFF", 
        fg = "#6E6D6D",
        primary = "#E683A9",
        secondary = "#F0B4C4"
        ) |>
        bs_add_variables(
            "navbar-bg" = "#E683A9",
            "navbar-light-color" = "#6E6D6D",
            "navbar-light-active-color" = "#FFFFFF"
        ),
    collapsible = TRUE,
    header = tagList(
        tags$link(rel = "stylesheet", type = "text/css", href = "assets/styles.css"),
        tags$head(tags$script(src = "assets/script.js", type = "text/javascript")),
    ),
    tabPanel(
        title = "Raw Data",
        card(
            class = "graph-card",
            card_header("Raw"),
            card_body(
                fillable = FALSE,
                tableOutput("attendanceTable")
            )
        ),
    ),
    tabPanel(
        title = "Summary Data",
        card(
            class = "graph-card",
            card_header("Summary"),
            card_body(
                fillable = FALSE,
                tableOutput("summaryTable")
            )
        ),
    ),
    tabPanel(
         title = "Individual",
         div(class = "container-fluid",
             div(class = "row",
                 div(class = "col-12 col-lg-3",
                    div(
                        #class = "individual-picker", 
                        virtualSelectInput(
                            "selected_id", 
                            label = "Choose a Student:", 
                            choices = unique(data$student_ID), 
                            selected = 1, search = TRUE
                            )
                        )
                    ),
                 div(
                     class = "col-12 col-lg-9",
                     card(
                         class = "graph-card",
                         card_header("Individual Attendance Plot"),
                         plotOutput("individual_graph") |> 
                             withSpinner()
                     )
                 )
             )
         )
    ),
    tabPanel(
        title = "Group",
        card(
            class = "graph-card",
            card_header("Group Cumulative Attendance Plot"),
            plotOutput("cumulative_graph")
        ),
        card(
            class = "graph-card",
            card_header("Group Daily Average Attendance Plot"),
            plotOutput("group_average_graph")
        ),
        card(
            textOutput("total_hours_text")
        )
    )
)