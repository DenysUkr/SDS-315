library(tidyverse)
library(mosaic)

# load NHANES_sleep.csv data
# Make sure to check for a header row!
NHANES_sleep= read.csv("NHANES_sleep.csv")
# how well are Americans sleeping, on average?
# the data distribution of sleeping hours per night in the sample
ggplot(NHANES_sleep) + 
  geom_histogram(aes(x = SleepHrsNight), binwidth=1)

# the sample mean should be a decent estimate for the population mean...
mean(~SleepHrsNight, data=NHANES_sleep)

# but how close is it to the right answer for the whole population?
# remember, this is just a survey... 
# a very well-designed survey, but a survey nonetheless!

# let's try a few bootstrap samples
# by repeating these lines below.
# Looks like our bootstrap estimate is pretty close.
# Doesn't seem like a huge amount of sampling variability...
NHANES_sleep_bootstrap = resample(NHANES_sleep)
mean(~SleepHrsNight, data=NHANES_sleep_bootstrap)

# Let's be more systematic, with 10,000 bootstrap samples
boot_sleep = do(10000)*mean(~SleepHrsNight, data=resample(NHANES_sleep))

# What does this boot_sleep object look like?
# Let's examine the first several lines: one column called mean
head(boot_sleep)

# bootstrap sampling distribution
ggplot(boot_sleep) + 
  geom_histogram(aes(x=mean))

# how spread out is the sampling distribution?
sd(~mean, data=boot_sleep)

# So it looks like a typical sampling error is about 0.03 hours,
# or roughly 2 minutes. 

# a confidence interval: a range of plausible values, 
# based on the sampling distribution
confint(boot_sleep, level=0.95)

# can we eyeball these lower and upper endpoints of the
# confidence interval from the histogram?


###
# Example 2: depression
###

# quick exploratory analysis
NHANES_sleep %>%
  group_by(Depressed) %>%
  summarize(count = n())

# let's make a DepressedAny variable
NHANES_sleep = NHANES_sleep %>%
  mutate(DepressedAny = ifelse(Depressed != "None", yes=TRUE, no=FALSE))

prop(~DepressedAny, data=NHANES_sleep)

# How precisely does this survey result characterize
# the frequency of depression among all Americans?
# Let's bootstrap to understand the likely magnitude of
# estimation error due to sampling variability

boot_depression = do(10000)*prop(~DepressedAny, data=resample(NHANES_sleep))

# sanity check: single column called prop_TRUE
head(boot_depression)

# histogram of the 10,000 different estimates
# for prop_TRUE
ggplot(boot_depression) + 
  geom_histogram(aes(x=prop_TRUE))

# a 95% confidence interval for the population proportion
confint(boot_depression, level = 0.95)

# again, can we eyeball this from the histogram?



###
# Smoke100
###

prop(~Smoke100, data=NHANES_sleep)
boot_smoking = do(10000)*prop(~Smoke100, data=resample(NHANES_sleep))
confint(boot_smoking, level=0.95)
