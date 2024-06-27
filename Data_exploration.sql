Select *
From CovidDeaths$
where continent is not NULL
order by 3,4



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
order by 1,2

-- Total Cases VS Total Deaths (Likelihood of Dying)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM CovidDeaths$
WHERE location like '%nd'
order by 1,2

-- Countries with Highest Infection rate
SELECT location, MAX(total_cases) as max_cases, MAX((total_cases/population)*100) as infected_population
FROM CovidDeaths$
group by location
order by infected_population DESC

-- Countries with highest Death_count per Population
SELECT location, MAX(cast(total_deaths as int)) as max_deaths, MAX((cast(total_deaths as int)/population)*100) as MAXdeath_percent
FROM CovidDeaths$
where continent is not NULL
group by location
order by max_deaths DESC, MAXdeath_percent DESC

-- Continents with highest death_count per population
SELECT location, MAX(cast(total_deaths as int)) as max_deaths
FROM CovidDeaths$
Where continent is NULL
Group by location
order by max_deaths DESC

--Across the world:
Select SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as deaths_per_cases
From CovidDeaths$
Where continent is not NULL

-- JOINING the 2 tables
-- Looking at total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_Vaccinated
From CovidDeaths$ dea
Join CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

-- Use CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_Vaccinated
From CovidDeaths$ dea
Join CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as percent_vaccinated
From PopVsVac

-- Use Temp_Table

-- Recommended to add the below command as it becomes efficient while dealing with Temp tables
DROP TABLE IF EXISTS #popVsva

CREATE TABLE #popVSvac
(Continent nvarchar(100), 
location nvarchar(100), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated float)

INSERT INTO #popVSvac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_Vaccinated
From CovidDeaths$ dea
Join CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as percent_vaccinated
From #popVSvac


-- Create Views:
Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_Vaccinated
From CovidDeaths$ dea
Join CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL

