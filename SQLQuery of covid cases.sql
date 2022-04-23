select * from [portfolio project of covid cases]..['covid-data']
order by 3,4

 


 select Location,date,total_cases,new_cases,population,total_deaths from [portfolio project of covid cases]..['covid-data']
order by 1,2

 

  select Location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathperc 
  from [portfolio project of covid cases]..['covid-data']
  order by 1,2


select Location,date,total_cases,total_deaths 
from [portfolio project of covid cases]..['covid-data'] 
where date='2022-04-20'
order by date ASC


select Location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathperc 
from [portfolio project of covid cases]..['covid-data'] where
location like '%kingdom%'
order by date desc

select Location,date,total_cases,population,(total_cases/population)*100 as got_covid 
from [portfolio project of covid cases]..['covid-data'] where
location ='united kingdom'
order by date desc


select Location,max(total_cases) as max_cases,population,max((total_cases/population))*100 as got_covid 
from [portfolio project of covid cases]..['covid-data'] 
group by location,population
order by got_covid desc



select Location,max(total_deaths) as max_deaths,population,max((total_deaths/population))*100 as got_died 
from [portfolio project of covid cases]..['covid-data'] 
group by location,population
order by got_died desc

select Location,max(cast(total_deaths as int)) as max_deaths 
from [portfolio project of covid cases]..['covid-data'] 
where continent is not null
group by location
order by max_deaths desc

select Location,max(cast(total_deaths as int)) as max_deaths 
from [portfolio project of covid cases]..['covid-data'] 
where continent is null
group by location
order by max_deaths desc

select continent,max(cast(total_deaths as int)) as max_deaths 
from [portfolio project of covid cases]..['covid-data'] 
where continent is not null
group by continent
order by max_deaths desc

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/ sum(new_cases)*100 as total
from [portfolio project of covid cases]..['covid-data']
where continent is not null
group by date
order by date desc



select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/ sum(new_cases)*100 as total
from [portfolio project of covid cases]..['covid-data']
where continent is not null
order by 1,2


select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations
from 
[portfolio project of covid cases]..['covid-vac'] vac
join [portfolio project of covid cases]..['covid-data'] dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 1,2,3

select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingjab


from 
  [portfolio project of covid cases]..['covid-data'] dea
join [portfolio project of covid cases]..['covid-vac'] vac
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3


---use CTE
with popvsvac(continent,location,date,population,new_vaccinations,rollingjab)
as
(
select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingjab


from 
  [portfolio project of covid cases]..['covid-data'] dea
join [portfolio project of covid cases]..['covid-vac'] vac
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
)

select * ,(rollingjab/population)*100
from popvsvac

--- temp table
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project of covid cases]..['covid-data'] dea
Join [portfolio project of covid cases]..['covid-vac'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project of covid cases]..['covid-data'] dea
Join [portfolio project of covid cases]..['covid-vac'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 