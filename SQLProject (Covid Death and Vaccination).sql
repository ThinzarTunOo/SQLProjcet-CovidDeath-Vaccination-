SELECT *
FROM ProfilioProject..[Covid vaccinatioin]
order by 3,4

SELECT *
FROM ProfilioProject..[Covid Death]
WHERE continent is not null
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From ProfilioProject..[Covid Death]
Order by 1,2

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From ProfilioProject..[Covid Death]
Order by 1,2

--Looking at total cases Vs total deaths in '%States%' Location
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From ProfilioProject..[Covid Death]
Where location like '%States%'
Order by 1,2

--Looking at total cases Vs population in '%States%' Location
--show percentage of pupulation get covid
SELECT location, date, total_cases,population, (total_cases/population)*100 As CasePercentage
From ProfilioProject..[Covid Death]
Where location like '%States%'
Order by 1,2

--Looking at highest infection rate compared to population
SELECT location, population, Max(total_cases) as HightestInfectionRate, MAX((total_cases/population)*100) As CasePercentageAffect
From ProfilioProject..[Covid Death]
WHERE continent is not null
Group by location, population
Order by CasePercentageAffect desc

--showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) As TotalDeathCount
From ProfilioProject..[Covid Death]
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

--showing contintents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From ProfilioProject..[Covid Death]
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Number
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProfilioProject..[Covid Death]
where continent is not null
Group by date
order by 1,2


--looking at total pupulation Vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100
From ProfilioProject..[Covid Death] dea
Join ProfilioProject..[Covid vaccinatioin] vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PropVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100
From ProfilioProject..[Covid Death] dea
Join ProfilioProject..[Covid vaccinatioin] vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PropVsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	Datae datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated numeric
	)
	insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100
From ProfilioProject..[Covid Death] dea
Join ProfilioProject..[Covid vaccinatioin] vac
	on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store for later visualization
Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/Population)*100
From ProfilioProject..[Covid Death] dea
Join ProfilioProject..[Covid vaccinatioin] vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
From #PercentPopulationVaccinated