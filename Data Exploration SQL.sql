/*Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/

/* 1. Selecting CovidDeaths Data */

Select *
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	order by 3,4;


/* 2. Select Groundwork Data */

Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	order by 1,2;


/* 3. Total Cases vs Total Deaths with likelihood of dying if you contract covid in your country */

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	-- and location like '%states%'
	order by 1,2;


/* 4. Total Cases vs Population with what percentage of population infected with Covid */

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	-- Where location like '%states%'
	order by 1,2;


/* 5. Countries with Highest Infection Rate compared to Population and Date */

Select Date, Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	--Where location like '%states%'
	Group by Location, Population, Date
	order by PercentPopulationInfected desc;


/* 6. Countries with Highest Death Count per Population */

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	-- and location like '%states%'
	Group by Location
	order by TotalDeathCount desc;

/* 7. Breaking down Data by Continent; Showing contintents with the highest death count per population */

Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	-- and location like '%states%'
	Group by continent
	order by TotalDeathCount desc;


/* 8. Global Numbers */

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	-- and location like '%states%'
	--Group By date
	order by 1,2;


/* 9. Total Population vs Vaccinations and Shows Percentage of Population that has recieved at least one Covid Vaccine */

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3;


/* 10. Using CTE to perform Calculation on Partition By from previous query */

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	-- , (RollingPeopleVaccinated/population)*100
		From PortfolioProject..CovidDeaths dea
		Join PortfolioProject..CovidVaccinations vac
			On dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
	)
		-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 From PopvsVac;


/* 11. Extra Tableau Table 2 */

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

/* 12. Extra Tabelau Table 3 */

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

