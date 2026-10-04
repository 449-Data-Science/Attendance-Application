server <- function(input, output) {
    output$attendanceTable <- renderTable({
        data
    })
    output$summaryTable <- renderTable({
        summary
    })
    output$individual_graph <- renderPlot({
        member_graph(data, input$selected_id)
    })
    output$cumulative_graph <- renderPlot({
        cumulative_plot(data)
    })
    output$group_average_graph <- renderPlot({
        group_plot(data)
    })
    output$total_hours_text <- renderText({
        find_total_hours(data)
    })
}