SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL AND location LIKE '%states%'
ORDER BY 1, 2

--Percentage cases per death
SELECT location, date, total_cases, CAST(total_deaths AS int), (CAST(total_deaths AS int)/total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Cases per population
SELECT location, date, population, total_cases, (total_cases/population)*100 InfectionPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Max Cases per Population
SELECT location, population, MAX(total_cases) MaxTotalCases, MAX((total_cases/population))*100 InfectionPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionPercentage DESC

--Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL AND location = 'Nigeria'
GROUP BY location
ORDER BY 2 DESC

--Highest Death Count per Continent
SELECT location, MAX(CAST(total_deaths AS int)) DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Global Numbers
SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Covid Vaccinations Table
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL

--Join Tables for Population vs New Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AddingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Vaccinated People per Population of each Country using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, AddingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AddingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (AddingPeopleVaccinated/population)*100
FROM PopvsVac


--Vaccinated People per Population of each Country using TempTable

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
AddingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AddingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM #PercentPopulationVaccinated

--Creating Views for later Visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AddingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT TOP 66880 *
FROM PercentPopulationVaccinated

CREATE VIEW InfectionPercentage AS
SELECT location, date, population, total_cases, (total_cases/population)*100 InfectionPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 1, 2

SELECT *
FROM InfectionPercentage
ORDER BY location, date