library(tidyverse)

green <- read.csv("greenbuildings.csv")
green$green_rating <- as.factor(green$green_rating) #make green_rating into dummy
green$class_a <- as.factor(green$class_a) #make class a into dummy
green$class_b <- as.factor(green$class_b) #make class b into dummy
#average rent for green buildings
mean(green$Rent[green$green_rating == 1])#30.01603
#average rent for non green buildings
mean(green$Rent[green$green_rating == 0]) #28.26678

mean(green$Gas_Costs[green$green_rating == 1])#30.01603
mean(green$Gas_Costs[green$green_rating == 0]) #28.26678

mean(green$Electricity_Costs[green$green_rating == 1])#30.01603
mean(green$Electricity_Costs[green$green_rating == 0]) #28.26678


ggplot(data=green) + geom_point(mapping=aes(x=cluster_rent, y=Rent, color=green_rating)) 
ggplot(data=green) + geom_point(mapping=aes(x=age, y=Rent, color=amenities))
ggplot(data=green) + geom_point(mapping=aes(x=leasing_rate, y=size)) + ylim(0,1000000)
sum(green$leasing_rate <= 10)
ggplot(data=green) + geom_point(mapping=aes(x=Electricity_Costs, y=Rent, color=green_rating)) 
ggplot(data=green) + geom_point(mapping=aes(x=Gas_Costs, y=Rent, color=green_rating)) 
ggplot(data=green) + geom_point(mapping=aes(x=size, y=Rent, color=green_rating)) 
ggplot(data=green) + geom_point(mapping=aes(x=age, y=Rent, color=class_a)) 
ggplot(data=green) + geom_line(mapping=aes(x=leasing_rate, y=Rent,color=green_rating)) 
 
ggplot(data=green) + geom_boxplot(mapping=aes(x=green_rating,y=Rent, color=green_rating))
ggplot(data=green) + geom_boxplot(mapping=aes(x=green_rating,y=Rent, color=class_a))
ggplot(data=green) + geom_boxplot(mapping=aes(x=green_rating,y=Rent, color=green_rating))
ggplot(data=green) + geom_bar(mapping=aes(x=class_a,fill=green_rating),position="dodge")
