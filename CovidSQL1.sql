
SELECT *
FROM SQLTutorial..CovidDeaths
order by 3,4

--SELECT *
--FROM SQLTutorial..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLTutorial..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths. since total_cases is nvarcher chnage to float.

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM SQLTutorial..CovidDeaths
order by 1,2

-- -- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS PercentagePopulationInfected
FROM SQLTutorial..CovidDeaths
where location like '%Albania%'
order by 1,2

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))) * 100 AS PercentagePopulationInfected
FROM SQLTutorial..CovidDeaths
group by location, population
order by 1,2

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
From SQLTutorial..CovidDeaths
group by location
order by TotalDeathCount desc

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From SQLTutorial..CovidDeaths
group by location
order by TotalDeathCount desc

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From SQLTutorial..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Break Things Down By Continent

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From SQLTutorial..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, sum(cast(new_cases as float)) --(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS PercentagePopulationInfected
From SQLTutorial..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global Number

SELECT sum(cast(new_cases as int))as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
From SQLTutorial..CovidDeaths
where continent is not null
order by 1,2


SELECT *
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Either

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations. The db will be save in Views

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLTutorial..CovidDeaths dea
JOIN SQLTutorial..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated

