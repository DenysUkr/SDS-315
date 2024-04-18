library(tidyverse)
library(mosaic)
library(MatchIt)

greenbuildings = read.csv("greenbuildings.csv")

#####
# Part I
#####

# Let's examine the "green premium"
# starting point: define revenue per sq ft
greenbuildings = mutate(greenbuildings,
                        rev_psf = Rent * leasing_rate/100)


# do green buildings earn more revenue?
mean(rev_psf ~ green_rating, data=greenbuildings)

# let's see a boxplot
# remember: factor tells R to treat a numerical code (here 0 or 1)
# as a categorical variable
ggplot(greenbuildings) +
  geom_boxplot(aes(x=factor(green_rating), y=rev_psf))

# But is it the green status, or other stuff that the green
# buildings have/are?

# here are a couple of potential confounders that arise from exploring the data

# 1) age
ggplot(greenbuildings) +
  geom_histogram(aes(x=age, y=..density.., binwidth=2)) +
  facet_wrap(~green_rating, nrow=2)

# Notice here we can see the whole distribution of ages.
# important for recognizing the second group of older buildings
# that is largely missing among the green-rated buildings

# It's a confounder because it's correlated with green_rating (the treatment)
# and also correlated with rev_psf (the outcome).
# this is a bit hard to see with just the scatterplot
# but much easier to see with the smooth trend added
ggplot(greenbuildings, aes(x=age, y=rev_psf)) +
  geom_point() +
  geom_smooth()

# a second confounder: building class
# let's calculate average rev_psf for class a and not class a
# (remember group/pipe/summarize)
class_summary = greenbuildings %>%
  group_by(class_a) %>%
  summarize(mean_rev_psf = mean(rev_psf))

# the numbers
class_summary

# a boxplot that shows both between and within-group variation
ggplot(greenbuildings) +
  geom_boxplot(aes(x=factor(class_a), y = rev_psf))



####
# Part II: matching and comparison
####

# step 1: look for matches based on age and class_a variables
# ratio = 3 says: look for 3 matches for each treated unit (green building)
green_match = matchit(green_rating ~ age + factor(class), data = greenbuildings, ratio=3)

# Step 2:
# Check covariate balance
summary(green_match)

# Extract only the matched pairs
green_matched = match.data(green_match)

# Step 3: run an analysis on the matched data.
# Here we perform a simple difference-of-means
# analysis on the matched data only
mean(rev_psf ~ green_rating, data=green_matched)
diffmean(rev_psf ~ green_rating, data=green_matched)

# bootstrapped confidence intervals
boot_match = do(1000)*diffmean(rev_psf ~ green_rating, data=resample(green_matched))
head(boot_match)

# let's look at the bootstrapped sampling distribution
ggplot(boot_match) +
  geom_histogram(aes(x=diffmean))

# confidence interval
confint(boot_match)

# The catch:
# Confounders that weren't matched on may still be unbalanced!
mean(amenities ~ green_rating, data= green_matched)
mean(City_Market_Rent ~ green_rating, data= green_matched)
mean(Utility_Costs ~ green_rating, data= green_matched)
