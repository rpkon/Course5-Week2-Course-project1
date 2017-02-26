activity <- read.csv("activity.csv", stringsAsFactors=FALSE,header=T,na.strings = c("NA"))
library(data.table)
> setDT(activity)
> class(activity)
[1] "data.table" "data.frame"

histogram:

hist(activity[,.(steps.total_per_day = sum(steps,na.rm=T)),by=date][,steps.total_per_day], main="Histogram of Total no. of Steps per day", xlab = "Total No. of Steps per day")

mean steps per day:

activity[,.(mean_steps_per_day = mean(steps,na.rm=T)),by=date][]

median steps per day:

activity[,.(median_steps_per_day = median(steps,na.rm=T)),by=date][]

Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis):

plot(unique(activity[,interval]),activity[,.(avg_no_of_steps_per_interval = mean(steps,na.rm=TRUE)),by=interval][,avg_no_of_steps_per_interval], type="l", xlab = "5 minute interval", ylab = "Average No. of Steps")

Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?:

> activity[,.(avg_no_of_steps_per_interval = mean(steps,na.rm=TRUE)),by=interval] [order(-avg_no_of_steps_per_interval)]
     interval avg_no_of_steps_per_interval
  1:      835                     206.1698
  2:      840                     195.9245
  3:      850                     183.3962
  4:      845                     179.5660
  5:      830                     177.3019
 ---                                      
284:      350                       0.0000
285:      355                       0.0000
286:      415                       0.0000
287:      500                       0.0000
288:     2310                       0.0000


Imputing missing values:

Note that there are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.

Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs):

> activity[,.N] - sum(complete.cases(activity))
[1] 2304

> sum(is.na(activity[,steps]))
[1] 2304

Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.:

avg_steps_by_interval <- activity[,.(avg_no_of_steps_per_interval = mean(steps,na.rm=TRUE)),by=interval]

activity_imputed <- merge(activity, avg_steps_by_interval, by = "interval", all.x=T)

> str(activity_imputed)
Classes ‘data.table’ and 'data.frame':  17568 obs. of  4 variables:
 $ interval                    : int  0 0 0 0 0 0 0 0 0 0 ...
 $ steps                       : int  NA 0 0 47 0 0 0 NA 0 34 ...
 $ date                        : chr  "2012-10-01" "2012-10-02" "2012-10-03" "2012-10-04" ...
 $ avg_no_of_steps_per_interval: num  1.72 1.72 1.72 1.72 1.72 ...
 - attr(*, ".internal.selfref")=<externalptr> 
 - attr(*, "sorted")= chr "interval"

Create a new dataset that is equal to the original dataset but with the missing data filled in:

 > activity_imputed_final <- activity_imputed [,.(date, interval, steps = ifelse(is.na(steps),avg_no_of_steps_per_interval,steps))]
> str(activity_imputed_final)
Classes ‘data.table’ and 'data.frame':  17568 obs. of  3 variables:
 $ date    : chr  "2012-10-01" "2012-10-02" "2012-10-03" "2012-10-04" ...
 $ interval: int  0 0 0 0 0 0 0 0 0 0 ...
 $ steps   : num  1.72 0 0 47 0 ...
 - attr(*, ".internal.selfref")=<externalptr> 
 - attr(*, "sorted")= chr "interval"

> sum(complete.cases(activity_imputed_final))
[1] 17568

Make a histogram of the total number of steps taken each day and Calculate 


hist([,.(total_steps_per_day = sum(steps)),by=date][,total_steps_per_day],main="Histogram of Total No. of Steps per day post imputation",xlab="Total No. of Steps per day")



and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment?
What is the impact of imputing missing data on the estimates of the total daily number of steps?
----------

mean steps per day:

avg_no_of_steps_per_day_aftre_imputation <- activity_imputed_final[,.(avg_steps_per_day = mean(steps)), by=date]

median steps per day:

activity_imputed_final[,.(median_steps_per_day = median(steps)), by=date]

Compare:

Total No. of steps per day:

total_no_of_steps_per_day_before_imputation = activity[,.(total_steps_per_day = sum(steps,na.rm=T)),by=date]
total_no_of_steps_per_day_before_imputation = total_no_of_steps_per_day_before_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]

total_no_of_steps_per_day_after_imputation = activity_imputed_final[,.(total_steps_per_day = sum(steps)),by=date]
total_no_of_steps_per_day_after_imputation = total_no_of_steps_per_day_after_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]
total_no_of_steps_per_day_diff = merge(total_no_of_steps_per_day_before_imputation, total_no_of_steps_per_day_after_imputation, by="date_new", all.x=T)

