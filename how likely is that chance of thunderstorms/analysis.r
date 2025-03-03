library(tidyverse) 
library(psych)
library(car)
library(ggplot2)
library(gridExtra)
library(qualtRics)
library(data.table)
library(ggridges)
options(scipen = 9999)
theme_set(theme_minimal())

# Import Data -----------------------------------
twitter_data <- read.csv("https://raw.githubusercontent.com/oucrcm/wxsurvey/master/how%20likely%20is%20that%20chance%20of%20thunderstorms/twitter_data.csv")
survey_data <- read.csv("https://raw.githubusercontent.com/oucrcm/wxsurvey/master/how%20likely%20is%20that%20chance%20of%20thunderstorms/survey_data.csv")
WX18 <- filter(survey_data, survey == "WX18")
WX19 <- filter(survey_data, survey == "WX19")

# Probability Words 2018 -----------------------------------
svr_prob_word_data_18 <- WX18 %>%
  filter(prob_event == "severe thunderstorm") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Severe Thunderstorm")

tor_prob_word_data_18 <- WX18 %>%
  filter(prob_event == "tornado") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Tornado")

# Combine Severe Thunderstorm and Tornado Datasets for 2018 -----------------------------------
prob_word_data_18 <- rbind(svr_prob_word_data_18, tor_prob_word_data_18)
prob_word_data_18$key <- as.factor(prob_word_data_18$key)
prob_word_data_18 <- transform(prob_word_data_18, key = reorder(key, value))

# Probability Words 2019 -----------------------------------
svr_prob_word_data_19 <- WX19 %>%
  filter(prob_event == "severe thunderstorms") %>% 
  select(risk_chan, risk_poss, risk_may, risk_exp) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Severe Thunderstorm")

tor_prob_word_data_19 <- WX19 %>%
  filter(prob_event == "tornadoes") %>% 
  select(risk_chan, risk_poss, risk_may, risk_exp) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Tornado")

# Combine Severe Thunderstorm and Tornado Datasets for 2019 -----------------------------------
prob_word_data_19 <- rbind(svr_prob_word_data_19, tor_prob_word_data_19)
prob_word_data_19$key <- as.factor(prob_word_data_19$key)
prob_word_data_19 <- transform(prob_word_data_19, key = reorder(key, value))

# FIGURE 1 -----------------------------------
forecasts <- twitter_data %>% 
  group_by(F) %>%
  drop_na(F) %>% 
  summarize(n = n())
forecasts

probability <- twitter_data %>%
  group_by(P) %>%
  drop_na(P) %>%
  summarize(n = n()) %>%
  mutate(p = (n / sum(n)) * 100)
probability

verbal <-twitter_data %>%
  group_by(V) %>%
  drop_na(V) %>%
  summarize(n = n()) %>%
  mutate(p = (n / sum(n)) * 100) 
verbal

total <- twitter_data %>% 
  group_by(T) %>%
  drop_na(T) %>% 
  summarize(n = n())
total

total_probabilistic <- twitter_data %>% 
  group_by(TP) %>%
  drop_na(TP) %>% 
  summarize(n = n()) %>%
  mutate(p = (n / sum(n)) * 100) 
total_probabilistic

# FIGURE 2 -----------------------------------
ggplot(total_probabilistic, aes(x = reorder(TP, -p), y = p, fill=p)) +
  geom_bar(stat = "identity") + 
  theme_gray() +
  scale_x_discrete(labels = c("Non-Descriptive", "Both", "Descriptive")) +
  theme(axis.text.x = element_text(size = 20))+
  theme(axis.text.y = element_text(size = 20))+
  theme(legend.position = "none") +
  xlab("") +
  ylab("Percentage") +
  theme(axis.title.y = element_text(size = 22)) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 22, b = 0, l = 0))) +
  scale_fill_gradient(low = "Light Blue", high = "#DC143C") 

# FIGURE 3A -----------------------------------
first <- ggplot(prob_word_data_18, aes(x = value, y = key)) +
   geom_density_ridges(aes(fill = key), alpha = 0.8, from = 0, to = 100, col = "white") +
   guides(fill = FALSE, color = FALSE) +
   scale_x_continuous(breaks = seq(0, 100, 10), labels = paste0(seq(0, 100, 10), "%")) +
   scale_y_discrete(labels = c("vry_low" = "Very low",
                               "vry_small" = "Very small",
                               "prty_low" = "Pretty low",
                               "small" = "Small",
                               "low" = "Low",
                               "slight" = "Slight",
                               "moderate" = "Moderate",
                               "good" = "Good",
                               "sig" = "Significant")) +
   labs( x = "Percent Chance", y = "") +
   theme_gray()+
   theme(axis.text.y = element_text(size = 12)) +
   theme(axis.title.x = element_text(size = 16)) +
   theme(axis.text.x = element_text(size = 14)) +
   theme(plot.title = element_text(size = 18, face = "bold"))

