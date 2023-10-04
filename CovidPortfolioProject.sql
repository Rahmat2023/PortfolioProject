select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
From PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total Deaths against the Total Cases in Nigeria
-- Shows the chances of dieing if one contracts the virus 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
Where location like 'Nigeria'
order by 1,2

-- Investigating Total Cases vs Population 
-- Showing what percentage of the population contracted the covid virus in Nigeria

select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
Where location like 'Nigeria'
order by 1,2 

-- Investigating Countries with the highest Infection Rate compared to poplution

select location, population, MAX(total_Cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
Group by location, population 
order by 4 desc

-- Investigating Countries with the highest Death Rate
select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, (MAX(total_deaths)/population)*100 as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by 4 desc

--Investigating Countries with the highest Death Count

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by 2 desc


--Continent with the highest Death Count
select continent, SUM(cast(total_deaths as int)) as TotalDeathbyContinent
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by 2 desc

--Global cases by date

select date, SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 desc

--Investigating Total Population vs vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) CummulativeTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
order by 2,3


--USING CTE

with PopVsVac (continent, location,date,population, new_vaccinations, CummulativeTotalVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) CummulativeTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
--order by 2,3
)
select *, (CummulativeTotalVaccinated/population)*100 PercentagePopulationVaccinated
from PopVsVac


--USING TEMP TABLE

DROP table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativeTotalVaccinated numeric,
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) CummulativeTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
--order by 2,3

select *, (CummulativeTotalVaccinated/population)*100 PercentagePopulationVaccinated
from #PercentagePopulationVaccinated


-- Creating view to store data for visualisation

create view CummulativeTotalVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) CummulativeTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
--order by 2,3

create view DeathCountbyContinent as
select continent, SUM(cast(total_deaths as int)) as TotalDeathbyContinent
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
--order by 2 desc