total_no_of_steps_per_day_diff[, ':=' (date.x = NULL, date.y = NULL)]

total_no_of_steps_per_day_diff[,diff_no_of_steps_per_day := total_steps_per_day.y - total_steps_per_day.x]

plot(total_no_of_steps_per_day_diff$date_new, total_no_of_steps_per_day_diff$diff_no_of_steps_per_day, col="red", xlab="date", ylab="Difference in Total No. of Steps per day", main = "Comparison of Total No. of steps per day before and after Imputation")

-------

Mean No. of steps per day:

mean_no_of_steps_per_day_before_imputation = activity[,.(mean_steps_per_day = mean(steps,na.rm=T)),by=date]
mean_no_of_steps_per_day_before_imputation = mean_no_of_steps_per_day_before_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]

mean_no_of_steps_per_day_after_imputation = activity_imputed_final[,.(mean_steps_per_day = mean(steps)),by=date]
mean_no_of_steps_per_day_after_imputation = mean_no_of_steps_per_day_after_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]
mean_no_of_steps_per_day_diff = merge(mean_no_of_steps_per_day_before_imputation, mean_no_of_steps_per_day_after_imputation, by="date_new", all.x=T)

mean_no_of_steps_per_day_diff[, ':=' (date.x = NULL, date.y = NULL)]

mean_no_of_steps_per_day_diff[,diff_no_of_steps_per_day := mean_steps_per_day.y - mean_steps_per_day.x]

plot(mean_no_of_steps_per_day_diff$date_new, mean_no_of_steps_per_day_diff$diff_no_of_steps_per_day, col="red", xlab="date", ylab="Difference in Mean No. of Steps per day", main = "Comparison of Mean No. of steps per day before and after Imputation")


Median No. of steps per day:

median_no_of_steps_per_day_before_imputation = activity[,.(median_steps_per_day = median(steps,na.rm=T)),by=date]
median_no_of_steps_per_day_before_imputation = median_no_of_steps_per_day_before_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]

median_no_of_steps_per_day_after_imputation = activity_imputed_final[,.(median_steps_per_day = median(steps)),by=date]
median_no_of_steps_per_day_after_imputation = median_no_of_steps_per_day_after_imputation[, date_new := as.POSIXct(date,format="%Y-%m-%d")]
median_no_of_steps_per_day_diff = merge(median_no_of_steps_per_day_before_imputation, median_no_of_steps_per_day_after_imputation, by="date_new", all.x=T)

median_no_of_steps_per_day_diff[, ':=' (date.x = NULL, date.y = NULL)]

median_no_of_steps_per_day_diff[,diff_no_of_steps_per_day := median_steps_per_day.y - median_steps_per_day.x]

plot(median_no_of_steps_per_day_diff$date_new, median_no_of_steps_per_day_diff$diff_no_of_steps_per_day, col="red", xlab="date", ylab="Difference in Median No. of Steps per day", main = "Comparison of Median No. of steps per day before and after Imputation")

-------
Are there differences in activity patterns between weekdays and weekends?

For this part the weekdays() function may be of some help here. Use the dataset with the filled-in missing values for this part.

Create a new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.
Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across
all weekday days or weekend days (y-axis). See the README file in the GitHub repository to see an example of what this plot should look like using simulated data.

activity_imputed_final[, ':=' (day_of_the_week = ifelse(weekdays(as.POSIXct(date,'%Y-%m-%d')) %in% c("Monday","Tuesday","Wednesday","Thursday","Friday"),"weekday", "weekend" ))]
activity_imputed_final$day_of_the_week <- as.factor(activity_imputed_final$day_of_the_week)

activity_by_day_of_the_week = activity_imputed_final[,.(mean_steps_per_interval = mean(steps)),by=.(interval,day_of_the_week)]


qplot(year, Emissions, data=NEI_Baltimore_LA_SCC_motor_sum, facets = . ~ fips) + geom_line() + ggtitle('Total PM2.5 Emissions in Los Angeles (06037) and Baltimore City (24510)')

qplot(interval, mean_steps_per_interval, data=activity_by_day_of_the_week, facets = .~day_of_the_week) + geom_line() + ggtitle('Comparision of Average Steps per Interval for Weekdays and Weekends')

----
kint2html:

library(knitr)
library(markdown)

knit2html(input = "PA1_template.Rmd", output = "PA1_template.html")



---

push to github:

#initilize local repo
git init

#point local repo to git repo

git remote add origin https://github.com/rpkon/Course5-Week2-Course-project1

#Issue commit

git commit -m "push to github repo"





