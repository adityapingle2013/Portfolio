select * from covidDeaths
where continent is not null
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from covidDeaths
where continent is not null
order by 1,2

-- looking total case vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covidDeaths
where location like '%india%'
and continent is not null
order by 1,2
	
-- looking at total cases vs population
--shows what percentage of population dying because of covid
select location,date,population,total_cases,(total_cases/population)*100 as percent_population_infected
from covidDeaths
where continent is not null
order by 1,2

--highest infected rate country complare to population
select location,population,max(total_cases) as highestinfectedcount,max((total_cases/population))*100 as percent_population_infected
from covidDeaths
where continent is not null
group by location,population
order by percent_population_infected desc

-- country with highest no of deaths per population
select location,max(cast(total_deaths as int)) as totalDeathsCount
from covidDeaths
where continent is not null
group by location,population
order by totalDeathsCount desc
 

-- continant with highest no of deaths per coontinant
select continent,max(cast(total_deaths as int)) as totalDeathsCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathsCount desc 
 


 -- showing with highest no of deaths per coontinant
select continent,max(cast(total_deaths as int)) as totalDeathsCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathsCount desc 


-- update the valse as getting zero encountered 
update covidDeaths
set new_cases = NULL,new_deaths= NULL
where new_cases = 0 or new_deaths =0;


--global numbers

select sum(new_cases) as total_case, sum(new_deaths) as total_deaths, SUM(new_deaths)/sum(new_cases)*100 as death_percentage
from covidDeaths
where continent is not null
--group by  date
order by 1,2


-- looking total population vs vaccinations

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(  bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date) as people_vaccinated
from  covidDeaths dea
join covidvaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE
with popvsvac ( continant, loaction, date, population, new_vaccinations, people_vaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(  bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date) as people_vaccinated
from  covidDeaths dea
join covidvaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (people_vaccinated/population)*100 
from popvsvac


--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continant nvarchar(255), 
loaction nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric ,
people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(  bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date) as people_vaccinated
from  covidDeaths dea
join covidvaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (people_vaccinated/population)*100 
from #PercentPopulationVaccinated

--create view
drop view if exists PercentPopulationVaccinated
create view  PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(  numeric, vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date) as people_vaccinated
from  covidDeaths dea
join covidvaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from 
PercentPopulationVaccinated



