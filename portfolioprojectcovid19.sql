--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..covidDeaths
--ORDER BY 1,2;

Select continent, location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
From PortfolioProject..covidDeaths
--WHERE location LIKE 'Viet%'
WHERE continent is null
ORDER BY 1,2;

-- Total cases and population
Select location, date, total_cases,population,(total_cases/population)*100 AS casespercentage
From PortfolioProject..covidDeaths
WHERE location LIKE 'South%'
ORDER BY 1,2;

-- Highest infection rate
Select location, MAX (total_cases)AS highestinfection,population, MAX((total_cases/population))*100 AS casespercentage
From PortfolioProject..covidDeaths
--WHERE location LIKE 'South%'
GROUP BY location, population
ORDER BY casespercentage desc;


-- Highest death rate
 Select location, MAX(cast (total_deaths AS float)) as totaldeath
From PortfolioProject..covidDeaths
--WHERE location LIKE 'South%'
WHERE continent is not null
GROUP BY location
ORDER BY totaldeath desc;

-- Break down by continent
 Select location, MAX(cast (total_deaths AS float)) as totaldeath
From PortfolioProject..covidDeaths
--WHERE location LIKE 'South%'
WHERE continent is null
GROUP BY location
ORDER BY totaldeath desc;

--other way

SELECT continent, SUM(max_total_deaths) AS Total_deaths_count
FROM (SELECT continent, location, MAX(cast(total_deaths as float)) AS max_total_deaths
	     FROM PortfolioProject..CovidDeaths
	     GROUP BY continent, location) as maxtotal-- created table to hold maximum death per country information

WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_deaths_count DESC;


--Global newcases and newdeaths


Select sum(new_cases) as totalnewcases, SUM (cast(new_deaths as float)) as totalnewdeaths,SUM (cast(new_deaths as float))/sum(new_cases) as deathpercentage
From PortfolioProject..covidDeaths
--WHERE location LIKE 'South%'
WHERE continent is null
--GROUP BY location
ORDER BY 1,2 desc

-- -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.date ) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- WITH CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABBLE
DROP Table if exists dbo.PopulationVaccinated
Create Table dbo.PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into dbo.PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
From dbo.PopulationVaccinated

---- Creating View to store data for later visualizations

Create View dbo.peoplePopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,cast (dea.Date as date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


