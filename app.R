#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

### Read ceX-QTL data

dfAllFreqs = readRDS("dfAllFreqsProcessed.rds.gz")
library(shinyWidgets)
library(shiny)
library(ggplot2)
library(viridis)
library(ggthemes)
library(dplyr)
library(shinycssloaders)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("ceX-QTL Data Browser"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("exp",
                  "Experiment to Display",choices = unique(dfAllFreqs$exp),
                  selected=unique(dfAllFreqs$exp)[1]
      ),
      uiOutput("generations"),
      uiOutput("chromosome"),
      uiOutput("positions"),
      uiOutput("ycoord"),
      actionButton("draw", "Draw plot")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot") %>% withSpinner()
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$generations <- renderUI({
    pickerInput(
      inputId = "gens", 
      label = "Choose Generations to View", 
      choices = sort(unique(dfAllFreqs$generation[dfAllFreqs$exp==input$exp])), 
      options = list(
        `actions-box` = TRUE, 
        size = 12
      ), selected = sort(unique(dfAllFreqs$generation[dfAllFreqs$exp==input$exp])),
      multiple = TRUE
    )
  })
  output$chromosome <- renderUI({
    pickerInput(
      inputId = "chrom", 
      label = "Chromosomes", 
      choices = sort(unique(dfAllFreqs$chrom[dfAllFreqs$exp==input$exp])), 
      options = list(
        `actions-box` = TRUE, 
        size = 12
      ), selected = sort(unique(dfAllFreqs$chrom[dfAllFreqs$exp==input$exp])),
      multiple = TRUE
    )
  })
  output$positions <- renderUI({
    sliderInput("pos", label = h3("Slider Range"), min = 0, 
                max = max(dfAllFreqs$pos_N2[dfAllFreqs$exp==input$exp & dfAllFreqs$chrom %in% input$chrom]), value = c(1, 19997000))
  })
  output$ycoord <- renderUI({
    sliderInput("yrange", label = h3("y Axis Range"), min = -0.5, 
                max = 0.5, value = c(-0.5, 0.5))
  })
  output$distPlot <- renderPlot({
    req(input$draw)
    req(isolate(input$gens))
    # generate bins based on input$bins from ui.R
    curDF = dfAllFreqs %>% filter(dfAllFreqs$exp==isolate(input$exp)&dfAllFreqs$generation %in% isolate(input$gens))
    curDF = curDF %>% filter(pos_N2>isolate(input$pos)[1]&pos_N2<isolate(input$pos)[2] & curDF$chrom %in% isolate(input$chrom))
    ggplot(curDF,aes(x=pos_N2,y=value,color=as.factor(generation),group=generation)) + 
      theme_base() +  geom_line() + 
      scale_color_viridis(name="generation",discrete=T,begin = 1,end=0) + 
      ylab("\u2190 CB4856               N2     \u2192") + xlab("Physical Position (mb)") + theme(plot.background = element_blank()) +
      geom_hline(yintercept=0,linetype=3) +
      facet_grid(exp~chrom,scales = "free",space="free_x") + scale_y_continuous(limits=c(isolate(input$yrange[1]),isolate(input$yrange[2]))) +
      scale_x_continuous(labels = function(x)sub("^0kb","0",ifelse(x<1e5,paste(x/1e3,"kb",sep=""),paste(x/1e6,"mb",sep="")))) +  
      theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.background = element_blank(),legend.position="bottom",legend.direction = "horizontal")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

