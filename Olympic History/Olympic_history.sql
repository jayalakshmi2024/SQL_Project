---------------------SQL PROJECT ON OLYMPIC HISTORY---------------------------------------

--1.How many olympic games have been held
SELECT COUNT(DISTINCT(GAMES)) AS TOTAL_OLYMPIC_GAMES FROM OLYMPIC_HISTORY
--2.List down all olympics held so far
SELECT DISTINCT YEAR,SEASON,CITY FROM OLYMPIC_HISTORY ORDER BY YEAR

--3.Total number of nations participated in each olympic games
WITH ALL_COUNTRIES AS
(SELECT  GAMES ,NR.REGION  FROM OLYMPIC_HISTORY OH 
JOIN OLYMPIC_HISTORY_NOC_REGIONS NR ON OH.NOC = NR.NOC),
TOTAL_COUNTRIES AS
(SELECT DISTINCT GAMES , REGION FROM ALL_COUNTRIES)
SELECT GAMES,COUNT(REGION)AS TOTAL 
FROM TOTAL_COUNTRIES GROUP BY GAMES ORDER BY GAMES;
--4.Which year saw the highest and lowest number of countries
WITH ALL_COUNTRIES AS
(SELECT  GAMES ,NR.REGION  FROM OLYMPIC_HISTORY OH 
JOIN OLYMPIC_HISTORY_NOC_REGIONS NR ON OH.NOC = NR.NOC),

TOTAL_COUNTRIES AS
(SELECT DISTINCT GAMES , REGION FROM ALL_COUNTRIES),
COUNTRIES_COUNT AS
(SELECT GAMES,COUNT(REGION)AS TOTAL 
FROM TOTAL_COUNTRIES GROUP BY GAMES ORDER BY GAMES)

SELECT  DISTINCT 


