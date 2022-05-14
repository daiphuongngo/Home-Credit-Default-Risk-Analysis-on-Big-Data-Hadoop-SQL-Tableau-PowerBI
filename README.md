# Home Credit Default Risk Analysis on Big Data (Hadoop, SQL), Python, Tableau, Power BI

## Overview:

I chose Home Credit Default Risk as it has many datasets to explore, analyze and visualize. I will upgrade it gradually with more in-depth analysis and viz. The class required only SQL, Scala, Hadoop, Hive, HDFS, Zeppelin. However, I also used Python, Tableau, Power BI to improve a wide range of skills. 

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

- POS_CASH_balance:

| SK_ID_PREV | SK_ID_CURR | MONTHS_BALANCE | CNT_INSTALMENT | CNT_INSTALMENT_FUTURE | NAME_CONTRACT_STATUS | SK_DPD | SK_DPD_DEF |
|-|-|-|-|-|-|-|-|

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

Home Credit should focus on Working income type (rejected 748, 49% of rejected cases), Married couples (approved 2/3 of cases), Secondary/High school education (73% of approved cases) background of applicants as the first priority & the main customer target. Secondary customer targets should be Commercial Associates, Single/Not Married customers, High School.

## Hadoop

### Before I start, what is Hadoop?

Hadoop is an open source software platform for scalable, distributed computing. It provides fast and reliable analysis of both structured data and unstructured data. Apache Hadoop software library is essentially a framework that  allows for the distributed processing of large datasets across  clusters of computers using a simple programming model. Hadoop can scale up from single servers to thousands of  machines, each offering local computation and storage.

Hadoop Ecosystem Projects includes components as below. However, I will use only HBase, HDFS, Hive, Zeppelin to conduct ETL, analysis and visualization.

- Hadoop Common utilities

- Avro: A data serialization system with scripting languages.

- Chukwa: managing large distributed systems.

- HBase: A scalable, distributed database for large tables.

- HDFS: A distributed file system that provides high-throughput access to application data. It uses a master/slave architecture in which one device  (master) termed as NameNode controls one or more other devices (slaves) termed as DataNode. It breaks Data/Files into small blocks (128 MB each block) and  stores on DataNode and each block replicates on other nodes to  accomplish fault tolerance. NameNode keeps the track of blocks written to the DataNode. There are Assumptions and Goals of HDFS:

	+ Hardware Failure

	+ Streaming Data Access (Best for batch processing)

	+ Large Data Sets

	+ Simple Coherency Model (write-once-read-many access model)

	+ Portability Across Heterogeneous Hardware and Software Platforms

- Hive: data summarization and ad hoc querying.

- MapReduce: A distributed processing on compute clusters. In other words, it is a software framework for distributed processing of large data sets. The framework takes care of scheduling tasks, monitoring them  and re-executing any failed tasks. It splits the input data set into independent chunks that are  processed in a completely parallel manner. MapReduce framework sorts the outputs of the maps, which are  then input to the reduce tasks. Typically, both the input and the  output of the job are stored in a file system.

- Zeppelin: a web-based notebook for data ingestion, exploration, visualization, sharing collaborative features of Hadoop ecosystem. It has a concept called “interpreter”, a language backend that enables various data sources to be plugged into Zeppelin.

- Pig: A high-level data-flow language for parallel computation.

- ZooKeeper: coordination service for distributed applications.


## Hive 

### Creating Hive external & external tables for application & previous application datasets

I have created hive external and internal tables for our application and previous application dataset. I named them as application_external & application_orc and p_application_external and p_application_orc.

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

### Printing schema
```
%spark2
// Print the schema in a tree format
records.printSchema()
```

### Grouping the data by income type

I can show the cout of income_type by using Spark. the GROUP BY income_type command can help to draw the values in the result.

The Working, Commerical associate & Pensioner working types plays a significant role in the distribution of loan applications while Unemployed type has very rare cases to apply for loan successfully.

```
%spark2.spark
val Results = records.groupBy("income_type").count()
Results.show()
```

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

### Loan Approval’s Bar chart by Income Type

For the cases of Approved , Working income_type dominated the largest portion with 1341 cases while commercial associate kept their position at the 2nd rank, pensioner and state servant still placed the 3rd and 4th.

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

Married customers played the most crucial in cases of application getting approval for loan by ⅔ of cases (1733 cases). The second highest family status was single/not married but consisted of only 311 cases.

### Loan application by family status

Married people applied more loans than any other groups of family status with 2,772 cases which is more than 5-fold of the second highest Single / Not married applications. 

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

## Visualizing charts in Tableau & Power BI:

### Living Background of Loan Applicants by Gender

Among loan applicants by Gender, the result shows a tendency that Female applicants seem to have more demand to apply for loans than Male. More specifically, female applicants having house / aprtment contribute nearly 3K of applications, roughly 2-fold the ones submitted by Male also having house / aprtment. Other types of applications living with parents, municial aprtmetn, rented aprtment, office aprtment oversee a much lower applications by approximately 95% but Female applicants also seem to dominate the submission with 1.5 or 2-fold number of those by Male.

