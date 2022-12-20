/*SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4*/


/*SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4*/

--Select Data that we are going to be using

/*SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 --ordering by location and date*/



/*--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%pakistan%' AND continent is not null
ORDER BY 1,2*/



/*--Looking at Total Cases vs Population
--Shows % of population that got COVID 
SELECT
	Location,
	date,
	Population,
	total_cases,
	(total_cases/population)*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2*/


/*--What countries have the Highest Infection Rates compared to Population?
SELECT
	Location,
	Population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY InfectedPopulationPercentage DESC*/


--Showing countries with Highest Death Count per Population
/*SELECT
	Location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC*/


/*--BREAKING THINGS DOWN BY CONTINENT
SELECT
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC*/


/*--THIS IS THE RIGHT WAY TO DO THIS but for the sake of the project we're going to revert to breaking it down by continent
SELECT
	location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null --ANd
--WHERE continent NOT like '%income%' AND continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC*/


/*--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC*/


/*--GLOBAL NUMBERS
SELECT
	date,
	SUM(NEW_CASES) as total_cases,
	SUM(CAST(NEW_DEATHS AS INT)) as total_deaths,
	SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%STATES%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2*/


/*SELECT
	SUM(NEW_CASES) as total_cases,
	SUM(CAST(NEW_DEATHS AS INT)) as total_deaths,
	SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%STATES%'
WHERE continent is not null
ORDER BY 1,2
--removing date in select and group by gives the total sum of all cases and deaths*/



--LOOKING AT TOTAL POPULATION VS VACCINATIONS
/*--joining the deaths and vax tables on location and date
SELECT *
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date*/

--getting a rolling number of vaccinations
/*SELECT deaths.continent,
	deaths.location,
	deaths.date,
	deaths.population,
	vax.new_vaccinations,
	SUM(CONVERT(bigint, vax.new_vaccinations)) --could also do SUM(CAST(vax.new_vaccinations AS BIGINT))
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
		AS RollingPeopleVaccinated,
--	(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3*/


/*--USE CTE for RollingPeopleVaccinated
WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT deaths.continent,
	deaths.location,
	deaths.date,
	deaths.population,
	vax.new_vaccinations,
	SUM(CONVERT(bigint, vax.new_vaccinations)) --could also do SUM(CAST(vax.new_vaccinations AS BIGINT))
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
		AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 PercentVaccinated
FROM PopvsVax*/


/*--USING TEMP TABLE For PercentVaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated --useful for when you run temptables multiple tiems
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent,
	deaths.location,
	deaths.date,
	deaths.population,
	vax.new_vaccinations,
	SUM(CONVERT(bigint, vax.new_vaccinations)) --could also do SUM(CAST(vax.new_vaccinations AS BIGINT))
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) 
		AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
--WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 PercentVaccinated
FROM #PercentPopulationVaccinated*/


--Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT
	deaths.continent,
	deaths.date,
	deaths.population,
	vax.new_vaccinations,
	SUM(CONVERT(bigint, vax.new_vaccinations))
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated



