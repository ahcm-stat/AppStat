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
    titlePanel("Filering Panel"),

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

                    pickerInput("patient_origin",
                        "Sector of origin of patients:",
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
                    "Patients",

                    pickerInput("patient_gender", "Patient genders:",
                        choices = c("Male", "Female"),
                        selected = c("Male", "Female"),
                        multiple = TRUE
                    ),

                    sliderInput("patient_age", "Age range of patients:",
                        min = 0,
                        max = 100,
                        value = c(0, 100),
                        step = 1
                    ),

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

}

shinyApp(ui = ui, server = server)