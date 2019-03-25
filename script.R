#NOTE GET PERIOD FUNCTION IS NOT WORKING BECAUSE OF SOMETHING TO DO WITH GET_MONTHLY_DATES

# refer to scripts in folder 'api_based_scripts...' to
# build each of the below functions based on frequency of report

load_packages <- function() {
  library(googlesheets)
  library(readr)
  library(dplyr)
  library(lubridate)
  library(stringr)
}
suppressPackageStartupMessages(load_packages())

# download report details using googlesheets via OAuth authentication
gs_auth()
ss <- gs_title("Reports identified for back-up")
report_details <- gs_read(ss, ws = "report_details")
# in case above command fails 
# becuase someone has changed the name of the sheet
# use the below back-up commands which works with document key
# ss_backup <- gs_key("1lAfyijkUGc_cvC01VhgMHTwsOxWMQyoavujcHi27SXE")
# report_details <- gs_read(ss_backup, ws = "report_details")

get_daily_dates <- function(start_period, end_period) {
  diff <- interval(start_period, end_period)
  diff <- as.period(diff, unit = "day")
  dates <- start_period + 0:diff$day
  dates <- gsub("-", "", dates)
  dates <- paste0("D", dates)
  return(dates)
}

get_weekly_dates <- function(start_period, end_period) {
  diff <- interval(start_period, end_period)
  diff <- as.period(diff, unit = "day")
  num_of_weeks <- diff$day%/%7
  dates <- start_period + weeks(0:num_of_weeks)
  # IBM gives incomplete weekly data if year end falls in the middle of the week
  # hence new year starts have to have their own weeks
  dates <- append(dates, c(ymd("2018-01-01"), ymd("2019-01-01")))
  dates <- gsub("-", "", dates)
  dates <- paste0("W", dates)
  return(dates)
}

get_monthly_dates <- function(start_period) {
  dates <- start_period %m+% months(0:24)
  dates = gsub("-", "", dates)
  dates = paste0("M", dates)
  return(dates)
}

get_period <- function(start_period, end_period, frequency) {
  # returns vector of all periods that can be inserted into api link
  
  if(frequency == "daily") {return(get_daily_dates(start_period, end_period))}
  if(frequency == "weekly") {return(get_weekly_dates(start_period, end_period))}
  if(frequency == "monthly") {return(get_monthly_dates(start_period))}
}

get_modified_api <- function(period, original_api) {
  # return api valid for that period
  gsub(pattern = "period_a=.\\d{8}", replacement = paste0("period_a=",period), original_api)
}

get_raw_report <- function(api_modified) {
  read_csv(api_modified)
}
get_clean_report <- function(raw_report, report_name, frequency, unit_of_analysis) {
  # returns clean report
  # remove totals
  raw_report <- raw_report %>% 
    filter(`Site ID` != "Total")
  
  # remove 'Bounce Rate Integer' if it exists as one of the columns
  if(str_detect(str_flatten(colnames(raw_report), collapse = ","), "Bounce Rate Integer")) {loc_bounce_rate_integer <- grep("Bounce Rate Integer", colnames(raw_report))
  raw_report <- raw_report[,-loc_bounce_rate_integer]}
  
  # convert average time on page to seconds
  if(str_detect(str_flatten(colnames(raw_report), collapse = ","), "Average Time On Page")) {raw_report$`Average Time On Page` <- as.numeric(raw_report$`Average Time On Page`)}
  
  # break down top_second_category into two categories
  if(str_detect(str_flatten(colnames(raw_report), collapse = ","), "Page Attribute: URL Top  Second Category")) {
    cats <- str_split_fixed(raw_report$`Page Attribute: URL Top  Second Category`,fixed("|"), 2)
    cats <- as.data.frame(cats, stringsAsFactors = FALSE)
    cats <- apply(cats, 2, function(col) ifelse(col ==  "", NA, as.character(col)))
    colnames(cats) <- c("Top Level Category", "Top Second Level Category")
    raw_report <- cbind(raw_report, cats)
    raw_report <- raw_report %>% 
      select(`Site ID`,`Mobile Device Type`,`Marketing Channel`,`Page Attribute: URL Top  Second Category`, `Top Level Category`, `Top Second Level Category`,`Page Attribute: Page Type`,`Page Views`,`Entry Page Views`,`Average Time On Page`,`Bounce Rate`,`Unique Visitors`)
    }
  # add columns for
    # site url <not doing>
    # site group/segment <not doing>
    # report frequency (daily, weekly, monthly)
  raw_report$report_name <- report_name
    # report unit of analysis (pageviews, unique visitors, etc.)
  raw_report$unit_of_analysis <- unit_of_analysis
    # report name as per google sheet
  raw_report$frequency <- frequency
  return(raw_report)
}
save_raw_report <- function(raw_report, report_name, unit_of_analysis, frequency, period) {
  # saves report in csv format
  file_name <- paste(report_name, unit_of_analysis, frequency, period, sep = "_")
  file_name <- paste0(file_name, ".csv")
  path_name <- paste("raw_reports", file_name, sep = "/")
  write_csv(raw_report, path = path_name)
}

save_clean_report <- function(clean_report, report_name, unit_of_analysis, frequency, period) {
  # saves report in csv format
}

for(i in 1:nrow(report_details)) {
  report_name <- report_details$report_name[i]
  frequency <- report_details$frequency[i]
  unit_of_analysis <- report_details$unit_of_analysis[i]
  start_period <- report_details$start_period[i]
  end_period <- report_details$end_period[i]
  original_api <- report_details$original_api[i]
  
  report_periods <- get_period(start_period, end_period, frequency)
  
  for(period in report_periods){
    modified_api <- get_modified_api(period, original_api)
    raw_report <- get_raw_report(modified_api)
    save_raw_report(raw_report, report_name, unit_of_analysis, frequency, period)
    clean_report <- get_clean_report(raw_report, frequency, unit_of_analysis)
    save_clean_report(clean_report, report_name, unit_of_analysis, frequency, period)
  }
}