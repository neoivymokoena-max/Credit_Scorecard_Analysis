# Credit_Scorecard_Analysis
Built a credit risk scorecard project to predict the probability of default (PD) using German Credit data. It transforms raw borrower data into an interpretable, points based scoring system aligned with banking industry practices.
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

### 7. Scorecard Development

* Converted model coefficients into points using PDO scaling
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
<img width="535" height="379" alt="ROC_Curve" src="https://github.com/user-attachments/assets/83738d88-5c44-4a48-96c6-e346a69b3cc5" />

---

## Business Value

This scorecard enables:

* Risk-based lending decisions
* Customer segmentation
* Improved credit approval strategies

---

## Tools Used

* R (dplyr, pROC)
* Logistic Regression
* WOE & IV techniques
---
## Neo Ivy Mokoena
Graduate Quantitative Risk Analyst with strong foundation in statistical modelling and financial risk analytics.


