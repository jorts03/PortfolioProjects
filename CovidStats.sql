-- Global Covid Statistics from January 2020 through April 2021
SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Data Selection
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths ORDER BY location, date


-- Total Cases vs Total Deaths in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentage_dead
FROM PortfolioProject..CovidDeaths 
WHERE location = 'United States'
ORDER BY location, date 


-- Global Total Cases vs Total Population 
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentage_infected
FROM PortfolioProject..CovidDeaths 
ORDER BY location, date


-- Highest Infection Rate vs Total Population
SELECT location, MAX(total_cases) as infection_high, population, MAX((total_cases/population)) * 100 AS percentage_infected_high
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population
ORDER BY percentage_infected_high DESC


-- Highest Death Count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY total_deaths DESC


-- Deaths per Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY total_deaths DESC


-- Day with highest death count
SELECT date, SUM(CAST(new_deaths AS INT)) AS deaths_per_day
FROM PortfolioProject..CovidDeaths
GROUP BY date
ORDER BY deaths_per_day DESC


-- Day with highest death percentage
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS percentage_dead
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY percentage_dead DESC


-- Total death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS total_percentage_dead
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- Total Population vs Total Vaccination by date
WITH PopVSVax (location, population, date, new_vaccinations, rolling_vax_sum)
AS
(
SELECT vax.location, population, vax.date, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER(PARTITION BY vax.location ORDER BY vax.location, vax.date) AS rolling_vax_sum
FROM PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vax
ON deaths.location = vax.location AND deaths.date = vax.date
WHERE vax.new_vaccinations IS NOT NULL
)
SELECT *, rolling_vax_sum/population * 100 AS percentage_vaxxed
FROM PopVSVax


-- Views
CREATE VIEW CasesVSDeathsUSA AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentage_dead
FROM PortfolioProject..CovidDeaths 
WHERE location = 'United States'

CREATE VIEW InfRateVSPop AS
SELECT location, MAX(total_cases) as infection_high, population, MAX((total_cases/population)) * 100 AS percentage_infected_high
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population

CREATE VIEW PopVSVax AS
SELECT vax.location, population, vax.date, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER(PARTITION BY vax.location ORDER BY vax.location, vax.date) AS rolling_vax_sum
FROM PortfolioProject..CovidDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vax
ON deaths.location = vax.location AND deaths.date = vax.date
WHERE vax.new_vaccinations IS NOT NULL

