SELECT * FROM SQL_Data_Eploration..CovidDeaths
order by 3,4

--Visualizing the locations, dates, total cases, total deaths in the different populations 
SELECT * FROM SQL_Data_Eploration..CovidVaccinations
order by 3,4
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM SQL_Data_Eploration..CovidDeaths
order by 1,2 


-- Calculating the likelihood of dying of Covid compared to the number of cases in Canada--  
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_to_cases_%
FROM SQL_Data_Eploration..CovidDeaths
WHERE LOCATION LIKE '%Canada%'
ORDER BY 1,2 


-- Looking at the total cases compared to the populatioln number --
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS Cases_to_population_Percentage
FROM SQL_Data_Eploration..CovidDeaths 
--WHERE LOCATION LIKE '%Canada%' 
ORDER BY 1,2 


-- Countries with the highest infection rates compared to the population-- 

SELECT location, population, MAX(total_cases) AS highest_infection_count , MAX((total_cases/population))*100 
AS highest_infection_rates
FROM SQL_Data_Eploration..CovidDeaths 
GROUP BY Location, population 
ORDER BY highest_infection_rates desc

-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count_population
FROM SQL_Data_Eploration..CovidDeaths 
WHERE continent is not null 
GROUP BY Location, population 
ORDER BY highest_death_count_population desc


-- Showing countries with highest death count per continent
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count_continent
FROM SQL_Data_Eploration..CovidDeaths 
WHERE continent is null 
GROUP BY location
ORDER BY highest_death_count_continent desc


-- Total death in cases per 
SELECT SUM(CAST (new_cases AS INT)) AS Total_Cases, SUM(CAST (new_deaths AS INT)) AS Total_Deaths, 
SUM(Cast(new_deaths AS int))/SUM(new_cases)*100 as Death_Percentage
FROM SQL_Data_Eploration..CovidDeaths 

 
 -- Looking at total population vs Vaccination 
 SELECT * 
 FROM SQL_Data_Eploration..CovidDeaths Death
 JOIN SQL_Data_Eploration..CovidVaccinations Vaccination
  ON death.location = vaccination.location
  and Vaccination.date = Vaccination.date


  --USING CTE
  with PopVsVac (continent, Location, Date, Population, new_vaccinations, TotalVaccinationsNumber) 
  as 
  (
  -- total population vs vaccination 
  SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
   SUM(Cast(vaccination.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date) as TotalVaccinationsNumber
   --, (TotalVaccinationsNumber/population)*100
  FROM SQL_Data_Eploration..CovidDeaths Death
  JOIN SQL_Data_Eploration..CovidVaccinations Vaccination
  ON death.location = vaccination.location
  and Vaccination.date = Vaccination.date
  WHERE death.continent is not null
  --order by 2,3
  )
  SELECT * , (TotalVaccinationsNumber/Population)*100
  FROM PopVsVac



  --Creating Temporary Table 
  Drop table if exists PercentPopulationVaccinated
  CREATE TABLE PercentPopulationVaccinated
  (Continent nvarchar (255),
  Location nvarchar (255),
  Date datetime,
  Population numeric,
  New_Vaccination numeric,
  TotalVaccinationsNumber numeric
  )
  insert into PercentPopulationVaccinated
  SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
   SUM(Cast(vaccination.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)
   as TotalVaccinationsNumber
  FROM SQL_Data_Eploration..CovidDeaths Death
  JOIN SQL_Data_Eploration..CovidVaccinations Vaccination
  ON death.location = vaccination.location
  and Vaccination.date = Vaccination.date
 -- WHERE death.continent is not null
Select * , (TotalVaccinationsNumber/Population)*100
from PercentPopulationVaccinated


-- Creating view to store data for later visulaization using Tableau

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
   SUM(Cast(vaccination.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)
   as TotalVaccinationsNumber
  FROM SQL_Data_Eploration..CovidDeaths Death
  JOIN SQL_Data_Eploration..CovidVaccinations Vaccination
  ON death.location = vaccination.location
  and Vaccination.date = Vaccination.date
 WHERE death.continent is not null
 
 Select * from PercentPopulationVaccinated 

 