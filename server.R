library(shiny)

shinyServer(function(input, output, session) {

  # Menus
  ## Create a menu to select the years to be loaded
  output$selectCourse <- renderUI({
      selectInput("selectCourse", "Choose a course:", courses)
  })
  
  # Load data
  ## Load setting data from selected file
  gradesSettings <- reactive({
    validate(
      need(input$selectCourse, "select a course"),
      need(input$id, "enter your studentID")
    )
    read.xlsx2(file = paste0("data/", input$selectCourse, ".xlsx", sep = ""),
               sheetName = "Settings",
               header = TRUE,
               stringsAsFactors = FALSE,
               colClasses = c("character", "character"))
  })
  
  ## Get number of students
  nStudents <- reactive({
    gradesSettings() %>%
      filter(item == "Number of Students") %>%
      select(value)
  })
  
  ## Get row number of max points
  maxPoints <- reactive({
    gradesSettings() %>%
      filter(item == "Row number max points") %>%
      select(value)
  })
  
  good.l <- reactive({
    gradesSettings() %>%
      filter(item == "Good") %>%
      select(value)
  })
  
  average.l <- reactive({
    gradesSettings() %>%
      filter(item == "Average") %>%
      select(value)
  })
  
  poor.l <- reactive({
    gradesSettings() %>%
      filter(item == "Poor") %>%
      select(value)
  })
  
  ## Check if points can be recieved from exams
  exam.t <- reactive({
    gradesSettings() %>%
      filter(item == "Exam") %>%
      select(value)
  })
  
  ## Check if points can be recieved from assignments
  assignment.t <- reactive({
    gradesSettings() %>%
      filter(item == "Assignment") %>%
      select(value)
  })
  
  ## Check if points can be recieved from quizzes
  quiz.t <- reactive({
    gradesSettings() %>%
      filter(item == "Quiz") %>%
      select(value)
  })
  
  ## Check if points can be recieved from participation
  participation.t <- reactive({
    gradesSettings() %>%
      filter(item == "Class Participation") %>%
      select(value)
  })
  
  ## Check if points can be recieved from extra points
  extra.t <- reactive({
    gradesSettings() %>%
      filter(item == "Extra Points") %>%
      select(value)
  })
  
  ## Check if points can be recieved from presentation
  presentation.t <- reactive({
    gradesSettings() %>%
      filter(item == "Class Participation") %>%
      select(value)
  })
  
  ## Check if points can be recieved from homwork
  homework.t <- reactive({
    gradesSettings() %>%
      filter(item == "Homework") %>%
      select(value)
  })
  
  ## Get time of last update from seleced file
  output$updateTime <- renderText({
    validate(
      need(input$selectCourse, ""),
      need(input$id, "")
    )
    as.character(file.info(paste0("data/", input$selectCourse, ".xlsx", sep = ""))$mtime)
  })
  
  ## Load grades from file
  grades <- reactive({
    validate(
      need(input$selectCourse, "select a course"),
      need(input$id, "enter your id")
    )
    read.xlsx(file = paste0("data/", input$selectCourse, ".xlsx", sep = ""),
              sheetName = "Grades",
              rowIndex = c(1:(as.numeric(nStudents())+1)))
  })
  
  gradesMax <- reactive({
    validate(
      need(input$selectCourse, "select a course"),
      need(input$id, "enter your id")
    )
    
    grades.max <- read.xlsx(file = paste0("data/", input$selectCourse, ".xlsx", sep = ""),
                            sheetName = "Grades",
                            startRow = as.numeric(maxPoints())-1,
                            endRow = as.numeric(maxPoints()),
                            colIndex = 1:ncol(grades()))
    
    grades.max <- grades.max[-c(1:2)]
    colnames(grades.max) <- c("A", colnames(grades())[-c(1:5)])
    grades.max
  })
  
  gradesAvg <- reactive({
    validate(
      need(input$selectCourse, "select a course"),
      need(input$id, "enter your id")
    )
    
    grades()[,6:ncol(grades())] %>% summarise_each(funs(mean))
  })
  
  # Get data for specific student
  gradesStudent <- reactive({
    grades() %>%
      filter(ID.number == input$id & Email.address == input$email)
      #filter(ID.number == input$id)
  })
  
  # Boxes for the overall performance
  output$letterGrade <- renderValueBox({
    # Set valuebox parameter depending on performance
    if(gradesStudent()$Course.total >= as.numeric(good.l())){
      c.vb <- "green"
      i.vb <- "thumbs-up"
    } else if(gradesStudent()$Course.total >= as.numeric(average.l())){
      c.vb <- "yellow"
      i.vb <- "flash"
    } else {
      c.vb <- "red"
      i.vb <- "fire"
    }
    
    valueBox(
      gradesStudent()$Grade, "Letter Grade",
      icon = icon(i.vb, lib = "glyphicon"),
      color = c.vb
    )
  })
  
  output$percentGrade <- renderValueBox({
    # Set valuebox parameter depending on performance
    if(gradesStudent()$Course.total >= as.numeric(good.l())){
      c.vb <- "green"
      i.vb <- "thumbs-up"
    } else if(gradesStudent()$Course.total >= as.numeric(average.l())){
      c.vb <- "yellow"
      i.vb <- "flash"
    } else {
      c.vb <- "red"
      i.vb <- "fire"
    }
    
    valueBox(
      paste0(round(gradesStudent()$Course.total * 100, 2), "%"), "Percentage",
      icon = icon(i.vb, lib = "glyphicon"),
      color = c.vb
    )
  })
  
  output$classRank <- renderValueBox({
    tmp.df <- grades()[order(grades()$Course.total, decreasing = TRUE),]
    studentRank <- which(tmp.df$ID.number == input$id)
    
    valueBox(
      paste0("Rank #", studentRank),
      paste0("in class out of ", nStudents()),
      icon = icon("user", lib = "glyphicon"),
      color = "aqua"
    )
  })
  
  # Part performance
  ## Extra points
  observe({
    if(extra.t() == "Yes"){
      output$extraPoints <- renderValueBox({
        sp <- gradesStudent()$Extra.points
        mp <- gradesMax()$Extra.points
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | mp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " from Extra Points", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }

  ## Presentation
    if(presentation.t() == "Yes"){
      output$presentation <- renderValueBox({
        sp <- gradesStudent()$Presentation
        mp <- gradesMax()$Presentation
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Presentations", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }
  
  ## Exam total
    if(exam.t() == "Yes"){
      output$examTotal <- renderValueBox({
        sp <- gradesStudent()$Exam.total
        mp <- gradesMax()$Exam.total
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Exams", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }
    
  ## Assignment total
    if(assignment.t() == "Yes"){
      output$assignmentTotal <- renderValueBox({
        sp <- gradesStudent()$Assignment.total
        mp <- gradesMax()$Assignment.total
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Assignments", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }
    
  ## Quiz total
    if(quiz.t() == "Yes"){
      output$quizTotal <- renderValueBox({
        sp <- gradesStudent()$Quiz.total
        mp <- gradesMax()$Quiz.total
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Quizzes", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }
    
  ## Participation total
    if(participation.t() == "Yes"){
      output$classParticipationTotal <- renderValueBox({
        sp <- gradesStudent()$Class.Participation.total
        mp <- gradesMax()$Class.Participation.total
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Participation", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }

  ## Homework total
    if(homework.t() == "Yes"){
      output$homeworkTotal <- renderValueBox({
        sp <- gradesStudent()$Homework.total
        mp <- gradesMax()$Homework.total
        if(sp == 0){
          pp <- 0
        } else {
          pp <- round(sp/mp*100, 2)
        }
        
        # Set valuebox parameter depending on performance
        if(pp/100 >= as.numeric(good.l()) | pp == 0){
          c.vb <- "green"
          i.vb <- "thumbs-up"
        } else if(pp/100 >= as.numeric(average.l())){
          c.vb <- "yellow"
          i.vb <- "flash"
        } else {
          c.vb <- "red"
          i.vb <- "fire"
        }
        
        valueBox(
          paste0(sp, " (", pp, "%)"),
          paste0("out of ", mp, " points from Homeworks", sep = ""),
          icon = icon(i.vb, lib = "glyphicon"),
          color = c.vb
        )
      })
    }
  })

  # Timeline plots
  ## Get individual timeline data
  participation.time <- reactive({
    df <- gradesStudent()[, grep("^Class.Participation", names(gradesStudent()), value = TRUE)]
    df <- melt(df, measure.vars = names(df))
    df <- df[-1,]
    df$variable <- gsub("[.]", " ", gsub("([0-9]+)[.]", "\\1/", df$variable))
    df <- df %>%
      filter(!is.na(value))
    
    df.avg <- gradesAvg()[, grep("^Class.Participation", names(gradesAvg()),
                             value = TRUE)]
    df.avg <- melt(df.avg, measure.vars = names(df.avg))
    df.avg <- df.avg[-1,]
    df.avg <- df.avg %>%
      filter(!is.na(value))
    
    df$avg <- df.avg$value
    df <- melt(df, variable.name = "type")
    df
  })
  
  homework.time <- reactive({
    df <- gradesStudent()[, grep("^Homework", names(gradesStudent()), value = TRUE)]
    df <- melt(df, measure.vars = names(df))
    df <- df[-1,]
    df$variable <- gsub("[.]", " ", gsub("([0-9]+)[.]", "\\1/", df$variable))
    df <- df %>%
      filter(!is.na(value))
    
    df.avg <- gradesAvg()[, grep("^Homework", names(gradesAvg()),
                                 value = TRUE)]
    df.avg <- melt(df.avg, measure.vars = names(df.avg))
    df.avg <- df.avg[-1,]
    df.avg <- df.avg %>%
      filter(!is.na(value))
    
    df$avg <- df.avg$value
    df <- melt(df, variable.name = "type")
    df
  })
  
  exam.time <- reactive({
    df <- gradesStudent()[, grep("^Exam", names(gradesStudent()), value = TRUE)]
    df <- melt(df, measure.vars = names(df))
    df <- df[-1,]
    df$variable <- gsub("[.]", " ", gsub("([0-9]+)[.]", "\\1/", df$variable))
    df <- df %>%
      filter(!is.na(value))
    
    df.avg <- gradesAvg()[, grep("^Exam", names(gradesAvg()),
                                 value = TRUE)]
    df.avg <- melt(df.avg, measure.vars = names(df.avg))
    df.avg <- df.avg[-1,]
    df.avg <- df.avg %>%
      filter(!is.na(value))
    
    df$avg <- df.avg$value
    df <- melt(df, variable.name = "type")
    df
  })
  
  assignment.time <- reactive({
    df <- gradesStudent()[, grep("^Assignment", names(gradesStudent()), value = TRUE)]
    df <- melt(df, measure.vars = names(df))
    df <- df[-1,]
    df$variable <- gsub("[.]", " ", gsub("([0-9]+)[.]", "\\1/", df$variable))
    df <- df %>%
      filter(!is.na(value))
    
    df.avg <- gradesAvg()[, grep("^Assignment", names(gradesAvg()),
                                 value = TRUE)]
    df.avg <- melt(df.avg, measure.vars = names(df.avg))
    df.avg <- df.avg[-1,]
    df.avg <- df.avg %>%
      filter(!is.na(value))
    
    df$avg <- df.avg$value
    df <- melt(df, variable.name = "type")
    df
  })
  
  quiz.time <- reactive({
    df <- gradesStudent()[, grep("^Quiz", names(gradesStudent()), value = TRUE)]
    df <- melt(df, measure.vars = names(df))
    df <- df[-1,]
    df$variable <- gsub("[.]", " ", gsub("([0-9]+)[.]", "\\1/", df$variable))
    df <- df %>%
      filter(!is.na(value))
    
    df.avg <- gradesAvg()[, grep("^Quiz", names(gradesAvg()),
                                 value = TRUE)]
    df.avg <- melt(df.avg, measure.vars = names(df.avg))
    df.avg <- df.avg[-1,]
    df.avg <- df.avg %>%
      filter(!is.na(value))
    
    df$avg <- df.avg$value
    df <- melt(df, variable.name = "type")
    df
  })
  
  ## Plot for participation over time
  observe({
    if(participation.t() == "Yes"){
      output$participationPlot <- renderPlot({
        df <- participation.time()
        dft <- gradesMax()$Class.Participation.total
        px <- "Date"
        py <- "Points"
        pt <- "Participation over Time"
        
        p <- ggplot(df, aes(x = as.integer(as.factor(variable)), y = value, color = type)) +
          geom_point() + 
          geom_line() +
          scale_x_discrete(labels = df$variable, expand = c(0.1,-1)) +
          labs (x = px, y = py) +
          ggtitle(pt) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 12),
                axis.text.y = element_text(size = 12),
                axis.title.y = element_text(size = 14, vjust = 1.5),
                axis.title.x = element_text(size = 14, vjust = -1.5),
                plot.title = element_text(size = 18, vjust = 2),
                plot.margin = unit(c(1, 1, 1, 1), "lines"),
                plot.background = element_rect(fill = "transparent",colour = NA),
                legend.background = element_rect(fill = "transparent",colour = NA),
                legend.position="top"
          ) +
          scale_colour_brewer(palette = "Dark2", labels=c("My points", "Class average"))+
          guides(colour = guide_legend(title = "Colors"))
        print(p)
      }, bg = "transparent")
    }
    
    if(exam.t() == "Yes"){
      output$examPlot <- renderPlot({
        df <- exam.time()
        dft <- gradesMax()$Exam.total
        px <- "Exams"
        py <- "Points"
        pt <- "Exam performance over Time"
        
        p <- ggplot(df, aes(x = as.integer(as.factor(variable)), y = value, color = type)) +
          geom_point() + 
          geom_line() +
          scale_x_discrete(labels = df$variable, expand = c(0.1,-1)) +
          labs (x = px, y = py) +
          ggtitle(pt) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 12),
                axis.text.y = element_text(size = 12),
                axis.title.y = element_text(size = 14, vjust = 1.5),
                axis.title.x = element_text(size = 14, vjust = -1.5),
                plot.title = element_text(size = 18, vjust = 2),
                plot.margin = unit(c(1, 1, 1, 1), "lines"),
                plot.background = element_rect(fill = "transparent",colour = NA),
                legend.background = element_rect(fill = "transparent",colour = NA),
                legend.position="top"
          ) +
          scale_colour_brewer(palette = "Dark2", labels=c("My points", "Class average"))+
          guides(colour = guide_legend(title = "Colors"))
        print(p)
      }, bg = "transparent")
    }
    
    if(homework.t() == "Yes"){
      output$homeworkPlot <- renderPlot({
        df <- homework.time()
        dft <- gradesMax()$Homework.total
        px <- "Homeworks"
        py <- "Points"
        pt <- "Homework performance over Time"
        
        p <- ggplot(df, aes(x = as.integer(as.factor(variable)), y = value, color = type)) +
          geom_point() + 
          geom_line() +
          scale_x_discrete(labels = df$variable, expand = c(0.1,-1)) +
          labs (x = px, y = py) +
          ggtitle(pt) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 12),
                axis.text.y = element_text(size = 12),
                axis.title.y = element_text(size = 14, vjust = 1.5),
                axis.title.x = element_text(size = 14, vjust = -1.5),
                plot.title = element_text(size = 18, vjust = 2),
                plot.margin = unit(c(1, 1, 1, 1), "lines"),
                plot.background = element_rect(fill = "transparent",colour = NA),
                legend.background = element_rect(fill = "transparent",colour = NA),
                legend.position="top"
          ) +
          scale_colour_brewer(palette = "Dark2", labels=c("My points", "Class average"))+
          guides(colour = guide_legend(title = "Colors"))
        print(p)
      }, bg = "transparent")
    }
    
    if(assignment.t() == "Yes"){
      output$assignmentPlot <- renderPlot({
        df <- assignment.time()
        dft <- gradesMax()$Assignment.total
        px <- "Assignments"
        py <- "Points"
        pt <- "Assignment performance over Time"
        
        p <- ggplot(df, aes(x = as.integer(as.factor(variable)), y = value, color = type)) +
          geom_point() + 
          geom_line() +
          scale_x_discrete(labels = df$variable, expand = c(0.1,-1)) +
          labs (x = px, y = py) +
          ggtitle(pt) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 12),
                axis.text.y = element_text(size = 12),
                axis.title.y = element_text(size = 14, vjust = 1.5),
                axis.title.x = element_text(size = 14, vjust = -1.5),
                plot.title = element_text(size = 18, vjust = 2),
                plot.margin = unit(c(1, 1, 1, 1), "lines"),
                plot.background = element_rect(fill = "transparent",colour = NA),
                legend.background = element_rect(fill = "transparent",colour = NA),
                legend.position="top"
          ) +
          scale_colour_brewer(palette = "Dark2", labels=c("My points", "Class average"))+
          guides(colour = guide_legend(title = "Colors"))
        print(p)
      }, bg = "transparent")
    }
    
    if(quiz.t() == "Yes"){
      output$quizPlot <- renderPlot({
        df <- quiz.time()
        dft <- gradesMax()$Homework.total
        px <- "Quizzes"
        py <- "Points"
        pt <- "Quiz performance over Time"
        
        p <- ggplot(df, aes(x = as.integer(as.factor(variable)), y = value, color = type)) +
          geom_point() + 
          geom_line() +
          scale_x_discrete(labels = df$variable, expand = c(0.1,-1)) +
          labs (x = px, y = py) +
          ggtitle(pt) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 12),
                axis.text.y = element_text(size = 12),
                axis.title.y = element_text(size = 14, vjust = 1.5),
                axis.title.x = element_text(size = 14, vjust = -1.5),
                plot.title = element_text(size = 18, vjust = 2),
                plot.margin = unit(c(1, 1, 1, 1), "lines"),
                plot.background = element_rect(fill = "transparent",colour = NA),
                legend.background = element_rect(fill = "transparent",colour = NA),
                legend.position="top"
          ) +
          scale_colour_brewer(palette = "Dark2", labels=c("My points", "Class average"))+
          guides(colour = guide_legend(title = "Colors"))
        print(p)
      }, bg = "transparent")
    }
  })
  
  
  # Raw data
  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    df <- gradesStudent() 
    head(input$maxrows)
    print(df)
    options(orig)
  })
})
