get_report_details <- function(report_name) {
  # return start_period, end_period, frequency
}
get_period <- function(start_period, end_period, frequency) {
  # return dataframe of all periods
}
get_api <- function(period, report_name) {
  # return api valid for that period
}
get_report <- function(api_modified) {
  # return dataframe of raw downloaded report
}
get_clean_report <- fuction(report, frequency, unit_of_analysis) {
  # returns clean report
  # remove totals
  # convert to date format
  # remove bounce rate integer
  # convert average time on page to seconds
  # break down top_second_category into two categories
  # add columns for
    # site url
    # site group/segment
    # report frequency (daily, weekly, monthly)
    # report unit of analysis (pageviews, unique visitors, etc.)
    # report name as per google sheet
}
name_and_save_report <- function(clean_report, report_name, period) {
  # saves report in csv format
}

