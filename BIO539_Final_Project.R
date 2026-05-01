

#### Reading in raw FSUCML Seawater Monitoring System Data and cleaning it up to get daily water variable averages, monthly water variable averages, and summer month only variable averages

### ONLY CHANGE TO SCRIPT IS CSV FILE BEING READ INTO READ_CSV(). FORMATTING SHOULD NOT NEED TO BE CHANGED ASSUMING RAW CSV FILE WAS NOT CHANGED. FILE SHOULD BE SIMILIAR TO CMLAHWQ_20230629-20250501.csv

water_edit<-read_csv("FSUCML Seawater Monitoring System Data/CMLAHWQ_20230629-20250501.csv", skip=2)
#after read_csv() insert FSUCML Water Data CSV for whatever site being analyzed
#reads in water data csv file and skips the first 2 rows and start reading from third row which contains headers, saved in water_edit variable

daily_average_values <- water_edit |> mutate(DateTimeStamp = parse_date_time(DateTimeStamp, orders = c("mdy HM", "mdy HMS", "mdy")),date = as.Date(DateTimeStamp)) |> group_by(date) |> summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))

#takes the water_edit data, converts the datetimestamp column values from 6/29/2023 13:15 into 2023-06-29 and removes the time, keeping the column just as collection date. Then it groups by date and takes the average of all the values(Temp, Sal, etc) for that date. This allows us to the get average values for that specifically collection date. We now get the individual water variable values for each date instead of every 15 mins. Saved as variable daily_average_values

daily_average_values<-daily_average_values |> drop_na()
#drops any rows with NA values or no data


any(is.na(daily_average_values))
#checks if any rows has NA



daily_average_values<-daily_average_values |> select(-Historical,-ProvisionalPlus)
#remove the columns that are not needed for quantitative analysis, like historical,provincialplus



daily_average_values_cleaned<- daily_average_values |> mutate(date=ymd(date), year=year(date), month=month(date), day=day(date))
#separates out date column into separate columns for year, month, day values. Values are stored as integers, Month contains 1:12, Year is 2023, 2024, 2025, Day is 1:31. Adds these 3 new columns to end of tibble.


unique(daily_average_values_cleaned$year)
unique(daily_average_values_cleaned$month)
unique(daily_average_values_cleaned$day)
#checks to make sure all values are present


monthly_averages_by_year<-daily_average_values_cleaned |> group_by(month,year) |> summarise(across(-c(day,date),~ mean(.x, na.rm = TRUE))) 
#takes daily_average_values_cleaned groups by month and year (May 2023) and then averages within the groups to get monthly average for each water variable. Excludes the day and date columns and ignores missing values.  

summer_months_averages<-monthly_averages_by_year |>filter(month>=4 & month<=8) |>  group_by(month)
#subsets out from the monthly_averages_by_year tibble and gets the averages for summer months, these are april/fourth month up to and including august/eight month.

#### Summer months only water variable data line graphs

summer_months_averages_pivot<- summer_months_averages |> pivot_longer(cols=-c(month,year), names_to = "Water_Variable", values_to = "Value") 
#makes a longer pivot table of the summer_months_averages data to make it easier to use for later graphing


summer_months_averages_pivot |> ggplot(aes(x=month,y=Value, color=factor(year)))+geom_line()+geom_point()+facet_wrap(~ Water_Variable, scales="free_y", labeller=labeller(Water_Variable=c(Temp="Temp(°C)", Sal="Salinity(ppt)", ph="pH", DO_mgl= "DO (mg/L)", SpCond="Specific Conductivity(mS/cm)", Depth="Depth(m)", DO_pct="DO_pct(percent saturation)", Turb="Turbidity")))+labs(color="Year", x= "Month", y="Water Variable Values")+ scale_x_continuous(breaks = 1:12, labels = month.abb)

