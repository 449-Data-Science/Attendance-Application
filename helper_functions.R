time_fixer <- function(a_number) {
    a_string <- as.character(a_number)
    new_string <- substring(a_string, 11)
    return(new_string)
}

time_rounder <- function(time) {
    h <- hour(time)
    m <- minute(time)
    
    if (h == 15 && m >= 10 && m <= 40) {  # if 3:10 to 3:40, default 3:30
        time <- update(time, hour = 15, minute = 30, second = 0)
    }  else if (h == 17 && m >= 45) {  # if after 5:45, default to 6:00
        time <- update(time, hour = 18, minute = 0, second = 0)
    }
    
    return(time)
}

hour_min_format <- function(val) { # convert 6.5 hours to 6:30
    if (is.null(val) || length(val) == 0 || is.na(val) || !is.numeric(val)) {
        "00:00"
    } else {
        hour <- floor(val)
        mins <- floor((val - hour) * 60)
        sprintf("%02d:%02d", hour, mins)
    }
}

process_data <- function(raw, roster) {
    roster <- rename(roster, student_ID = `Full Name`)
    
    data <- raw |>
        rowwise() |>
        mutate(
            time = time_fixer(time_rounder(Time)), # round, then convert to str
            student_ID = StudentID,
            date = as.character(as.POSIXct(Date, format="%Y:%m:%d"))
        ) |>
        group_by(student_ID, date) |>
        reframe(
            time_arrived = time_fixer(
                min(as.POSIXct(time, format="%H:%M:%S"), na.rm = TRUE)),
            time_left = time_fixer(
                max(as.POSIXct(time, format="%H:%M:%S"), na.rm = TRUE)),
            time_spent = ifelse(
                time_arrived != time_left, 
                round(as.numeric(difftime(
                    max(as.POSIXct(time, format="%H:%M:%S"), na.rm = TRUE), 
                    min(as.POSIXct(time, format="%H:%M:%S"), na.rm = TRUE), 
                    units = "hours")), digits = 2), 
                1
            ),
            weekday = weekdays(as.Date(date, format = "%Y-%m-%d")),
            identified = ifelse(substr(student_ID, 1, 4) == "#WD:", FALSE, TRUE)
        ) |>
        arrange(date, time_arrived) |>
        unique() |>
        left_join(roster, by = "student_ID")
    
    return(data)
}

process_summary <- function(raw, specific) {
    data <- raw |>
        filter(
            case_when(
                specific == "Freshman" ~ Grade == 9,
                specific == "Sophomore" ~ Grade == 10,
                specific == "Junior" ~ Grade == 11,
                specific == "Senior" ~ Grade == 12,
                specific == "STL" ~ `Team Status` == "STL",
                specific == "UL" ~ `Team Status` == "UL",
                specific == "Business" ~ Subteam == "Business",
                specific == "Data Science" ~ Subteam == "Data Science",
                specific == "Electronics" ~ Subteam == "Electronics",
                specific == "Mechanics" ~ Subteam == "Mechanics",
                specific == "Programming" ~ Subteam == "Programming",
                specific == "Identified" ~ identified == TRUE,
                TRUE ~ student_ID == student_ID
            )
        ) |>
        group_by(student_ID) |>
        summarize(total = sum(time_spent)) |>
        arrange(desc(total)) |>
        rowwise() |>
        mutate(total_string = hour_min_format(total))
    
    return(data)
}

member_graph <- function(raw, selected_id) {
    data <- raw |>
        filter(student_ID %in% selected_id) |>
        mutate(student_ID = factor(student_ID))
    
    ggplot(data, aes(x = date, y = time_spent, color = student_ID)) +
        geom_line() +
        geom_point() +
        theme_bw() +
        theme(legend.position = "bottom")
}

find_total_hours <- function(data) {
    total_hours <- data |>
        summarize(total = sum(data$time_spent)) |>
        pull(total) |>
        as.character()
    
    hours_text <- paste0("Total hours: ", total_hours)
        
    return(hours_text)
}

find_average_hours <- function(raw) {
    data <- raw |>
        group_by(date, weekday) |>
        summarise(time = sum(time_spent)) |>
        group_by(weekday) |>
        summarise(time = mean(time))
    
    days <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
    times <- sapply(days, \(x) data[data$weekday == x, ]$time)
    text <- sapply(times, \(x) paste0(hour_min_format(x)))
    text <- paste0(text, collapse = " || ")
    return(text)
}

find_grade_hours <- function(raw, per_capita) {
    temp <- raw |>
        select(student_ID, Grade) |>
        unique()
    count <- sapply(9:12, \(x) sum(temp$Grade == x, na.rm = TRUE)) |> unlist()
    
    data <- raw |>
        na.omit() |>
        group_by(Grade) |>
        summarise(hours = sum(time_spent))
    
    hours <- data$hours
    hours <- if_else(rep(per_capita, 4), hours / count, hours)
    text <- sapply(hours, \(x) paste0(hour_min_format(x)))
    text <- paste0(text, collapse = " || ")
    return(text)
}

find_subteam_hours <- function(raw) {
    members <- raw |> 
        na.omit() |>
        select(student_ID, Subteam) |>
        unique() |>
        group_by(Subteam) |>
        summarise(count = n())
    
    data <- raw |>
        na.omit() |>
        group_by(Subteam) |>
        summarise(hours = sum(time_spent))
    
    per_capita <- round(data$hours / members$count, 2)
    names(per_capita) <- data$Subteam
    text <- sapply(per_capita, \(x) paste0(hour_min_format(x)))
    text <- paste0(text, collapse = " || ")
}

find_wds <- function(raw) {
    data <- raw |>
        filter(identified == FALSE) |>
        pull(student_ID)
}

cumulative_plot <- function(raw) {
    data <- raw |>
        group_by(date) |>
        summarize(
            total_time_daily = sum(time_spent)
        ) |>
        mutate(
            date = as.Date(date, format = "%Y-%m-%d")
        )
    
    data$cumulative_hours = round(cumsum(data$total_time_daily), 2)
    
    ggplot(data, aes(x = date, y = cumulative_hours)) +
        geom_area(fill = "#a7000a", alpha = 0.5) +
        geom_line(color = "black", size = 0.5) +
        scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
        labs(x = "Date", y = "Cumulative Hours") + 
        theme_bw()
}

group_plot <- function(raw) {
    data <- raw |>
        group_by(date) |>
        summarize(
            total_time_daily = sum(time_spent)
        ) |>
        mutate(
            date = as.Date(date, format = "%Y-%m-%d")
        )
    ggplot(data, aes(x = date, y = total_time_daily)) +
        geom_bar(stat = "identity", fill = "#a7000a") +
        scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
        labs(x = "Date", y = "Daily Average Hours") +
        expand_limits(y = 0) +
        theme_bw()
    
}