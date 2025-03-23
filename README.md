# Small Business Credit Analysis

This repository contains analysis related to small business credit assessments using SAS and Excel data. The project includes data files for KPI reports, card monthly reports, and an analysis script in SAS.

## Directory Structure

small-business-credit-analysis/ 
Output_summary_appropriateness_report
├── data/ 
│ ├── SB_Card_Monthly_Report_Dummy_Data.xlsx 
│ ├── Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx 
├── scripts/ 
│ ├── Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas
│ ├── SB_Card_Monthly_Report_Dummy_Data.sas 
├── README.md
├── LICENSE 

├── .gitignore



### `data/`
- **SB_Card_Monthly_Report_Dummy_Data.xlsx**: Contains dummy data for the Small Business Card monthly report.
- **Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx**: Contains dummy data for the appropriateness weekly KPI report.

### `scripts/`
- **Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas**: A SAS script used to analyze the data, including steps to import, process, and generate reports.
- **SB_Card_Monthly_Report_Dummy_Data.sas**: A SAS script used to idnetify issues with the existing data and provide solution to missing, incorrect data, data formatting and final report

### Output_summary_appropriateness_report 
- Interpretation of output for the following question below
 Our business partners have approached us with a request to build a report, measuring the operational health of a new process that was recently launched to meet regulatory requirements. The process requires frontline employees to have Appropriateness conversations with each customer, ensuring the customer’s financial needs are considered when recommending a suitable product. Completion of this process is evidenced through the completion of Appropriateness notes in our front-end system. The corresponding data is then generated and fed downstream to databases that our team has access to.

The workbook attached (Appropriateness Weekly KPI Report Dummy Data) contains three sets of data: Sales, Notes, and Regions. Using these datasets and analytics tools available to you, please create a report that captures completion volumes and rates (number and percentage of sales with Appropriateness notes):
a.	Across eligible transaction types (new account, new credit card, new term purchase)
b.	Across select regions (Greater Toronto, BC & Yukon, Atlantic Provinces)
c.	On a weekly basis (Friday to Thursday cycle)
d.	On an aggregated basis (since inception)

If you observe any potential issues during development or QA, please evaluate its materiality and provide a rationalization to the best of your ability. Prepare a high-level summary of key trends and findings for our business partners. Please share a copy of the SAS/SQL code you wrote to support this analysis.



## How to Use

1. Clone this project to your computer:
   ```bash
   git clone https://github.com/yourusername/small-business-credit-analysis.git

2. Navigate to the scripts/ folder:

    cd small-business-credit-analysis/scripts/

3. Open and run
    Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas script in your SAS Studio software.
    SB_Card_Monthly_Report_Dummy_Data.sas script in your SAS Studio software.