#plots the summer_months_averages_pivot tibble with months on the x axis and the variable ranges on y, each year is a different color. Facet wrap by different variables, scales are independent on y axis for each variable. Relabels the graphs to be more descriptive, relabel the x axis label is Month, y axis is Water Variable value and instead of numbers for months, it is the actual name of the summer month


#### Monthly water variable values line graph
monthly_averages_by_year_pivot<-monthly_averages_by_year |> pivot_longer(cols=-c(month,year), names_to = "Water_Variable", values_to = "Value") 
#makes a longer pivot table of the monthly_averages_by_year data to make it easier to use for later graphing


monthly_averages_by_year_pivot |>mutate(date = as.Date(paste(year, month, 1, sep = "-"))) |>  ggplot(aes(x=date,y=Value, color=factor(year)))+geom_line()+geom_point()+facet_wrap(~ Water_Variable, scales="free_y", labeller=labeller(Water_Variable=c(Temp="Temp(°C)", Sal="Salinity(ppt)", ph="pH", DO_mgl= "DO (mg/L)", SpCond="Specific Conductivity(mS/cm)", Depth="Depth(m)", DO_pct="DO_pct(percent saturation)", Turb="Turbidity")))+labs(color="Year", x= "Date(Year-Month)", y="Water Variable Values")

#first mutates monthly_averages_by_year_pivot table by joining month and year columns together to get a date column that is 2023-06. Then plot by date, water variable value and color by year. This allows the plots to be graphed in chronological order and be more cohesive to visualize since 2023 and 2025 have partial data for their years. Date is on the x axis and the variable ranges on y, each year is a different color. Facet wrap by different variables, scales are independent on y axis for each variable. Relabels the graphs to be more descriptive, relabel the x axis label to be Date(Year-Month), y axis is Water Variable values.

##### Daily water variable values Boxplots

daily_average_values_pivot<-daily_average_values_cleaned |> pivot_longer(cols = c(Temp, SpCond, pH, Sal, Depth, Turb, DO_pct, DO_mgl), names_to = "Water_Variable", values_to = "Value")
#takes the daily_average_values_cleaned data and pivots based on listed water variable columns and their values, keeps the date, year, month, and day columns as is.

daily_average_values_pivot |>filter(month>=4 & month<=8) |>  ggplot(aes(x=factor(month), y=Value, fill=factor(year)))+geom_boxplot()+ facet_wrap(~Water_Variable, scales="free_y",labeller=labeller(Water_Variable=c(Temp="Temp(°C)", Sal="Salinity(ppt)", pH="pH", DO_mgl= "DO (mg/L)", SpCond="Specific Conductivity(mS/cm)", Depth="Depth(m)", DO_pct="DO_pct(percent saturation)", Turb="Turbidity")))+ scale_x_discrete(labels = month.abb[4:8])+labs(x= "Summer Months",fill="Year", y="Water Variables")

#takes the daily_average_values_pivot data and filters for summer months (4:8) and makes boxplots of summer months across years faceted by each water variable. Shows the range of values for each variable at each summer months across different years. Facet wrap by different water variables, scales are independent on y axis for each variable. Relabels the graphs to be more descriptive, relabel the x axis label to be Summer Months, y axis is Water Variables values.

#### Water Variable Data, Daily Values

daily_average_values_pivot |> ggplot(aes(x=date,y=Value,color=factor(year)))+geom_line()+ facet_wrap(~Water_Variable,scales="free_y",labeller=labeller(Water_Variable=c(Temp="Temp(°C)", Sal="Salinity(ppt)", pH="pH", DO_mgl= "DO (mg/L)", SpCond="Specific Conductivity(mS/cm)", Depth="Depth(m)", DO_pct="DO_pct(percent saturation)", Turb="Turbidity")))+ labs(color="Year")+labs(x= "Date(Year-Month-Day",fill="Year", y="Water Variables")

#takes daily_average_values_pivot data and plots each daily date's water variable value as a line graph. Date(year-month-day) is on the x axis and the variable ranges on y, each year is a different color. Facet wrap by different variables, scales are independent on y axis for each variable. Relabels the graphs to be more descriptive, relabel the x axis label to be Date(Year-Month), y axis is Water Variable values.

