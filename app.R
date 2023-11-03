library(shiny)
library(shinythemes)

ui <- navbarPage(
  title = "OPTIC Policy Wheels",
  theme = shinythemes::shinytheme("readable"),
  
  # footer = footer("Copyright © 2021"),
  
  tabPanel("About this tool",
           p("This tool allows you to create policy wheels for your organization."),
           p("To get started, click on the 'Make policy wheel' tab.")),
  
  tabPanel("Make policy wheel",
           p("Filler content for the 'Make policy wheel' tab.")),
  
  tabPanel("Tutorial",
           p("Filler content for the 'Tutorial' tab."))
)

server <- function(input, output) {
  # server code goes here
}

shinyApp(ui = ui, server = server)
