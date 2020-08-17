# WARNING: set the file R_root as your working directory.

# DESCRIPTION ------------------------------------------------------------------

# Script title: app.
# Date: 2020-08-09.
# Tasks: a) make panels for filtering variables;
# Input: sqlite database "database_v2.db".
# Output: tables and graphs.
# Aims: implementing an app for data summary.


# PACKAGES----------------------------------------------------------------------

load_lib <- c(
    "shiny",
    "shinyWidgets",
    "shinydashboard",
    "RSQLite"
)

install_lib <- load_lib[!load_lib %in% installed.packages()]
for (lib in install_lib) install.packages(lib, dependencies = TRUE)
sapply(load_lib, require, character = TRUE)


# DATABASE CONNECTION ----------------------------------------------------------

db_path <- paste(getwd(), "databases", "database_v2.db", sep = "/")
db_conn <- dbConnect(drv = SQLite(), dbname = db_path)


# INITIALIZATION ---------------------------------------------------------------

# de_tipo_atendimento, de_origem, de_desfecho, descricao,
#   "de_exame, de_analito", min_exame_analito, range_dias, genero, range_idade,
#   id_paciente.

my_database <- "hsl_exames"

filtered_data <- dbGetQuery(db_conn, paste("SELECT * FROM", my_database))

id_set_1 <- c("de_tipo_atendimento", "de_origem", "de_desfecho", "id_paciente")

selected_labels <- list()
selected_labels[seq_len(length(id_set_1))] <- NULL


# MAIN -------------------------------------------------------------------------

ui <- dashboardPage(
    dashboardHeader(title = "My test app"),

    dashboardSidebar(),

    dashboardBody(

        fluidRow(
            column(width = 3,
                pickerInput(
                    inputId = "var_id_paciente",
                    label = "ID do paciente:",
                    choices = var_data,
                    options = list(`live-search` = TRUE,
                                    `actions-box` = TRUE,
                                    `selected-text-format` = "count > 1"),
                    multiple = TRUE
                )
            ),

            column(width = 1,
                prettyToggle(
                    inputId = "group_var_id_paciente",
                    label_on = "Agrupar",
                    icon_on = icon("check"),
                    status_on = "success",
                    label_off = "Não agrupar",
                    icon_off = icon("remove"),
                    status_off = "warning"
                )
            )
        )
    )
)

server <- function(input, output) {
    id_labels <- lapply(id_set_1, function(i) input[[i]])

    for (i in seq_len(length(id_labels))) {
        direction_1 <- setdiff(id_labels[[i]], selected_labels[[i]])
        direction_2 <- setdiff(id_labels[[i]], selected_labels[[i]])

        if (length(direction_1) + length(direction_2) > 0) {
            changed_id <- i
            selected_labels[changed_id] <- id_labels[[changed_id]]
            break
        } else {
           changed_id <- 0
        }
    }

    if (changed_id) {
        filtered_data <- dbGetQuery(
            db_conn,
            paste(
                "SELECT *", id_set_1[changed_id], "FROM", my_database, "WHERE",
                id_set_1[changed_id], "=", selected_labels[[changed_id]]
            )
        )
    }

    filtered_labels <- lapply(filtered_data, unique)
}

shinyApp(ui, server)