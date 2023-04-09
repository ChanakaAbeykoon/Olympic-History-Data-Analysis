create table if not exists athlete_events
(
id	int,
Name varchar(100),
sex	varchar(100),
age	varchar(100),
height varchar(100),
weight varchar(100),
team varchar(100),
noc varchar(100),
games varchar(100),
year int,
season varchar(100),
city varchar(100),
sport varchar(100),
event varchar(100),
medal varchar(100)
)
create table if not exists noc_regions
(
noc varchar(100),
region varchar(100),
notes varchar(100)
)
 select count(*)from athlete_events;
 
 --Q 01 find the total no of Olympic Games held as per the dataset.
 
select count(distinct games) as total_olympic_games
from athlete_events;

--Q 02. ist down all the Olympic Games held so far

select distinct ae.year,ae.season,ae.city
from athlete_events ae
order by year;

--03. return the Olympic Games which had the highest participating countries and the lowest participating countries.

with all_countries as
              (select games, nr.region
              from athlete_events ae
              join noc_regions nr ON nr.noc=ae.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;
 
 --5th question Which nation has participated in all of the olympic games?
 
 with tot_games
		 as (select count(distinct games) as total_games
		 from athlete_events),
	countries 
		 as (select nr.region , games
		 from athlete_events ae
		 join noc_regions nr on
		 nr.noc = ae.noc
		 group by nr.region, games),
	participated_country
         as (select region , count(1) as participated
		 from countries 
		 group by region)
	select pc.*
    from participated_country pc
    join tot_games tg on 
    tg.total_games = pc.participated
  
--6th question Which nation has participated in all of the olympic games?

with t1 as
          	(select count(distinct games) as total_games
          	from athlete_events where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from athlete_events where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games;
      
--7th question
--Which Sports were just played only once in the olympics.

with tot_games
		as (select distinct games, sport
			from athlete_events),
	games_count
		as (select sport, count(games) as no_of_games
			from tot_games
			group by sport)
select gc.*,tg.games
from games_count gc
join tot_games tg on
tg.sport = gc.sport
where gc.no_of_games = 1;


--8th question
Fetch the total no of sports played in each olympic games
 select* from athlete_events; 
 
 with t1
 as (select distinct games , sport
 from athlete_events),
 t2 as
	(select games , count(sport) as no_of_sports
    from t1
    group by games)
select * from t2
order by no_of_sports desc;

--9th question
Fetch oldest athletes to win a gold medal
with t1 as	
		(select *
		from athlete_events
		where medal = 'Gold' and age <> 'NA'),
	t2 as 
		(select *,
		rank() over(order by age desc) as rnk
		from t1)
select *
from t2
where rnk = 1;

--10th question
select* from athlete_events;

with M
	as	(select count(sex) as male_count
		from athlete_events
		where sex = 'M'),
	F
    as	(select count(sex) as female_count
		from athlete_events
        where sex = 'F')
select male_count/female_count as ratio
from M 
join F on F.female_count and M.male_count;

--11th question
Fetch the top 5 athletes who have won the most gold medals.

with t1
	as (select name , team, count(medal) as tot_medal
		from athlete_events
		where medal = 'Gold'
        group by name, team
        order by tot_medal desc),
	t2
    as (select name, team, tot_medal,
		dense_rank() over(order by tot_medal desc) as rnk
		from t1)
select name, team ,tot_medal
from t2
where rnk <=5 ;

--12th question
--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

with t1
		as (select name, team, count(medal) as tot_medal
		from athlete_events
		group by name , team
		order by tot_medal desc),
	t2 
		as (select name, team ,tot_medal,
		dense_rank() over(order by tot_medal desc) as rnk
		from t1)
select name, team, tot_medal
from t2
where rnk<=5
order by tot_medal desc;


--13th question
Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.


with t1
	as (select nr.region, count(medal) as tot_medal 
		from athlete_events ae
		join noc_regions nr on
		nr.noc=ae.noc
        where medal <> 'NA'
		group by nr.region
		order by tot_medal desc),
	t2
    as (select *,
    dense_rank() over(order by tot_medal desc) as rnk
    from t1)
select * 
from t2
where rnk<=5
order by rnk;

--14th question
List down total gold, silver and bronze medals won by each country.

	with t1 as
			(select nr.region, medal
			from athlete_events ae
			join noc_regions nr on
			nr.noc=ae.noc
			where medal <> 'NA'
			order by nr.region),
        t2 as
			(select region, medal, count(*) as total
            from t1
            group by region,medal),
		t3 as
			(select *,
            case when medal = 'Gold' then total end as Gold_medals,
            case when medal = 'Silver' then total end as Silver_medal,
            Case when medal = 'Bronze' then total end as Bronze_medal
            from t2)
	select region,coalesce(sum(Gold_medals),0) as 'Gold',
			coalesce(sum(Silver_medal),0) as 'Silver',
            coalesce(sum(Bronze_medal),0) as 'Bronze'
    from t3
    group by region
    
--15th question
List down total gold, silver and bronze medals won by each country corresponding to each olympic games

with t1 as
			(select games,nr.region, medal
			from athlete_events ae
			join noc_regions nr on
			nr.noc=ae.noc
			where medal <> 'NA'
			order by nr.region),
        t2 as
			(select games,region, medal, count(*) as total
            from t1
            group by games,region,medal),
		t3 as
			(select *,
            case when medal = 'Gold' then total end as Gold_medals,
            case when medal = 'Silver' then total end as Silver_medal,
            Case when medal = 'Bronze' then total end as Bronze_medal
            from t2)
	select games,region,coalesce(sum(Gold_medals),0) as 'Gold',
			coalesce(sum(Silver_medal),0) as 'Silver',
            coalesce(sum(Bronze_medal),0) as 'Bronze'
    from t3
    group by region, games
    order by games, region 
    
--18th question
Which countries have never won gold medal but have won silver/bronze medals?

with t1 as
			(select nr.region, medal
			from athlete_events ae
			join noc_regions nr on
			nr.noc=ae.noc
			where medal <> 'NA'
			order by nr.region),
        t2 as
			(select region, medal, count(*) as total
            from t1
            group by region,medal),
		t3 as
			(select *,
            case when medal = 'Gold' then total end as Gold_medals,
            case when medal = 'Silver' then total end as Silver_medal,
            Case when medal = 'Bronze' then total end as Bronze_medal
            from t2),
		t4 as
			(select region,
            coalesce(sum(Gold_medals),0) as 'Gold',
			coalesce(sum(Silver_medal),0) as 'Silver',
            coalesce(sum(Bronze_medal),0) as 'Bronze'
			from t3
			group by region)
select *
from t4
where Gold = 0 and (silver>0 or bronze>0)
order by silver , bronze

--19th question
In which Sport/event, Italy has won highest medals.

with t1
	as  (select sport, medal
		from athlete_events ae
		join noc_regions nr on
		nr.noc = ae.noc
		where nr.region = 'Italy' and medal <> 'NA'),
	t2
    as (select *, count(*) as tot_medal
		from t1
		group by sport, medal),
	t3
	as (select sport, sum(tot_medal) as total_medal
		from t2
        group by sport),
	t4
    as (select *, 
    rank() over(order by total_medal desc) as rnk
	from t3)
select sport, total_medal
from t4
where rnk = 1

--20th question
Break down all olympic games where Italy won medal for Rowing and how many medals in each olympic games

	with t1
		as	(select team,sport, medal, games
			from athlete_events ae
			join noc_regions nr on
			nr.noc = ae.noc
			where nr.region = 'India' and medal <> 'NA'),
		t2
        as (select team,sport, games, count(medal) as medal_count
			from t1
            where sport = 'Hockey'
            group by games, team, sport)
	select * 
    from t2