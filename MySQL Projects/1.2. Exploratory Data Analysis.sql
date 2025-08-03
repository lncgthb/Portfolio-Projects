-- EXPLORATORY DATA ANALYSIS
-- exploring the DATA SET for ANALYSIS	

SELECT *
FROM layoffs_staging2;
-- determining MAX values for laid_offs
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- the maximum number of individuals laid off is 12,000, and the maximum percentage represents all of the company's employees


SELECT *
FROM layoffs_staging2;
-- determining the dissolved company's funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- some companies raised about 2 billion dollars, but they dissolve


SELECT *
FROM layoffs_staging2;
-- determining sum of total laid off per company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; -- 2 is the 2nd column
-- Too many workers were laid off by nearly large corporations.


SELECT *
FROM layoffs_staging2;
-- figuring out the MIN and MAX `date` of layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- The time frame spans from March 2020 to March 2023. (3-year data)


SELECT *
FROM layoffs_staging2;
-- identifying which countries have the most layoffs
SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- The United States had the most layoffs


SELECT *
FROM layoffs_staging2;
-- determining the year in which the most lay off
SELECT YEAR(`date`) AS Year_, SUM(total_laid_off)
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY Year_
ORDER BY 1 DESC;
-- 2022 had the most layoffs, but 2023 will have more because 2023 just has three months of data
-- so, 2023 is the year that others will be laid off


SELECT *
FROM layoffs_staging2;
-- determining which stage of the company had the most layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- Post-IPO companies had the most layoffs because they are generally big companies


SELECT *
FROM layoffs_staging2;
--  determining which companies dissolve
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- This does not apply to SUM because we don't have other data
-- But I tried AVG, but I suppose this will not apply to us because we are lucky the largest sum is only 2


SELECT *
FROM layoffs_staging2;
-- determining how many layoffs they had per month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- This is useful for visualization for month.


SELECT *
FROM layoffs_staging2;
-- Monthly analysis of ROLLING TOTAL using Common Table Expression CTE Rolling Total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, 
SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total_Final
FROM Rolling_Total;
-- This is useful for visualization


SELECT *
FROM layoffs_staging2;
-- determining COMPANY per YEAR of laid off and rate it until 5
WITH Company_Year AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT company, years, total_laid_off,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE years IS NOT NULL AND ranking <= 5
ORDER BY years ASC, total_laid_off DESC;
-- GOOD FOR VIISUALIZATION ranking top five companies with the most laid offs every year



