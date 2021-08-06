rm(list=ls())

library(ggplot2)
library(tidyverse)
library(reshape2)

airport <- read.csv("ABIA.csv")

sum(is.na(airport))
airport[is.na(airport)] <- 0
sum(is.na(airport))

attach(airport)

#if we look at a general histogram of arrival and departure delays overall, we see that it is mainly 0 with a few outliers
ggplot(data=airport)+geom_histogram(mapping=aes(x=ArrDelay),bins = 100,binwidth = 15,fill="red") + xlab("Arrival Delay") + ggtitle("Arrival Delay Count")
ggplot(data=airport)+geom_histogram(mapping=aes(DepDelay),bins = 100,binwidth = 15,fill="blue") + xlab("Arrival Delay") + ggtitle("Arrival Delay Count")

#We can maybe also see which carriers have had the most delays
ggplot(data=airport)+geom_point(mapping=aes(x=ArrDelay,y=DepDelay)) + facet_grid(UniqueCarrier~.) + ggtitle("Departure Delay vs Arrival Delay by Carrier")
#For the most part, the carriers did not try to make up for delays

#Look just at AUS
ggplot(data=airport) + geom_histogram(mapping=aes(x=UniqueCarrier),stat="count") + ggtitle("Carrier Operations in-and-out of Austin")
sum(airport$UniqueCarrier == "WN")
#WN has the most - 34876 - Southwest
sum(airport$UniqueCarrier == "NW")
#NW is least - 121 - Northwest Airlines

#check average delay
arr_delay_avg = mean(ArrDelay[ArrDelay>0])
arr_delay_avg #28.09363
dep_delay_avg = mean(DepDelay[ArrDelay>0])
dep_delay_avg #23.9783
#Both averages are between 20 and 30 minutes
#can maybe check how the average delay per carrier relates
carr_delay_avg = mean(CarrierDelay[CarrierDelay>0])
carr_delay_avg #31.04813

#Check average delay per carrier
carr_delay_df <- airport %>% group_by(UniqueCarrier) 
carr_delay_df <- carr_delay_df %>% summarise(arr_delay_avg = mean(ArrDelay[ArrDelay>0]),dep_delay_avg = mean(DepDelay[ArrDelay>0]))
carr_delay_df

ggplot(data=carr_delay_df) + geom_bar(mapping=aes(x=UniqueCarrier,y=arr_delay_avg),stat="identity",position="dodge")
ggplot(data=carr_delay_df) + geom_bar(mapping=aes(x=UniqueCarrier,y=dep_delay_avg),stat="identity",position="dodge")

#combine the plots to see how the arrival vs departure delays are per carrier to see if one carrier has more of one type
test_data_long <- melt(carr_delay_df,id="UniqueCarrier")
test_data_long
ggplot(data=test_data_long) + geom_bar(mapping=aes(x=UniqueCarrier,y=value,fill=variable),stat="identity",position="dodge") + ggtitle("Average Arrival and Departure Delay per Carrier")

#Based on these plots, we can maybe predict the probability of being delayed 25 minutes by each carrier
carr_prob_df <- airport %>% group_by(UniqueCarrier) 
carr_prob_df <- carr_prob_df %>% summarise(carr_delay_25 = length(CarrierDelay[CarrierDelay>25])/length(CarrierDelay[CarrierDelay]))
carr_prob_df
test_data_long2 <- melt(carr_prob_df,id="UniqueCarrier")
test_data_long2
ggplot(data=test_data_long2) + geom_bar(mapping=aes(x=UniqueCarrier,y=value,fill=variable),stat="identity") + ggtitle("Carrier Probablity of being Delayed 25 minutes")
# YV and 9E have the highest probability
# NW is probably more reliable since it has the highest operations so you have more choices and the probability of being delayed is about 20%




