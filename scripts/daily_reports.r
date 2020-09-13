suppressMessages(library(tidyverse))
suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(plotly))

options(scipen=9999) # Disables scientific notation

setwd('~/repos/RReporting')
cwd <- getwd()
csvpath <- paste(cwd, "/scripts/data/jira_tickets.csv", sep = '')

data <- suppressMessages(read_csv(csvpath))

# Changing the order of the data to suit better for Cumulative Flow Diagram
cfdLevels <- c("Backlog", "Selected for Development", "In Progress", "Closed", "Done")
data$status <- factor(data$status,levels = cfdLevels)
## Cumulative Flow Diagram ##
cumplot_pre <- ggplot(data, aes(x = currentdate, fill = status))
cumplot_pre + geom_bar(aes(y = ..count.., text = paste('Date: ', as.Date(currentdate), '\n',
                                                      'Status: ', status)))+
              ggtitle("Cumulative Flow Diagram")+
              theme(axis.title.x = element_blank())+
              ylab("Count of Tickets")+
              scale_fill_manual(values = c("#2eb9d1", "#7f1dcf", "#fc3903", "#a6948f", "#fc9d03")) -> cumplot
# Interactive Plotly plot
cumplot_plotly <- ggplotly(cumplot, tooltip = c("count", "text"))

cumplot_plotly

## Percent Stacked Barchart ##
data %>% select(currentdate, status) %>% 
  filter(currentdate > Sys.Date() -30) %>% 
  ggplot(aes(currentdate, fill = status))+
  geom_bar(aes(y = ..count.., text = paste('Date: ', as.Date(currentdate), '\n',
                                           'Status: ', status)), position = "fill") -> psb_pre

psb_plotly <- ggplotly(psb_pre, tooltip = c("text"))
psb_plotly

## Area Chart ""
ggplot(data, aes(x = currentdate, y = status, fill = status))+
  geom_area()

data %>% 
  select(currentdate, status) %>% 
  group_by(currentdate) %>% 
  table() -> new_data

new_data

new_df <- as.data.frame(new_data)
