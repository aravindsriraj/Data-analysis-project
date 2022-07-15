select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4;

-- Select Data that we are going to be using

select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location='India' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in India
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as 'Highest Infection Count', max((total_cases/population)) *100 as 'Percent of Population infected'
from PortfolioProject..CovidDeaths
group by location,population
order by [Percent of Population infected] desc;


-- Let's break things down by continent

-- Showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as 'Highest Death Count'
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by [Highest Death Count] desc;


-- Global numbers

select date,sum(total_cases) as 'Total cases',sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

select sum(total_cases) as 'Total cases',sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2;


-- Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as 'Rolling People Vaccinated'
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date
and dea.continent is not null
order by 2,3;


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as 'Rolling People Vaccinated'
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * ,(RollingPeopleVaccinated/Population)*100 
from PopvsVac;



-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinaions numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as 'Rolling People Vaccinated'
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated;


-- Creating view for store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as 'Rolling People Vaccinated'
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated;
