addResourcePath("assets", "www")

ui <- navbarPage(
    title = "Attendance Application",
    id = "main_nav",
    theme = bs_theme(
        version = 5,
        bg = "#ffffff",
        fg = "#3a0b12",
        primary = "#a7000a",
        secondary = "#e8839f"
    ),
    inverse = TRUE,
    collapsible = TRUE,
    header = tagList(
        tags$link(rel = "stylesheet", type = "text/css", href = "assets/styles.css"),
        tags$head(tags$script(src = "assets/script.js", type = "text/javascript"))
    ),

    # ---- FRONT PAGE ----------------------------------------------------------
    tabPanel(
        title = "Front Page",
        div(
            class = "page-heading",
            span(class = "eyebrow", "Team overview"),
            h1("Attendance at a glance")
        ),
        div(
            class = "row g-4 mb-4",
            div(
                class = "col-12 col-lg-4",
                card(
                    class = "stat-card stat-card--crimson h-100",
                    card_header("Total Hours Attended"),
                    card_body(uiOutput("total_hours_text"))
                )
            ),
            div(
                class = "col-12 col-lg-8",
                card(
                    class = "stat-card stat-card--white h-100",
                    card_header("Average Hours per Meeting"),
                    card_body(uiOutput("average_hours_text"))
                )
            )
        ),
        div(
            class = "row g-4 mb-4",
            div(
                class = "col-12 col-lg-6",
                card(
                    class = "stat-card stat-card--pink h-100",
                    card_header("Average Subteam Hours per Capita"),
                    card_body(uiOutput("average_subteam_text"))
                )
            ),
            div(
                class = "col-12 col-lg-6",
                card(
                    class = "stat-card stat-card--blush h-100",
                    card_header("Average Grade Hours per Capita"),
                    card_body(uiOutput("average_grade_text"))
                )
            )
        ),
        div(
            class = "row g-4",
            div(
                class = "col-12 col-lg-6",
                card(
                    class = "graph-card",
                    card_header("Group Cumulative Attendance Plot"),
                    card_body(plotOutput("cumulative_graph", height = "380px"))
                )
            ),
            div(
                class = "col-12 col-lg-6",
                card(
                    class = "graph-card",
                    card_header("Group Daily Average Attendance Plot"),
                    card_body(plotOutput("group_average_graph", height = "380px"))
                )
            )
        )
    ),

    # ---- ADMIN PANEL ---------------------------------------------------------
    tabPanel(
        title = "Admin Panel",
        div(class = "admin-wrap", uiOutput("admin_panel"))
    )
)
