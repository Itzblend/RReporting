suppressMessages(library(tidyverse))
suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(plotly))

options(scipen=9999) # Disables scientific notation

setwd('~/repos/RReporting')
cwd <- getwd()

csvpath <- paste(cwd, "/scripts/data/jira_tickets.csv", sep = '')
data <- suppressMessages(read_csv(csvpath))




data$status <- factor(data$status, levels = c("Backlog", "Selected for Development", "In Progress", "Closed", "Done"))


cumplot_pre <- ggplot(data, aes(x = currentdate, fill = status))
cumplot_pre + geom_bar(aes(y = ..count..))+
              ggtitle("Cumulative Flow Diagram")+
              theme(axis.title.x = element_blank())+
              ylab("Count of Tickets")+
              scale_fill_manual(values = c("#2eb9d1", "#7f1dcf", "#fc3903", "#a6948f", "#fc9d03")) -> cumplot

cumplot_plotly <- ggplotly(cumplot, tooltip = "status")

cumplot_plotly

ggplot(data, aes(x = currentdate, y = status, fill = status))+
  geom_area()

data %>% 
  select(currentdate, status) %>% 
  group_by(currentdate) %>% 
  table() -> new_data

new_data

new_df <- as.data.frame(new_data)

ggplot(new_df, aes(x = currentdate, y = sum(Freq), fill = status))+
  geom_bar(stat = "identity")

  