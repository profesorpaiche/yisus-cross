
# LIBRARIES
# --------------------------------------------------------------------------- #

library(shiny)
library(dplyr)
library(stringr)
library(DT)

# FUNCIONES
# FIXME: Better organize functions. Also documentation
# --------------------------------------------------------------------------- #

# Function 1: Conver references to a list author-year

create_filename <- function(references) {
    # Defining the regex string
    author_format <- references[1]
    year_format <- references[2]
    references <- references[-c(1:3)]

    # Cleaning the references
    references <- tibble(references = references) %>%
        mutate(
            author = search_for_author(references, author_format),
            year = search_for_year(references, year_format),
            title = search_for_title(references, year_format),
            file_name = paste0(author, "-", year)
        ) %>%
        select(file_name, title, author, year, references)
    return(references)
}

search_for_author <- function(references, format) {
    if (format ==  "Surname, F.S.") {
        search_pattern <- "[,]"
    } else if (format == "Surname FS") {
        search_pattern <- " "
    }
    author <- str_split_fixed(references, search_pattern, n = 2)[, 1]
    author <- chartr(" ", "_", author)
    return(author)
}

search_for_year <- function(references, format) {
    if (format %in% c("2000:", "(2000)", "(2000),")) {
        year <- str_extract(references, "(\\d{4})")
    } else if (format == "2000.NL") {
        references <- trimws(references)
        n <- nchar(references)
        year <- substring(references, n - 4, n - 1)
    }
    return(year)
}


search_for_title <- function(references, format) {
    if (format %in% c("2000:", "2000.NL")) {
        search_pattern <- ": "
    } else if (format == "(2000)") {
        search_pattern <- "[)] "
    } else if (format == "(2000),") {
        search_pattern <- "[)], "
    }
    title <- str_split_fixed(references, search_pattern, n = 2)[, 2]
    title <- str_split_fixed(title, "[.]", n = 2)[, 1]
    return(title)
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
