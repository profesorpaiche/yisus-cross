
# LIBRARIES
# --------------------------------------------------------------------------- #

library(shiny)
library(dplyr)
library(stringr)

# FUNCIONES
# --------------------------------------------------------------------------- #

# Function 1: Conver references to a list author-year

create_filename <- function(references) {
    # Defining the regex string
    author_format <- references[1]
    year_format <- references[2]
    references <- references[-c(1:3)]

    if (author_format ==  "Surname, F.S.") {
        author_search <- "([,])"
    } else if (author_format == "Surname FS") {
        author_search <- " "
    }

    if (year_format == "2000:") {
        year_search <- "(\\d{4}: )"
    } else if (year_format == "(2000)") {
        year_search <- "[)] "
    }

    # Cleaning the references
    references <- tibble(references = references) %>%
        mutate(
            author = str_split_fixed(references, author_search, n = 2)[, 1],
            author = chartr(" ", "_", author),
            year = str_extract(references, "(\\d{4})"),
            title = str_split_fixed(references, year_search, n = 2)[, 2],
            title = str_split_fixed(title, "[.]", n = 2)[, 1],
            file_name = paste0(author, "-", year)
        ) %>%
        select(file_name, title, author, year, references)

    return(references)
}

# Function 2: Get the current files

old_files <- function(files) {
    files <- files %>%
        as_tibble() %>%
        rename(files = value) %>%
        mutate(
            file_name = str_split_fixed(files, "[.]", n = 2)[, 1],
            author = str_split_fixed(file_name, "[-]", n = 2)[, 1],
            year = str_split_fixed(file_name, "[-]", n = 2)[, 2]
        )
    return(files)
}

# Funciton 3: Look for references in other article notes

look_references <- function(references) {
    ini_idx <- which(str_detect(references, "# References"))
    fin_idx <- which(str_detect(references, "-->"))
    references <- references[(ini_idx + 2):(fin_idx - 1)]
    return(references)
}

# Function 4: Check if old files are in the reference of current files

cross_reference <- function(this, in_this) {
    n <- length(this)
    all_cross <- c()
    for (i in 1:n) {
        cross <- str_detect(in_this, this[i])
        if (any(cross)) all_cross <- c(all_cross, this[i])
    }
    return(all_cross)
}

old_in_current <- function(old, current) {
    old_cross <- cross_reference(old, current)
    return(old_cross)
}

# Function 5: Check if the current file is in the references of old files

current_in_old <- function(current, old) {
    n <- length(old)
    current_cross_idx <- c()
    for (i in 1:n) {
        old_references <- readLines(old[i], warn = FALSE)
        old_references <- look_references(old_references)
        old_references <- create_filename(old_references)
        cross <- cross_reference(current, old_references$file_name)
        if (!is.null(cross)) current_cross_idx <- c(current_cross_idx, i)
    }
    return(current_cross_idx)
}

# GENEREAL OPTIONS
# --------------------------------------------------------------------------- #

options(stringsAsFactors = FALSE)
