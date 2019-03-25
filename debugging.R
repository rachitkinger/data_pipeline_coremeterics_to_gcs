dapi <- report_details$original_api[1]
wapi <- report_details$original_api[6]
mapi <- report_details$original_api[7]

x1 <- report_details$start_period[1]
y1 <- report_details$start_period[1]
f1 <- report_details$frequency[1]
x2 <- report_details$start_period[6]
y2 <- report_details$start_period[6]
f2 <- report_details$frequency[6]
x3 <- report_details$start_period[7]
y3 <- report_details$start_period[7]
f3 <- report_details$frequency[7]

d <- get_period(x1, y1, f1)

get_period_2 <- function(start_period, end_period, frequency) {

dates <- if_else(frequency == "daily", get_daily_dates(start_period, end_period),
        if_else(frequency == "weekly", get_weekly_dates(start_period, end_period),
                get_monthly_dates(start_period)))

return(dates)
}


# deleted some lines below

# then added this comment 

