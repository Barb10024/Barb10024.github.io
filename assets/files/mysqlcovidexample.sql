Use covid;
/*
Exploratory Data Analysis(EDA) of Covid-19 dataset from Our World in Data.
SKILLS USED:  JOINS, COMMON TABLE EXPRESSION(CTE's), TEMP TABLES, WINDOW FUNCTIONS, AGGREGATE FUNCTIONS
*/

-- #1 Continents with Highest Death Count per Population

SELECT
	location, 
    MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- #2 GLOBAL NUMBERS

SELECT
	SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths, 
    SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY  continent,
		  location;


-- #3 Total Population vs Vaccinations
-- Shows Rolling Total Population at each location that has recieved at least one Covid Vaccine

SELECT 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.location 
									ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
	JOIN covidvaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location,
		 date;


 -- #4 Using a Common Table Expression(CTE) to perform percentage calculation on PARTITION BY in previous query #3

 WITH pop_vs_vac (
	continent, 
    location, 
    date, 
    population, 
    new_vaccinations, 
    rolling_people_vaccinated
    )
AS
(
SELECT
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY  dea.Location 
									ORDER BY location, date) AS rolling_people_vaccinated
FROM coviddeaths dea
	JOIN covidvaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated / population) * 100 AS rolling_percentage
FROM pop_vs_vac;


-- #5 Using Temp Table to perform percentage calculation on PARTITION BY  in previous query #3
/**  I haven't figured out how to insert into a temporary table from
a pre-existing table without throwing an error mismatch in the number of fields.  **/

DROP TEMPORARY TABLE IF EXISTS percent_pop_vaccinated;
CREATE TEMPORARY TABLE percent_pop_vaccinated (
	continent VARCHAR(10),
	location VARCHAR(30),
	date DATETIME,
	population BIGINT,
	new_vaccinations BIGINT,
	rolling_people_vaccinated BIGINT
);
INSERT INTO  percent_pop_vaccinated
SELECT 
	dea.continent, 
	dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations) OVER (PARTITION BY dea.Location 
											ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM coviddeaths dea
	JOIN covidvaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.location IS NOT NULL

SELECT *, (rolling_people_vaccinated / population) * 100 AS rolling_percentage
FROM percent_pop_vaccinated;
