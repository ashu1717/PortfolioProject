Select * 
From PortfolioProject..Coviddeaths$
Order by 3,4;

--Select * 
--From PortfolioProject..Covidvaccination$
--Order by 3,4;

--Select Data that we are going to be using

Select Location,date, total_cases, new_cases, total_deaths,population
From PortfolioProject..Coviddeaths$
Order By 1,2;

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid in US

--To chnage data type from nvarchar to float for divison

Alter Table PortfolioProject..Coviddeaths$ Alter Column total_cases float;
Alter Table PortfolioProject..Coviddeaths$ Alter Column total_deaths float;

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths$
Where location like '%states'
Order by 1,2;

--SHows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths$
Where location like '%india'
Order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population got Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..Coviddeaths$
Where location like '%India'
Order by 1,2;


--Looking AT countries with highest infection rate compared to population
Select Location,population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..Coviddeaths$
--Where location like 'a%'
Group by location,population
Order by InfectedPopulationPercentage Desc;


--Showing countries with highest death count per population

Select Location, max(Total_deaths) as TotalDeathCount 
From PortfolioProject..Coviddeaths$
Where continent is not NULL
--Where location like 'a%'
Group by location
Order by TotalDeathCount Desc;

-- let's break things down by continent

Select continent, max(Total_deaths) as TotalDeathCount 
From PortfolioProject..Coviddeaths$
Where continent is not NULL 
--Where location like 'a%'
Group by continent
Order by TotalDeathCount Desc;

--Continent with highest death count per population

Select continent, max(Total_deaths) as TotalDeathCount 
From PortfolioProject..Coviddeaths$
Where continent is not NULL 
--Where location like 'a%'
Group by continent
Order by TotalDeathCount Desc;


--Global Numbers

Select SUM(new_cases)as total_cases,SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths$
--Where location like '%India'
where continent is not null
--Group by date 
Order by 1,2;


--Using CTE,
--No. of columns in CTE has to be equal
--Looking at total poupulation vs vaccination
With PopvsVac(Continent,Location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location Order by dea.location,dea.date) As RollingPeopleVaccinated
From PortfolioProject..Coviddeaths$ dea
JOIN PortfolioProject..Covidvaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3;
)
select *,(RollingPeopleVaccinated/population)*100
From PopvsVAc


--Using Temp
Drop table if exists #percentVaccinated
Create table #PercentVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingPeoplevaccinated numeric
)

Insert Into #PercentVaccinated
Select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.New_vaccinations as float)) Over (Partition by dea.Location order by Dea.location,dea.date) As RollingpeopleVaccinated
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccination$ vac
On dea.location=vac.location
And dea.date=vac.date
Where dea.continent is not null
Order by 3,4;
select *,(RollingPeopleVaccinated/population)*100
From #PercentVaccinated


-- Creating View to store data for later visualisations,
Create View vPercentVaccinated as 
Select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.New_vaccinations as float)) Over (Partition by dea.Location order by Dea.location,dea.date) As RollingpeopleVaccinated
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccination$ vac
On dea.location=vac.location
And dea.date=vac.date
Where dea.continent is not null
--Order by 2,3;

Select * 
From vPercentVaccinated