![Living Background of Loan Applicants by Gender](https://user-images.githubusercontent.com/70437668/138408668-5839b767-c253-4a87-82b6-a42df5cdcf1c.jpg)

![Living Background of Loan Applicants by Gender](https://user-images.githubusercontent.com/70437668/140484418-f6c9110a-6d4a-42a6-ad6b-902468625552.jpg)

### Loan Applications by Family Status

Married applicants play the most significant role in submission for loans. They seem to need more financial plan support for marriage life together. In contrast, other types, especially people without marriage due to different factors and reasons might not care for financial loans for themselves or for a life with other significant others. This is why Married ones distribute up to 2.8K of applications (roughly 65.3%), which is more than 5-fold the Single/Not Married (12.23%), 6.5-fold the Civil Marriage (10.01%), 9-fold the Widow (7.21%) and 12.5-fold the Separated (5.23%).

![Loan applications by family status](https://user-images.githubusercontent.com/70437668/138408685-c430d66f-4182-4076-91e0-90955be465b6.jpg)

![Loan applications by family status](https://user-images.githubusercontent.com/70437668/140484455-8d67093e-6b2e-4306-a7dd-1b6f1483e86f.jpg)

### Percentage of Loan Applications by Family Status 

(same conclusion as above)

![Percentage of loan applications by family status ](https://user-images.githubusercontent.com/70437668/138408705-77485972-7369-415a-a32e-6c7c4116874b.jpg)

![Percentage of loan applications by family status](https://user-images.githubusercontent.com/70437668/140484469-9973d556-4778-4a69-95fe-c3abb1e79678.jpg)

### Contract Status by Income Type

Applicants with Working Contract Status tend to a a great demand for financial loans although they earn income from their contract. One reason might be that loan approval tend to prefer people with a confirmed working contract. So, those applicants have an existing demand for financial plans and loans to help them finance other costs paid monthly over the years, such as cars, condos, houses, etc. They distributes more than 50% of all contract types. Meanwhile, Commercial Associate have less than a half of applicants having working contract, which is about 24.2% of all types. Pensioners also have a decent demand for loans which contribute 18.4% while State Servants provide only 6.5%.

![Contract Status by Income Type](https://user-images.githubusercontent.com/70437668/138408514-01b4dc82-bf5f-49da-96ea-de562a40b4f4.jpg)

![Contract Status by Income Type](https://user-images.githubusercontent.com/70437668/140484484-699abc75-4449-4812-a244-2c673583a2bd.jpg)

### Education type of applicants who got the most loan approvals

Secondary / Secondary Special Education Type dominated the distribution of loan applicants' educational background by 72.75%. Meanwhile, Higher education consisted of the second-ranked type by 23.15%. However, Income Higher, Lower Secondary and Academic Degree are the least significant and they comprised only roughly 4.1% of the whole distribution.

![Education type of applicants who got the most loan approvals](https://user-images.githubusercontent.com/70437668/138408564-c312b289-2db8-46ba-b34f-4406b875715f.jpg)

![Education type of applicants who got the most loan approvals](https://user-images.githubusercontent.com/70437668/140484503-84ec3124-da24-4599-9ddf-337f95121f85.jpg)

### Income Sources of Loan Applicants

![Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/138408604-69600898-47aa-4b6c-aba2-548cd4a4f63f.jpg)

![Income Sources of Loan Applicants](https://user-images.githubusercontent.com/70437668/140484514-5dca47af-c41b-4bfe-a33d-a719c5b9eafa.jpg)

### Loan Purposes of applicants who got the most loan rejection

Working type XNA exercised control over the Income Sources by roughly 64.58% of the total applicants whose contract status was canceled or refused. This was much higher than any other sources such as XAP accounting for 28.56%, and other much less prevalent types such as Repairs accounting for 2.56%, etc.

![Income type of applications who got the most loan rejection](https://user-images.githubusercontent.com/70437668/138408628-2bb8d7c0-b2bf-4f83-a2d4-703787f6a05d.jpg)

![Income type of applications who got the most loan rejection](https://user-images.githubusercontent.com/70437668/140484524-5cd7fb2c-e73b-40c7-beb9-5bf3e1f944a5.jpg)

### Average Income by Income Type

In the Approved cases, it shows quite a difference from the descending order of Working types. Commercial led the distribution of applications with nearly $200K on average. State servants reached more than $178K on average but didn't have a great number of approved loans. This might be because their income sources are not clear enough to comply with loan requirements. Meanwhile the most approved Income Type was Working but its average income was roughly $164K. A reason which helped them to take the lead might be that their income sources are reliable with legal working contracts. Next, Pensioner also had an adequate average income of around $128K. This type could also be targeted for potential cases for approval if Home Credit Group's loan team can review cases of this type thoroughly to look for more potential and reliable applicants.


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




