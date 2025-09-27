/*
A data set consist of 25 Netflix in 'users' table from US(11 record), CA(7 records), MX(7) and their movie viewing activity in 'Activity' table. There are total 58 movies.
Our task is to engineer these new features for each user, based on their activity:
- Date from the first movie they finished
- Name of the first movie they finished
- Date from the last movie they finished
- Name of the last movie they finished
- Movies started
- Movies finished 
Steps : 
     1.  created subquery "user_summary" to get the 
         - Count of movies started and movies finished 
         - Date from the first and last movie user finished 
	2. joined user_summary with activity to get Name of the first and last movie they finished

Note : Below are the users who has finished watching two movies in a day: 
       - User 16 has watched two first movies Minari and Parasite on 2025-04-30.
       - User 17 has watched Big Hero 6 and Shrek on 2025-05-11 as their last two movies.
       - User 20 has watched Luca and The Wolf of Wall Street on 2024-11-27 as their last two movies.
*/

-- Drop temp table if already exists; 
DROP TABLE temp;

-- Created temporary table to store the output of the query; 
CREATE TEMPORARY TABLE temp AS 
WITH user_summary AS(
SELECT 		 
			 user_id,
			 MIN(CASE WHEN finished = 1 THEN activity.date END ) AS date_first_movie, 
             MAX(CASE WHEN finished = 1 THEN activity.date END ) AS date_last_movie,
             COUNT(activity.id) movies_started, 
             COUNT(CASE WHEN activity.finished THEN activity.id END ) AS movies_finished
from  activity 
group by user_id
order by user_id desc
)
select 		users.id, 
            users.created_at,
            us.date_first_movie,
			min(first_movie_details.movie_name) first_movie_name, 
            us.date_last_movie,
            max(last_movie_details.movie_name) last_movie_name  ,
            us.movies_started,
            us.movies_finished    
from 		users
inner join  user_summary us
on 			users.id = us.user_id
left join 	activity first_movie_details 
on 			us.user_id = first_movie_details.user_id  
and 		first_movie_details.finished = 1 
and 		first_movie_details.date = us.date_first_movie 
left join 	activity  last_movie_details 
on 			us.user_id = last_movie_details.user_id  
and 		last_movie_details.finished = 1 
and 		last_movie_details.date = us.date_last_movie 
group by    users.id, 
            users.created_at,
            us.date_first_movie,
            us.date_last_movie,
            us.movies_started,
            us.movies_finished;

select 	* 
from 	temp;

-- How many users have "Fight Club" as the last film they've seen? Answer is 3
select 	count(id) as cnt_Fight_Club  
from 	temp 
where 	last_movie_name = 'Fight Club';
