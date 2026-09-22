SELECT * FROM layoffs_data;

SELECT * ,
ROW_NUMBER() OVER(PARTITION BY Company,Location_HQ,Laid_Off_Count,Layoff_date,Funds_Raised,Stage,Date_Added,Country,Percentage) AS dup_row
FROM layoffs_data;

-- FINDING DUPLICATE COLUMNS
SELECT * 
FROM (
	SELECT * ,
	ROW_NUMBER() OVER(PARTITION BY Company,Location_HQ,Laid_Off_Count,Layoff_date,Funds_Raised,Stage,Date_Added,Country,Percentage) AS dup_row
	FROM layoffs_data
) t
WHERE t.dup_row > 1 ;

-- COUNTING THE APPEARANCE OF EACH COMPANY 
SELECT Company,
COUNT(Company) appearances
FROM layoffs_data
GROUP BY Company
ORDER BY appearances DESC;

-- TOP 5 COMPANIES WITH THE MOST LAYOFF
SELECT Company,
COUNT(Company) number_of_layoff
FROM layoffs_data
GROUP BY Company
ORDER BY number_of_layoff DESC
LIMIT 5;

-- COMPANIES THAT APPEARS MORE THAN 5 FROM HIGHEST TO LOWEST
SELECT Company,
COUNT(Company) appearances
FROM layoffs_data
GROUP BY Company
HAVING appearances > 5
ORDER BY appearances DESC;

-- COMPANIES THAT APPEARS MORE THAN 5 FROM HIGHEST TO LOWEST WITH ALL THE COLUMNS
SELECT * 
FROM (
	SELECT *,
	COUNT(Company) OVER(PARTITION BY Company) AS appearances
	FROM layoffs_data
) t
WHERE t.appearances > 5;

-- RENAMING A DATE COLUMN TO LAYOFF DATE
ALTER TABLE layoffs_data
RENAME COLUMN `Date` TO `Layoff_date`;

SELECT * FROM layoffs_data;

-- REPLACING - WITH / IN DATE
UPDATE layoffs_data
SET `layoff_date` = REPLACE(`layoff_date`,"-","/");

-- CHECKING AND SEARCHING FOR DIFFERENT DATE FORMAT
SELECT layoff_date,
CASE 
WHEN layoff_date LIKE '%/%/%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
	THEN DATE_FORMAT(STR_TO_DATE(layoff_date,'%m/%d/%Y'),'%Y-%m-%d')
    
WHEN layoff_date LIKE '%-%-%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
	THEN DATE_FORMAT(STR_TO_DATE(layoff_date,'%d-%m-%Y'),'%Y-%m-%d')
    
WHEN layoff_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
	THEN layoff_date
END cleanDate
FROM layoffs_data;

-- UPDATE DATE FORMAT TO MYSQL STANDARD
UPDATE layoffs_data
SET layoff_date = (
	CASE 
WHEN layoff_date LIKE '%/%/%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
	THEN DATE_FORMAT(STR_TO_DATE(layoff_date,'%m/%d/%Y'),'%Y-%m-%d')
    
WHEN layoff_date LIKE '%-%-%' AND layoff_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
	THEN DATE_FORMAT(STR_TO_DATE(layoff_date,'%d-%m-%Y'),'%Y-%m-%d')
    
WHEN layoff_date REGEXP '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
	THEN layoff_date
END
);

SELECT * FROM layoffs_data;

-- CHANGE THE DATA TYPE TO DATE 
ALTER TABLE layoffs_data
MODIFY COLUMN Layoff_date DATE;

-- SINCE WHEN DID EACH COMPANY LAYOFF START FROM TODAY
SELECT *,
DATEDIFF(CURDATE(),Layoff_date) AS days_ago
FROM layoffs_data;

SELECT *,
DATE_SUB(Layoff_date, INTERVAL 1 YEAR) 
FROM layoffs_data;

-- SHOW THE COMPANIES THAT LAYOFF IN THE LAST 30 DAYS
SELECT *
FROM layoffs_data
WHERE layoff_date = YEAR(DATE_SUB(Layoff_date, INTERVAL 1 YEAR))