CONCAT(FIRST_VALUE(GAMES) OVER(ORDER BY TOTAL),'-',FIRST_VALUE(TOTAL) OVER (ORDER BY TOTAL)) AS HIGHEST_COUNTRIES,
CONCAT(FIRST_VALUE(GAMES) OVER(ORDER BY TOTAL DESC),'-',FIRST_VALUE(TOTAL) OVER (ORDER BY TOTAL DESC)) AS LOWEST_COUNTRIES
FROM COUNTRIES_COUNT;
--5.Which nation participated in all of the olympics
 with tot_games as
              (select count(distinct games) as total_games
              from olympic_history),
          countries as
              (select games, nr.region as country
              from olympic_history oh
              join olympic_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;
--6.sport that was held all the summer in olympics
WITH SPORT_TABLE AS
(SELECT DISTINCT(YEAR),SPORT,SEASON FROM OLYMPIC_HISTORY WHERE SEASON = 'Summer' ORDER BY YEAR)
SELECT SPORT,COUNT(SPORT) AS TOTAL
FROM SPORT_TABLE GROUP BY SPORT HAVING 
COUNT(SPORT) IN (SELECT COUNT(DISTINCT(YEAR)) FROM OLYMPIC_HISTORY WHERE SEASON = 'Summer');
							  
--7.which games were playes only once in the olympics
with sport_count as
(select distinct(sport),year from olympic_history group by year,sport)
select sport,count(sport) from sport_count group by sport having count(sport) = 1;
							  
--8.Total number of sports played in each olympic games
with total_games as
(select distinct(games),sport from olympic_history order by games)
select games,count(sport) as counts from total_games group by games order by counts desc;
							  
--9.Oldest athletes to win a gold medal
with update_age as 
(select name,medal,
cast(case when age = 'NA' then '0' else age end as int) as age
from olympic_history),
ranking as
(select *, rank() over(order by age desc) as rnk
 from update_age where medal='Gold')
    select *
    from ranking
    where rnk = 1;
--10.Ratio of female to male in all olympic games

select sum(case when sex = 'M' then 1 else 0 end) as count_male,
  sum(case when sex = 'F' then 1 else 0 end) as count_female,                        
  concat('1:',round(sum(case when sex = 'M' then 1 else 0 end)/sum(case when sex = 'F' then 1 else 0 end)::decimal ,2)) as ratio
 from olympic_history;
 --another solution
    with t1 as
        	(select sex, count(1) as cnt
        	from olympics_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;

--11.top 5 athletes with more gold medals
with GOLD_MEDAL AS
(SELECT NAME,COUNT(MEDAL) as total ,team 
 FROM OLYMPIC_HISTORY 
 WHERE MEDAL = 'Gold'group by name,team order by total desc),
 ranking as
 (select *,dense_rank() over (order by total desc) as rnk from gold_medal)
  select name,total,team from ranking where rnk <=5;
  
---12.top 5 athletes with more medals including gold,silver and bronze

with GOLD_MEDAL AS
(SELECT NAME,COUNT(MEDAL) as total ,team 
 FROM OLYMPIC_HISTORY
 where medal in ('Gold','Silver','Bronze')
 group by name,team order by total desc),
 ranking as
 (select *,dense_rank() over (order by total desc) as rnk from gold_medal)
  select name,total,team from ranking where rnk <=5;
  
  
--13.top 5 countries to receive more medals
with countries as
(select oh.medal,oh.noc as country,nr.region from olympic_history oh 
join olympic_history_noc_regions nr on oh.noc = nr.noc),
GOLD_MEDAL AS
(SELECT country,COUNT(MEDAL) as total  
 FROM countries
 where medal in ('Gold','Silver','Bronze')
 group by country order by total desc),
 ranking as
 (select *,dense_rank() over (order by total desc) as rnk from gold_medal)
  select country,total from ranking where rnk <=5;
  
--14. Total silver ,gold and bronze won by each country
create extension tablefunc;
select country,
coalesce(Gold,0) as Gold,
coalesce (Silver,0) as Silver,
coalesce(Bronze,0) as Bronze
from crosstab(
                      'select nr.region,medal,count(medal) from olympic_history oh 
                      join olympic_history_noc_regions nr on oh.noc = nr.noc
                       where medal <>''NA'' group by nr.region,medal order by nr.region,medal',
	                    'values (''Bronze''),(''Silver''),(''Gold'')')
						as final_result(country varchar,Bronze bigint,Gold bigint,Silver bigint)
						order by Bronze desc,Silver desc,Gold desc;


--15.List of silver,gold and bronze won by each country in each games
select 
      substring(games,1,position(' - ' in games)-1) as games,
      substring(games,position(' - ' in games)+ 3 )as country,
      coalesce(Gold,0) as Gold,
      coalesce(Silver,0) as Silver,
      coalesce(Bronze,0) as Bronze
from crosstab(
               'select concat(games, '' - '', nr.region) as games,medal,count(medal) as total from olympic_history oh 
                join olympic_history_noc_regions nr on nr.noc = oh.noc
                 where medal<>''NA''
                group by games,nr.region,medal
                order by games,medal',
                'values(''Bronze''),(''Gold''),(''Silver'')')
                as final_result (games text,Bronze bigint,Gold bigint,Silver bigint);
				
 --16. Which country won the most gold,most silver,most bronze in each Olympic games.
with temp as						
(select 
      substring(games_region,1,position(' - ' in games_region)-1) as games,
      substring(games_region,position(' - ' in games_region)+ 3 )as country,
      coalesce(Gold,0) as Gold,
      coalesce(Silver,0) as Silver,
      coalesce(Bronze,0) as Bronze
from crosstab(
               'select concat(games, '' - '', nr.region) as games_region,medal,count(medal) as total from olympic_history oh 
                join olympic_history_noc_regions nr on nr.noc = oh.noc
                 where medal<>''NA''
                group by games,nr.region,medal
                order by games,medal',
                'values(''Bronze''),(''Gold''),(''Silver'')')
                as final_result (games_region text,Bronze bigint,Gold bigint,Silver bigint)
				order by games_region)
select distinct games,
concat(first_value(country)over (partition by games order by gold desc),' - ',
max(gold) over (partition by games order by gold desc))
 as max_gold,
 concat(first_value(country)over (partition by games order by silver desc),' - ',
max(silver) over (partition by games order by silver desc))
 as max_silver,
 concat(first_value(country)over (partition by games order by bronze desc),' - ',
max(bronze) over (partition by games order by bronze desc))
 as max_bronze 
from temp order by games;


--17.Which country won the most gold,most silver,most bronze and most medal in each Olympics games.

with temp as						
(select 
      substring(games_region,1,position(' - ' in games_region)-1) as games,
      substring(games_region,position(' - ' in games_region)+ 3 )as country,
      coalesce(Gold,0) as Gold,
      coalesce(Silver,0) as Silver,
      coalesce(Bronze,0) as Bronze
from crosstab(
               'select concat(games, '' - '', nr.region) as games_region,medal,count(medal) as total from olympic_history oh 
                join olympic_history_noc_regions nr on nr.noc = oh.noc
                 where medal<>''NA''
                group by games,nr.region,medal
                order by games,medal',
                'values(''Bronze''),(''Gold''),(''Silver'')')
                as final_result (games_region text,Bronze bigint,Gold bigint,Silver bigint)
				order by games_region),
medal_total as 
(select nr.region as country,games,count(medal)as total from olympic_history oh 
 join olympic_history_noc_regions nr on oh.noc= nr.noc
where medal <>'NA'
group by games,country order by games )

select distinct t.games,
concat(first_value(t.country)over (partition by t.games order by t.gold desc),' - ',
max(t.gold) over (partition by t.games order by t.gold desc))
 as max_gold,
 concat(first_value(t.country)over (partition by t.games order by t.silver desc),' - ',
max(t.silver) over (partition by t.games order by t.silver desc))
 as max_silver,
 concat(first_value(t.country)over (partition by t.games order by t.bronze desc),' - ',
max(t.bronze) over (partition by t.games order by t.bronze desc))
 as max_bronze, 
concat(first_value(tm.country)over (partition by tm.games order by tm.total desc nulls last),' - ',
max(tm.total) over (partition by tm.games order by tm.total desc))as max_value
from temp t join medal_total tm on tm.games = t.games and tm.country = t.country order by t.games;


--18.Countries with no gold and have silver/bronze
with cte as
(select country,
 coalesce(Gold,0)as gold,
 coalesce(Silver,0) as silver,
 coalesce(Bronze,0) as bronze
 from crosstab
 ('select nr.region as country,medal,count(medal) from olympic_history oh 
  join olympic_history_noc_regions nr on oh.noc = nr.noc
 where medal<>''NA''
 group by nr.region,medal
 order by nr.region,medal',
  'values(''Bronze''),(''Gold''),(''Silver'')')
 as result(country varchar,bronze bigint,gold bigint,silver bigint))
 select gold,silver,bronze,country
from cte where (silver>0 or bronze > 0) and (gold=0) order by silver desc nulls last,bronze desc nulls last;

--19.sport in which India won maximum medals
with temp as
(select sport,nr.region,count(medal) as total from olympic_history oh 
join olympic_history_noc_regions nr on oh.noc = nr.noc
where medal<>'NA' and nr.region = 'India'
group by sport,nr.region
order by total desc limit 1),
ranking as
(select *,rank() over (order by total desc) as rnk from temp)
select sport,total from ranking where rnk=1

--20.list the games that India won medals for hockey
select games,sport,count(medal) as total from olympic_history oh 
join olympic_history_noc_regions nr on oh.noc = nr.noc
where medal<>'NA' and nr.region = 'India' and sport = 'Hockey'
group by games,sport
order by total desc















