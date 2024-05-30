SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Total Cases and Deaths in the US
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	population
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND
	  continent IS NOT NULL
ORDER BY 3,4 


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 3,4 


--Looking at countries with highest Infection Rate compared to Population

SELECT 
	Location,  
	Population,
	MAX(total_cases) AS HighestInfectionCount,	 
	MAX(cast(total_cases AS float)/cast(population AS float))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT 
	Location,
	MAX(cast(total_deaths AS float)) AS TotalDeathCount	 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT 
	location,
	MAX(cast(total_deaths AS float)) AS TotalDeathCount	 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS Total_Cases,
	SUM(cast(new_deaths AS float)) AS Total_Deaths, 
	Nullif(sum(new_deaths), 0)/nullif(sum(new_cases), 0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NUll
--GROUP BY date
ORDER BY 1,2


--Join: Looking at Total Population vs Vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--Use CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT  #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 1,2

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later

CREATE VIEW PercentPeopleVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2

SELECT *
FROM PercentPeopleVaccinated