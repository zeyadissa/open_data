#functions for common usage

#Functions

#Gets links from any single url; string matches
GetLinks <- function(url_name,string){
  files <- c()
  #this is inefficient and bad practice but it's a small vector.
  for(i in seq_along(url_name)){
    pg <- rvest::read_html(url_name[i])
    pg<-(rvest::html_attr(rvest::html_nodes(pg, "a"), "href"))
    files <- c(files,pg[grepl(string,pg,ignore.case = T)])
    files <- files %>% unique()
  }
  return(files)
}

#Read all csvs from urls; unz for zips
UnzipCSV <- function(files){
  #creates temp file to read in the data
  temp <- tempfile()
  download.file(files,temp)
  #This is needed because a zip file may have multiple files
  file_names <- unzip(temp,list=T)$Name
  data<- lapply(file_names,
                function(x){
                  da <- data.table::fread(unzip(temp,x))
                  #janitor to clean unruly names
                  names(da) <- names(da) %>% janitor::make_clean_names()  
                  return(da)
                })
  #unlink the temp file, important to do
  unlink(temp)
  data}

ReadExcelSheets <- function(filename, sheet_names, tibble = T) {
  #default args
  if(missing(sheet_names)){
    sheets <- readxl::excel_sheets(filename)
  } else {
    sheets <- sheet_names
  }
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  return(x)
}

ReadODSSheets <- function(filename, tibble = T) {
  sheets <- readODS::list_ods_sheets(filename)
  x <- lapply(sheets, function(X) readODS::read_ods(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  return(x)
}

#Download and read excel
ReadExcel <- function(files,sheets){
  #creates temp file to read in the data
  temp <- tempfile()
  download.file(files,temp)
  data <- ReadExcelSheets(filename = temp,sheet_names = sheets)
  #unlink the temp file, important to do
  unlink(temp)
  data}

#Download and read excel
ReadODS <- function(files){
  #creates temp file to read in the data
  temp <- tempfile()
  download.file(files,temp)
  #This is needed because a zip file may have multiple files
  data <- ReadODSSheets(temp)
  #unlink the temp file, important to do
  unlink(temp)
  data}
