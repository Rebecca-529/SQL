--Select * 
--from PortfolioProject..CovidDeaths
--order by 3,4


--Select * 
--from PortfolioProject..['Covid Vaccinations']
--order by 3,4

-- Selecting my data
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1, 2

-- Looking at total cases vs total deaths
-- Shows the likelihood of duing if you contract covid in a certain country
Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.. coviddeaths
where location like '%states%'
	AND continent is not NULL
order by 1, 2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CovidContractedPercentage
from PortfolioProject..coviddeaths
where location like '%states%' 
	AND continent is not NULL
order by 1,2

-- Looking at countries with highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestPositiveCount, MAX((total_cases/population))*100 as CovidContractedPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location, population
order by CovidContractedPercentage desc


-- Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalCovidDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by TotalCovidDeathCount desc

-- Showing data by continent
-- Showing continents by highest total death count

Select location, MAX(cast(total_deaths as int)) as TotalCovidDeathCount
from PortfolioProject..CovidDeaths
where continent is NULL and location not in ('world', 'high income','upper middle income','lower middle income','low income', 'international')
group by location
order by TotalCovidDeathCount desc

-- Looking at continents average people fully vaccinated by total covid death count
Select PortfolioProject..CovidDeaths.location, AVG(cast(PortfolioProject..CovidVaccinations.people_fully_vaccinated as bigint)) as AVG_Ppl_Fully_Vacc, MAX(cast(PortfolioProject..CovidDeaths.total_deaths as int)) as TotalCovidDeathCount
from PortfolioProject..CovidDeaths
left join PortfolioProject..CovidVaccinations
on PortfolioProject..CovidDeaths.row_id = PortfolioProject..CovidVaccinations.row_id
where PortfolioProject..CovidDeaths.continent is NULL and PortfolioProject..CovidDeaths.location not in ('world', 'high income','upper middle income','lower middle income','low income', 'international')
group by PortfolioProject..CovidDeaths.location
order by TotalCovidDeathCount desc


-- Global Numbers
-- Looking dates with the highest death percentage

Select date, sum(new_cases) as Total_New_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from PortfolioProject.. coviddeaths
Where continent is not NULL and total_cases >0 and total_deaths >0
group by date
order by DeathPercentage DESC

-- Looking at world death percentage
Select sum(new_cases) as Total_New_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from PortfolioProject.. coviddeaths
Where continent is not NULL and total_cases >0 and total_deaths >0
order by 1,2

-- More joins
Select * 
from PortfolioProject.. coviddeaths as deaths
join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date

-- Use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, rollingvaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(bigint, vaccinations.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as deaths
join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
)
Select *, (RollingVaccinations/Population)*100 as PercentofPopVacc
from PopvsVac

-- Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar (255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(bigint, vaccinations.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as deaths
join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

Select *, (RollingVaccinations/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visulizations
Create view PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
sum(convert(bigint, vaccinations.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from PortfolioProject..CovidDeaths as deaths
join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

Select *
from PercentPopulationVaccinated