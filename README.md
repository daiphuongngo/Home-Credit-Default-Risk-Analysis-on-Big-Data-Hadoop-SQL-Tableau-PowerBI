## Home Credit Default Risk Analysis on Big Data (Hadoop, SQL), Tableau, Power BI

## Category: 

- Banking

- Credit

- Finance

- Financial Institute

## Dataset: Home Credit Default Risk

Original: https://www.kaggle.com/c/home-credit-default-risk

Customized datasets:

- application.csv: (Application dataset)

| prev_id | curr_id | contract | amount | credit | down_payment | start_day | purpose | contract_status | payment_type | reject_reason | client | product_type | channel | yield_group | 
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|


- p_application.csv: (Previous Application dataset)

| curr_id | contract | sex | car | income | credit | income_type | education | family_status | house | start_day | organization | 
|-|-|-|-|-|-|-|-|-|-|-|-|

Original datasets:

![home_credit](https://user-images.githubusercontent.com/70437668/147731951-9f81a423-c763-438c-8743-fb625f49aed8.png)

## Business Case:

"Many people struggle to get loans due to insufficient or non-existent credit histories. And, unfortunately, this population is often taken advantage of by untrustworthy lenders. Home Credit Group strives to broand fiancial inclusion for the unbanked population by providing a positive and safe borrowing experience. In order to make sure this underserved population has a positive loan experience, Home Credit makes use of a variety of alternative data--including telco and transactional information--to predict their clients' repayment abilities.

While Home Credit is currently using various statistical and machine learning methods to make these predictions, they're challenging Kagglers to help them unlock the full potential of their data. Doing so will ensure that clients capable of repayment are not rejected and that loans are given with a principal, maturity, and repayment calendar that will empower their clients to be successful."

## Targets:

Conducting a basic Explanatory Data Analysis on their customized datasets as attached on the Big Data platform to analyze the loan applicants' background and help Home Credit Group expanding their financial services to those who are unable to access financial service. 

## Languages & Tools: 

- Python 

- SQL

- Scala 

+ Hadoop

+ Hive

+ HDFS

+ Zeppelin

+ Tableau

+ Power BI

## Business Questions: 

- Family status of the loan applicants?

- Occupation of the loan applicant?

- Education of the loan applicant?

- How capable would each applicant be of repaying a loan? 

## Final Conclusion:

Most significant background check of applicants who got the most loan approvals:

- Working Income Type

- Married Family Status

- Secondary/Special Secondary Education Type

Home Credit should:

- Focus on Working income type, Married couples, Secondary/High school education background of applicants as the first priority and the main customer target

- Secondary customer target should be Commercial Associates, Single/Not Married customers, High School

## Hive 

### Creating Hive external & external tables for application & previous application datasets

We have created hive external and internal tables for our application and previous application dataset. We named them as application_external & application_orc and p_application_external and p_application_orc.

```
CREATE EXTERNAL TABLE IF NOT EXISTS p_application_external(prev_id int, curr_id int, contract string, amount float, credit float, down_payment float, start_day, purpose string, contract_status string, payment_type string, reject_reason string, client string, product_type string, channel string, yield_group string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION /tmp/group/p_application
```
```
CREATE TABLE IF NOT EXISTS p_application_ORC (prev_id int, curr_id int, contract string, amount int, credit int, income_type string, education string, family_status string, house string, start_day string, organization string)
STORED AS ORC;
```

### Loading the data from external table to internal table for both application and p_application data sets
```
INSERT INTO TABLE p_application_orc 
SELECT *
FROM p_application_external;
```

```
INSERT INTO TABLE application_orc 
SELECT *
FROM application_external;
```

### Printing out the created tables
```
SELECT *
FROM application_external
LIMIT 10;
```

```
SELECT *
FROM application_ORC
LIMIT 10;
```

## HBase
```
sandbox-hdp login: root
root@sandbox-hdp.hortonworks.com's password: ...
[root@sandbox-hdp ~]# hbase shell
hbase(main):001:0> application
hbase(main):002:0> list
```

Output
```
=> ["ATLAS_ENTITY_AUDIT_EVENTS", "Product", "application", "atlas_titan"]
```

## Hive (again)

### Creating external tables for HBase

```
CREATE EXTERNAL TABLE ext_hbase_application (curr_id int, contract string, sex string, car string, income float, credit float, income_type float, education, family_status, house, start_day, organization string)
STORED BY ‘org.apache.hadoop.hive.hbase.HBaseStorageHandler’
WITH SERDEPROPERTIES (“hbase.columns.mapping” = “:key, details: contract, details: sex, details: car, details: income, details: credit, details: income_type, details: education, details: family_status, details: house, details: start_day, details: organization)
TBLPROPERTIES(“hbase.table.name” = “application”, “hbase.mapred.output.outputtable” = “application”)
![image](https://user-images.githubusercontent.com/70437668/147803000-645e3acd-ebd9-4c4f-bf30-9e74b8b36871.png)
```

![image](https://user-images.githubusercontent.com/70437668/147803001-edffbfe6-b983-4eff-a200-23d0ffd28f83.png)

## Zeppelin

### Retrieve data from the external HBase application table

```
%jdbc(hive)
SELECT *
FROM ext_hbase_application
WHERE income_type='Pensioner'
ORDER BY income DESC;
```
 The top 5 Pensioner income types with the highest income have contracts of Cash loans and Revolving loans and Female applicants without Car dominate the loan applications. 
 
### Creating dataframes and loading the data from HDFS

```
%spark2
// Create an application Dataframe from CSV file
Val records = (spark.read
	.option(“header”, “true”) // Use the first line as header
	.option(“inferSchma”, “true”) // Infer schema
	.csv(“/tmp/group/application/application.csv”))
```

Output
```
records: org.apache.spark.sql.DataFrame = [curr_id: int, contract: string ... 10 more fields]
```

```
%spark2
records.select(“curr_id”, “contract”, ”sex”, ”car”, ”income”, ”credit”, ”income_type”, ”education”, ”family_status”, ”house”,”start_day”, ”organization”).show()
```

![image](https://user-images.githubusercontent.com/70437668/147803515-38291d39-171b-429f-85cc-c3d20eb6ce7f.png)

### Printing schema
```
%spark2
// Print the schema in a tree format
records.printSchema()
```
![image](https://user-images.githubusercontent.com/70437668/147803544-87347130-8e99-4458-998c-6226ac7c8c91.png)

### Grouping the data by income type

We can show the cout of income_type by using Spark. the GROUP BY income_type command can help to draw the values in the result.

The Working, Commerical associate & Pensioner working types plays a significant role in the distribution of loan applications while Unemployed type has very rare cases to apply for loan successfully.

```
%spark2.spark
val Results = records.groupBy("income_type").count()
Results.show()
```
![image](https://user-images.githubusercontent.com/70437668/147803700-71789fb0-0498-4162-a5dd-da595aa626cd.png)

### Creating tempview tables

Creating temporary tables can help to run SQL queries from required tables and then visualize requested figures.
```
%spark2
records.createOrReplaceTempView("Recordsview")
```

```
%spark2
Results.createOrReplaceTempView("Incometypeview")
```
![image](https://user-images.githubusercontent.com/70437668/147803840-286047b2-8be8-46df-a1a8-e5445859ec1b.png)

![image](https://user-images.githubusercontent.com/70437668/147803845-ec1cfc46-35a1-4fee-b190-6baa7be9fe8c.png)

The result generated with spark2.sql from the temporary table of Income type shows the same output as the one with spark.

### Which income type of applicants who got approval for a loan?

Our table illustrates that Working people received the most loan approval by 1341 ( 50.8 % of income type) while their average income ranked 3rd by near 165 thousand (24.2%). Meanwhile, Commercial associate obtained the 2nd highest approvals for loan while their average income placed the highest by more than 195 thousand. Pensioner and State servant were among the lowest cases of approved applicants.

```
%spark2.sql
SELECT Recordsview.income_type, COUNT(p_application_orc.contract_status) AS approved, AVG(Recordsview.income) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.income_type
ORDER BY COUNT(p_application_orc.contract_status) DESC
```
![image](https://user-images.githubusercontent.com/70437668/147804055-2f0e2897-7f48-4169-9701-984c847c570b.png)

![image](https://user-images.githubusercontent.com/70437668/147804065-850f19b0-3d1e-4a7d-ad5a-6b9988099885.png)

### Loan Approval’s Bar chart by Income Type

For the cases of Approved , Working income_type dominated the largest portion with 1341 cases while commercial associate kept their position at the 2nd rank, pensioner and state servant still placed the 3rd and 4th.

![image](https://user-images.githubusercontent.com/70437668/147804079-47caac55-2442-45ad-8f02-8aa8948da2f9.png)

### Which income type of applicants who got rejected for a loan?

Working dominated this field with the highest case of rejected applicant for a loan (748) although their average income ranked 3rd by slightly more than 172 thousand of application who got rejected.

Commercial got the second highest case by 411 while taking the 1st place of average income by more than 206 thousand.
Pensioner and State servant were among the lowest cases of rejected applicants but State Servant (ranked last) obtained the 2nd highest average income by more than 196 thousand.

```
%spark2.sql
SELECT Recordsview.income_type, COUNT(p_application_orc.contract_status) AS approved, AVG(Recordsview.income) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Refused" OR p_application_orc.contract_status = "Canceled"
GROUP BY Recordsview.income_type
ORDER BY COUNT(p_application_orc.contract_status) DESC
```

![image](https://user-images.githubusercontent.com/70437668/147804272-7a95cdf9-15ca-44f2-ac87-7c57219b1747.png)

![image](https://user-images.githubusercontent.com/70437668/147804278-7a7f91d3-5b75-4bc2-a606-f0e07182f2c2.png)

This is a pie chart we had visualized so you can see the working type dominates roughly half of the applicant with income type rejected for a loan.

### Which Family Status got the most loan approval?

Married couples took the majority of family status to be approved for a loan with 1733 cases. This is visualized this on a pie chart below.
```
%spark2.sql
SELECT Recordsview.family_status, COUNT(p_application_orc.curr_id) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.family_status
ORDER BY COUNT(p_application_orc.curr_id) DESC
```

![image](https://user-images.githubusercontent.com/70437668/147804295-3418470e-2cc0-4cae-8460-c37b48bc460b.png)

![image](https://user-images.githubusercontent.com/70437668/147804361-819f3452-d1c3-4c47-ad8b-500696752b2a.png)

Married customers played the most crucial in cases of application getting approval for loan by ⅔ of cases (1733 cases).
The second highest family status was single/not married but consisted of only 311 cases.

### Loan application by family status

Married people applied more loans than any other groups of family status with 2,772 cases which is more than 5-fold of the second highest Single / Not married applications. 

![image](https://user-images.githubusercontent.com/70437668/147804385-a839d1e5-de00-4a36-8546-2353d2c02455.png)

### Which education type of applicants got the most loan approvals?

Looking at the education background of applicant group getting the most loan approvals, secondary/secondary special played the most significant role in this field with the highest count by 1917 (73 %). Meanwhile, higher education came at the 2nd place with 610 cases (23%). Incomplete higher and Lower Secondary contributed minor figures of 3% and 1%, respectively.

```
%spark2.sql
SELECT Recordsview.education, COUNT(p_application_orc.curr_id) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.education
ORDER BY COUNT(p_application_orc.curr_id) DESC
```
![image](https://user-images.githubusercontent.com/70437668/147804488-ccd306e5-2e2d-4765-bc72-d085ee677cc4.png)

![image](https://user-images.githubusercontent.com/70437668/147804572-b9f35a9a-305a-40e1-b7ad-adec6870c117.png)

## Visualizing charts in Tableau & Power BI:

### Living Background of Loan Applicants by Gender

![Living Background of Loan Applicants by Gender](https://user-images.githubusercontent.com/70437668/138408668-5839b767-c253-4a87-82b6-a42df5cdcf1c.jpg)

![Living Background of Loan Applicants by Gender](https://user-images.githubusercontent.com/70437668/140484418-f6c9110a-6d4a-42a6-ad6b-902468625552.jpg)

### Loan applications by family status

![Loan applications by family status](https://user-images.githubusercontent.com/70437668/138408685-c430d66f-4182-4076-91e0-90955be465b6.jpg)

![Loan applications by family status](https://user-images.githubusercontent.com/70437668/140484455-8d67093e-6b2e-4306-a7dd-1b6f1483e86f.jpg)

### Percentage of loan applications by family status 

![Percentage of loan applications by family status ](https://user-images.githubusercontent.com/70437668/138408705-77485972-7369-415a-a32e-6c7c4116874b.jpg)

![Percentage of loan applications by family status](https://user-images.githubusercontent.com/70437668/140484469-9973d556-4778-4a69-95fe-c3abb1e79678.jpg)

### Contract Status by Income Type

![Contract Status by Income Type](https://user-images.githubusercontent.com/70437668/138408514-01b4dc82-bf5f-49da-96ea-de562a40b4f4.jpg)

![Contract Status by Income Type](https://user-images.githubusercontent.com/70437668/140484484-699abc75-4449-4812-a244-2c673583a2bd.jpg)

### Education type of applicants who got the most loan approvals

![Education type of applicants who got the most loan approvals](https://user-images.githubusercontent.com/70437668/138408564-c312b289-2db8-46ba-b34f-4406b875715f.jpg)

![Education type of applicants who got the most loan approvals](https://user-images.githubusercontent.com/70437668/140484503-84ec3124-da24-4599-9ddf-337f95121f85.jpg)

### Income Sources of Loan Applicants

![Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/138408604-69600898-47aa-4b6c-aba2-548cd4a4f63f.jpg)

![Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/140484514-5dca47af-c41b-4bfe-a33d-a719c5b9eafa.jpg)

### Income type of applications who got the most loan rejection

![Income type of applications who got the most loan rejection](https://user-images.githubusercontent.com/70437668/138408628-2bb8d7c0-b2bf-4f83-a2d4-703787f6a05d.jpg)

![Income type of applications who got the most loan rejection](https://user-images.githubusercontent.com/70437668/140484524-5cd7fb2c-e73b-40c7-beb9-5bf3e1f944a5.jpg)

### Average Income by Income Type

![Average Income by Income Type](https://user-images.githubusercontent.com/70437668/138408493-42a014a1-1a22-4c47-a50a-b4712937a300.jpg)

![Average Income by Income Type](https://user-images.githubusercontent.com/70437668/140484541-c6aeaaae-5729-4b41-8092-fcf1bd85e228.jpg)

### Credit Amount by Income Sources of Loan Applicants

![Credit Amount by Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/138408538-8329ea1b-93cc-48c0-aa15-b2bcafa3e33b.jpg)

![Credit Amount by Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/140484552-dd90ef33-6daf-4319-9a09-3fa80ac1302b.jpg)

## Dashboards:

### Dashboard - Income type, Family Status, Education, Credit Amount

![Dashboard - Income type, Family Status, Education, Credit Amount](https://user-images.githubusercontent.com/70437668/138408987-1c864496-ef72-406b-99d3-a0e29dc9213b.jpg)

### Dashboard - Income Type and Average

![Dashboard - Income Type and Average](https://user-images.githubusercontent.com/70437668/138409002-ed5f0e0d-98e5-4c70-a0e2-6b1ca70ea55d.jpg)

### Dashboard - Approved applicants by family, contract status, income type

![Dashboard - Approved applicants by family, contract status, income type](https://user-images.githubusercontent.com/70437668/138409033-7816863a-fc6f-492c-b84e-fadeaff9da8c.jpg)




