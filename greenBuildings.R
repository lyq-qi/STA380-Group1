library(dplyr)
library(ggplot2)
library(ggthemes)

greenbuildings <- read.csv("greenbuildings.csv")
greenbuildings$Green <- ifelse(greenbuildings$LEED == 1 | greenbuildings$Energystar ==1, "Green","Non-Green")
#Create database that has only green buildings and one that has no green buildings
greenOnly = greenbuildings %>% filter(green_rating == 1)
nonGreen = greenbuildings %>% filter(LEED == 0 & Energystar == 0)

#Create a variable to calculate the difference for green buildings vs average rent in their cluster
greenOnly <- greenOnly %>%  mutate("greenRentVsClusterRent" = Rent-cluster_rent)
medRentDiff <- median(greenOnly$greenRentVsClusterRent)

#Calculate count, median rent, median leasing rate for green buildings
greenCount <- greenOnly %>% summarise(n())
medGreenCapacity <- greenbuildings %>%  filter((LEED == 1 | Energystar == 1)) %>% summarise(median(leasing_rate)/100)
medGreenRent <- greenbuildings %>%  filter((LEED == 1 | Energystar == 1)) %>% summarise(median(Rent))


#Calculate count, median rent, median leasing rate for non-green buildings
greenCount <- nonGreen %>% summarise(n())
medNonGreenCapacity <- nonGreen %>%  filter((LEED == 0 & Energystar == 0)) %>% summarise(median(leasing_rate)/100)
medNonGreenRent <- nonGreen %>%  filter((LEED == 0 & Energystar == 0)) %>% summarise(median(Rent))

#Calculate median gas and electric cost 
medGasCost <- greenbuildings %>% summarise(median(Gas_Costs))
medElectricCost <- greenbuildings %>% summarise(median(Electricity_Costs))

#setSquareFootage for further calculations
sqFt = 250000
#Set a weight of .9 for green electric and gas cost since they use less than non-green buildings. 
#This is a subjective number and can be changed with future research regarding how much will actually be saved
greenCostWeighted = .9

#Calculate expected rent, expense, and profit if our building was green
#Weight rent by expected capacity and calculate rent by adding rent diff b/w green/non green buildings
#and adding that to the median non green rent. 
greenExpectedRent <- (medNonGreenRent + medRentDiff) * medGreenCapacity * sqFt
#Weight expenses by expected savings by using less resources
greenExpectedExpense <- (sqFt * medGasCost * greenCostWeighted) + (sqFt * medElectricCost * greenCostWeighted)
greenExpectedProfit <- greenExpectedRent - greenExpectedExpense

#Calculate expected rent, expense, and profit if our building was not green. 
#Weight rent by expected capacity and calculate rent by multiplying square feet by median rent of non green
#buildings. Expected expenses was not weighted because they will use all resources.

nonGreenExpectedRent <- medNonGreenRent * medNonGreenCapacity * sqFt
nonGreenExpectedExpense <- (sqFt * medGasCost) + (sqFt * medElectricCost)
nonGreenExpectedProfit <- nonGreenExpectedRent - nonGreenExpectedExpense

#Calculate the expected profit difference if the building chose to be green
buildingDiff <- greenExpectedProfit-nonGreenExpectedProfit
greenOnly$buildingDiff <- greenOnly$Rent - greenOnly$cluster_rent
#Set green premium so we can calculate expected payback period and long-haul profits
options("scipen" = 100,"digits" = 4) #Gets rid of scientific notation
greenCert <- 100000000 *.05

paybackPeriod = greenCert/buildingDiff

layer1 <- ggplot(data = greenOnly, aes(x = cluster, y = buildingDiff)) 
layer2 <- layer1 + geom_point() 
layer3 <- aes(col = cluster_rent)
layer3

bxp <- ggplot(greenbuildings, aes(x = Green, y = Rent)) +
  geom_boxplot(color = "black", fill = c("darkgreen","red")) + coord_flip() + 
  labs(x = "Green Classification",y = "Rent per Square Foot")
bxp
boxplot(Rent ~ Green, data = greenbuildings, main = "Building Rent Data", 
        xlab = "Green Classification",ylab = "Rent per Square Foot", col = c("green","red"),
        horizontal = TRUE)
greenOnly$idu <-  as.numeric(row.names(greenOnly))
greenOnly$aboveMedDiff <- ifelse(greenOnly$buildingDiff >2.1,1,0)
nonGreen %>% filter(size >200000) %>% summarise(median(leasing_rate)) 



# This is the only code needed for my plot 

greenOnly = greenbuildings %>% filter(green_rating == 1)
greenOnly$buildingDiff <- greenOnly$Rent - greenOnly$cluster_rent
greenOnly$idu <-  as.numeric(row.names(greenOnly))

buildingDiffPlot <- ggplot(greenOnly, aes(x= idu, y=buildingDiff, label=buildingDiff)) + 
   coord_flip() +ylim(-20,20) +  aes(col = aboveMedDiff) +geom_point()
  
buildingDiffPlot <- buildingDiffPlot +ggtitle("Difference between rent price in green buildings and average rent in their cluster")
buildingDiffPlot  <- buildingDiffPlot + labs(y="Price Difference", x = "Cluster Index", colour = "Above median price \ndifference of $2.1")           
