
pacman::p_load(tidyverse, gglm)
pacman::p_load(knitr,dplyr,AICcmodavg)
pacman::p_load(inspectdf,tidyr,stringr, stringi,DT, lubridate)
pacman::p_load(mlbench,mplot)
pacman::p_load(tidymodels,glmx)
pacman::p_load(ggplot2,ggpubr,ggthemes,gridExtra,scales)
pacman::p_load(viridis,hrbrthemes)
pacman::p_load(rvest, RSelenium)
pacman::p_load(shiny, shinydashboard, shinyWidgets, shinyjs, shinyBS, shinyalert, shinyFiles, shinyFeedback, shinyjqui, shinyMobile, shinythemes, shinytoastr, shinyWidgets,DT)
pacman::p_load(dashboardthemes)

# Load dataset
seek_ds <- read.csv("seek_ds.csv")

# Filter the dataset
seek_ds_filtered <- seek_ds %>% filter(salary_annual >= 50000)

# Find the 10 most common job titles
common_titles <- seek_ds %>%
    count(job_title, sort = TRUE) %>%
    top_n(10)

# Find the 10 most common industries
common_industries <- seek_ds_filtered %>%
  count(industry, sort = TRUE) %>%
  top_n(10)

# Convert 'date_posted' column to date-time format
seek_ds$date_posted <- as.Date(seek_ds$date_posted)

# Count job postings per day per state
jobs_by_date_state <- seek_ds %>%
    count(date_posted, state)

# Create a new column 'week_start' that indicates the start of the week
jobs_by_date_state$week_start <- floor_date(jobs_by_date_state$date_posted, "week")

# Group data by 'state' and calculate the number of positions for each state
state_positions <- seek_ds %>%
    group_by(state) %>%
    summarise(n = n(), .groups = 'drop')

# Group data by 'state' and calculate the median salary for each state
state_salaries <- seek_ds_filtered %>%
    group_by(state) %>%
    summarise(median_salary = median(salary_annual, na.rm = TRUE), .groups = 'drop')

# Join the state_positions and state_salaries dataframes
state_summary <- inner_join(state_positions, state_salaries, by = "state")

states <- c("NSW", "QLD", "SA", "ACT", "VIC", "WA", "TAS", "NT")

ui <- dashboardPage(
  dashboardHeader(title = "Data Science Job Opportunities in Australia"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Job Market", tabName = "job_market", icon = icon("globe")),
      menuItem("Job Titles and Industries", tabName = "job_titles", icon = icon("industry")),
      menuItem("Time-Based Analysis", tabName = "time_analysis", icon = icon("history")),

        # interactive inputs 
       dateRangeInput("date_range", "Date range:", start = "2023-05-06", end = "2023-06-26"),
       checkboxGroupInput("states", "Select states:", choices = states, selected = states),
       numericInput("min_salary", "Minimum salary:", value = 50000, min = 30000, max = 150000, step = 1000)
    )
  ),
  dashboardBody(
    tabItems(
      # Job Market tab
      tabItem(tabName = "job_market",
        fluidRow(
          box(
            title = "Salary Distribution",
            width = 6,
            plotOutput("histogram")
          ),
          box(
            title = "Number of positions per state",
            width = 6,
            plotOutput("barplot")
          ),
          box(
            title = "Salary Distribution by State",
            width = 6,
            plotOutput("boxplot")
          ),
          box(
            title = "Summary by state",
            width = 6,
            DT::dataTableOutput("state_summary_table")
          )
        )
      ),
          
    # Job Titles Tab
    tabItem(tabName = "job_titles",
      fluidRow(
        box(
          title = "10 Most Common Job Titles",
          width = 6,
          plotOutput("common_titles")
        ),
        box(
          title = "10 Most Common Industries",
          width = 6,
          plotOutput("common_industries")
        ),
        box(
          title = "Median Salaries by Industry",
          width = 6,
          plotOutput("industry_salaries")
        ),
        box(
          title = "Data Tables",
          width = 6,
          selectInput("table_to_view", "Select table to view:", 
                      choices = c("Common Job Titles", "Common Industries", "Industry Salaries(in thousands)"),
                      selected = "Common Job Titles"),
          conditionalPanel(
            condition = "input.table_to_view == 'Common Job Titles'",
            DT::dataTableOutput("common_titles_table")
          ),
          conditionalPanel(
            condition = "input.table_to_view == 'Common Industries'",
            DT::dataTableOutput("common_industries_table")
          ),
          conditionalPanel(
            condition = "input.table_to_view == 'Industry Salaries(in thousands)'",
            DT::dataTableOutput("industry_salaries_table")
          )
        )
      )
    ),

      # Time-Based Analysis of Job Postings Tab
      tabItem(tabName = "time_analysis",
        fluidRow(
          box(
            title = "Job Postings Over Time, Stacked by State, with Week Start Indicated by Dashed Lines",
            width = 6,
            plotOutput("jobs_by_date_state")
          ),
          box(
            title = "Job Postings by Day of the Week",
            width = 6,
            plotOutput("jobs_by_weekday_state")
          )
        )
      )
    )
  )
)



