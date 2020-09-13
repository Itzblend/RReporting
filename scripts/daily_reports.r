suppressMessages(library(tidyverse))
suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(plotly))
suppressMessages(library(gridExtra))
theme_set(theme_classic())



options(scipen=9999) # Disables scientific notation

setwd('~/repos/RReporting')
cwd <- getwd()
csvpath <- paste(cwd, "/scripts/data/jira_tickets.csv", sep = '')
# R makes the best guess on which data type to use and hence failing sometimes
# so we specify couple columns' data types here
data <- suppressMessages(read_csv(csvpath, col_types = cols(parent_key = col_character(),
                                                            parent_id = col_number())))

# Changing the order of the data to suit better for Cumulative Flow Diagram
cfdLevels <- c("Backlog", "Selected for Development", "In Progress", "Closed", "Done")
data$status <- factor(data$status,levels = cfdLevels)


## Cumulative Flow Diagram ##
data %>% 
  group_by(currentdate, status) %>% 
  summarise(count = length(status)) %>%
  ggplot(aes(x = currentdate, y = count, fill = status)) +
  geom_col(position = position_stack()) +
  ggtitle("Cumulative Flow Diagram")+
  theme(axis.title.x = element_blank())+
  ylab("Count of Tickets")+
  scale_fill_manual(values = c("#2eb9d1", "#7f1dcf", "#fc3903", 
                               "#a6948f", "#fc9d03")) -> cumplot

cumplot_plotly <- ggplotly(cumplot)


## Percent Stacked Barchart ##
data %>% select(currentdate, status) %>% 
  filter(currentdate > Sys.Date() -30) %>% 
  ggplot(aes(currentdate, fill = status))+
  geom_bar(aes(y = ..count.., text = paste('Date: ', as.Date(currentdate), '\n',
                                           'Status: ', status)), position = "fill") -> psb_pre

psb_plotly <- ggplotly(psb_pre, tooltip = "text")


## Area Chart ""
data %>% select(currentdate, status) %>% 
  filter(currentdate > Sys.Date() - 120) %>% 
  ggplot(aes(currentdate, fill = status))+
  geom_area(stat = "count") -> areachart

areachart_plotly <- ggplotly(areachart)


## Tickets by project
data %>% 
  filter(currentdate == Sys.Date() - 1) %>% 
  group_by(project_key, status) %>% 
  summarise(ticket_count = length(project_key)) %>% 
  ggplot(aes(reorder(project_key, -ticket_count), ticket_count, fill = status))+
  geom_bar(stat = "identity") -> ticketCount_barplot

ticketCount_barplot
ticketCount_plotly <- ggplotly(ticketCount_barplot, tooltip = c("status", "ticket_count"))



## Save files to pdf

create_reports <- function() {
  pdf("reports.pdf")
  print(cumplot)     # Plot 1 --> in the first page of PDF
  print(psb_pre) # Plot 2 ---> in the second page of the PDF
  print(areachart)
  print(ticketCount_barplot)
  dev.off()
}

create_reports()