####Scatterplot comparisons

daily_average_values_cleaned |> ggplot(aes(x=Temp, y=DO_mgl, color=factor(year)))+geom_point()+geom_smooth(method = "lm", se=T)+facet_wrap(~year)+labs(x="Temperature(°C)", y="DO(mg/L)")
#scatter plot of temperature and DO data faceted by year for each day from daily_average_values_cleaned data

daily_average_values_cleaned |> ggplot(aes(x=Temp, y=Sal, color=factor(year)))+geom_point()+geom_smooth(method = "lm", se=T)+facet_wrap(~year)+labs(x="Temperature(°C)", y="Salinity(ppt)")
#scatter plot of temperature and Salinity data faceted by year for each day from daily_average_values_cleaned data

daily_average_values_cleaned |> ggplot(aes(x=Temp, y=pH, color=factor(year)))+geom_point()+geom_smooth(method = "lm", se=T)+facet_wrap(~year)+labs(x="Temperature(°C)", y="pH")
#scatter plot of temperature and pH data faceted by year for each day from daily_average_values_cleaned data

daily_average_values_cleaned |> ggplot(aes(x=Sal, y=pH, color=factor(year)))+geom_point()+geom_smooth(method = "lm", se=T)+facet_wrap(~year)+labs(x="Salinity(ppt)", y="pH")
#scatter plot of Salinity and pH data faceted by year for each day from daily_average_values_cleaned data

####### Heat maps

monthly_averages_by_year |> ggplot(aes(x=factor(year), y=month,fill=Temp))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "lightpink", high="darkred")+labs(x="Year", y="Months", fill="Temperature(°C)")
#heat map of temperature for each of the 12 months compared across years 2023-2025 from monthly_averages_by_year data

summer_months_averages |> ggplot(aes(x=factor(year), y=month,fill=Temp))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "lightpink", high="darkred")+labs(x="Year", y="Summer Months", fill="Temperature(°C)")
#heat map of temperature for the summer months compared across years 2023-2025 from summer_months_averages data

monthly_averages_by_year |> ggplot(aes(x=factor(year), y=month,fill=Sal))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "honeydew", high="darkgreen")+labs(x="Year", y="Months", fill="Salinity(ppt)")
#heat map of salinity for each of the 12 months compared across years 2023-2025 from monthly_averages_by_year data

summer_months_averages |> ggplot(aes(x=factor(year), y=month,fill=Sal))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "honeydew", high="darkgreen")+labs(x="Year", y="Summer Months", fill="Salinity(ppt)")
#heat map of salinity for the summer months compared across years 2023-2025 from summer_months_averages data


monthly_averages_by_year |> ggplot(aes(x=factor(year), y=month,fill=DO_mgl))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "lightyellow", high="orange")+labs(x="Year", y="Months", fill="DO(mg/L)")
#heat map of DO for each of the 12 months compared across years 2023-2025 from monthly_averages_by_year data


summer_months_averages |> ggplot(aes(x=factor(year), y=month,fill=DO_mgl))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "lightyellow", high="orange")+labs(x="Year", y="Summer Months", fill="DO(mg/L")
#heat map of DO for the summer months compared across years 2023-2025 from summer_months_averages data

monthly_averages_by_year |> ggplot(aes(x=factor(year), y=month,fill=pH))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "white", high="skyblue")+labs(x="Year", y="Months", fill="pH")
#heat map of pH for each of the 12 months compared across years 2023-2025 from monthly_averages_by_year data


summer_months_averages |> ggplot(aes(x=factor(year), y=month,fill=pH))+geom_tile()+ scale_y_continuous(breaks = 1:12,labels = month.name)+ scale_fill_gradient(low= "white", high="skyblue")+labs(x="Year", y="Summer Months", fill="pH")
#heat map of pH for the summer months compared across years 2023-2025 from summer_months_averages data




#### total of 16 graphs produced





































