--SELECT * FROM [SQL_PROJECT-1].dbo.Coviddeaths ORDER BY 3,4

--SELECT * FROM [SQL_PROJECT-1].dbo.Covidvaccination ORDER BY 3,4

--Selecting the data that will be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [SQL_PROJECT-1].dbo.Coviddeaths ORDER BY 1,2

--Looking at the total cases vs the total deaths

SELECT Location, SUM(CAST(total_cases as BIGINT)) AS Totalcases, SUM(CAST(total_deaths AS BIGINT)) AS Totaldeaths, 
CONCAT(ROUND((SUM(CAST(total_deaths as FLOAT)) / SUM(CAST(total_cases AS FLOAT))) * 100,2),'%') AS DeathRate
FROM [SQL_PROJECT-1].dbo.Coviddeaths 
GROUP BY Location 

/* this code above shows the likelihood of the survival of a Covid contracted patient
respective to the country he lives in
*/

--Looking at the total cases vs the population

SELECT Location, date, total_cases, Population, CONCAT((CAST(total_cases AS FLOAT) / CAST(Population AS FLOAT)) * 100 , '%') AS DeathRate
FROM [SQL_PROJECT-1].dbo.Coviddeaths 
WHERE total_cases <> ''

/* this code above shows the percentage of the population who got Covid
*/

-- Looking at the countries with highest infection rate compared to the population

SELECT Location, Population, MAX(total_cases) AS Max_cases,
ROUND((MAX(total_cases) / CAST(Population AS FLOAT)) *100,5) AS InfectionRate
FROM [SQL_PROJECT-1].dbo.Coviddeaths
GROUP BY Location, Population
ORDER BY InfectionRate DESC

/* this code above shows the percentage of Covid cases compared to the 
country's population in descending order. this shows the country/ countries
that has the highest Covid cases per population.
*/

--Looking at the countries with highest death count per population

SELECT Location, CAST(MAX(total_deaths) AS BIGINT) AS DeathCount
FROM [SQL_PROJECT-1].dbo.Coviddeaths
WHERE Location NOT IN ('Asia' , 'Africa')
GROUP BY Location
ORDER BY DeathCount DESC

/* this code above shows the highest total death count of the countries
by the countries caused by Covid 19.
*/

--Looking at the continents with highest death count per population

SELECT Continent, CAST(MAX(total_deaths) AS BIGINT) AS DeathCount
FROM [SQL_PROJECT-1].dbo.Coviddeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY DeathCount DESC

-- GLOBAL NUMBERS

SELECT  SUM(new_cases) AS NewCases, SUM(new_deaths) AS Deaths, (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)))*100 AS DeatheRatePercentage
FROM [SQL_PROJECT-1].dbo.Coviddeaths
GROUP BY date
ORDER BY date

/* This above code shows the number of  news cases, death everyday and the death rate in percentage
*/


--Looking at the Total population and the vaccination using CTE

With popsvsvac (location, population, new_vaccinations, Vaccination_Rate) as (
SELECT DEATH.location ,death.population, SUM(CAST(vac.new_vaccinations AS BIGINT)) AS Total_Vaccination, 
CONCAT(ROUND((SUM(CAST(vac.new_vaccinations AS FLOAT)) / death.population ),3),'%') AS Vaccination_Rate
FROM 
[SQL_PROJECT-1].dbo.Coviddeaths AS DEATH
JOIN [SQL_PROJECT-1].dbo.Covidvaccination AS VAC
ON DEATH.date = VAC.date AND DEATH.location = VAC.location
GROUP BY DEATH.location, DEATH.population
--ORDER BY DEATH.location
)

SELECT * FROM popsvsvac

/* This code above gives data of the vaccinate rate of the population of the countries
*/

--TEMP TABLE


DROP TABLE IF EXISTS #PopulationVaccinatePercen;

CREATE TABLE #PopulationVaccinatePercen
(Location nvarchar(255),
Population int,
new_vaccination nvarchar(255),
Vaccination_Rate nvarchar(255)
)

INSERT INTO #PopulationVaccinatePercen
SELECT DEATH.location ,death.population, SUM(CAST(vac.new_vaccinations AS BIGINT)) AS Total_Vaccination, 
CONCAT(ROUND((SUM(CAST(vac.new_vaccinations AS FLOAT)) / death.population ),3),'%') AS Vaccination_Rate
FROM 
[SQL_PROJECT-1].dbo.Coviddeaths AS DEATH
JOIN [SQL_PROJECT-1].dbo.Covidvaccination AS VAC
ON DEATH.date = VAC.date AND DEATH.location = VAC.location
GROUP BY DEATH.location, DEATH.population
ORDER BY DEATH.location

SELECT * FROM #PopulationVaccinatePercen

-- Creating view to store data for later visualization

CREATE VIEW PercentPopulation as
SELECT DEATH.location ,death.population, SUM(CAST(vac.new_vaccinations AS BIGINT)) AS Total_Vaccination, 
CONCAT(ROUND((SUM(CAST(vac.new_vaccinations AS FLOAT)) / death.population ),3),'%') AS Vaccination_Rate
FROM 
[SQL_PROJECT-1].dbo.Coviddeaths AS DEATH
JOIN [SQL_PROJECT-1].dbo.Covidvaccination AS VAC
ON DEATH.date = VAC.date AND DEATH.location = VAC.location
GROUP BY DEATH.location, DEATH.population

SELECT * FROM PercentPopulation
