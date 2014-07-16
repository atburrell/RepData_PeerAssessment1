
###################### Loading and Processing Data
## Load and clean data
data <- read.csv("activity.csv", header=TRUE)
data$date <- as.Date(data$date, format="%Y-%m-%d")



###################### What is the mean total number of steps taken per day?
## Plot histogram of total number of steps taken per day
daily_total <- aggregate(steps ~ date, data = data, sum) ## aggregate data frame for total steps by day
library(ggplot2) 
qplot(dsteps, data=daily_total, geom="histogram", binwidth = 2500)


## Calculate mean and median steps taken per day
paste("Mean total steps taken per day:", round(mean(daily_total$steps)))
paste("Median total steps taken per day:", median(daily_total$steps))



###################### What is the average dailhy activity pattern?
## Plot the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)
daily_pattern <- aggregate(steps ~ interval, data = data, mean) ## aggregate data frame with average steps by interval
require(ggplot2)
qplot(interval, steps, data=daily_pattern, geom="line")


## Calculate 5 minute interval with maximum number of steps
paste("5 minute interval with maximum average number of steps:", daily_pattern[(daily_pattern$steps == max(daily_pattern$steps)),1])
paste("Average maximum number of steps:", round(max(daily_pattern$steps)))



###################### Imputing Missing Values

## Calculate total number of rows with NA values
impute_list <- grep(TRUE, is.na(data$steps))
paste("Number of NA values:", length(impute_list))


## Fill in the missing values. Strategy is to use average value for the interval.
data_imputed <- data

for (x in impute_list){
  data_imputed[x,"steps"] <- daily_pattern[(daily_pattern$interval == data_imputed[x,"interval"]),"steps"]
}

## Plot histogram of total number of steps taken per day
daily_imputed_total <- aggregate(steps ~ date, data = data_imputed, sum) ## aggregate data frame for daily total steps
require(ggplot2)
qplot(daily_imputed_total$steps, geom="histogram", binwidth = 2500)

## Calculate mean and median steps taken per day
paste("Mean total steps taken per day:", round(mean(daily_imputed_total$steps)))
paste("Median total steps taken per day:", round(median(daily_imputed_total$steps)))

t_test <- t.test(daily_imputed_total$steps, daily_total$steps)
t_test["p.value"]  

t.test(daily_imputed_total$steps, daily_total$steps)



###################### Are there differences in activity patterns between weekdays and weekends?


## Create a new factor variable in the dataset with two levels – “weekday” and “weekend”
data_imputed$weekday <- weekdays(data_imputed$date)
data_imputed$weekday[data_imputed$weekday == "Saturday" | data_imputed$weekday == "Sunday"] <- "weekend"
data_imputed$weekday[data_imputed$weekday != "weekend"] <- "weekday"
data_imputed$weekday <- as.factor(data_imputed$weekday)

## Make a panel plot cof the 5-minute interval (x-axis) and the average number of steps taken,
## averaged across all weekday days or weekend days (y-axis)
weekday_pattern <- aggregate(steps ~ interval + weekday, data = data_imputed, mean)
require(ggplot2)
qplot(interval, steps, data=weekday_pattern, geom="line", facets= weekday~.)



