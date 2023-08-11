SELECT*
FROM covid_data..CovidDeaths
	ORDER  BY 3,4
	
	
	
	
--	SELECT*
--FROM covid_data..CovidVaccinations
--	ORDER  BY 3,4



--Selecting data for exploration


SELECT location,date,total_cases,total_deaths,new_cases,population
FROM covid_data..CovidDeaths
ORDER BY 1,2



--looking at total cases vs total deaths
--showing the percentage per total cases of death in the states

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM covid_data..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2





--now we are going to look at total cases per population
SELECT location,date,total_cases,population,(total_cases/population)*100 as population_perc
FROM covid_data..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2



--looking at countries highest infection rate compared to population
SELECT location,population,max(total_cases) as highest_case_count ,max((total_cases/population))*100 as perc_pop_infected
FROM covid_data..CovidDeaths
GROUP BY location,population
ORDER BY perc_pop_infected DESC


--countries with highest death count per population
-- total_death is not the right data type we have to cast it as a int
-- adding the where statement its an issue with the data where it shows the whole continent
SELECT location,max(cast(total_deaths as int)) as death_count
FROM covid_data..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY death_count DESC
  

-- now lets checkout the continent values
SELECT continent,max(cast(total_deaths as int)) as death_count
FROM covid_data..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_count DESC

--global numbers
SELECT date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_perc
FROM covid_data..CovidDeaths
WHERE continent is not null
 GROUP BY date 
 ORDER BY 1,2
  
  --TOTAL NUMBERS
  SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_perc
FROM covid_data..CovidDeaths
WHERE continent is not null
 ORDER BY 1,2
  -- -- ------------------------
  -- joining vaccination and death table


  SELECT *
  FROM covid_data..CovidDeaths  AS cd
  JOIN covid_data..CovidVaccinations as cv
  ON cd.location = cv.location AND cd.date = cv.date
   

   -- total population vs vaccination
   
   
   SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
   SUM(CAST(cv.new_vaccinations as int))OVER   (PARTITION BY cd.location order by cd.location,cd.date) as rolling_vaccination
  FROM covid_data..CovidDeaths  AS cd
  JOIN covid_data..CovidVaccinations as cv
  ON cd.location = cv.location AND cd.date = cv.date
   WHERE cd.continent is not null
   ORDER By  2,3
     
--- using cte for rolling number over population
with t1 as (SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
   SUM(CAST(cv.new_vaccinations as int))OVER   (PARTITION BY cd.location order by cd.location,cd.date) as rolling_vaccination
  FROM covid_data..CovidDeaths  AS cd
  JOIN covid_data..CovidVaccinations as cv
  ON cd.location = cv.location AND cd.date = cv.date
   WHERE cd.continent is not null
   )
   select*,(rolling_vaccination/population)*100 as rolling_vac_perc
   FROM t1
   -- using temporary table
   CREATE TABLE
