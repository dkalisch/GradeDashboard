library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Grade Dashboard"
  ),
  
  dashboardSidebar(
    sidebarMenu(id = "sidebarmenu",
                #tags$a(href='http://new.trinity.edu', tags$img(src = 'logos/tlogo.png', height = '167', width = '240')),
                conditionalPanel("input.sidebarmenu === 'dashboard'",
                                 uiOutput("selectCourse"),
                                 textInput("id", label = "Enter your studentID"),
                                 textInput("email", label = "Enter your email")),
                                 submitButton("Get my grade!", icon("graduation-cap")),
                tags$style(type='text/css', "
                           button { font-size: 30px; position: absolute; left: 12px; }
                           #updateTime{position: absolute; left: 12px;}
                           #updateTimeHead{position: relative; left: 12px;}
                           " ),
                br(),
                br(),
                br(),
                br(),
                menuItem("Dashboard", tabName = "dashboard", icon = icon("tachometer")),
                menuItem("Timeline", tabName = "timeline", icon = icon("area-chart")),
                menuItem("Raw data", tabName = "rawdata", icon = icon("table")),
                br(),
                br(),
                HTML("<p id='updateTimeHead'>Last update:</p>"),
                textOutput("updateTime"),
                br(),
                br(),
                helpText(HTML("&copy; 2016 - Dr. Dominik Kalisch <br />This software is still in beta status.<br />Please report a problem to <br /><a href='mailto:dkalisch@trinity.edu'>dkalisch@trinity.edu</a>"), style = "margin-left: 12px")
    )
  ),
  
  dashboardBody(
    #tags$head(tags$style(HTML('
    #    .skin-blue .main-header .logo {
    #                          background-color: #3c8dbc;
    #                          }
    #                          .skin-blue .main-header .logo:hover {
    #                          background-color: #3c8dbc;
    #                          }
    #                          '))),
    tabItems(
      tabItem("dashboard",
              h2("Overall Performance"),
              fluidRow(
                valueBoxOutput("letterGrade", width = 4),
                valueBoxOutput("percentGrade", width = 4),
                #valueBoxOutput("totalPoints", width = 4),
                valueBoxOutput("classRank", width = 4)
              ),
              
              h2("Performance per Part"),
              fluidRow(
                valueBoxOutput("extraPoints"),
                valueBoxOutput("presentation"),
                valueBoxOutput("examTotal"),
                valueBoxOutput("assignmentTotal"),
                valueBoxOutput("quizTotal"),
                valueBoxOutput("classParticipationTotal"),
                valueBoxOutput("homeworkTotal")
              )
      ),
      tabItem("timeline",
              h2("Your development over time"),
              fluidRow(
                plotOutput('participationPlot'),
                br(),
                plotOutput('examPlot'),
                br(),
                plotOutput('homeworkPlot'),
                br(),
                plotOutput('assignmentPlot'),
                br(),
                plotOutput('quizPlot')
              )
      ),
      tabItem("rawdata",
              numericInput("maxrows", "Rows to show", 25),
              verbatimTextOutput("rawtable"),
              downloadButton("downloadCsv", "Download as CSV")
      )
    )
  ),
  skin = "blue"
)