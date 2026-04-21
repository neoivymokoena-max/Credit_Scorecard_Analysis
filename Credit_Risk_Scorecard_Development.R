#The dataset used in this project is the German Credit dataset, has been preprocessed.

# Load dataset directly
df <- read.csv("https://raw.githubusercontent.com/selva86/datasets/master/GermanCredit.csv")

# Begin by Inspecting the dataset
head(df,5)
str(df)

#Step1:Understand the Target Variable:credit_risk default = 0 and non-default=1
table(df$credit_risk)

##Step1.2:convert default to 1 and non-default(good) to 0, this follows industry convention.
(df$credit_risk=ifelse(df$credit_risk == 0,1,0))
table(df$credit_risk)

#Step2:Verify before modelling
str(df$credit_risk)
table(df$credit_risk)

##Step3:Data Cleaning
library(dplyr)

#Check missing values
(colSums(is.na(df)))

#Convert character to factor
df=df %>% mutate_if(is.character,as.factor)

#Check structure
str(df)

#Step4:Train test split, WITHOUT the caret fallback.
set.seed(123)
#Split by class
default_1=df[df$credit_risk ==1,]
default_0=df[df$credit_risk ==0,]
#Sample each group
train_1=default_1[sample(1:nrow(default_1), 0.7 * nrow(default_1)),]
train_0=default_0[sample(1:nrow(default_0), 0.7 * nrow(default_0)),]
#Combine
train=rbind(train_1, train_0)
test=df[!(rownames(df) %in% rownames(train)),]

#sanity check
dim(train)
dim(test)

##Step5: Build the Logistic regression model
(model=glm(credit_risk~.,data = train, family = binomial))
summary(model)
#5.1 convert to the odds ratio (crucial)
exp(coef(model))
#5.2 identifying most important variables
summary(model)$coefficients
#5.3 Quick model quality check: lower AIC=better model fit
(model1=glm(credit_risk~., data = train, family = binomial))
(model2=step(model1))
(AIC(model1))
(AIC(model2))
(AIC(model))
#step_wise selection removes useless variables, simplifies model and reduces aic.
(step_model=step(model))
AIC(step_model)

#Step6: Make predictions
(probabilities=predict(model,test,type = "response"))
#Converts to binary predictions
(predictions=ifelse(probabilities > 0.5,1,0))

#Step7:Evaluate model w/o Caret package confusion Matrix
#Step7.1:Create confusion matrix manually and understand the matrix
table(Predicted=predictions, Actual=test$credit_risk)
#Step7.2:Calculate key metrics manually
(conf_mat=table(predictions, test$credit_risk))
(accuracy=sum(diag(conf_mat))/sum(conf_mat))
#Step7.2.1: Sensitivity (Recall for defaults), how many actual defaulters did we catch?
(sensitivity=conf_mat[2,2]/(conf_mat[2,2]+conf_mat[1,2]))
#7.2.2:Specificity, How well do we identify good customers?
(specificity=conf_mat[1,1]/(conf_mat[1,1]+conf_mat[2,1]))

#Step7.3:Threshold tuning
(predictions=ifelse(probabilities > 0.3,1,0))

#Step7.4:ROC + AUC
library(pROC)
roc_curve <- roc(test$credit_risk, probabilities)
plot(roc_curve, col = "blue", main = "ROC Curve - Credit Risk Model")
abline(a = 0, b = 1, lty = 2, col = "red")

##Step8:Feature Selection-Improve the model, what analysts actually do. 
(step_model=step(model))
summary(step_model)
#Step8.1:Better threshold
(predictions_custom=ifelse(probabilities > 0.3,1,0))

#step9:Visuals
# Distribution of predicted probabilities
hist(probabilities, breaks = 30, main = "Predicted Default Probabilities")

## Build Credit_scorecard by adding WOE & IV
#Step1: Select important variables
(vars=c("duration", "amount", "checking_status", "credit_history", "savings_status", "installment_rate"))

#Step2:Bin variables
#Duration
(df$duration_bin=cut(df$duration, breaks = c(0,12,24,36,Inf), labels = c("0-12","12-24","24-36","36+"), include.lowest = T))
(df <- df[!is.na(df$duration_bin), ])
(table(df$duration_bin, useNA = "ifany"))

#Amount
(df$amount_bin=cut(df$amount, breaks = quantile(df$amount, probs = seq(0,1,0.25)),include.lowest = T))

