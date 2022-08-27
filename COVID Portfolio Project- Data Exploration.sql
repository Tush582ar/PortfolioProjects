--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


	Select *
	From Portfolio_Project..CovidDeaths$
	where continent is not null 
	order by 3,4




	Select Location, date, total_cases, new_cases, total_deaths, population
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you test positive for corona virus in your country

	Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From Portfolio_Project..CovidDeaths$
	Where continent is not null
	order by 1,2

	-- For Tableau
	Select  sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	From Portfolio_Project..CovidDeaths$
	Where continent is not null
	order by 1,2

	Select continent,sum(cast(new_deaths as int)) as TotalDeathCount
	From Portfolio_Project..CovidDeaths$
	where continent  is not null and  
	location not in ('World','European Union' , 'International')
	Group by continent
	Order by TotalDeathCount  desc

	Select Location,Population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	--Where location = 'India'
	Group By location, population
	Order by PercentPopulationInfected desc

	Select Location,date,Population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	--Where location = 'India'
	Group By location, population,date
	Order by PercentPopulationInfected desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

	Select Location, date,  total_cases,Population, (total_cases/population)*100 as PercentPopulationInfected
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	--Where location = 'India'
	order by 1,2

-- Infection Rate per Country compared to population

	Select  location,population, max(total_cases) as max_infectionCount,(max(total_cases/Population))*100 as PercentMaxPopulationInfected
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	group by location,population 
	order by max_infectionCount desc

-- Countries with Highest Death Count compared to population

	Select location, max(cast(total_deaths as int)) as TotalDeathCount
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	Group by location
	Order by TotalDeathCount desc

-- Breaking things down by continent

--  Continents with Highest Death Count per population

	Select continent, max(cast(total_deaths as int)) as TotalDeathCount
	From Portfolio_Project..CovidDeaths$
	where continent is not null
	Group by continent
	Order by TotalDeathCount desc

--  Global Numbers
	
		Select Date, SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Global_Death_Percentage
		From Portfolio_Project..CovidDeaths$
		Where  continent is not null
		Group by date
		order by 1,2	

	
	Select  SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Global_Death_Percentage
	From Portfolio_Project..CovidDeaths$
	Where  continent is not null
	order by 1,2

--	JOINING Covid_Deaths and CovidVaccinations Tables
	
	Select *
	From Portfolio_Project..CovidDeaths$ as da
	JOIN Portfolio_Project..CovidVaccinations$ as vac
	ON  da.location = vac.location
	AND da.date = vac.date

-- Looking at Total Population VS Total Vaccinations

	Select  da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By da.Location order by da.location,da.date) as  Per_Country_Vaccinations_till_date
	--, (Per_Country_Vaccinations_Till_Date/Population)*100
	From Portfolio_Project..CovidDeaths$ as da
	JOIN Portfolio_Project..CovidVaccinations$ as vac
	ON  da.location = vac.location
	AND da.date = vac.date
	Where da.continent is not null 
 	Order by 2,3


-- Using CTE

	With 
	Vacvspop  (continent,location, date, population,new_vaccinations, Per_Country_Vaccinations_Till_Date)
	as (
	Select  da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By da.Location order by da.location,da.date) as  Per_Country_Vaccinations_till_date
	--, (Per_Country_Vaccinations_Till_Date/Population)*100
	From Portfolio_Project..CovidDeaths$ as da
	JOIN Portfolio_Project..CovidVaccinations$ as vac
	ON  da.location = vac.location
	AND da.date = vac.date
	Where da.continent is not null 
 	--Order by 2,3
	)
	Select *, (Per_Country_Vaccinations_Till_Date/population)*100 as 
	From Vacvspop
	

-- Temp Tables

	Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	( continent nvarchar(255),
	 location nvarchar(255),
	 date datetime,
	 population numeric,
	 new_vaccinations numeric,
	 Per_Country_Vaccinations_Till_Date numeric
	 )
	 
	 Insert Into #PercentPopulationVaccinated
	 Select  da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	 SUM(cast(vac.new_vaccinations as int)) OVER (Partition By da.Location order by da.location,da.date) as  Per_Country_Vaccinations_till_date
	--, (Per_Country_Vaccinations_Till_Date/Population)*100
	From Portfolio_Project..CovidDeaths$ as da
	JOIN Portfolio_Project..CovidVaccinations$ as vac
	ON  da.location = vac.location
	AND da.date = vac.date
	Where da.continent is not null 
 	Order by 2,3

	Select *, (Per_Country_Vaccinations_Till_Date/population)*100 
	From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
	
	Create View PercentPopulationVaccinated as 
	Select  da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	 SUM(cast(vac.new_vaccinations as int)) OVER (Partition By da.Location order by da.location,da.date) as  Per_Country_Vaccinations_till_date
	--, (Per_Country_Vaccinations_Till_Date/Population)*100
	From Portfolio_Project..CovidDeaths$ as da
	JOIN Portfolio_Project..CovidVaccinations$ as vac
	ON  da.location = vac.location
	AND da.date = vac.date
	Where da.continent is not null 
 	--Order by 2,3
	
	Select *, (Per_Country_Vaccinations_till_date/population)*100 as percentage_People
	From PercentPopulationVaccinated
