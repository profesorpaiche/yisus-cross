function(input, output) {
    # Current files
    current_references <- eventReactive(input$load_current, {
        file <- input$current
        current_references <- readLines(file$datapath) %>%
            look_references() %>%
            create_filename()
    })

    observeEvent(input$load_current, {
        output$current_content <- renderPrint({
            print(current_references())
        })
    })

    # Old files
    old_references <- eventReactive(input$old, {
        files <- input$old
        old_files(files$name)
    })

    observeEvent(input$old, {
        output$old_content <- renderPrint({
            print(old_references())
        })
    })

    # Old in current file
    old_cross <- eventReactive(input$old_in_current, {
        old_in_current(
            old_references()$file_name,
            current_references()$file_name
        )
    })

    observeEvent(input$old_in_current, {
        output$old_cross <- renderPrint({
            print(old_cross())
        })
    })

    # Current in old references
    current_cross <- eventReactive(input$current_in_old, {
        current_file <- input$current$name
        current_file <- str_split_fixed(current_file, "[.]", n = 2)[, 1]
        current_file_idx <- current_in_old(
            current_file,
            input$old$datapath
        )
        input$old[current_file_idx, "name"]
    })

    observeEvent(input$current_in_old, {
        output$current_cross <- renderPrint({
            print(current_cross())
        })
    })
}
