select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject..covidDeaths$
order by 1,2

--total cases vs total death
--likelyhood of dying if you contract covid by country

select location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject..covidDeaths$
--where location like '%%kingdom'
order by 1,2


--countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount,max (round((total_cases/population)*100,2))as PercentPopulationInfected
from PortfolioProject..covidDeaths$
where location in ('united states')
group by location, population
order by PercentPopulationInfected desc

--countries with highest deathcount per population

select location, max(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..covidDeaths$
where continent is not null
group by location,population
order by TotalDeathcount desc


--break it by contitinent

select continent, max(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..covidDeaths$
where continent is not null
group by continent
order by TotalDeathcount desc


--global numbers


select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..covidDeaths$
--where location like '%%kingdom'
where continent is not null
--group by date
order by 1,2

-------------------------------------------------------------

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


---useing cte

with popvsvac (continent, location, date, population,new_vaccination, RollingPeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select *, round((RollingPeoplevaccinated/population)*100,2) as rollinpeoplevaccinatedpercent from popvsvac order by 2


--temp table

Drop table if Exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--------------------------

--creating view to store data for later visualization

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null