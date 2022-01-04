--------------------------------------------------------------------------
-- DATA ANALYSIS PORTFOLIO PROJECT - SQL DATA EXPLORATION - PROJECT 1/4 --
--------------------------------------------------------------------------


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
--Overall likelihood of dying if you contract covid by country (with option to view ONLY United States stats)

SELECT location, population, MAX(total_cases) AS TotalInfectionCount, MAX(cast(total_deaths as int)) AS TotalDeathCount, (MAX(total_deaths)/MAX(total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathPercentage desc


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid each day (with option to view ONLY United States stats)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
--WHERE continent is not null
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Total Death Count by country

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Looking at Highest Death Rate compared to population by country

SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDiedByCountry
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationDiedByCountry DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE in order to utilize created RollingPeopleVaccinated column to further analyze
--Looking at percentage of population vaccinated by country over time

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac


--Using TEMP TABLE in order to utilize created RollingPeopleVaccinated column to further analyze
--Looking at percentage of population vaccinated by country over time

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


-- CREATING VIEWS to store data for later visualizations in Tableau

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


Create View TotalDeathCountByContinent AS
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount DESC

SELECT *
FROM TotalDeathCountByContinent 