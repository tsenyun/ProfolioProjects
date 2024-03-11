
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- WHERE continent is NOT NULL
-- Buz the contient data is also included in the database



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in a given country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast (total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE 
--Location like '%Germany%' AND 
continent is NOT NULL
ORDER BY 1,2



-- Delete duplicated rows

WITH CTE(
	iso_code,
	continent, 
	location, 
	date, 
	population,  
	total_cases,
	new_cases,
	new_cases_smoothed,
	total_deaths,
	new_deaths,
	new_deaths_smoothed,
	total_cases_per_million,
	new_cases_per_million,
	new_cases_smoothed_per_million,
	total_deaths_per_million,
	new_deaths_per_million,
	new_deaths_smoothed_per_million,
	reproduction_rate,	
	icu_patients,	
	icu_patients_per_million,	
	hosp_patients,	
	hosp_patients_per_million,	
	weekly_icu_admissions,
	weekly_icu_admissions_per_million,
	weekly_hosp_admissions,
	weekly_hosp_admissions_per_million,
    duplicatecount)
AS (SELECT iso_code,
	continent, 
	location, 
	date, 
	population,  
	total_cases,
	new_cases,
	new_cases_smoothed,
	total_deaths,
	new_deaths,
	new_deaths_smoothed,
	total_cases_per_million,
	new_cases_per_million,
	new_cases_smoothed_per_million,
	total_deaths_per_million,
	new_deaths_per_million,
	new_deaths_smoothed_per_million,
	reproduction_rate,	
	icu_patients,	
	icu_patients_per_million,	
	hosp_patients,	
	hosp_patients_per_million,	
	weekly_icu_admissions,
	weekly_icu_admissions_per_million,
	weekly_hosp_admissions,
	weekly_hosp_admissions_per_million, 
				   ROW_NUMBER() OVER(PARTITION BY iso_code,
	continent, 
	location, 
	date, 
	population,  
	total_cases,
	new_cases,
	new_cases_smoothed,
	total_deaths,
	new_deaths,
	new_deaths_smoothed,
	total_cases_per_million,
	new_cases_per_million,
	new_cases_smoothed_per_million,
	total_deaths_per_million,
	new_deaths_per_million,
	new_deaths_smoothed_per_million,
	reproduction_rate,	
	icu_patients,	
	icu_patients_per_million,	
	hosp_patients,	
	hosp_patients_per_million,	
	weekly_icu_admissions,
	weekly_icu_admissions_per_million,
	weekly_hosp_admissions,
	weekly_hosp_admissions_per_million
           ORDER BY iso_code) AS DuplicateCount
    FROM PortfolioProject..CovidDeaths)
DELETE FROM CTE
WHERE duplicatecount > 1;



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (cast (total_cases as float)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
ORDER BY 1,2



-- Looking at Country with Highest Infection Rate compared to Population

SELECT location, population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with Highest Death Count per Population

SELECT location,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Let's break things down by continent

SELECT location,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is NULL AND
	location <> 'High income' AND
	location <> 'Upper middle income' AND
	location <> 'lower middle income' AND
	location <> 'low income'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- somehow the income info is also here???

SELECT continent,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- 'CAST () AS INT' to make it correct, when doing, check if the data is logical




-- Showing continent with the highest death count per population

SELECT continent,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global numbers

SELECT 
	--date,
	SUM(cast(new_cases as INT)) AS Total_cases, 
	SUM(cast(new_deaths as INT)) AS Total_deaths,
	SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- cannot be divided by 0, use NULLIF(x,0)
-- if remove date will get total cases
-- CAST(x as INT) OR CONVERT(INT,x)




-- Looking at Total Population vs vaccinations
-- added up the new vaccinations by order (using Partition By)

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) 
	OVER (Partition BY Dea.location ORDER BY Dea.location, Dea.date)
	AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 ->cannot do it when you just created it
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac 
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
ORDER BY 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollongPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) 
	OVER (Partition BY Dea.location ORDER BY Dea.location, Dea.date)
	AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 ->cannot do it when you just created it
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac 
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollongPeopleVaccinated/Population)*100
FROM PopvsVac


-- Use Temp Table

DROP TABLE if exists #temp_PercentPopulationVaccinated
Create Table #temp_PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #temp_PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) 
	OVER (Partition BY Dea.location ORDER BY Dea.location, Dea.date)
	AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 ->cannot do it when you just created it
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac 
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #temp_PercentPopulationVaccinated







--Creating View to store data for later visualization

Create View PercentPopulationVaccinated AS
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollongPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) 
	OVER (Partition BY Dea.location ORDER BY Dea.location, Dea.date)
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac 
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollongPeopleVaccinated/Population)*100 AS RollongVaccinatedPercentage
FROM PopvsVac

-- Ctrl+shift+R,refresh, to get the red underlines off 

-- Looking at Country with Highest Infection Rate compared to Population
Create View HighestInfectionRateCountry AS
SELECT location, population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
Create View TotalDeathCountCountry AS
SELECT location,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC

Create View TotalDeathCountContinent AS
SELECT continent,
	MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
WHERE continent is not NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

Create View TotalGlobalNumbersDate AS
SELECT 
	date,
	SUM(cast(new_cases as INT)) AS Total_cases, 
	SUM(cast(new_deaths as INT)) AS Total_deaths,
	SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
--ORDER BY 1,2

Create View DeathPercentage AS
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast (total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE 
--Location like '%Germany%' AND 
continent is NOT NULL
--ORDER BY 1,2

Create View PercentPopulationInfected AS
SELECT location, date, total_cases, population, (cast (total_cases as float)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Germany%'
--ORDER BY 1,2
