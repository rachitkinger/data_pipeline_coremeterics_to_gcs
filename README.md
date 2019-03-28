## Building data pipeline from IBM Coremetrics to GCS 

This project builds redundancy in critical business reports for business continuity purposes.  

Note that this does not backup all the raw data. It backs up all required reports for the time period for which they are available (Jan-2017 to Mar-2019 note that date range can be modified by using the GSheet mentioned below). These are reports that include top line metrics like pageviews, unique visitors, etc which can be broken down my dimensions that we tend to use most often at JPIMedia. These reports are daily, weekly and monthly reports.  

To look at all the reports that are actually downloaded by this script visit [this Google Sheet](https://docs.google.com/spreadsheets/d/1lAfyijkUGc_cvC01VhgMHTwsOxWMQyoavujcHi27SXE/edit?usp=sharing) (owner of sheet: Ben Haynes ben.haynes@jpimedia.co.uk).  

The script was run on a Google VM instance using the R version 3.5.3. with the following required packages:  

1. readr  
2. dplyr  
3. lubridate  
4. stringr  
5. googlesheets

Each report was downloaded as a csv file.  

The data was downloaded onto a Google Cloud Storage bucket gs://ibm_da_backup  ]

## Additional usage notes  
Two types of reports were saved:  

1. Raw reports (as is reports from IBM)  
2. Clean reports (cleaned up reports which are more user friendly and ready for analysis)  

The naming convention is `"report_name"_"unit_of_analysis"_"frequency"_"period".csv`  
The raw reports are stored in a folder called `raw_reports` and clean reports in `clean_reports`.  

## Notes on column names  
### "Page Attribute: URL Top  Second Category", "Top Level Category", "Top Second Level Category"  

Report number 3 and 10 had a column called `Page Attribute: URL Top  Second Category`. For an article that is published under `/sport/football` the value for this column would be `"Sport | Football"`. For the sake of analysis this has been split into two columns called "Top Level Category" and "Top Second Level Category"  

### "Average Time On Page"  
For the sake of analysis this has been converted in seconds.  

### Logs  
The script generates two logs.  

1. Download log - a log of all reports downloaded. It contains the following information:  
  - Number of rows per downloaded report  
  - Report name  
  - Report period  
2. Warning log - a log of all instances when a report hit its size limit, i.e., reached 50k rows. This means that the data returned by that report is no longer accurate and hence cannot be used for complete analysis.  

## What data not to use  

This section will be populated once we know which reports hit their size limit.  




