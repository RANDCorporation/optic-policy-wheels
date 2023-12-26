library(shiny)
library(shinythemes)
library(haven)
library(openxlsx)

ui <- navbarPage(
  title = "OPTIC Policy Wheels",
  theme = shinythemes::shinytheme("readable"),
  
  # footer = footer("Copyright © 2021"),
  
  tabPanel("About this tool",
           p("This tool allows you to create policy wheels for your organization."),
           p("To get started, click on the 'Make policy wheel' tab.")),
  
  tabPanel("Make policy wheel",
           p("Filler content for the 'Make policy wheel' tab."),
           fileInput("file1", "Upload Data (CSV format)"),
           plotOutput("myplot", 
                      width = paste0(96*20, "px"), 
                      height = paste0(96*12, "px")
           ),
           actionButton("updateBtn", "Update Plot"),
           downloadButton("downloadBtn", "Download Plot as SVG")
           ),
  
  tabPanel("Tutorial",
           p("Filler content for the 'Tutorial' tab."))
)

server <- function(input, output, session) {
  
  # defining a reactive value
  raw = reactiveVal()
  plot_out = reactiveVal()
  
  # reading in data
  raw <- reactive ({req(input$file1)
    
        if(substrRight(input$file1$datapath, 4)==".csv"){
          cat("data imported.")
          input_data <- read.csv(input$file1$datapath, header=T)}
        else if (substrRight(input$file1$datapath, 5)==".xlsx"){
          input_data <- openxlsx::read.xlsx(input$file1$datapath)}
        else if (substrRight(input$file1$datapath, 4)==".dta"){
          input_data <- read.dta(input$file1$datapath)}
        else if (substrRight(input$file1$datapath, 9)==".sas7bdat"){
          input_data <- read_sas(input$file1$datapath)}
        else {stop("Please upload a csv, xlsx, dta, or sas7bdat file")}
    input_data})
  
  # Observe the button click and recalculate the plot
  observeEvent(input$updateBtn, {
    plot_out = reactive({
      #req(raw())
      plot_policy_wheels(data = raw(),
                         
                         # Ordering policies by name:
                         policies = c("Any Naloxone Access Law (NAL)", "NAL Standing Order or Protocol", "NAL Prescriptive Authority", "Any Good Samaritan Law (GSL)", "GSL Arrest"),
                         
                         # name of the state variable
                         state_var = "state",
                         
                         # Restrict to relevant policy intervals, for locations that implemented the policy
                         policy_intervals = c(2010, 2015, 2020),
                         plot_colors = c("#1f77b4", "#ff7f0e", "#FFFF00", "#dab8e5", "#9467bd"),
                         legend_args = list(x = "center", xjust = 0.5, y.intersp = 1.3, x.intersp = 1.3, cex = 2.5, pt.cex = 2.7, bty = "n", ncol = 2),
                         
                         panel_width = 4,
                         panel_height = 5)
    })
  })
  
  # Render the plot in the UI with fixed width and height
  output$myplot <- renderPlot({
    
    plot_out()
    
  }, 
  width = 96*20, 
  height = 96*12)
  
  # Download handler
  output$downloadBtn <- downloadHandler(
    
    filename = function() {
      "myfile.svg"
    },
    content = function(file) {
      
      # Save the plot as an SVG file
      svg(file, width = paste0(96*20, "px"), height = paste0(96*12, "px"))
      plot_out()
      dev.off()
    }
  )
}

shinyApp(ui = ui, server = server)
