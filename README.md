# 📊 Company Layoffs — SQL Data Cleaning & Exploratory Data Analysis

## 📌 Overview
This project cleans and analyzes a dataset of global company layoffs using **MySQL**. It covers duplicate detection, standardizing inconsistent date formats, and exploratory analysis to find which companies laid off the most employees and when.

- **Tool used:** MySQL Workbench
- **Schema:** `employees_layoff`
- **Table:** `layoffs_data`
- **Columns:** `Company`, `Location_HQ`, `Industry`, `Laid_Off_Count`, `Layoff_date`, `Funds_Raised`, `Stage`, `Date_Added`, `Country`, `Percentage`

  
---

## 🎯 Objectives
- Identify and inspect duplicate records in the dataset
- Standardize inconsistent date formats and correct the column data type
- Find which companies had the most layoffs, and how frequently they appear in the data
- Analyze layoffs by recency (days since layoff, layoffs within the last 30 days)

---

## 🧹 Part 1: Data Cleaning

### 1. Finding Duplicate Rows
Used `ROW_NUMBER()` partitioned across every column to flag exact duplicates.
```sql
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY Company, Location_HQ, Laid_Off_Count, Layoff_date,
                 Funds_Raised, Stage, Date_Added, Country, Percentage
) AS dup_row
FROM layoffs_data;

-- FINDING DUPLICATE ROWS
SELECT *
FROM (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY Company, Location_HQ, Laid_Off_Count, Layoff_date,
                     Funds_Raised, Stage, Date_Added, Country, Percentage
    ) AS dup_row
    FROM layoffs_data
) t
WHERE t.dup_row > 1;
```
![Finding duplicate rows](screenshots/01_find_duplicates.png)

---

### 2. Fixing Inconsistent Date Formats
The `Layoff_date` column contained mixed formats (`MM/DD/YYYY`, `DD-MM-YYYY`, `YYYY/MM/DD`). A `CASE` + `REGEXP` check was used to detect the format of each row before standardizing it.
```sql
-- CHECKING AND SEARCHING FOR DIFFERENT DATE FORMATS
SELECT layoff_date,
CASE
    WHEN layoff_date LIKE '%/%/%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
        THEN DATE_FORMAT(STR_TO_DATE(layoff_date, '%m/%d/%Y'), '%Y-%m-%d')

    WHEN layoff_date LIKE '%-%-%' AND layoff_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
        THEN DATE_FORMAT(STR_TO_DATE(layoff_date, '%d-%m-%Y'), '%Y-%m-%d')

    WHEN layoff_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
        THEN layoff_date
END cleanDate
FROM layoffs_data;
```
![Checking date formats](screenshots/06_date_format_check.png)

Once verified, the same `CASE` logic was applied in an `UPDATE` statement, and the column was converted from text to a proper `DATE` type.
```sql
-- UPDATE DATE FORMAT TO MYSQL STANDARD
UPDATE layoffs_data
SET layoff_date = (
    CASE
        WHEN layoff_date LIKE '%/%/%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN DATE_FORMAT(STR_TO_DATE(layoff_date, '%m/%d/%Y'), '%Y-%m-%d')

        WHEN layoff_date LIKE '%-%-%' AND layoff_date REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
            THEN DATE_FORMAT(STR_TO_DATE(layoff_date, '%d-%m-%Y'), '%Y-%m-%d')

        WHEN layoff_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
            THEN layoff_date
    END
);

-- CHANGE THE DATA TYPE TO DATE
ALTER TABLE layoffs_data
MODIFY COLUMN Layoff_date DATE;
```
![Updating date format and column type](screenshots/07_update_date_alter_type.png)

---

### 3. Renaming a Column
The original `Date` column was renamed to `Layoff_date` for clarity.
```sql
-- RENAMING A DATE COLUMN TO LAYOFF DATE
ALTER TABLE layoffs_data
RENAME COLUMN `Date` TO `Layoff_date`;
```
![Renaming the date column](screenshots/05_rename_column.png)

---

## 🔍 Part 2: Exploratory Data Analysis

### 4. Counting Layoff Appearances per Company
```sql
-- COUNTING THE APPEARANCE OF EACH COMPANY
SELECT Company,
       COUNT(Company) appearances
FROM layoffs_data
GROUP BY Company
ORDER BY appearances DESC;
```
![Company appearance counts](screenshots/02_company_appearances.png)

---

### 5. Top 5 Companies With the Most Layoffs
```sql
-- TOP 5 COMPANIES WITH THE MOST LAYOFF
SELECT Company,
       COUNT(Company) number_of_layoff
FROM layoffs_data
GROUP BY Company
ORDER BY number_of_layoff DESC
LIMIT 5;
```
![Top 5 companies by layoff count](screenshots/03_top5_companies.png)

**Result:** Amazon and Google tied for the most layoff records (12 each), followed by Rivian (8), Microsoft (7), and Better.com (6).

---

### 6. Companies Appearing More Than 5 Times
```sql
-- COMPANIES THAT APPEAR MORE THAN 5 TIMES, HIGHEST TO LOWEST
SELECT Company,
       COUNT(Company) appearances
FROM layoffs_data
GROUP BY Company
HAVING appearances > 5
ORDER BY appearances DESC;
```
![Companies with more than 5 appearances](screenshots/04_companies_over5.png)

The same result was also pulled with every column retained, using a window function instead of `GROUP BY`:
```sql
-- SAME RESULT, WITH ALL COLUMNS, USING A WINDOW FUNCTION
SELECT *
FROM (
    SELECT *,
    COUNT(Company) OVER(PARTITION BY Company) AS appearances
    FROM layoffs_data
) t
WHERE t.appearances > 5;
```

---

### 7. Days Since Each Layoff & Recent Layoffs
```sql
-- SINCE WHEN DID EACH COMPANY LAYOFF START, FROM TODAY
SELECT *,
       DATEDIFF(CURDATE(), Layoff_date) AS days_ago
FROM layoffs_data;

-- SHOW COMPANIES THAT LAID OFF STAFF IN THE LAST 30 DAYS
SELECT *
FROM layoffs_data
WHERE Layoff_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
```
![Days ago and last-30-days layoffs](screenshots/08_days_ago_last30days.png)

---

## 📈 Key Insights
- Amazon and Google appear most frequently in the dataset (12 layoff events each), indicating repeated rounds of layoffs rather than a single event.
- Several rows were exact duplicates and were identified using `ROW_NUMBER()` before being removed/reviewed.
- The raw date data arrived in at least three different formats, which required regex pattern matching to safely standardize before converting the column to a native `DATE` type.

---

## 🛠️ Skills Demonstrated
- Window functions (`ROW_NUMBER()`, `COUNT() OVER(PARTITION BY ...)`)
- Duplicate detection with derived subqueries
- Data cleaning with `CASE`, `REGEXP`, `STR_TO_DATE`, and `DATE_FORMAT`
- Schema changes: `ALTER TABLE`, `RENAME COLUMN`, `MODIFY COLUMN`
- Date arithmetic: `DATEDIFF`, `DATE_SUB`, `CURDATE`
- Aggregation and filtering: `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`

---

## 🚀 How to Use This Repo
1. Clone the repo:
2. Import the `layoffs_data` dataset into MySQL Workbench under the `employees_layoff` schema.
3. Run the scripts from the `queries/` folder in order (cleaning first, then EDA).
4. Compare your output with the corresponding screenshot in `screenshots/`.

---

## 📬 Contact
**Usama Abdullahi Sani**
- LinkedIn: www.linkedin.com/in/usama-abdullahi-sani-60a2b6248
- Email:usamasaniabdullahi814@gmail.com
