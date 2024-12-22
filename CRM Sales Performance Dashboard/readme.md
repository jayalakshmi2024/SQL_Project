### CRM Sales Dashboard
##### Project Summary
Maven Analytic is a company that specializes in selling computer hardware to large businesses. They have just started using a new CRM system to track  their sales opportunities but have no visibility of the data outside the platform. To combat this, an interactive dashboard was built that enables the sales managers to track their team’s performance. Our goal is to track the Sales performance by each sales team and the total products sold quarterly.
This project uses synthetically generated data for analysis from an open source called Synthea. Synthea is an open-source, synthetic patient generator that models the medical history of synthetic patients. Imported the csv files into PostgreSQL. And the size of the dataset was approximately 400000 records for each table. It consists of the patients, immunizations, condition and encounters details.

##### Dataset
The dataset consists of 4 csv files the includes account, product, sales team and sales pipelines details. The dataset contains close to 10,000 records and 10 fields. Imported all the csv files, transformed and loaded into PowerBI desktop. Account table consists of company, sector, year established etc. Product consists of a list of products that are sold. The sales team and sales pipelines consist of managers, sales agents, region, sales closed, stages, close date etc.

##### Studying the Dataset

It is observed that under account details we have 85 accounts to which the sales have been closed and there are 7 distinct products that are sold. The data shows that there are 35 distinct sales agents under 6 distinct managers in 3 different regions. The total number of null values, blanks, empty and duplicate values have also been studied.

##### Data Cleaning and transformation

Once the data has been imported into PowerBI, basic cleaning operations to change the datatype, rename any columns, delete or replace null records, extract the required field have been done. Added extra columns to extract quarterly fiscal year and then use it for later analysis.

##### Creating Measures using DAX Formulas

Created measures to calculate quarterly sales, quarterly product count using DAX formulas in PowerBI from the existing data which are needed to create specific metrics relevant to the business questions. Separate measures have also been created to calculate the number of deals in won, lost, engaging and prospecting stage.

##### Data Visualization:

