-- Covid Death

SELECT *
FROM dbo.CovidDeath
ORDER BY 1,2;


ALTER TABLE	dbo.CovidDeath
ALTER COLUMN total_cases numeric(18,0);


-- Total Cases vs Total Deaths (Death percentage) in NZ

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeath
WHERE location like 'New Zealand'
ORDER BY 1,2;


-- Total Cases vs Population in NZ (what percentage of population got Covid)

SELECT location, date, Population, total_cases, (total_deaths / Population)*100 AS CovidPercentage
FROM dbo.CovidDeath
WHERE location like 'New Zealand'
ORDER BY 1,2;


-- Countries with highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / Population)*100 AS InfectionPercentage
FROM dbo.CovidDeath
GROUP BY location, population
ORDER BY InfectionPercentage desc;


-- Countries with highest Death Count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Continent with highest Death Count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeath
WHERE continent IS NULL 
AND location NOT LIKE '%income'
AND location NOT LIKE 'world'
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Global Numbers per day

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeath
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


-- Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeath, (SUM(new_deaths) / SUM(new_cases))*100 AS DeathPercentage
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2 


-- Total Population and New Vaccination

SELECT cd.continent, cd.location, cd.date, population, new_vaccinations
FROM CovidDeath AS cd
JOIN CovidVaccination AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- Accumulated Total Vaccination

SELECT cd.continent, cd.location, cd.date, new_vaccinations, 
SUM(CONVERT(numeric, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS TotalVaccination
FROM CovidDeath AS cd
JOIN CovidVaccination AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- Percentage of New Vaccination over Total Population (Using CTE)

WITH popvsvac (continnt, location, date, population, new_vaccinations, TotalVaccination)
AS (
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations, 
SUM(CONVERT(numeric, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS TotalVaccination
FROM CovidDeath AS cd
JOIN CovidVaccination AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (TotalVaccination / population) * 100 AS VaccinPercentage
FROM popvsvac;


-- Percentage of New Vaccination over Total Population (Using New Table)

DROP TABLE IF exists VaccinationPopulationPercentage 
CREATE TABLE VaccinationPopulationPercentage 
	(continent nvarchar(50),
	location nvarchar(50),
	date date,
	population numeric,
	new_vaccination numeric,
	TotalVaccinatoin numeric)

INSERT INTO VaccinationPopulationPercentage
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations, 
SUM(CONVERT(numeric, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS TotalVaccination
FROM CovidDeath AS cd
JOIN CovidVaccination AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

SELECT * , (TotalVaccinatoin / population)*100 AS VaccinPercentage
FROM VaccinationPopulationPercentage;


