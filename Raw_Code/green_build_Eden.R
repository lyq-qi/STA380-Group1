library(ggplot2)

gb = read.csv("greenbuildings.csv")
gb$net = as.factor(gb$net)
gb$green_rating = as.factor(gb$green_rating)
gb$LEED = as.factor(gb$LEED)
gb$Energystar = as.factor(gb$Energystar)
gb$renovated = as.factor(gb$renovated)

#examining variable I found interesting relative to rent 
#no relationship
ggplot(data=gb,aes(x=net, y=Rent)) + geom_boxplot() 
ggplot(data=gb,aes(x=renovated, y=Rent)) + geom_boxplot()   

#dividing into age group to see avg per age group
avg_age = median(gb[gb$green_rating == 1,]$age)

new_building = gb %>% filter(age <= 10 )
mid_building = gb %>% filter(age > 10 & age <= avg_age)
old_building =gb %>% filter(age >= 30 )

#based on these plots, we saw that as age increases, the buildings with green rating increases in rent
ggplot(data=new_building,aes(x=green_rating, y=Rent)) + geom_boxplot()  
ggplot(data=mid_building,aes(x=green_rating, y=Rent)) + geom_boxplot()                        
ggplot(data=old_building,aes(x=green_rating, y=Rent)) + geom_boxplot() 

#taking a closer look at the specific value, rent for green increases until around the median age of 22 then it decreases slightly but still higher then when its new
new_rent = median(new_building[new_building$green_rating == 1,]$Rent)#26.75
mid_rent = median(mid_building[mid_building$green_rating == 1,]$Rent)#29
old_rent = median(old_building[old_building$green_rating == 1,]$Rent)#28.9

#what about lease rates for different age group? It seems like it decreases but then increase as it got older, might be affect by other variables.
#However, still have higher rate then all the non-green buildings
ggplot(data=new_building,aes(x=green_rating, y=leasing_rate)) + geom_boxplot()  
ggplot(data=mid_building,aes(x=green_rating, y=leasing_rate)) + geom_boxplot()                        
ggplot(data=old_building,aes(x=green_rating, y=leasing_rate)) + geom_boxplot() 

median(new_building[new_building$green_rating == 1,]$leasing_rate)#95.63
median(mid_building[mid_building$green_rating == 1,]$leasing_rate)#91.91
median(old_building[old_building$green_rating == 1,]$leasing_rate)#94.71

#How can we adjust our profit/revenue prediction base on that?