server <- function(input, output) {
  # Define reactive dataset based on the inputs
  reactive_seek_ds_filtered <- reactive({
    seek_ds %>%
      filter(
        salary_annual >= input$min_salary,
        date_posted >= input$date_range[1],
        date_posted <= input$date_range[2],
        state %in% input$states
      )
  })

  # Define reactive datasets for state_positions and state_salaries based on filtered dataset
  reactive_state_positions <- reactive({
    reactive_seek_ds_filtered() %>%
      group_by(state) %>%
      summarise(n = n(), .groups = 'drop')
  })

  reactive_state_salaries <- reactive({
    reactive_seek_ds_filtered() %>%
      group_by(state) %>%
      summarise(median_salary = median(salary_annual, na.rm = TRUE), .groups = 'drop')
  })

  # Define reactive dataset for state_summary
  reactive_state_summary <- reactive({
    inner_join(reactive_state_positions(), reactive_state_salaries(), by = "state")
  })

  # job_market Tab
  output$histogram <- renderPlot({
    ggplot(reactive_seek_ds_filtered(), aes(x = salary_annual)) +
      geom_histogram(binwidth = 5000, fill = "#4e4e87") +
      geom_vline(aes(xintercept = median(salary_annual, na.rm = TRUE)), color = "#483bcf", linetype = "dashed", size = 1) +
      geom_text(aes(x = median(salary_annual, na.rm = TRUE), y = 16, label = "Median"), color = "#28262b") +
      labs(x = "Annual Salary", y = "Count", title = "Salary Distribution") +
      theme_minimal()
  })

  output$barplot <- renderPlot({
    ggplot(reactive_state_positions(), aes(x = reorder(state, n), y = n)) +
      geom_bar(stat="identity", fill = '#4e4e87') +
      coord_flip() +
      labs(x = 'State', y = 'Number of positions', title = 'Number of positions per state') +
      theme_minimal()
  })

  output$boxplot <- renderPlot({
    ggplot(reactive_seek_ds_filtered(), aes(x = state, y = salary_annual)) +
      geom_boxplot(fill = "#4e4e87", outlier.shape = NA) +
      labs(x = "State", y = "Annual Salary", title = "Salary Distribution by State") +
      theme_minimal()
  })

  output$state_summary_table <- DT::renderDataTable({
    DT::datatable(reactive_state_summary(), caption = "The number of positions per state and median salary per state")
  })


  # Define reactive dataset based on the inputs
  reactive_seek_ds_filtered <- reactive({
    seek_ds %>%
      filter(
        salary_annual >= input$min_salary,
        date_posted >= input$date_range[1],
        date_posted <= input$date_range[2],
        state %in% input$states
      )
  })
  
  # Define reactive common_titles and common_industries
  reactive_common_titles <- reactive({
    reactive_seek_ds_filtered() %>%
      count(job_title, sort = TRUE) %>%
      top_n(10)
  })

  reactive_common_industries <- reactive({
    reactive_seek_ds_filtered() %>%
      count(industry, sort = TRUE) %>%
      top_n(10)
  })
  
  # Define reactive industry_salaries based on common_industries and filtered dataset
  reactive_industry_salaries <- reactive({
    reactive_seek_ds_filtered() %>%
      group_by(industry) %>%
      summarise(median_salary = median(salary_annual, na.rm = TRUE), .groups = 'drop') %>%
      filter(industry %in% reactive_common_industries()$industry) %>%
      mutate(median_salary = median_salary / 1000)
  })

  # Job Titles and Industries Tab
  output$common_titles <- renderPlot({
    ggplot(reactive_common_titles(), aes(x = reorder(job_title, n), y = n)) +
      geom_bar(stat = "identity", fill = '#4e4e87') +
      coord_flip() +
      labs(x = 'Job Title', y = 'Frequency', title = '10 Most Common Job Titles')+
      theme_minimal()
  })
  
  output$common_industries <- renderPlot({
    ggplot(reactive_common_industries(), aes(x = reorder(industry, n), y = n)) +
      geom_bar(stat = "identity", fill = '#4e4e87') +
      coord_flip() +
      labs(x = 'Industry', y = 'Frequency', title = '10 Most Common Industries') +
      theme_minimal()
  })
  
  output$industry_salaries <- renderPlot({
    ggplot(reactive_industry_salaries(), aes(x = reorder(industry, -median_salary), y = median_salary)) +
      geom_bar(stat = "identity", fill = '#4e4e87') +
      coord_flip() +
      scale_y_continuous(labels = scales::comma) +
      labs(x = 'Industry', y = 'Median Salary (in thousands)', title = 'Median Salaries by Industry') +
      theme_minimal()
  })

  output$common_titles_table <- DT::renderDataTable({
    if (input$table_to_view == 'Common Job Titles') {
      reactive_common_titles()
    }
  })

  output$common_industries_table <- DT::renderDataTable({
    if (input$table_to_view == 'Common Industries') {
      reactive_common_industries()
    }
  })

  output$industry_salaries_table <- DT::renderDataTable({
    if (input$table_to_view == 'Industry Salaries(in thousands)') {
      reactive_industry_salaries()
    }
  })


    # Define reactive datasets for jobs_by_date_state and jobs_by_weekday_state
    reactive_jobs_by_date_state <- reactive({
    reactive_seek_ds_filtered() %>%
        count(date_posted, state) %>%
        mutate(week_start = floor_date(date_posted, "week"))
    })

    reactive_jobs_by_weekday_state <- reactive({
    reactive_seek_ds_filtered() %>%
        mutate(weekday = weekdays(date_posted)) %>%
        count(weekday, state) %>%
        mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))
    })



  # Time-Based Analysis of Job Postings Tab
  # this is different from the one in the report as I removed the null values, so the graph looks different
    output$jobs_by_date_state <- renderPlot({
    # Create a line plot for job postings over time, stacked by state
    ggplot(reactive_jobs_by_date_state(), aes(x = date_posted, y = n, fill = state)) +
        geom_area(alpha=0.8 , size=.5, colour="white") +
        scale_fill_viridis(discrete = TRUE) +
        theme_ipsum() + 
        labs(x = 'Date', y = 'Number of Job Postings', fill = 'State', title = 'Job Postings Over Time by State') +
        geom_vline(aes(xintercept = as.numeric(week_start)), linetype="dashed", color = "#3a2c5f", size=0.5) +
        theme_minimal()
    })

    output$jobs_by_weekday_state <- renderPlot({
    # Create a bar plot for job postings per weekday, stacked by state
    ggplot(reactive_jobs_by_weekday_state(), aes(x = weekday, y = n, fill = state)) +
        geom_bar(stat = "identity") +
        scale_fill_viridis(discrete = TRUE) +
        labs(x = 'Weekday', y = 'Number of Job Postings', fill = 'State', title = 'Job Postings by Day of the Week') +
        theme_ipsum() +
        theme_minimal()
    })

}

shinyApp(ui = ui, server = server)