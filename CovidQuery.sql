-- LET'S CHECK OUT OUR DATA

SELECT * 
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths,  population
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs. total deaths.
-- Shows the likelihood of dying from covid.

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs. population.
-- Shows what percentage of population got covid.

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentOfPopulationInfected
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Looking at the countries with the highest infection rate compared to population.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentOfPopulationInfected
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC

-- Looking at the countries with the highest death count per population.

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN TO CONTINENT.

-- Showing the continents with the highest death count per population.

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL

-- Looking at total population vs. vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
--	   , (TotalVaccinations / dea.population) * 100 AS PercentageOfVaccination
FROM covidDeaths AS dea
JOIN covidVaccination AS vac
	ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date

-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM covidDeaths AS dea
JOIN covidVaccination AS vac
	ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (TotalVaccinations / population) * 100 AS PercentageOfVaccination
FROM PopVsVac

-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date DATETIME, population NUMERIC, new_vaccinations NUMERIC, TotalVaccinations NUMERIC)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM covidDeaths AS dea
JOIN covidVaccination AS vac
	ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalVaccinations / population) * 100 AS PercentageOfVaccination
FROM #PercentPopulationVaccinated

-- Creating VIEW to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
--	   , (TotalVaccinations / dea.population) * 100 AS PercentageOfVaccination
FROM covidDeaths AS dea
JOIN covidVaccination AS vac
	ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL 



CREATE VIEW CountryInfecctionRate 
AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentOfPopulationInfected
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population

CREATE VIEW CountryDeathCount 
AS
SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location