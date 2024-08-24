-- Data cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns


CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num -- cause date is a keyword
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num 
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'casper' ;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num 
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1; -- Can't update anything in cte






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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num 
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardizing data

SELECT  company, TRIM(company)  -- trim takes the white spaces from both sides
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry -- * was used to show all the columns
FROM layoffs_staging2;
-- WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) -- LOOKING FOR SOMETHING THAT ISN'T A WHITE SPACE
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
 -- STR_TO_DATE(`date`, '%m/%d/%Y') -- formatting the date from text into the standard date format--
FROM layoffs_staging2           -- capital M inplace of small m will give nothing -- capital Y is preferred --
;

UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- do this on the staging table and never on raw table. It will change the datatype of the actual table
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT DISTINCT* 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';



SELECT Distinct* 
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT DISTINCT t1.industry, t2.industry  -- yahan se aa rha
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
SET t1.company = t2.company
WHERE t1.industry IS NULL -- OR t1.industry = '')
AND t2.industry IS NOT NULL;

