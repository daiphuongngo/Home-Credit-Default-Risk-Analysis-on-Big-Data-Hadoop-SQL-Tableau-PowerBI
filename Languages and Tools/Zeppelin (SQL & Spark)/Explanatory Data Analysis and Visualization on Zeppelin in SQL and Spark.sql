-- Explanatory Data Analysis and Visualization on Zeppelin in SQL and Spark

--Load data to Zeppelin:
%spark2
val ApplicationData = (spark.read
		.option("header", "true") -- Use first line as header
		.option("inferSchema", "true") -- Infer Schema
		.csv("/tmp/group/application.csv")

%spark2
val PreviousApplicationData = (spark.read
		.option("header", "true") -- Use first line as header
		.option("inferSchema", "true") -- Infer Schema
		.csv("/tmp/group/p_application/previous_application.csv")


--Print Schema:
%spark2
ApplicationData.printSchema()

%spark2
PreviousApplicationData.printSchema()


--Analysis:
--Select all columns from ApplicationData in Spark:
%spark2
ApplicationData.select("curr_id", "contract", "sex", "car", "income", "income_type", "education", "family_status", "house", "start_day", "organization").show()


/*Count all income types from the ApplicationData in Spark:
Working and Commercial associate applicants play significant roles in loan demand with 2,607 and 1,173 applications, respectively. Meanwhile, Pensioner and State servant have less applications with 902 and 315 applications, respectively but they can be targeted as potential customers.*/
%spark2.spark
val IncomeTypeResults = ApplicationData.groupby("income_type").count()
IncomeTypeResults.show()

--Visualizing the Income Types by Line chart:
%spark2.sql
SELECT * 
FROM IncomeTypeView;


--Create Temporary Views:
%spark2
ApplicationData.createOrReplaceTempView("ApplicationDataView")

%spark2
PreviousApplicationData.createOrReplaceTempView("PreviousApplicationDataView")

%spark2
IncomeTypeResults.createOrReplaceTempView("IncomeTypeView")


/*Show the ext_hbase_application filtered with Pensioner income_type on Zeppelin: 
House and apartment dominate the living background of loan applications. More specifically, Female applicants are nearly 4-fold the number of Male applicants when filtering the income type by Pensioner.*/
%jdbc(hive)
SELECT * 
FROM ext_hbase_application
WHERE income_type = ‘Pensioner’
ORDER BY income DESC;


/*Familly Status of Applicants who applied for a Loan (Bar chart):
Married people applied more loans, with 2,722 applications, than any other groups of family status. */
%spark2.sql
SELECT ApplicationDataView.family_status, COUNT(p_application_ORC.curr_id)
FROM p_application_ORC
JOIN ApplicationDataView
ON ApplicationDataView.curr_id = p_application_ORC.curr_id
GROUP BY ApplicationDataView.family_status
ORDER BY COUNT(p_application_ORC.curr_id) DESC;


/*Which income type of applicants got the most loan approvals? What was their average income in approved case?
Our table illustrates that Working people received the most loan approval by 1,341 (50.8 % of income type) while their average income ranked 3rd by nearly 165,000 (24.2%). 
Meanwhile, Commercial associate obtained the 2nd highest approvals for loan while their average income placed the highest by more than 195,000. 
Pensioner and State servant were among the lowest cases of approved applicants.
For the cases of Approved, Working income_type dominated the largest portion with 1341 cases while commercial associate kept their position at the 2nd rank, 
pensioner and state servant still placed the 3rd and 4th. */

%sparl2.sql
SELECT ApplicationDataView, COUNT(p_application_ORC.contract_status) AS Approved, AVG(ApplicationDataView.income) 
FROM p_application_ORC
JOIN ApplicationDataView 
ON ApplicationDataView.curr_id = p_application_ORC.curr_id
WHERE p_application_ORC.contract_status = "Approved"
GROUP BY ApplicationDataView.income_type
ORDER BY COUNT(p_application_ORC.contract_status) DESC;


/*Which income type got the most loan rejection? What was their average income in rejected case?
Working dominated this field with the highest case of rejected applicant for a loan (748) although their average income ranked 3rd by slightly more than 172 thousand of application who got rejected.
Commercial got the second highest case by 411 while taking the 1st place of average income by more than 206 thousand.
Pensioner and State servant were among the lowest cases of rejected applicants but State Servant (ranked last) obtained the 2nd highest average income by more than 196 thousand. */
%spark2.sql
SELECT ApplicationDataView, COUNT(p_application_ORC.contract_status) AS Approved, AVG(ApplicationDataView.income) 
FROM p_application_ORC
JOIN ApplicationDataView 
ON ApplicationDataView.curr_id = p_application_ORC.curr_id
WHERE p_application_ORC.contract_status = "Refused" OR p_application_ORC.contract_status = "Canceled"
GROUP BY ApplicationDataView.income_type
ORDER BY COUNT(p_application_ORC.contract_status) DESC;


/*Which Family Status got the most loan approval? 
Married couples took the majority of family status to be approved for a loan with 1,733 cases (66%).
Married customers played the most crucial in cases of application getting approval for loan by ⅔ of cases (1733 cases).
The second highest family status was single/not married but consisted of only 311 cases. */
%spark2.sql
SELECT ApplicationDataView.family_status, COUNT(p_application_ORC.curr_id) 
FROM p_application_ORC
JOIN ApplicationDataView
ON ApplicationDataView.curr_id = p_application_ORC.curr_id
WHERE p_application_ORC.contract_status = "Approved"
GROUP BY ApplicationDataView.family_status
ORDER BY COUNT(p_application_ORC.curr_id) DESC;


/* Which education type of applicants got the most loan approvals?
Looking at the education background of applicant group getting the most loan approvals, secondary/secondary special played the most significant role in this field 
with the highest count by 1917 (73 %). Meanwhile, higher education came at the 2nd place with 610 cases (23%). 
Incomplete higher and Lower Secondary contributed minor figures of 3% and 1%, respectively. 
Secondary/Secondary special took approximately ¾ of the pie chart. Educated applicants tends to get more loan approvals. */
%spark2.sql
SELECT ApplicationDataView.education, COUNT(p_application_ORC.curr_id) 
FROM p_application_ORC
JOIN ApplicationDataView.contract_status = "Approved"
GROUP BY ApplicationDataView.education
ORDER BY COUNT(p_application_ORC.curr_id) DESC;
