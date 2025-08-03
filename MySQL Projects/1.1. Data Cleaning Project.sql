-- DATA CLEANING PROJECT - fixing numerous issues with your data so that it can be used for visualization or projects


# creating database
DROP DATABASE IF EXISTS `tech_layoffs_data`;
CREATE DATABASE `tech_layoffs_data`;
USE `tech_layoffs_data`;


# creating header for our table
CREATE TABLE layoffs (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
);

# running the table with the header and/or with the data
SELECT *
FROM layoffs
;

# turning on local infile to allow the use of csv file
show global variables like 'local_infile';
set global local_infile=true;

# mysql copy csv file data with the table header we created
LOAD DATA LOCAL INFILE "#CSV FILE COPY LOCAL PATH" INTO TABLE layoffs
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;


SELECT *
FROM layoffs;


-- DATA CLEANING PROJECT - fixing numerous issues with your data so that it can be used for visualization or projects 
-- staging or step-by-step process
-- 0. Create a staging table to utilize the procedure while not touching the original/raw data
-- 1. Remove Duplicates
-- 2. Standardize the Data - example is for incorrect spelling
-- 3. Check for NULL or blank values
-- 4. Remove any columns or rows with no data
-- ------------------------


-- 0. Create a staging table to utilize the procedure while not touching the original/raw data
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- 1. Remove Duplicates

-- a. identify unique and duplicate data, using 1 for unique and 2 for duplicate
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

-- b. generating a CTE for checking the duplicate data
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- c. MySQL differs from other databases because it lacks a designated/unique row/column number
-- we need to create an extra table and delete the duplicate from there
-- ** we need to add a data type before creating/using the initial staging.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
); --ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- note that I am using VSCode

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

-- check first
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 

-- then delete
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- 2. Standardize the Data - example is for incorrect spelling, white spaces
-- check the first data column that you wish to standardize
-- check company
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- TRIM removes white space at the beginning or the end
UPDATE layoffs_staging2
SET company = TRIM(company);

-- check if updated
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- check the industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- check the industry column
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- update/standardize this as "Crypto"
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- check the standardized table
SELECT *
FROM layoffs_staging2;

-- look for other columns to standardize; it is advisable to look over all of the columns and update them
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1; -- 1 is equal to COLUMN NUMBER

-- remove other character that is not included
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- check the industry column again
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1; -- 1 is equal to COLUMN NUMBER

-- next, if you have a date, update the data type to DATE.
-- check first
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- change it to a DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- change the DATA TYPE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


-- 3. Check NULL or Blank values to see if we can standardize with other data
SELECT *
FROM layoffs_staging2;

-- check industry column
SELECT * 
FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL;

-- for the following query, change blank to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- to make the column equal to other data, check and join it
SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- after that, make it equal
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- check again that the above query is accurate
SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;


-- 4. Remove any columns or rows with no data

-- Checking null values for total_laid_off and percentage_laid_off
SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- DELETE the data if you BELIEVE this will not help you in visualization due to a lack of data
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- check if deleted
SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- delete row_num because we do not need it
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- DONE!
SELECT *
FROM layoffs_staging2;



-- You can also check the STAGE column for BLANK or IS NULL data. (no other data can be updated into the stage column.)
-- TRYING OTHERS
SELECT *
FROM layoffs_staging2
WHERE stage = '' OR stage IS NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Zapp';


-- You can also check the Country data for BLANK or IS NULL. (nothing)
-- TRYING OTHERS
SELECT *
FROM layoffs_staging2
WHERE country = '' OR country IS NULL;


    
    





