# DESCRIPTION ------------------------------------------------------------------

# Script title: sql_query_fun.
# Date: 2020-08-07.
# Tasks: return a string for generic SQL queries;
# Input: sqlite database "database_v2.db".
# Output: none.
# Aims: implementing a function for data retrival through sql query.
# Packages dependences: none.


# TASK -------------------------------------------------------------------------

my_query <- function(table, cols_show = "*", cols_where = NULL,
                     cols_group = NULL, cols_having = NULL, cols_order = NULL,
                     limit = NULL, distinct = FALSE) {
    db_show <- paste(cols_show, collapse = ", ")
    if (!distinct) {
        my_select <- paste("SELECT", db_show, "FROM", table, sep = " ")
    } else {
        my_select <- paste("SELECT DISTINCT", db_show, "FROM", table, sep = " ")
    }

    if (!is.null(cols_where)) {
        db_where <- paste(unlist(cols_where), collapse = " ")
        my_where <- paste("WHERE", db_where, sep = " ")
    } else {
        my_where <- ""
    }

    if (!is.null(cols_group)) {
        db_group <- paste(cols_group, collapse = ", ")
        my_group_by <- paste("GROUP BY", db_group, sep = " ")
    } else {
        my_group_by <- ""
    }

    if (!is.null(cols_having)) {
        db_having <- paste(unlist(cols_having), collapse = " ")
        my_having <- paste("HAVING", db_having, sep = " ")
    } else {
        my_having <- ""
    }

    if (!is.null(cols_order)) {
        db_order <- paste(cols_order, collapse = ", ")
        my_order_by <- paste("ORDER BY", db_order, sep = " ")
    } else {
        my_order_by <- ""
    }

    if (!is.null(limit)) {
        db_limit <- paste(limit, collapse = ", ")
        my_limit <- paste("LIMIT", db_limit, sep = " ")
    } else {
        my_limit <- ""
    }

    final_query <- paste(my_select, my_where, my_group_by, my_having,
        my_order_by, my_limit,
        sep = " "
    )

    return(final_query)
}