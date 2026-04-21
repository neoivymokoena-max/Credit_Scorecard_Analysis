# Credit_Scorecard_Analysis
End-to-end credit risk scorecard model using WOE, IV, and logistic regression (industry-standard approach used in banking)
# Credit Risk Scorecard Model (WOE + Logistic Regression)

## Overview

This project builds a credit risk scorecard to predict the probability of default using the German Credit dataset. The model transforms raw borrower data into an interpretable points-based scoring system aligned with banking industry practices.

---

## Objective

To develop a robust, interpretable credit risk model that:

* Predicts borrower default probability (PD)
* Ranks customers by risk
* Converts model outputs into a scorecard (points system)

---

## Methodology

### 1. Data Preprocessing

* Cleaned dataset and handled missing values
* Converted target variable into binary (default = 1, non-default = 0)

### 2. Feature Engineering

* Binned continuous variables (duration, amount, installment rate)
* Grouped categorical variables into risk-relevant categories

### 3. WOE Transformation

* Calculated Weight of Evidence (WOE) for each bin
* Ensured monotonic relationship with default risk

### 4. Feature Selection (IV)

* Evaluated Information Value (IV) for predictive strength
* Selected strongest variables:

  * Checking account status
  * Credit history
  * Loan duration

### 5. Model Development

* Built logistic regression model using WOE variables

### 6. Model Evaluation

* ROC Curve and AUC used to assess performance
* Model demonstrates strong discriminatory power
* AUC: 0.786
* Gini: 0.572
* KS Statistic: 0.4614  
The model demonstrates strong discriminatory power and effective separation between good and bad borrowers.

### 7. Scorecard Development

* Converted model coefficients into points using PDO scaling
* Scores were scaled using PDO = 20 and base odds = 50:1, aligning with standard credit risk scoring frameworks.
* Scores were rescaled to a 300–850 range to align with standard credit scoring frameworks used in banking.
* Final score = sum of points across variables

---

## Key Insights

* Liquidity indicators (checking/savings) are strongest predictors
* Longer loan duration significantly increases default risk
* High loan exposure increases risk at upper levels
 

---

## Outputs

* Credit scorecard table (points per bin)
* ROC curve (model performance)
* Customer risk scores
<img width="1000" height="800" alt="scorecard_table" src="https://github.com/user-attachments/assets/cc118d84-5757-48a4-93e0-434aa9b85af4" />
<img width="800" height="600" alt="score_distribution" src="https://github.com/user-attachments/assets/b43eafc0-c9e7-46b0-926a-e80a697e7f76" />
<img width="800" height="600" alt="score_bands" src="https://github.com/user-attachments/assets/8983bb48-fc48-47e4-8052-9eb9852f9996" />
<img width="663" height="550" alt="ROC Curve" src="https://github.com/user-attachments/assets/dceb2503-9976-41d5-97d9-bc63d899b969" />


---

## Business Value

This scorecard enables:

* Reduce default rates.
* Segment customers by risk.
* Improved credit approval strategies.
* Support risk-based pricing strategies and lending decisions.

---

## Tools Used

* R (dplyr, pROC)
* Logistic Regression
* WOE & IV techniques
* Gini & KS statistic
---
## Neo Ivy Mokoena
Graduate Quantitative Risk Analyst with strong foundation in statistical modelling and financial risk analytics.


