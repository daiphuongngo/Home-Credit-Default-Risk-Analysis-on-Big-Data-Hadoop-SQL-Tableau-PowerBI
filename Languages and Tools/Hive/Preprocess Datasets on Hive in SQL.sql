--Preprocess the datasets on HIVE:

--1.	Load sales data
/* First load application.csv & p_application.csv files into Hadoop directory: /tmp/group & p_application.csv files into Hadoop directory: /tmp/group/p_application */

--2.	then create HIVE external tables and load the csv files  
--application.csv
CREATE EXTERNAL TABLE IF NOT EXISTS application _external (curr_id STRING, contract STRING, sex STRING, car STRING, income INT, credit DOUBLE, income_type STRING, education STRING, family_status STRING, house STRING, start_day STRING, organization STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/group’;
--p_application.csv
CREATE EXTERNAL TABLE IF NOT EXISTS p_application _external (prev_id INT, curr_id INT, contract STRING,  amount DOUBLE, credit DOUBLE, down_payment DOUBLE, start_day STRING, purpose STRING, contract_status STRING, payment_type STRING, reject_reason STRING, client STRING, product_type STRING, channel STRING, yield_group STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/group/p_application’;

--3.	Then create HIVE internal tables for both CSV files
--application
CREATE TABLE IF NOT EXISTS application _ORC (curr_id INT, contract STRING, sex STRING, car STRING, income INT, credit DOUBLE, income_type STRING, education STRING, family_status STRING, house STRING, start_day STRING, organization STRING)   
STORED AS ORC;

--p_application
CREATE TABLE IF NOT EXISTS p_application _ORC (prev_id INT, curr_id INT, contract STRING,  amount DOUBLE, credit DOUBLE, down_payment DOUBLE, start_day STRING, purpose STRING, contract_status STRING, payment_type STRING, reject_reason STRING, client STRING, product_type STRING, channel STRING, yield_group STRING)
STORED AS ORC;

--4.	Then load data from external to internal ORC 
INSERT INTO TABLE application_ORC SELECT * FROM application_external;  

INSERT INTO TABLE p_application_ORC SELECT * FROM p_application_external;  

--5.	select from tables to see the data  - screen print results 
SELECT * FROM application_external
LIMIT 10;

SELECT * FROM application_ORC
LIMIT 10;

--6.	login to Hbase and create HBase tables
create table 'Application', 'application_details';

create table 'PreviousApplication', 'p_application_details';

--7.	Create tables in HIVE that maps directly to the HBase tables 
--application
CREATE EXTERNAL TABLE ext_hbase_application (curr_id STRING, contract STRING, sex STRING, car STRING, income INT, credit DOUBLE, income_type STRING, education STRING, 
                                             family_status STRING, house STRING, start_day STRING, organization STRING)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' 
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key, application_details: contract, application_details: sex, application_details: car, application_details: income, 
                    application_details: credit, application_details: income_type, application_details: education, application_details: family_status, application_details: house, 
                    application_details: start_day, application_details: organization")
TBLPROPERTIES("hbase.table.name" = "Application","hbase.mapred.output.outputtable" = "Application");

--p_application
CREATE EXTERNAL TABLE ext_hbase_p_application (prev_id INT, curr_id INT, contract STRING, amount DOUBLE, credit DOUBLE, down_payment DOUBLE, start_day STRING, purpose STRING, 
                                             contract_status STRING, payment_type STRING, reject_reason STRING, client STRING, product_type STRING, channel STRING, yield_group STRING)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' 
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key, p_application_details: prev_id, p_application_details: contract, p_application_details: amount, p_application_details: credit, 
                    p_application_details: down_payment, p_application_details: start_day, p_application_details: purpose, p_application_details: contract_status, 
                    p_application_details: payment_type, p_application_details: reject_reason, p_application_details: client, p_application_details: product_type, 
                    p_application_details: channel, p_application_details: yield_group")
TBLPROPERTIES("hbase.table.name" = "PreviousApplication","hbase.mapred.output.outputtable" = "PreviousApplication");

--8.	From hive we insert records into HBase table
INSERT INTO TABLE ext_hbase_application
SELECT * 
FROM application_ORC;

INSERT INTO TABLE ext_hbase_p_application
SELECT * 
FROM p_application_ORC;