#Checking_status
(df$status_bin=as.character(df$status))
(df$status_bin[df$status_bin %in% c("no checking account")] = "no account")
(df$status_bin[df$status_bin %in% c("...< 0 DM")] = "low")
(df$status_bin[df$status_bin %in% c("0 <= ... < 200 DM")] = "medium")
(df$status_bin[df$status_bin %in% c(">= 200 DM")] = "high")
(df$status_bin = as.factor(df$status_bin))

#Credit_history
(df$credit_history_bin <- as.character(df$credit_history))

(df$credit_history_bin[df$credit_history_bin %in% 
                          c("critical account/other credits existing")] <- "high_risk")

(df$credit_history_bin[df$credit_history_bin %in% 
                          c("delay in paying off in the past")] <- "medium_risk")

(df$credit_history_bin[df$credit_history_bin %in% 
                          c("existing credits paid back duly till now",
                            "no credits taken/all credits paid back duly")] <- "low_risk")

(df$credit_history_bin <- as.factor(df$credit_history_bin))

#Savings
(df$savings_bin=as.character(df$savings))
(df$savings_bin[df$savings_bin %in% c("unknown/no savings account")] = "none")
(df$savings_bin[df$savings_bin %in% c("...<100 DM")] = "low")
(df$savings_bin[df$savings_bin %in% c("100<= ...<500 DM")] = "medium")
(df$savings_bin[df$savings_bin %in% c("500<= ... <1000 DM")] = "high")
(df$savings_bin=as.factor(df$savings_bin))

#installment_rate
(df$installment_rate_bin=cut(df$installment_rate, breaks = c(0,2,3,4), labels = c("low","medium","high"), include.lowest = T))
unique(df$installment_rate)
table(df$installment_rate)

#Step2.1:for verification ALWAYS!
(table(df$duration_bin, useNA = "ifany"))
(table(df$amount_bin))
(table(df$status_bin))
(table(df$credit_history_bin))
(table(df$savings_bin))
(table(df$installment_rate_bin))

woe_function <- function(df, var, target) {
  
  library(dplyr)
  
  woe_table <- df %>%
    group_by(.data[[var]]) %>%
    summarise(
      good = sum(.data[[target]] == 0),
      bad  = sum(.data[[target]] == 1),
      .groups = "drop"
    ) %>%
    mutate(
      dist_good = good / sum(good),
      dist_bad  = bad / sum(bad),
      WOE = log((dist_good + 1e-6) / (dist_bad + 1e-6)),
      IV  = (dist_good - dist_bad) * WOE
    )
  
  return(woe_table)
}

#Step2.2:Apply WOE to each variable
(woe_function(df, "installment_rate_bin", "credit_risk"))
(woe_function(df, "status_bin", "credit_risk"))
(woe_function(df, "credit_history", "credit_risk"))
(woe_function(df, "savings_bin", "credit_risk"))
(woe_function(df, "duration_bin", "credit_risk"))
(woe_function(df, "amount_bin", "credit_risk"))


##Step3:Create an APPLY Function
apply_woe = function(df, var, target) {
  
  library(dplyr)
  
  #step1: get WOE table
  woe_tbl = woe_function(df, var, target)
  
  #step2:rename the first column to match variable
  colnames(woe_tbl)[1] = var 
  
  #step3:join WOE back to data_set
  df=df %>%
    left_join(woe_tbl[, c(var, "WOE")], by = var)
  
  #step4:rename new column
  new_name = paste0(var, "_woe")
  colnames(df)[ncol(df)] = new_name
  
  
  return(df)
  
}

##Step3.1:Apply to all variables
(df=apply_woe(df, "duration_bin", "credit_risk"))
(df=apply_woe(df, "amount_bin", "credit_risk"))
(df=apply_woe(df, "installment_rate_bin", "credit_risk"))
(df=apply_woe(df, "status_bin", "credit_risk"))
(df=apply_woe(df, "credit_history", "credit_risk"))
(df=apply_woe(df, "savings_bin", "credit_risk"))

#Step3.2: verify the transformation
head(df[, c("duration_bin", "duration_bin_woe")])
head(df[, c("credit_history_bin", "credit_history_woe")])

#Step3.3:Sanity check
summary(df$duration_bin_woe)
summary(df$status_bin_woe)
summary(df$amount_bin_woe)
summary(df$savings_bin_woe)
summary(df$credit_history_woe)
summary(df$installment_rate_bin_woe)

