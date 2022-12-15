SELECT *
FROM COVIDDEATHS
WHERE continent is NOT NULL
ORDER BY 3,4 desc;

-- SELECT *
-- FROM coviddeaths
-- ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by 1,2;

-- looking at total cases vs total deaths
--chance of death if you contracted covid in your country

SELECT location, date, total_cases, total_deaths, round(((total_deaths/total_cases) * 100),2) as DeathPercentage
FROM coviddeaths
WHERE location ILIKE 'United States'
order by 1,2;

-- total cases vs population. (US)
-- what % of population got covid

SELECT location, date, total_cases, population, round(((total_cases/population) * 100),2) as CaughtCovidPercentage
FROM coviddeaths
WHERE location ILIKE 'United States'
order by 1,2;

-- Looking at countries with highest infection rate compared to population.

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(round(((total_cases/population) * 100),2)) as CaughtCovidPercentage
FROM coviddeaths
GROUP BY 1,2
ORDER BY CaughtCovidPercentage desc;

-- looking at countries with highest deaths and death rate compared to population.

SELECT location, MAX(total_deaths) as deathcount, MAX(round(((total_deaths/population) * 100),2)) as DeathPercentage
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY deathcount desc;

--LET'S BREAK IT DOWN BY CONTINENT

SELECT location, MAX(total_deaths) as deathcount, MAX(round(((total_deaths/population) * 100),2)) as DeathPercentage
FROM coviddeaths
WHERE continent is NULL
GROUP BY location
ORDER BY deathcount desc;


--global numbers 

--total 
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,  round((sum(new_deaths)/ sum(new_cases))*100, 2) as DeathPercentage
FROM coviddeaths
WHERE continent is not null
order by 1,2;

--day by day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,  round((sum(new_deaths)/ sum(new_cases))*100, 2) as DeathPercentage
FROM coviddeaths
WHERE continent is not null
group by date
order by 1,2;


-- Looking at new vaccinations per day 

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- WITH CTE

with PopVSVac as (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3)

-- looking at percentage vaccinated over time
SELECT *, round(rollingpeoplevaccinated/population*100, 2)as RollingPercentageVaccinated
FROM PopVSvac;


--Temp Table

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

SELECT *, round(rollingpeoplevaccinated/population*100, 2)as RollingPercentageVaccinated
FROM PercentPopulationVaccinated;

-- creating view to store data for later visualizations

Create View PercentPopulationVaccinatedView as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


