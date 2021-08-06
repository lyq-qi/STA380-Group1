library(dplyr)
greenbuildings <- read.csv("greenbuildings.csv")
head(greenbuildings)
#Create database that has only green buildings and one that has no green buildings
greenOnly = greenbuildings %>% filter(LEED == 1 | Energystar == 1)#%>% = Pipe an object forward into a function or call expression.
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

#Set green premium so we can calculate expected payback period and long-haul profits
options("scipen" = 100,"digits" = 4) #Gets rid of scientific notation
greenCert <- 100000000 *.05

paybackPeriod = greenCert/buildingDiff




