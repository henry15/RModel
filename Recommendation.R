## Steps to host in local
library(plumber)
library(jsonlite)
#r <- plumb("D:/ISM/structureValidatingProcedures/Task3_B.R")   -- give your folder path
#r$run(port = 8000)

####-----Recommendation Engine -----

#* @get  /analyse
function(input){
  
splitVals = strsplit(input, ',')
for(v in splitVals){
# input the searchCategory id as per the requirement
searchCategory= v  ##'133629'

#read the data ---- Note: Alter the file path as per your location
data<- read.csv("rub_dat_Minimised.csv") 
filter=subset(data, category_id==searchCategory) #filter the data as per input
frame=data.frame(filter)
customerIds=frame[1]   # frame1 index fetches the customerId column values
#print(nrow(customerIds))
for(customerid in customerIds){
  #find categoryIds for each customerid and store in variable
  filteredCategoryId= subset(data, customer_id %in% customerid & category_id != v, select = category_id)
}

filteredCategoryId= subset(filteredCategoryId, !(category_id %in% (v)) & category_id != v, select = category_id)

frequencyData=data.frame(filteredCategoryId)
library(sqldf)
# query above frequencyData variable to get the frequency count
RecommendedCategories= sqldf(sprintf("select category_id,count(category_id) as frequency, cast(count(category_id) AS real)/%s as RelFreq from frequencyData 
                              where category_id != '%s'
                              Group By category_id 
                              order by RelFreq desc Limit 25",nrow(customerIds),searchCategory))


# Read the categoryName file and query through it to fetch corresponding names for recommendedCategoryIds
CategoryNameData <- read.csv("Strukturbaum_Namen.csv") 
RecommendedCategoryName = sqldf(sprintf("select rc.RelFreq as RelativeFrequency, rc.frequency as Frequency, category_de as GermanName, category_en as EnglishName 
                        from CategoryNameData cd
                        inner join RecommendedCategories rc on rc.category_id = cd.category_id
                        and cd.category_id != '%s'
                        group by cd.category_id
                        order by rc.RelFreq  desc Limit 25",searchCategory))

#Get the categoryName for input categoryId
searchcategoryName= subset(CategoryNameData, category_id == searchCategory, select = category_de)

#print(paste('TOP 10 Recommendations for \'',searchcategoryName[1,],'\' are: '))
#print(as.data.frame(RecommendedCategoryName))

    
  }
return(toJSON(as.data.frame(RecommendedCategoryName)))
}
