# maven-toys-sql-data-analysis

This project is aimed at performing SQL-based data analysis on a dataset containing various details about toys, stores, sales, inventory, and more. The analysis focuses on multiple aspects such as product sales, inventory, seasonal trends, and store performance.

## Project Overview  
The main goals of this project are:  
1. **Database Setup and Schema Creation**:  
   - Created a schema named `maven_toys` to store and organize the dataset.  
2. **Data Cleaning**:  
   - Cleaned and formatted columns in tables (e.g., removing dollar signs, date formatting).  
3. **Data Analysis**:  
   - Performed multiple SQL queries to derive insights such as top-performing stores, seasonal trends, and product profitability.

## Dataset Description  
The dataset for this project was obtained from Maven Analytics' Data Playground page. The dataset contains multiple tables with relevant information for data analysis, including sales, inventory, product details, and store information. It includes the following tables:

- **calendar**: Contains date information.  
- **data_dict**: Describes the fields and tables in the dataset.  
- **inventory**: Contains inventory details for products across various stores.  
- **product**: Contains details about products such as name, category, cost, and price.  
- **sales**: Contains sales data including product sales, units sold, and store IDs.  
- **stores**: Contains information about stores including their location, name, and opening date.  

## Tools Used  
- **PostgreSQL**:  
  The project is implemented in PostgreSQL, where all the data cleaning and analysis was done using SQL queries.  

## Skills Practiced  
- **Data Cleaning**: Formatting and cleaning raw data for analysis.  
- **SQL Queries**: Writing complex SQL queries to perform data analysis.  
- **Database Management**: Setting up a schema and managing tables in a relational database.  

## Acknowledgments  
The dataset was obtained from 👉 Maven Analytics' [Data Playground](https://mavenanalytics.io/data-playground?dataStructure=Multiple%20tables&order=number_of_records%2Cdesc&page=1&pageSize=5). You can explore other datasets on their platform for further analysis.

