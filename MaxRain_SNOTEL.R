#Looking at max rainfall events for Joe Wright and lower elevation SNOTEL sites in the northern Front Range

library(RNRCS) # pull SNOTEL data
library(ggplot2)
library(dplyr)
library(lubridate)
library(dataRetrieval)
library(Hmisc)

setwd("C:/Users/sears/Documents/Research/Snow_Hydro_Research/Max_rain_events/")

#download Joe Wright SNOTEL data from WY 2010 to present and add as a df. Also, get date into correct format.
JWhourly_SNO <- grabNRCS.data(network = "SNTL", site_id = 1161, timescale = "hourly", DayBgn = '2009-10-01', DayEnd = '2020-08-27') %>%
  mutate(Date = ymd_hm(Date))

#write csv of raw file and fix a few things
write.csv(JWhourly_SNO,"C:/Users/sears/Documents/Research/Snow_Hydro_Research/Max_rain_events/BM_Hourly_WY10to20_fix.csv", row.names = FALSE)

#read in hourly data for the 4 SNOTEL sites
Hourly_Rain <- read.csv("C:/Users/sears/Documents/Research/Snow_Hydro_Research/Max_rain_events/SNOTEL_rain.csv") %>%
  mutate(Date = mdy_hm(Date))

###################################################################################
#####PLOT THEME
#Height and width
PlotWidth = 15
PlotHeight = 9

#ggplot theme to control formatting parameters for plots with month on the x-axis
PlotTheme = theme(axis.text=element_text(size=20),    #Text size for axis tick mark labels
                  axis.title.x=element_text(size=24, hjust=0.5, margin=margin(t=20, r=20, b=20, l=20)),               #Text size and alignment for x-axis label
                  axis.title.y=element_text(size=24, vjust=0.5,  margin=margin(t=20, r=20, b=20, l=20)),              #Text size and alignment for y-axis label
                  plot.title=element_text(size=26,face="bold",hjust=0.5, margin=margin(t=20, r=20, b=20, l=20)),      #Text size and alignment for plot title
                  legend.title=element_text(size=24),                                                                    #Text size of legend category labels
                  legend.text=element_text(size=20),                                                                   #Text size of legend title
                  legend.position = "bottom")   

colors1 <- c("blue", "green4", "red", "purple")
colors2 <- c("black", "black", "black", "black")
################################################################################################
##PROCESS SOME DATA

#factor so SNOTEL sites stay together
Hourly_Rain$SNOTEL <- factor(Hourly_Rain$SNOTEL, levels=c("Joe Wright", "Hourglass Lake", "Black Mountain", "Copeland Lake"))

#add a WY column
Hourly_Rain <- addWaterYear(Hourly_Rain)

#aggregate to get annual max
Annual_Max <- aggregate(Rain_mm ~ SNOTEL+waterYear, data = Hourly_Rain, max)

#labels for WYs
WYLabels = c("2010", "2011", "2012", "2013", "2014", "2015", "2016","2017", "2018", "2019", "2020")

PLOT ="Annual Max Bar Plot"
custom_breaks <- seq(2010, 2020, 1)
ggplot(Annual_Max, aes(x=waterYear, y = Rain_mm, fill=factor(SNOTEL))) + geom_col(position = "dodge2") + labs(x="Water Year", y= "Rain (mm)") + scale_x_continuous(breaks = custom_breaks) + PlotTheme 

ggsave(paste(PLOT,".png",sep=""), width = PlotWidth, height = PlotHeight)

PLOT = "Annual Max Boxplot"
ggplot(Annual_Max, aes(x=SNOTEL, y = Rain_mm, fill=SNOTEL)) + geom_boxplot(outlier.shape=NA) + PlotTheme +  labs(y="Rain (mm)", x="SNOTEL") + scale_color_manual(values = colors1)

###geom_jitter(size=3, width=0.01) + 
ggsave(paste(PLOT,".png",sep=""), width = PlotWidth, height = PlotHeight)

write.csv(Annual_Max,"C:/Users/sears/Documents/Research/Snow_Hydro_Research/Max_rain_events/Annual_Max_Summary.csv", row.names = FALSE)

