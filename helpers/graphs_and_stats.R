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
        drop_na(Grade) |>
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
        drop_na(Subteam) |>
        select(student_ID, Subteam) |>
        unique() |>
        group_by(Subteam) |>
        summarise(count = n())
    
    data <- raw |>
        drop_na(Subteam) |>
        group_by(Subteam) |>
        summarise(hours = sum(time_spent))
    
    per_capita <- round(data$hours / members$count, 2)
    names(per_capita) <- data$Subteam
    text <- sapply(per_capita, \(x) paste0(hour_min_format(x)))
    text <- paste0(text, collapse = " || ")
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
        geom_line(color = "darkred", linewidth = 2) +
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