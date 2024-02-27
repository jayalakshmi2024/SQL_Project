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
extract(month from age('2022-12-31',p.birthdate))>=6
order by age)
select p.id,p.birthdate,concat(p.first,' ' ,p.last) as name ,
extract(year from AGE(current_date,P.birthdate)) as age,p.ethnicity,p.Gender,p.Zip,p.race,p.county,
c.earlydate,
case when c.patient is not null then 1
else 0
end as flu_shot_2022
from patients p  left join cte c on c.patient = p.id where p.id in (select patient from active_patients)



select AGE(current_date,birthdate) as age from patients




