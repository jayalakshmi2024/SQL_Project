-- Created conditions,encounters,immunizations and patients tables
CREATE TABLE conditions (
START DATE
,STOP DATE
,PATIENT VARCHAR(1000)
,ENCOUNTER VARCHAR(1000)
,CODE VARCHAR(1000)
,DESCRIPTION VARCHAR(200)
);

CREATE TABLE encounters (
 Id VARCHAR(100)
,START TIMESTAMP
,STOP TIMESTAMP
,PATIENT VARCHAR(100)
,ORGANIZATION VARCHAR(100)
,PROVIDER VARCHAR(100)
,PAYER VARCHAR(100)
,ENCOUNTERCLASS VARCHAR(100)
,CODE VARCHAR(100)
,DESCRIPTION VARCHAR(100)
,BASE_ENCOUNTER_COST FLOAT
,TOTAL_CLAIM_COST FLOAT
,PAYER_COVERAGE FLOAT
,REASONCODE VARCHAR(100)
--,REASONDESCRIPTION VARCHAR(100)
);

CREATE TABLE immunizations
(
 DATE TIMESTAMP
,PATIENT varchar(100)
,ENCOUNTER varchar(100)
,CODE int
,DESCRIPTION varchar(500)
--,BASE_COST float
);

CREATE TABLE patients
(
 Id VARCHAR(100)
,BIRTHDATE date
,DEATHDATE date
,SSN VARCHAR(100)
,DRIVERS VARCHAR(100)
,PASSPORT VARCHAR(100)
,PREFIX VARCHAR(100)
,FIRST VARCHAR(100)
,LAST VARCHAR(100)
,SUFFIX VARCHAR(100)
,MAIDEN VARCHAR(100)
,MARITAL VARCHAR(100)
,RACE VARCHAR(100)
,ETHNICITY VARCHAR(100)
,GENDER VARCHAR(100)
,BIRTHPLACE VARCHAR(100)
,ADDRESS VARCHAR(100)
,CITY VARCHAR(100)
,STATE VARCHAR(100)
,COUNTY VARCHAR(100)
,FIPS INT 
,ZIP INT
,LAT float
,LON float
,HEALTHCARE_EXPENSES float
,HEALTHCARE_COVERAGE float
,INCOME int
,Mrn int
);

select * from patients;
select * from immunizations;
select * from encounters;
AGE(current_date,P.birthdate) as age,


with cte as
(select patient,min(date) as earlydate from immunizations 
where description = 'Seasonal Flu Vaccine' and date between '2022-01-01 00:00:00' and '2022-12-31 23:59:00'
group by patient
order by earlydate),
active_patients as
(select distinct patient,AGE(current_date,P.birthdate) as age from encounters e join patients p on p.id=e.patient 
 where start between '2020-01-01 00:00' and '2022-12-31 23:59' and p.deathdate is null and 
EXTRACT(EPOCH FROM age('2022-12-31',pat.birthdate)) / 2592000>=6
order by age)
select p.id,p.birthdate,concat(p.first,' ' ,p.last) as name ,
extract(year from AGE(current_date,P.birthdate)) as age,p.ethnicity,p.Gender,p.Zip,p.race,p.county,
c.earlydate,
case when c.patient is not null then 1
else 0
end as flu_shot_2022
from patients p  left join cte c on c.patient = p.id where p.id in (select patient from active_patients)



select AGE(current_date,birthdate) as age from patients