#Step4:Build the Final WOE based model
(model_woe = glm(credit_risk~ 
                  duration_bin_woe +
                  amount_bin_woe +
                  installment_rate_bin_woe +
                  status_bin_woe+
                  credit_history_woe +
                  savings_bin_woe,
                data = df,
                family = binomial))

###Building scorecard table w/ points per bin
#Step1:run the coefficients
(names(coef(model_woe)))
(coef(model_woe))

#Step2:Define Scaling standard
PDO=20
base_score=600
base_odds=50

factor=PDO / log(2)
offset=base_score - factor * log(base_odds)
log_odds <- predict(model_woe, type = "link")
df$final_score <- offset + factor * log_odds

min_score <- min(df$final_score)
max_score <- max(df$final_score)
df$final_score <- 300 + 
  (df$final_score - min_score) * (850 - 300) / (max_score - min_score)
(df$final_score=round(df$final_score))

summary(df$final_score)

#Step4:Robust score_card function
scorecard_table <- function(df, var, target, model, factor) {
  
  woe_tbl <- woe_function(df, var, target)
  
  coef_name <- paste0(var, "_woe")
  
  if (!(coef_name %in% names(coef(model)))) {
    stop(paste("Variable", coef_name, "not in model"))
  }
  
  beta <- coef(model)[coef_name]
  
  woe_tbl$Points <- -beta * woe_tbl$WOE * factor
  woe_tbl$Variable <- var
  
  #standardize column name
  colnames(woe_tbl)[1] <- "Bin"
  
  return(woe_tbl[, c("Variable", "Bin", "WOE", "Points")])
}

##Step4:Generate Scorecard for each variable
(sc_duration=scorecard_table(df, "duration_bin", "credit_risk", model_woe, factor))
(sc_amount=scorecard_table(df, "amount_bin", "credit_risk", model_woe, factor))
(sc_install=scorecard_table(df, "installment_rate_bin","credit_risk", model_woe, factor))
(sc_status=scorecard_table(df, "status_bin", "credit_risk", model_woe, factor))
(sc_credit=scorecard_table(df, "credit_history", "credit_risk", model_woe, factor))
(sc_savings=scorecard_table(df, "savings_bin", "credit_risk", model_woe, factor))

names(coef(model_woe))

#Step5:Combine into Final sore_card
final_scorecard=rbind(
  sc_duration,
  sc_amount,
  sc_install,
  sc_status,
  sc_credit,
  sc_savings
)

final_scorecard

##outputs
#Score distribution histogram
if(!dir.exists("outputs")) {
  dir.create("outputs")
}
png("outputs/score_distribution.png", width = 800, height = 600)
hist(df$final_score,
     breaks = 30,
     main = "Credit Score Distribution",
     xlab = "Score",
     ylab = "Frequency")
dev.off()

#Packages to help with various outputs
install.packages("gridExtra")

library(gridExtra)
library(grid)

##Scorecard table
png("outputs/scorecard_table.png", width = 1000, height = 800)

grid.table(final_scorecard)

dev.off()

#Risk Bands
(df$score_band <- cut(df$final_score,
                     breaks = c(300, 500, 600, 700, 850),
                     labels = c("High Risk", "Medium Risk", "Low Risk", "Very Low Risk"),
                     include.lowest = TRUE))

table(df$score_band)

##Score bands Bar_chart
png("outputs/score_bands.png", width = 800, height = 600)

barplot(table(df$score_band),
        main = "Customer Risk Segments",
        xlab = "Risk Category",
        ylab = "Count")

dev.off()

##Adding Gini
#Step1:Get the probabilities
probs=predict(model_woe, type = "response")

#Step2:Load proc for AUC and Gini
library(pROC)

#Step3:Calculate AUC
(roc_obj=roc(df$credit_risk, probs))
(auc_value=auc(roc_obj))

#Step4:Calculate gini
(gini=2*auc_value-1)

##KS Calculation
library(dplyr)

ks_table=data.frame(
  actual=df$credit_risk,
  prob=probs
)

ks_table=ks_table %>%
  arrange(desc(prob)) %>%
  mutate(
    cum_good=cumsum(actual == 0)/sum(actual == 0),
    cum_bad=cumsum(actual ==1)/sum(actual == 1),
    ks=abs(cum_bad - cum_good)
  )

#Step5:ks value
(ks_value=max(ks_table$ks))






















