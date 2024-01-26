select * from project..CovidDeaths order by 3,4;
select * from project..Covidvacinations order by 3,4;

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from project..CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
where location like 'india'
order by 1,2

--loking at total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as PeopleAffected
from project..CovidDeaths
--where location like 'india'
order by 1,2

--looking at countries  with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PeopleAffected
from project..CovidDeaths
where location like 'i%'
group by location,population
order by PeopleAffected desc

--showing Countries with highest death count per population
select location,max(cast(total_deaths as int)) as highestDeathCount
from project..CovidDeaths
where continent is not null
group by location
order by highestDeathCount desc

--showing continents with the highest death count per population
 select continent,max(cast(total_deaths as int)) as highestDeathCount
from project..CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc

--global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as Deathpercentage
from project..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total Population vs Vaccination


select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from project..CovidDeaths dea
join project..Covidvacinations vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


--with cte

with popvsVac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from project..CovidDeaths dea
join project..Covidvacinations vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100
from popvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from project..CovidDeaths dea
join project..Covidvacinations vac
	on dea.location =vac.location
	and dea.date =vac.date
--where dea.continent is not null
order by 2,3

select *,(Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated 

create view PercentPopulationVaccinated1 as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from project..CovidDeaths dea
join project..Covidvacinations vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated1