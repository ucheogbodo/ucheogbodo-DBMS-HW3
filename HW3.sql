-- Name: Uche Ogbodo
-- DBMS HW#3

-- Created database 'global_energy'
create database global_energy;
use global_energy;

-- Table 1: Countries
-- countrycode is the primary key
create table countries (
	CountryCode varchar(10) primary key,
    CountryName varchar(100),
    Continent varchar(100)
);

-- Table 2: Operators
-- operatorid is the primary key
-- Foreign key HeadquartersCountry references countries(CountryCode)
create table operators (
	OperatorID int primary key,
    OperatorName varchar(100),
    HeadquartersCountry varchar(100),
    foreign key(HeadquartersCountry) references countries(CountryCode)
);

-- Table 3: Fuel Types
-- fuelid is the primary key
create table fuel_types (
	FuelID int primary key,
    FuelCategory varchar(100),
    FuelName varchar(100)
);

-- Table 4: Power Plants
-- plantid is the primary key

-- 3 Foreign Keys
-- CountryCode references countries(CountryCode)
-- OperatorID references operators(OperatorID)
-- FuelID references fuel_types(FuelID)

create table power_plants(
	PlantID int primary key,
    PlantName varchar(100),
    CountryCode int,
    OperatorID int,
    FuelID int,
    foreign key(CountryCode)
		references countries(CountryCode),
	foreign key(OperatorID)
		references operators(OperatorID),
	foreign key(FuelID)
		references fuel_types(FuelID),
	CapacityMW int,
    CommissionYear int
);

-- Table 5: Generation Records
-- Composite Primary Keys: (plantid,year)
-- Foreign key: plantid references power_plants(PlantID)
create table generation_records(
	plantid int,
    year int,
    generationgwh decimal(10,2),
    primary key(plantid, year),
    foreign key(plantid) references power_plants(PlantID)
);

-- Table 6: Emission Metrics
-- Composite Primary Keys: (plantid, year)
-- Foreign Key: plantid references power_plant(PlantID
create table emission_metrics (
	plantid int,
    year int,
    co2emissiontonnes decimal(12,2),
    primary key(plantid, year),
    foreign key(plantid) references power_plants(PlantID)
);

-- Part II: SQL Queries
-- Q1
select 
	power_plants.PlantName, 
	countries.CountryName, 
	operators.OperatorName, 
    fuel_types.FuelCategory, 
    fuel_types.FuelName,
    power_plants.CapacityMW,
    power_plants.CommissionYear
from power_plants
join countries
	on power_plants.CountryCode = countries.CountryCode
join operators
	on power_plants.OperatorID = operators.OperatorID
join fuel_types
	on power_plants.FuelID = fuel_types.FuelID
order by power_plants.CapacityMW desc;

-- Q2
select
	power_plants.PlantName,
    power_plants.CountryCode,
    generation_records.year,
    generation_records.generationgwh,
    emission_metrics.co2emissionstonnes
from power_plants
join generation_records
	on power_plants.PlantID = generation_records.PlantID
join emission_metrics
	on power_plants.PlantID = emission_metrics.PlantID
    and generation_records.year = emission_metrics.year
where generation_records.year = 2024
order by emission_metrics.co2emissionstonnes asc;

-- Q3
select
	power_plants.PlantName,
    power_plants.CountryCode,
    generation_records.year,
    generation_records.generationgwh,
    emission_metrics.co2emissionstonnes
from power_plants
join generation_records
	on power_plants.PlantID = generation_records.plantID
join emission_metrics
	on power_plants.PlantID = emission_metrics.plantid
    and generation_records.year = emission_metrics.year
where generation_records.year = 2024
order by emission_metrics.co2emissionstonnes asc;

-- Q4
with OperatorGeneration as (
	select
		power_plants.OperatorID,
        sum(generation_records.generationgwh) as TotalGenerationGWh
	from power_plants
    inner join generation_records
		on power_plants.PlantID = generation_records.plantid
	group by power_plants.OperatorID
)
select
	operators.OperatorName,
    operators.HeadquartersCountry,
    OperatorGeneration.TotalGenerationGWh
from operators
inner join OperatorGeneration
	on operators.OperatorID = OperatorGeneration.OperatorID
order by OperatorGeneration.TotalGenerationGWh desc;

-- Q5
with CountryGeneration as (
	select
		power_plants.CountryCode,
        sum(generation_records.generationgwh) as TotalGenerationGWh
	from power_plants
    inner join generation_records
		on power_plants.PlantID = generation_records.plantid
	group by power_plants.CountryCode
),
CountryEmissions as (
	select
		power_plants.CountryCode,
        sum(emission_metrics.co2emissionstonnes) as TotalCO2EmissionsTonnes
	from power_plants
    inner join emission_metrics
		on power_plants.PlantID = emission_metrics.plantid
	group by power_plants.CountryCode
)
select
	countries.CountryName,
    CountryGeneration.TotalGenerationGWh,
    CountryEmissions.TotalCO2EmissionsTonnes
from countries
inner join CountryGeneration
	on countries.CountryCode = CountryGeneration.CountryCode
inner join CountryEmissions
	on countries.CountryCode = CountryEmissions.CountryCode
order by CountryGeneration.TotalGenerationGWh desc;