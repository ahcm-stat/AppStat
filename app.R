# DESCRIPTION ------------------------------------------------------------------

# Script title: app.
# Date: 2020-08-17.
# Tasks: make panels for filtering variables and display graphics;
# Input: sqlite database "database.db".
# Output: shiny app.
# Aims: implementing an app for data summary of "database.db".


# PACKAGES ---------------------------------------------------------------------

load_lib <- c(
    "shiny",
    "shinyWidgets",
    #"shinydashboard",
    "RSQLite",
    "plyr",
    "dplyr"
)

install_lib <- load_lib[!load_lib %in% installed.packages()]
for (lib in install_lib) install.packages(lib, dependencies = TRUE)
sapply(load_lib, require, character = TRUE)


# SUBROUTINES ------------------------------------------------------------------

source("my_query.R")


# DATABASE CONNECTION ----------------------------------------------------------

if ("db_conn" %in% ls()) dbDisconnect(db_conn) # disconnect database.

db_conn <- dbConnect(drv = SQLite(), dbname = "database.db")


# UI/SERVER --------------------------------------------------------------------

ui <- fluidPage(
    titlePanel("Filtering Panel"),

    sidebarLayout(
        sidebarPanel(
            width = 5,

            tabsetPanel(
                type = "pills",

                tabPanel(
                    "Hosptial",

                    pickerInput("hospital_data", "Hospital:",
                        choices = c("HSL", "Einstein", "Fleury")
                    ),

                    uiOutput("out_patient_origin")

                ),

                tabPanel(
                    "Patients",

                    uiOutput("out_patient_gender"),

                    uiOutput("out_patient_age"),

                    sliderInput("patient_stay",
                        "Patient's length of stay (in days):",
                        min = 0,
                        max = 100,
                        value = c(0, 100),
                        step = 1
                    ),

                    pickerInput("patient", "Patients:",
                        choices = LETTERS[1:5],
                        selected = NULL,
                        multiple = TRUE,
                        options = list(
                            `actions-box` = TRUE,
                            `live-search` = TRUE
                        )
                    )
                ),

                tabPanel(
                    "Exams",

                    pickerInput("exams", "Exams:",
                        choices = LETTERS[1:5],
                        selected = NULL,
                        multiple = TRUE,
                        options = list(
                            `actions-box` = TRUE,
                            `live-search` = TRUE
                        )
                    ),

                    pickerInput("analit", "Exam analytes:",
                        choices = LETTERS[1:5],
                        selected = NULL,
                        multiple = TRUE,
                        options = list(
                            `actions-box` = TRUE,
                            `live-search` = TRUE
                        )
                    )
                ),

                tabPanel(
                    "Grouping",

                    actionButton("group_data", "Group data")
                ),

                tabPanel(
                    "Columns",

                    checkboxGroupInput("select_columns", "Select:",
                        choices = LETTERS[1:5],
                        inline = FALSE
                    )
                )
            )
        ),

        mainPanel(
            width = 7,

            tabsetPanel(
                type = "pills",

                tabPanel("Description"),

                tabPanel("Graphics"),

                tabPanel("Filtered Data")
            )
        )
    )
)

server <- function(input, output, session) {
    tables <- reactive({
        hospital <- switch(input$hospital_data,
            HSL = "hsl_",
            Einstein = "eins_",
            Fleury = "fleury_"
        )

        exams <- dbGetQuery(
            db_conn,
            paste0("SELECT * FROM ", hospital, "exames")
        )

        patients <- dbGetQuery(
            db_conn,
            paste0("SELECT * FROM ", hospital, "pacientes")
        )

        if (hospital == "hsl_") {
            outcomes <- dbGetQuery(
                db_conn,
                paste0("SELECT * FROM ", hospital, "desfechos")
            )
        } else {
            outcomes <- "table not defined"
        }

        result <- list(exams = exams, patients = patients, outcomes = outcomes)

        return(result)
    })

    output$out_patient_origin <- renderUI({
        pickerInput("patient_origin",
            "Sector of origin of patients:",
            choices = unique(tables()$exams$de_origem),
            multiple = TRUE,
            options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE
            )
        )
    })

    output$out_patient_gender <- renderUI({
        pickerInput("patient_gender",
            "Gender of patients:",
            choices = unique(tables()$patients$ic_sexo),
            multiple = TRUE,
            options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE
            )
        )
    })

    output$out_patient_age <- renderUI({
        age <- 2020 - as.numeric(tables()$patients$aa_nascimento)
        age_range <- range(age, na.rm = TRUE)
        sliderInput("patient_age", "Age range of patients:",
            min = age_range[1],
            max = age_range[2],
            value = age_range,
            step = 1
        )
    })

}

shinyApp(ui = ui, server = server)