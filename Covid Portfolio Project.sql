/*
Covid 19 Data Exploration 

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaxxx
--order by 3,4

-- Selecting Data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population contracted Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectionRate
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by InfectionRate desc



-- Showing Countries with Highest Death Count per Population

Select location, population, Max(total_deaths) as TotalDeathCount, Max((total_deaths/population)*100) as HighestPopulationDeath
From PortfolioProject..CovidDeaths
--Where location like'%states%'
Group by Location, population
order by HighestPopulationDeath desc


Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by HighestDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per poulation

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Total deaths vs Total Cases per continent
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Continents with highest infection rate
Select continent, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where continent is not null


--GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations
--Showing Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(convert(int, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaxxx vax
	ON dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3


-- USing CTE to perform calculation on Partition By in previous query
With PopvsVac (Continet, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(convert(int, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaxxx vax
ON dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Using TEMP TABLE to perform calculation 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(convert(int, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaxxx vax
	ON dea.location = vax.location
	and dea.date = vax.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Cretaing view to store data for later visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, sum(convert(int, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaxxx vax
ON dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
--order by 2,3


--Select *
--From PercentPopulationVaccinated