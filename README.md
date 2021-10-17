## Home Credit Default Risk Analysis on Big Data (Hadoop) platform

## Dataset: Home Credit Default Risk

Original: https://www.kaggle.com/c/home-credit-default-risk

Customized datasets:

- application.csv: (Application dataset)

| prev_id	| curr_id	| contract | amount | credit | down_payment | start_day | purpose | contract_status | payment_type | reject_reason | client | product_type | channel | yield_group | 

- p_application.csv: (Previous Application dataset)

| curr_id	| contract | sex | car | income | credit | income_type | education | family_status | house | start_day | organization | 

## Business Case:

"Many people struggle to get loans due to insufficient or non-existent credit histories. And, unfortunately, this population is often taken advantage of by untrustworthy lenders. Home Credit Group strives to broand fiancial inclusion for the unbanked population by providing a positive and safe borrowing experience. In order to make sure this underserved population has a positive loan experience, Home Credit makes use of a variety of alternative data--including telco and transactional information--to predict their clients' repayment abilities.

While Home Credit is currently using various statistical and machine learning methods to make these predictions, they're challenging Kagglers to help them unlock the full potential of their data. Doing so will ensure that clients capable of repayment are not rejected and that loans are given with a principal, maturity, and repayment calendar that will empower their clients to be successful."

## Targets:

Conducting a basic Explanatory Data Analysis on their customized datasets as attached on the Big Data plaform to analyze the loan applicants' background and help Home Credit Group expanding their financial services to those who are unable to access financial service. 

## Languages & Tools: 

- SQL

- Scala 

+ Hadoop

+ Hive

+ HDFS

+ Zeppelin

## Business Questions: 

- Family status of the loan applicants?

- Occupation of the loan applicant?

- Education of the loan applicant?

- How capable would each applicant be with repaying a loan? 

## Final Conclusion:

Most significant background check of applicants who got the most loan approvals:

- Working Income Type

- Married Family Status

- Secondary/Special Secondary Education Type

Home Credit should:

- Focus on Working income type, Married couples, Secondary/High school education background of applicants as the first priority and the main customer target

- Secondary customer target should be Commercial Associates, Single/Not Married customers, High School



