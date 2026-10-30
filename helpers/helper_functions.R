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
        apply_filters(specific) |>
        group_by(student_ID) |>
        summarize(total = sum(time_spent)) |>
        arrange(desc(total)) |>
        rowwise() |>
        mutate(total_string = hour_min_format(total))
    
    return(data)
}

apply_filters <- function(data, specific) {
    grades <- c(Freshman = 9, Sophomore = 10, Junior = 11, Senior = 12)
    subteams <- c("Business", "Data Science", "Electronics", "Mechanics", "Programming")
    sel_grades <- unname(grades[intersect(specific, names(grades))])
    sel_status <- intersect(specific, c("STL", "UL"))
    sel_sub <- intersect(specific, subteams)
    only_identified <- "Identified" %in% specific
    
    data |>
        filter(
            length(sel_grades) == 0 | Grade %in% sel_grades,
            length(sel_status) == 0 | `Team Status` %in% sel_status,
            length(sel_sub) == 0    | Subteam %in% sel_sub,
            !only_identified        | identified %in% TRUE
        )
}

find_wds <- function(raw) {
    data <- raw |>
        filter(identified == FALSE) |>
        pull(student_ID)
}
