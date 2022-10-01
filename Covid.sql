select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4


--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'malaysia'
order by 1,2


--Looking at Total cases vs population
--Show percentage of population infected Covid
select 
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 as Population_Infection_rate
from CovidDeaths
where location = 'malaysia'
order by 1,2


--Looking at Countries with highest infection rate compared to population
select 
	location,
	population,
	max(total_cases) as Highest_Infection_Count,
	max((total_cases/population))*100 as Population_Infection_rate
from CovidDeaths
group by 
	location,
	population
order by Population_Infection_rate desc


--Showing countries with highest death count per population
select 
	location, 
	max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking down by continent
--Showing continent with the highest death per population
select 
	continent, 
	max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null


--Looking at total population vs vaccinations
select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as int)) 
		over (partition by cd.location order by cd.location,cd.date) as Rolling_ppl_vaccinated
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.location = 'malaysia'
order by 1,2,3


--Use CTE
with Pop_vs_vac(continent, location, date, population, new_vaccinations, Rolling_ppl_vaccinated)
as
(select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as int)) 
		over (partition by cd.location order by cd.location,cd.date) as Rolling_ppl_vaccinated
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.location = 'malaysia'
)
select 
	*, 
	(Rolling_ppl_vaccinated/population)*100 as percentage_vaccinated
from Pop_vs_vac


--Temp Table
drop table if exists #Percent_porpulation_vaccinated
create table #Percent_porpulation_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_ppl_vaccinated numeric
)

insert into #Percent_porpulation_vaccinated
select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as int)) 
		over (partition by cd.location order by cd.location,cd.date) as Rolling_ppl_vaccinated
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.location = 'malaysia'

select 
	*, 
	(Rolling_ppl_vaccinated/population)*100 as percentage_vaccinated
from #Percent_porpulation_vaccinated


--Creating view to store data for later visualizations
create view Percent_population_vaccinated as
select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	sum(cast(cv.new_vaccinations as int)) 
		over (partition by cd.location order by cd.location,cd.date) as Rolling_ppl_vaccinated
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null


select *
from Percent_population_vaccinated