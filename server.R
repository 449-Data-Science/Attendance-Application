server <- function(input, output, session) {
    # Logistical Variables
    login <- reactiveVal(rstudioapi::isAvailable())
    tabs_shown <- reactiveVal(FALSE)
    login_fails <- reactiveVal(0L)
    correct_password <- "Justus Eichhorn - Czerny: Etudes for Piano, Op. 740: No. 14 in G Minor (Arr. Eichhorn)"
    
    # Dataframes
    summary <- reactiveVal(process_summary(data, NA))
    data <- reactiveVal(process_data(raw, roster))

    # ---- Tables ----------------------------------------------------------------
    output$attendanceTable <- renderTable({
        data()
    }, striped = TRUE, hover = TRUE, spacing = "m", width = "100%")

    output$summaryTable <- renderTable({
        summary() |>
            ungroup() |>
            transmute(
                Rank = row_number(),
                Student = student_ID,
                `Total Hours` = round(total, 2),
                `Time (hh:mm)` = total_string
            )
    }, striped = TRUE, hover = TRUE, spacing = "m", width = "100%")

    # ---- Plots -----------------------------------------------------------------
    output$individual_graph <- renderPlot({
        member_graph(data(), input$selected_id) |>
            polish_plot() +
            scale_color_manual(values = rep_len(brand_palette, 100)) +
            guides(x = guide_axis(angle = 45, check.overlap = TRUE))
    })

    output$cumulative_graph <- renderPlot({
        polish_plot(cumulative_plot(data()))
    })

    output$group_average_graph <- renderPlot({
        polish_plot(group_plot(data()))
    })

    # ---- Front page statistics -------------------------------------------------
    output$total_hours_text <- renderUI({
        txt <- sub("^Total hours:\\s*", "", find_total_hours(data()))
        num <- suppressWarnings(as.numeric(txt))
        if (!is.na(num)) txt <- format(round(num, 2), big.mark = ",", nsmall = 2)

        div(
            class = "kpi",
            span(class = "kpi__value", txt),
            span(class = "kpi__unit", "hours")
        )
    })

    output$average_hours_text <- renderUI({
        stat_chips(
            find_average_hours(data()),
            c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
        )
    })

    output$average_subteam_text <- renderUI({
        vals <- find_subteam_hours(data())
        n <- length(strsplit(vals, "||", fixed = TRUE)[[1]])
        teams <- sort(unique(as.character(na.omit(data()$Subteam))), method = "radix")
        stat_chips(
            vals,
            pick_labels(n, teams, c("Biz", "DS", "Elec", "Mech", "Prog"))
        )
    })

    output$average_grade_text <- renderUI({
        stat_chips(
            find_grade_hours(data(), TRUE),
            c("Freshmen", "Sophomores", "Juniors", "Seniors")
        )
    })

    # ---- Admin Panel -----------------------------------------------------------
    output$admin_panel <- renderUI({
        if (login()) {
            div(
                class = "auth-card auth-card--single",
                div(
                    class = "auth-main text-center",
                    div(class = "auth-badge auth-badge--success", icon_svg("check")),
                    h3("Access granted"),
                    p(class = "auth-sub", "You're signed in as an admin."),
                    actionButton("logout", "Sign out", class = "btn-outline-primary btn-auth")
                )
            )
        } else {
            div(
                class = "auth-card",
                div(
                    class = "auth-aside",
                    div(class = "auth-badge", icon_svg("lock")),
                    h2("Admin Panel"),
                    p("Restricted area. Sign in to view protected team data.")
                ),
                div(
                    class = "auth-main",
                    h3("Welcome back"),
                    p(class = "auth-sub", "Enter the admin password to continue."),
                    div(
                        class = "pw-field",
                        passwordInput(
                            "password", "Password",
                            placeholder = "Enter password", width = "100%"
                        ),
                        tags$button(
                            type = "button", class = "pw-toggle",
                            `aria-label` = "Show password",
                            icon_svg("eye"), icon_svg("eye_off")
                        )
                    ),
                    actionButton("login", "Sign in", class = "btn-primary btn-auth"),
                    uiOutput("login_status")
                )
            )
        }
    })

    observeEvent(input$login, {
        correct <- get0("correct_password", ifnotfound = NULL)
        if (is.null(correct)) message("correct_password is not defined.")

        attempt <- input$password
        ok <- !is.null(correct) && length(attempt) == 1 && nzchar(attempt) &&
            identical(as.character(attempt), as.character(correct))

        if (ok) {
            login_fails(0L)
            login(TRUE)
        } else {
            login(FALSE)
            login_fails(login_fails() + 1L)
        }
    })

    observeEvent(input$logout, {
        login(FALSE)
        login_fails(0L)
    })

    output$login_status <- renderUI({
        req(login_fails() > 0)
        div(
            class = "login-alert login-alert--error",
            role = "alert",
            icon_svg("alert"),
            span("Incorrect password. Please try again.")
        )
    })
    
    observeEvent(login(), {
        if (login() && !tabs_shown()) {
            for (tab1 in hidden_tabs()) appendTab("main_nav", tab1, select = FALSE)
            tabs_shown(TRUE)
        } else if (!login() && tabs_shown()) {
            updateNavbarPage(session, "main_nav", selected = "Admin Panel")
            for (tab2 in c("tab_summary", "tab_individual", "tab_raw")) removeTab("main_nav", tab2)
            tabs_shown(FALSE)
        }
    })
}
