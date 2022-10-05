--Select *
--FROM [Portfolio Project].dbo.['owid-covid-deaths']
--ORDER BY 3,4

--Select *
--FROM [Portfolio Project].dbo.['owid-covid-vaccinations']
--ORDER BY 3,4

--Select the data that we are going to be using

SELECT 
	location,
	date, 
	total_cases, 
	new_cases,
	total_deaths,
	population
FROM [Portfolio Project].dbo.['owid-covid-deaths']
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 
--Shows the likelihood of dying if you contract covid in your country
SELECT 
	location,
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE 
	location = 'United States'
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the population has contracted covid
SELECT 
	location,
	date, 
	total_cases, 
	population,
	(total_cases/population)*100 as infected_percentage
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE 
	continent is not null 
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to Population 
SELECT 
	location,
	Max(total_cases) as HighestInfectionCount,
	population,
	Max((total_cases/population)*100) as infected_percentage
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE continent is not null
GROUP BY
	location,
	population
ORDER BY infected_percentage desc

--Showing countries with the highest death count per Population 
SELECT 
	location,
	Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE 
	continent is not null 
GROUP BY
	location
ORDER BY
	TotalDeathCount desc

--Lets Break things down by continet 
SELECT 
	continent,
	Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE
	continent is not null 
GROUP BY
	continent
ORDER BY
	TotalDeathCount desc


-- Global Numbers 
SELECT 
	date, 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercntages
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE 
	continent is not null
GROUP BY 
	date
ORDER BY 1,2

--Looking at Total Population vs Vaccination 

SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].dbo.['owid-covid-deaths'] AS dea
join [Portfolio Project].dbo.['owid-covid-vaccinations'] AS vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent is not null
ORDER BY 2,3

--Use a CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RolloingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].dbo.['owid-covid-deaths'] AS dea
join [Portfolio Project].dbo.['owid-covid-vaccinations'] AS vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RolloingPeopleVaccinated/population)*100
FROM PopvsVac



--Creating a view to store data for later visualization

CREATE VIEW PopvsVac as 
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].dbo.['owid-covid-deaths'] AS dea
join [Portfolio Project].dbo.['owid-covid-vaccinations'] AS vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent is not null
--ORDER BY 2,3

CREATE VIEW TotalDeathCount as
SELECT 
	location,
	Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE 
	continent is not null 
GROUP BY
	location
--ORDER BY TotalDeathCount desc

CREATE VIEW InfectionRate as 
SELECT 
	location,
	Max(total_cases) as HighestInfectionCount,
	population,
	Max((total_cases/population)*100) as infected_percentage
FROM [Portfolio Project].dbo.['owid-covid-deaths']
WHERE continent is not null
GROUP BY
	location,
	population
--ORDER BY infected_percentage desc