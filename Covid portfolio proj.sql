SELECT *
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
order by 1,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs total deaths
--shows likelihooh of dying if you contact covid in your country

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--shows what percentage of population got covid

SELECT location,date,population,total_cases, (total_cases/population) *100 as InfectionRatePercentage
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--countries with the highest infection rate compared to population


SELECT location,population,max (total_cases )  as HighestInfectionCount,max ((total_cases/population)) *100 as PercentagePopulationInfected
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
and population is not null
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--Countries with the highest death count per population

SELECT location,max (cast(total_deaths as int) )  as TotalDeathCount
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--ANALYSIS BY CONTINENT



SELECT location,max (cast(total_deaths as int) )  as TotalDeathCount
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with the highest death count per population


SELECT continent,max (cast(total_deaths as int) )  as TotalDeathCount
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date,sum(new_cases ) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)  *100 as DeathPercentage
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


SELECT sum(new_cases ) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)  *100 as DeathPercentage
FROM [PortfolioProject 2].[dbo].[CovidDeaths$]
WHERE continent is not null
ORDER BY 1,2


--TOTAL POPULATION VS VACCINATION

SELECT *
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null
order by 2,3

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location)
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null
order by 2,3

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null
order by 2,3

--USING CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null)
--order by 2,3)

SELECT *,(RollingPeoplevaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null
order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationvaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject 2].dbo.CovidDeaths$ dea
join [PortfolioProject 2].dbo.CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent  is not null
--order by 2,3)

SELECT *
from PercentPopulationVaccinated