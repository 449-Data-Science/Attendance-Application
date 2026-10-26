# Source: All Claude

# Small inline SVG icons so the app needs no icon font or extra packages.
icon_svg <- function(name) {
    paths <- list(
        lock = paste0(
            '<rect x="4" y="10" width="16" height="11" rx="3"/>',
            '<path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
            '<circle cx="12" cy="15.5" r="1.2" fill="currentColor"/>'
        ),
        eye = paste0(
            '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/>',
            '<circle cx="12" cy="12" r="3"/>'
        ),
        eye_off = paste0(
            '<path d="M3 3l18 18"/>',
            '<path d="M10.6 6.1A10.9 10.9 0 0 1 12 6c6.4 0 10 6 10 6a17 17 0 0 1-3.3 4.1M6.6 7.7C3.9 9.6 2 12 2 12s3.6 7 10 7c1.7 0 3.2-.4 4.5-1"/>',
            '<path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/>'
        ),
        check = '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
        alert = paste0(
            '<circle cx="12" cy="12" r="9"/>',
            '<path d="M12 7.5v5.5"/>',
            '<circle cx="12" cy="16.5" r=".8" fill="currentColor"/>'
        )
    )
    HTML(sprintf(
        paste0(
            '<svg class="icon icon-%s" viewBox="0 0 24 24" width="1em" height="1em" ',
            'fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" ',
            'stroke-linejoin="round" aria-hidden="true" focusable="false">%s</svg>'
        ),
        name, paths[[name]]
    ))
}

# Pick the first label set whose length matches the number of values we have.
pick_labels <- function(n, ...) {
    for (labels in list(...)) {
        if (length(labels) == n) return(labels)
    }
    rep("", n)
}

# Turns "01:30 || 02:00 || ..." (what the helper functions return) into tiles.
stat_chips <- function(text, labels = NULL) {
    vals <- trimws(strsplit(paste(text, collapse = " "), "||", fixed = TRUE)[[1]])
    vals <- vals[nzchar(vals)]
    if (length(vals) == 0) {
        return(tags$p(class = "stat-empty", "No data yet"))
    }
    labels <- if (is.null(labels)) rep("", length(vals)) else labels
    if (length(labels) != length(vals)) labels <- rep("", length(vals))
    
    div(
        class = "chip-grid",
        lapply(seq_along(vals), function(i) {
            div(
                class = paste("stat-chip", if (vals[i] == "00:00") "is-zero"),
                if (nzchar(labels[i])) span(class = "stat-chip__label", labels[i]),
                span(class = "stat-chip__value", vals[i])
            )
        })
    )
}

# Shared look for every ggplot (layered on top of the theme the plot already has).
brand_palette <- c("#a7000a", "#e8839f", "#5c0006", "#f4a3b8", "#c4101c", "#7a0007")

polish_plot <- function(p) {
    p +
        theme(
            text = element_text(size = 13, colour = "#3a0b12"),
            panel.border = element_blank(),
            panel.grid.major = element_line(colour = "#f6dce4"),
            panel.grid.minor = element_blank(),
            axis.line = element_line(colour = "#e8b4c2"),
            axis.ticks = element_line(colour = "#e8b4c2"),
            axis.title = element_text(colour = "#7a0007", face = "bold"),
            axis.text = element_text(colour = "#6b3a44"),
            legend.title = element_blank(),
            plot.margin = margin(10, 14, 10, 10)
        )
}