# FIGURE 3B -----------------------------------
second <- ggplot(prob_word_data_19, aes(x = value, y = key)) +
   geom_density_ridges(aes(fill = key), alpha = 0.8, from = 0, to = 100, col = "white") +
   guides(fill = FALSE, color = FALSE) +
   scale_x_continuous(breaks = seq(0, 100, 10), labels = paste0(seq(0, 100, 10), "%")) +
   scale_y_discrete(labels = c("risk_chan" = "Chance", 
                               "risk_poss" = "Possible",
                               "risk_may" = "May",
                               "risk_exp" = "Expected")) +
   labs( x = "Percent Chance", y = "") + 
   theme_gray()+
   theme(axis.text.y = element_text(size = 18)) +
   theme(axis.title.x = element_text(size = 16)) +
   theme(axis.text.x = element_text(size = 14)) +
   theme(plot.title = element_text(size = 18, face = "bold"))

grid.arrange(first, second, nrow = 2)

# TABLE 3 & TABLE 4 -----------------------------------
twitter_data$ID <- 1:nrow(twitter_data)

twitter_data %>% 
  select(ID, ND1:ND5) %>% 
  gather(ND, Word, ND1:ND5) %>% 
  arrange(ID) %>% 
  drop_na(Word) %>% 
  group_by(Word) %>% 
  summarise(n = n()) %>% 
  arrange(-n) %>% 
  mutate(p = (n / sum(n)) * 100) %>% 
  print(n=100) %>%
  slice(1:10) -> ND_slice
print(ND_slice)

twitter_data %>% 
  select(ID, D1:D3) %>% 
  gather(D, Word, D1:D3) %>% 
  arrange(ID) %>% 
  drop_na(Word) %>% 
  group_by(Word) %>% 
  summarise(n = n()) %>% 
  arrange(-n) %>% 
  mutate(p = (n / sum(n)) * 100) %>%
  print(n = 100) %>%
  slice(1:10) -> D_slice
print(D_slice)

# TABLE 5 -----------------------------------
WX18 %>%
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  group_by(key) %>% 
  summarise(mean = mean(value), 
            sd = sd(value), 
            quantile_lower = quantile(value, probs = seq(0.25,0.25,0.25)), 
            quantile_upper = quantile(value, probs = seq(0.75, 0.75, 0.75)))  

# TABLE 6 -----------------------------------
WX19 %>%
  select(risk_chan, risk_poss, risk_may, risk_exp) %>% 
  gather() %>% 
  na.omit %>% 
  group_by(key) %>% 
  summarise(mean = mean(value), 
            sd = sd(value), 
            quantile_lower = quantile(value, probs = seq(0.25,0.25,0.25)), 
            quantile_upper = quantile(value, probs = seq(0.75, 0.75, 0.75))) 


# APPENDIX A -----------------------------------
prob <- WX18 %>%
  filter(prob_word == "probability") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Probability") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value)) 

chan <- WX18 %>%
  filter(prob_word == "chance") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Chance") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value))  

mean_diff = chan$mean - prob$mean
sd_diff = chan$sd - prob$sd

# APPENDIX B -----------------------------------
SVR18 <- WX18 %>%
  filter(prob_event == "severe thunderstorm") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Severe Thunderstorm") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value))

TOR18 <- WX18 %>%
  filter(prob_event == "tornado") %>% 
  select(vry_low, vry_small, prty_low, small, low, slight, moderate, 
         good, sig) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Tornado") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value))

mean_diff_18 = SVR18$mean - TOR18$mean
sd_diff_18 = SVR18$sd - TOR18$sd

SVR19 <- WX19 %>%
  filter(prob_event == "severe thunderstorms") %>% 
  select(risk_chan, risk_poss, risk_may, risk_exp) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Severe Thunderstorm") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value))

TOR19 <- WX19 %>%
  filter(prob_event == "tornadoes") %>% 
  select(risk_chan, risk_poss, risk_may, risk_exp) %>% 
  gather() %>% 
  na.omit %>% 
  mutate(event = "Tornado") %>%
  group_by(key) %>%
  summarise(mean = mean(value), sd = sd(value))

mean_diff_19 = SVR19$mean - TOR19$mean
sd_diff_19 = SVR19$sd - TOR19$sd