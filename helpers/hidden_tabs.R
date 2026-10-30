hidden_tabs <- function() {
    list(
        # ---- SUMMARY DATA ----------------------------------------------------
        tabPanel(
            title = "Summary Data",
            value = "tab_summary",
            div(
                class = "page-heading",
                span(class = "eyebrow", "Leaderboard"),
                h1("Summary")
            ),
            card(
                class = "graph-card table-card",
                card_header("Total Time by Student"),
                card_body(
                    fillable = FALSE,
                    filter_bar(),
                    div(class = "table-scroll", tableOutput("summaryTable"))
                )
            )
        ),
        
        # ---- INDIVIDUAL ------------------------------------------------------
        tabPanel(
            title = "Individual",
            value = "tab_individual",
            div(
                class = "page-heading",
                span(class = "eyebrow", "Member view"),
                h1("Individual attendance")
            ),
            div(
                class = "row g-4",
                div(
                    class = "col-12 col-lg-4 col-xl-3",
                    card(
                        class = "picker-card h-100",
                        card_body(
                            virtualSelectInput(
                                "selected_id",
                                label = "Choose a Student:",
                                choices = unique(data$student_ID),
                                selected = unique(data$student_ID)[1],
                                search = TRUE
                            )
                        )
                    )
                ),
                div(
                    class = "col-12 col-lg-8 col-xl-9",
                    card(
                        class = "graph-card",
                        card_header("Individual Attendance Plot"),
                        card_body(
                            plotOutput("individual_graph", height = "520px") |>
                                withSpinner(color = "#a7000a")
                        )
                    )
                )
            )
        ),
        
        # ---- RAW DATA --------------------------------------------------------
        tabPanel(
            title = "Raw Data",
            value = "tab_raw",
            div(
                class = "page-heading",
                span(class = "eyebrow", "Every check-in"),
                h1("Raw data")
            ),
            card(
                class = "graph-card table-card",
                card_header("Raw"),
                card_body(
                    fillable = FALSE,
                    div(class = "table-scroll", tableOutput("attendanceTable"))
                )
            )
        )
    )
}