
-- COVID_19  DATA_BASE EXPLORATORY DATA ANALYSIS.

select *
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
order by 3,4

--select * from Portfolio_project..['owid-covid-data_table2(vaccine)$']
--order by 3,4

select Location,date,total_cases, new_cases, total_deaths, population
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
order by 1,2

--Calculating Total Cases and Total Deaths.

select Location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
where location like '%india%'
order by 1,2

-- Calculating Total cases vs Population .


select Location,date,total_cases, total_deaths,(total_cases/population)*100 as population_infection_percentage
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
where location like '%india%'
order by 1,2 


--Countries with high infection rate to population



select Location,MAX(total_cases)as HIghest_infection_count,population ,MAX((total_cases/population)*100) as population_infection_percentage
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
group by location,population
order by population_infection_percentage desc


-- Countries with Highest Death Count per population

select Location,MAX(cast(Total_deaths as int)) as Total_death_count
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
where continent is not null
group by location
order by Total_death_count desc

--Looking  continent wise data

select continent,MAX(cast(Total_deaths as int)) as Total_death_count
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
where continent is not null
Group by continent
Order by Total_death_count desc



select location,MAX(cast(Total_deaths as int)) as Total_death_count
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
where continent is not null
Group by location
Order by Total_death_count desc




--Continent with highest death counts per population

select continent,MAX(cast(Total_deaths as int)) as Total_death_count
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
where continent is not null
Group by continent
Order by Total_death_count desc


-- Looking at global level


select SUM(new_cases)as total_new_cases,SUM(CAST(new_deaths as int)) as total_new_deaths ,Sum(new_cases)/Sum(cast(new_deaths as int)) as death_percentage

--,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from Portfolio_project..['owid-covid-data_table1(deaths)$'] 
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2 


-- total population vs vaccination


select death_.continent , death_.location, death_.date, death_.population ,vaccine_.new_vaccinations 
,SUM(CONVERT(int,vaccine_.new_vaccinations) ) over (partition by death_.Location order by death_.location ,death_.date) as people_vaccinated_roll
from Portfolio_project..['owid-covid-data_table1(deaths)$']  death_
join Portfolio_project..['owid-covid-data_table2(vaccine)$']  vaccine_
  on death_.location =vaccine_.location
  and death_.date = vaccine_.date
where death_.continent is not null
order by 2,3



--using cte

with pop_vs_vacc (Continent ,population ,Location , Date ,New_Vaccinations,people_vaccinated_roll)
as(
select death_.continent , death_.location, death_.date, death_.population ,vaccine_.new_vaccinations 
,SUM(CONVERT(int,vaccine_.new_vaccinations) ) over (partition by death_.Location order by death_.location ,death_.date) as people_vaccinated_roll
from Portfolio_project..['owid-covid-data_table1(deaths)$']  death_
join Portfolio_project..['owid-covid-data_table2(vaccine)$']  vaccine_
  on death_.location =vaccine_.location
  and death_.date = vaccine_.date
where death_.continent is not null
--order by 2,3

)
select * ,(people_vaccinated_roll / population)*100
from pop_vs_vacc


-- Temp table

DROP table if exists #Percentpopulationvaccinated

Create Table  #Percentagepopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
people_vaccinated_roll numeric
)



insert into #Percentagepopulationvaccinated


Select death_.continent , death_.location, death_.date, death_.population ,vaccine_.new_vaccinations 
,SUM(CONVERT(int,vaccine_.new_vaccinations) ) over (partition by death_.Location order by death_.location ,death_.date) as people_vaccinated_roll
from Portfolio_project..['owid-covid-data_table1(deaths)$']  death_
join Portfolio_project..['owid-covid-data_table2(vaccine)$']  vaccine_
  on death_.location =vaccine_.location
  and death_.date = vaccine_.date
--where death_.continent is not null
--order by 2,3


select * ,(people_vaccinated_roll/population)*100
from #Percentagepopulationvaccinated


--Creating  view for visualization


CREATE VIEW
Percentagepopulationvaccinated2 
as
select death_.continent , death_.location, death_.date, death_.population ,vaccine_.new_vaccinations 
,SUM(CONVERT(int,vaccine_.new_vaccinations) ) over (partition by death_.Location order by death_.location ,death_.date) as people_vaccinated_roll
from Portfolio_project..['owid-covid-data_table1(deaths)$']  death_
join Portfolio_project..['owid-covid-data_table2(vaccine)$']  vaccine_
  on death_.location =vaccine_.location
  and death_.date = vaccine_.date
where death_.continent is not null
--order by 2,3