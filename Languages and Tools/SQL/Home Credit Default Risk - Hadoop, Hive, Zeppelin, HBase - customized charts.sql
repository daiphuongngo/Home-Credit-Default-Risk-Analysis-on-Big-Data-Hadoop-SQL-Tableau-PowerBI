-- Customized datasets:

--- application.csv: (Application dataset)

| prev_id | curr_id | contract | amount | credit | down_payment | start_day | purpose | contract_status | payment_type | reject_reason | client | product_type | channel | yield_group | 
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|


---- p_application.csv: (Previous Application dataset)

| curr_id	| contract | sex | car | income | credit | income_type | education | family_status | house | start_day | organization | 
|-|-|-|-|-|-|-|-|-|-|-|-|

-- Hive

--- Creating Hive external & external tables for application & previous application datasets

CREATE EXTERNAL TABLE IF NOT EXISTS p_application_external(prev_id int, curr_id int, contract string, amount float, credit float, down_payment float, start_day, purpose string, contract_status string, payment_type string, reject_reason string, client string, product_type string, channel string, yield_group string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION /tmp/group/p_application

CREATE TABLE IF NOT EXISTS p_application_ORC (prev_id int, curr_id int, contract string, amount int, credit int, income_type string, education string, family_status string, house string, start_day string, organization string)

--- Loading the data from external table to internal table for both application and p_application data sets

INSERT INTO TABLE p_application_orc 
SELECT *
FROM p_application_external;

INSERT INTO TABLE application_orc 
SELECT *
FROM application_external;

--- Printing out the created tables

SELECT *
FROM application_external
LIMIT 10;

SELECT *
FROM application_ORC
LIMIT 10;


-- HBase
```
sandbox-hdp login: root
root@sandbox-hdp.hortonworks.com's password: ...
[root@sandbox-hdp ~]# hbase shell
hbase(main):001:0> application
hbase(main):002:0> list
```
---- Output
```
=> ["ATLAS_ENTITY_AUDIT_EVENTS", "Product", "application", "atlas_titan"]
```

-- Hive (again)

--- Creating external tables for HBase
```
CREATE EXTERNAL TABLE ext_hbase_application (curr_id int, contract string, sex string, car string, income float, credit float, income_type float, education, family_status, house, start_day, organization string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key, details: contract, details: sex, details: car, details: income, details: credit, details: income_type, details: education, details: family_status, details: house, details: start_day, details: organization)
TBLPROPERTIES('hbase.table.name' = 'application', 'hbase.mapred.output.outputtable' = 'application')
```

-- Zeppelin

--- Retrieve data from the external HBase application table

%jdbc(hive)
SELECT *
FROM ext_hbase_application
WHERE income_type='Pensioner'
ORDER BY income DESC;

---- The top 5 Pensioner income types with the highest income have contracts of Cash loans and Revolving loans and Female applicants without Car dominate the loan applications. 
 
--- Creating dataframes and loading the data from HDFS

```
%spark2
// Create an application Dataframe from CSV file
Val records = (spark.read
	.option("header", "true") // Use the first line as header
	.option("inferSchma", "true") // Infer schema
	.csv("/tmp/group/application/application.csv"))
```

Output
```
records: org.apache.spark.sql.DataFrame = [curr_id: int, contract: string ... 10 more fields]
```

```
%spark2
records.select("curr_id", "contract", "sex", "car", "income", "credit", "income_type", "education", "family_status", "house", "start_day", "organization").show()
```

--- Printing schema
```
%spark2
// Print the schema in a tree format
records.printSchema()
```

--- Grouping the data by income type
/* We can show the cout of income_type by using Spark. the GROUP BY income_type command can help to draw the values in the result.
The Working, Commerical associate & Pensioner working types plays a significant role in the distribution of loan applications while Unemployed type has very rare cases to apply for loan successfully.
*/
```
%spark2.spark
val Results = records.groupBy("income_type").count()
Results.show()
```

--- Creating tempview tables

---- Creating temporary tables can help to run SQL queries from required tables and then visualize requested figures.

```
%spark2
records.createOrReplaceTempView("Recordsview")
```

```
%spark2
Results.createOrReplaceTempView("Incometypeview")
```
/*The result generated with spark2.sql from the temporary table of Income type shows the same output as the one with spark.*/

--- Which income type of applicants who got approval for a loan?

---- Our table illustrates that Working people received the most loan approval by 1341 ( 50.8 % of income type) while their average income ranked 3rd by near 165 thousand (24.2%). Meanwhile, Commercial associate obtained the 2nd highest approvals for loan while their average income placed the highest by more than 195 thousand. Pensioner and State servant were among the lowest cases of approved applicants.

```
%spark2.sql
```
SELECT Recordsview.income_type, COUNT(p_application_orc.contract_status) AS approved, AVG(Recordsview.income) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.income_type
ORDER BY COUNT(p_application_orc.contract_status) DESC

--- Loan Approval’s Bar chart by Income Type

---- For the cases of Approved , Working income_type dominated the largest portion with 1341 cases while commercial associate kept their position at the 2nd rank, pensioner and state servant still placed the 3rd and 4th.

--- Which income type of applicants who got rejected for a loan?

/*Working dominated this field with the highest case of rejected applicant for a loan (748) although their average income ranked 3rd by slightly more than 172 thousand of application who got rejected.

Commercial got the second highest case by 411 while taking the 1st place of average income by more than 206 thousand.
Pensioner and State servant were among the lowest cases of rejected applicants but State Servant (ranked last) obtained the 2nd highest average income by more than 196 thousand.*/

```
%spark2.sql
```
SELECT Recordsview.income_type, COUNT(p_application_orc.contract_status) AS approved, AVG(Recordsview.income) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Refused" OR p_application_orc.contract_status = "Canceled"
GROUP BY Recordsview.income_type
ORDER BY COUNT(p_application_orc.contract_status) DESC

/*This is a pie chart we had visualized so you can see the working type dominates roughly half of the applicant with income type rejected for a loan.*/

--- Which Family Status got the most loan approval?

---- Married couples took the majority of family status to be approved for a loan with 1733 cases. This is visualized this on a pie chart below.
```
%spark2.sql
```
SELECT Recordsview.family_status, COUNT(p_application_orc.curr_id) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.family_status
ORDER BY COUNT(p_application_orc.curr_id) DESC

/*Married customers played the most crucial in cases of application getting approval for loan by ⅔ of cases (1733 cases).
The second highest family status was single/not married but consisted of only 311 cases.*/

--- Loan application by family status

---- Married people applied more loans than any other groups of family status with 2,772 cases which is more than 5-fold of the second highest Single / Not married applications. 

--- Which education type of applicants got the most loan approvals?

---- Looking at the education background of applicant group getting the most loan approvals, secondary/secondary special played the most significant role in this field with the highest count by 1917 (73 %). Meanwhile, higher education came at the 2nd place with 610 cases (23%). Incomplete higher and Lower Secondary contributed minor figures of 3% and 1%, respectively.

```
%spark2.sql
```
SELECT Recordsview.education, COUNT(p_application_orc.curr_id) 
FROM p_application_orc
JOIN Recordsview ON Recordsview.curr_id = p_application_orc.curr_id
WHERE p_application_orc.contract_status = "Approved"
GROUP BY Recordsview.education
ORDER BY COUNT(p_application_orc.curr_id) DESC