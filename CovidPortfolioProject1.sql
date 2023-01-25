select *
from [Portfolio Project]..CovidDeaths
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations
order by 3,4

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location='India'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of Population got covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
where location='India'
order by 1,2

-- Looking at countries with highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count 

select location,max(cast(total_deaths as int)) as TotalDeathCount  --The orginal dataset has the datatype as varchar(255) hence have to change it to int to get what we are looking for
from [Portfolio Project]..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

--Showing Continents with Highest Death Count 

select location,max(cast(total_deaths as int)) as TotalDeathCount  --The orginal dataset has the datatype as varchar(255) hence have to change it to int to get what we are looking for
from [Portfolio Project]..CovidDeaths
where continent is NULL
group by location
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not NULL
--group by date
order by 1,2

--Looking at total population vs vaccinations #1

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--Looking at total population vs vaccinations #2

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--Looking at total population vs vaccinations #3.1 (with CTE)

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingVaccinationCount)
as
( 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
--We had to create a CTE to incorporate the newly created column for an arithmetic expression
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
)
select *,(RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
from PopvsVac


--Looking at total population vs Vaccinations #3.2 Temp Table

Drop Table if exists #PercentPopulationVaccinated --Added so as to not get an error if any changes are to be made
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
--We had to create a Temp Table to incorporate the newly created column for an arithmetic expression
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

select *,(RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated

--Creating View to store data for visualisation

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

select * 
from PercentPopulationVaccinated