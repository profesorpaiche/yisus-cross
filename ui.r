source("helper.r")

fluidPage(
    titlePanel("Ciber Yisus Cross"),
    sidebarLayout(
        sidebarPanel(
            h3("Welcome!"),
            p("This is a small tool to find cross-references between the 
              articles you have read."),
            p("The data required follows a specific format, which I will tell
              you about later.")
        ),
        mainPanel(
            fileInput(
                "current",
                label = "Please, insert file with the references"
            ),
            actionButton(
                inputId = "load_current",
                label = "Load file"
            ),
            verbatimTextOutput("current_content"),
            hr(),
            fileInput(
                "old",
                label = "Please, insert all the files already read",
                multiple = TRUE
            ),
            verbatimTextOutput("old_content"),
            hr(),
            p("Look for old articles in the current references"),
            actionButton("old_in_current", "Old in current"),
            verbatimTextOutput("old_cross"),
            hr(),
            p("Look for current file in the references of the old files"),
            actionButton("current_in_old", "Current in old"),
            verbatimTextOutput("current_cross")
        )
    )
)
