Read Me File For R Script on FSUCML Seawater Monitoring Data Processing & Visualization

This script processes raw data from the FSUCML Seawater Monitoring System and produces cleaned datasets and visualizations of water variables. The script takes the high-frequency measurements (every 15 minutes)and turns it into Daily Averages, Monthly Averages, and Summer(April-August) Averages across all measured water variables (Temperature, Salinity, Dissolved Oxygen, Specific Conductivity, Turbidity, Depth,and pH). It also generates multiple plots to explore trends and relationships among these variables.

---

Input Requirements:
The script expects a CSV file formatted similarly to CMLAHWQ_20230629-20250501.csv and the only required modification in the script is updating the file path in the first line of read_csv("FSUCML Seawater Monitoring System Data/your_file.csv", skip=2) The first two rows of the CSV are skipped as the third row must contain column headers. No additional formatting changes should be necessary if the file structure is consistent.

---
Workflow Summary:
1. Data Import
   
The script reads the CSV file using `read_csv()` , skips metadata rows and stores data in `water_edit`

2. Daily Averages

It then converts `DateTimeStamp` into date format, groups data by date, calculates mean values for all numeric variables and removes missing values and unnecessary columns (`Historical`, `ProvisionalPlus`). These columns will not be used at all.
This outputs variable: daily_average_values_cleaned

3. Date Feature Extraction

The script extracts Year, Month, Day to allow for grouping and filtering later on.

 4. Monthly Averages

The daily averages data is then grouped by month and year and averages are computed for each water variable
This outputs: monthly_averages_by_year

5. Summer Subset (April–August)

From the month averages data, next it filters monthly data for months 4–8 (April-August) to used for seasonal analysis
This outputs: summer_months_averages

---

Visualizations

The script generates 16 total plots, listed as follows

1. Summer Monthly Line Graphs

Thess are line plots of water variables (April–August) and faceted by water variables and colored by year

2. Full Monthly Line Graphs

These are monthly line plots showing trends of the water variables across all available years. They are listed chronologically on the x-axis using combined year-month date. This is to better show the trends since 2023 and 2025 have incomplete/missing data from the months in which no sampling data was obtained.

3. Daily Boxplots (Summer Only)

Plot distribution of values for each variable, grouped by month and year, and only showing the range of the water variables for the summer months.

4. Daily Time Series

These are line plots of daily values faceted by water variable. This helps see any short-term fluctuations for the entire duration of the water monitoring.

5. Scatterplot Comparisons

Plotted scatterplot to explore the relationships between 
Temperature vs Dissolved Oxygen
Temperature vs Salinity
Temperature vs pH
Salinity vs pH

Each plot includes linear regression line and faceted by year

6. Heatmaps

Heatmaps are generated for Temperature, Salinity, Dissolved Oxygen, and pH. Each heat map is plotted with Month and Year and for each comparison, also includes full-year heatmap and summer-only heatmap to better see the seasonal relationships.

---

Key Variables Utilized

Temp = Temperature (°C)
Sal=  Salinity (ppt)
pH= Acidity/alkalinity
DO_mgl= Dissolved Oxygen (mg/L)
DO_pct = Percent saturation
SpCond = Specific Conductivity (mS/cm)
Depth = Water depth (m)
Turb = Turbidity

---
Other Notes:
Data was collected from June 2023 to May 2025. Therefore, it is missing data from the first six months of 2023 and the last six months of 2025 due to the nature of the monitoring time range. 
Missing values are removed before analysis. 
Monthly and daily averages ignore NA values (`na.rm = TRUE`). 
Summer is defined as April through August. 
Input data structure must remain consistent with original format.
Output should be cleaned datasets that show Daily averages, Monthly averages, and a Summer Averaged subset. Also 16 visualizations for preliminary data analysis
Must replace the CSV file path in read_csv(). The script is designed to be reusable across monitoring sites with minimal modification.

---















