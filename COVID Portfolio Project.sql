select *
from portfolioProject..CovidDeaths
where continent is not null 
order by 3,4 

--select *
--from portfolioProject..CovidVaccinations
--order by 3,4 


Select Location, Date, Total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Total Cases Vs Total Deaths 
-- Shows Likelihood of dying if you contract covid in the U.S.

Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as dec))*100 as DeathPercentage
from portfolioProject..CovidDeaths
where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases Vs Population 
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from portfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Countries with highest Infection Rate compared to Population 

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfected
from portfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population 
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population 

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by location 
order by TotalDeathCount desc


-- Breaking things down by continent 

-- Showing continents with the highest death count per population 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by continent 
order by TotalDeathCount desc




-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercantage
from portfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2



-- Total population vs. Vaccination 
-- Shows Percentage of population that has received at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition by in previous query


with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform calcutioon on Partion by in previous query


drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated



-- Creating a View to store data for later Visualizations



Create View percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
from percentPopulationVaccinated



-- Creating More views 


Create View TotalDeathCount as 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by continent 
--order by TotalDeathCount desc


select *
from TotalDeathCount


-- More Views 

Create view CountriesTotalDeathCount as
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by location 
--order by TotalDeathCount desc

select *
from CountriesTotalDeathCount


-- More View

Create view PercentPopulationInfected as
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfected
from portfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population 
--order by PercentPopulationInfected desc


select* 
from PercentPopulationInfected