/*******Movie-Rating Query Exercises********/
/*Find the titles of all movies directed by Steven Spielberg.*/

SELECT title FROM Movie 
WHERE director = "Steven Spielberg"

/*Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.*/
SELECT distinct year FROM Movie 
INNER JOIN Rating ON
Movie.mID=Rating.mID
WHERE Rating.stars >=4
ORDER BY year ASC



/*Find the titles of all movies that have no ratings.*/
SELECT title FROM Movie
LEFT JOIN Rating ON
Movie.mID=Rating.mID
WHERE stars is NULL

/*Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.*/

SELECT name FROM Reviewer
INNER JOIN Rating
ON Reviewer.rID = Rating.rID
WHERE Rating.ratingDate is NULL

/*Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.*/

SELECT name, title, stars, ratingDate
FROM Movie
INNER JOIN Rating ON
Movie.mID=Rating.mID
INNER JOIN Reviewer ON
Rating.rID = Reviewer.rID
ORDER BY name, title, stars

/*For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.*/

SELECT name, M1.title 
FROM Movie M1
INNER JOIN Rating R1 ON
M1.mID = R1.mID
INNER JOIN Movie M2 ON
M2.mID = R1.mID
INNER JOIN Rating R2 ON
M2.mID = R2.mID
INNER JOIN Reviewer ON
R1.rID = Reviewer.rID
WHERE R2.stars>R1.stars AND R2.ratingDate>R1.ratingDate AND R2.rID = R1.rID AND M1.mID = M2.mID
GROUP BY name, M1.title

/*For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.*/
SELECT title, MAX(stars)
FROM Movie
INNER JOIN Rating ON
Movie.mID = Rating.mID
GROUP BY title
HAVING COUNT(*) > 1

/*For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.*/

SELECT title, MAX(stars) - MIN(stars) AS rating_spread
FROM Movie
INNER JOIN Rating ON
Movie.mID = Rating.mID
GROUP BY title
ORDER BY rating_spread DESC, title

/*Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)*/

SELECT AVG(a.avg) - AVG(b.avg) FROM (
SELECT AVG(R1.stars) AS avg FROM Rating R1
INNER JOIN Movie M1 ON
M1.mID = R1.mID
WHERE year<1980
GROUP BY M1.mID) AS a,
(SELECT AVG(R2.stars) AS avg FROM Rating R2
INNER JOIN Movie M2 ON
M2.mID = R2.mID
WHERE year>=1980
GROUP BY M2.mID) AS b



/*******Movie-Rating Query Exercises Extras********/
/*Find the names of all reviewers who rated Gone with the Wind. */
SELECT name FROM Rating
INNER JOIN Reviewer ON
    Reviewer.rID = Rating.rID
INNER JOIN Movie ON
    Movie.mID = Rating.mID
WHERE title = 'Gone with the Wind'
GROUP BY name;

/*For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.*/
SELECT name, title, stars FROM Rating
INNER JOIN Reviewer ON
    Reviewer.rID = Rating.rID
INNER JOIN Movie ON
    Movie.mID = Rating.mID
WHERE name = director;

/*Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) */
SELECT name as titlename FROM Reviewer
UNION ALL
SELECT title FROM Movie
ORDER BY titlename;

/*Find the titles of all movies not reviewed by Chris Jackson.*/
SELECT title FROM Movie
WHERE Movie.mID NOT IN (SELECT Rating.mID FROM Rating
INNER JOIN Reviewer ON
    Reviewer.rID = Rating.rID 
INNER JOIN Movie ON
    Movie.mID = Rating.mID
WHERE name = "Chris Jackson");

/*For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. */
SELECT distinct R1.name, R2.name
FROM Reviewer R1 join Rating Rat1 
join Reviewer R2 join Rating Rat2
ON R1.rID = Rat1.rID AND R2.rID=Rat2.rID
WHERE R1.name != R2.name AND R1.name<R2.name 
AND Rat1.mID = Rat2.mID

SELECT distinct R1.name, R2.name
FROM Reviewer R1
INNER JOIN Rating Rat1 ON
R1.rID = Rat1.rID
INNER JOIN Reviewer R2 ON
R1.name != R2.name
INNER JOIN Rating Rat2 ON
R2.rID = Rat2.rID
WHERE Rat1.mID = Rat2.mID AND R1.name < R2.name

/*For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. */
SELECT name, title, stars
FROM Movie
INNER JOIN Rating R1 ON
R1.mID = Movie.mID
INNER JOIN Reviewer ON
Reviewer.rID = R1.rID
WHERE NOT exists (SELECT * FROM Rating R2
WHERE R1.stars > R2.stars)


/*List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.*/
SELECT title, AVG(stars) AS avg_rating FROM Movie
INNER JOIN Rating ON
Movie.mID=Rating.mID
GROUP BY title
ORDER BY avg_rating DESC, title;

/*Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)*/
Select name FROM Reviewer
INNER JOIN Rating ON
Reviewer.rID = Rating.rID
GROUP BY Rating.rID
HAVING COUNT(*) >= 3

Select distinct name FROM Reviewer
INNER JOIN Rating ON
Reviewer.rID = Rating.rID
WHERE (Select Count(*) FROM Rating WHERE Reviewer.rID = Rating.rID) >= 3

/*Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) */
Select M1.title, M1.director
FROM Movie M1
INNER JOIN Movie M2 ON
M1.director = M2.director
GROUP BY M1.director, M1.title
HAVING COUNT(M1.director)>1

/*Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)*/
SELECT M2.title, AVG(R2.stars) AS avg FROM Movie M2
INNER JOIN Rating R2 ON
M2.mID = R2.mID
GROUP BY M2.title
HAVING (SELECT MAX(avg_rating) FROM (SELECT title, AVG(R1.stars) AS avg_rating 
FROM Movie M1
INNER JOIN Rating R1 ON
M1.mID=R1.mID
GROUP BY M1.title
ORDER BY avg_rating DESC, M1.title)) = avg

/*Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)*/
SELECT M2.title, AVG(R2.stars) AS avg FROM Movie M2
INNER JOIN Rating R2 ON
M2.mID = R2.mID
GROUP BY M2.title
HAVING (SELECT MIN(avg_rating) FROM (SELECT title, AVG(R1.stars) AS avg_rating 
FROM Movie M1
INNER JOIN Rating R1 ON
M1.mID=R1.mID
GROUP BY M1.title
ORDER BY avg_rating DESC, M1.title)) = avg

/*For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.*/

Select director, title, MAX(stars)
FROM Movie 
INNER JOIN Rating ON
Movie.mID = Rating.mID
WHERE director is NOT NULL
GROUP BY Movie.director

/************Social Network Query Exercises************/
/*Find the names of all students who are friends with someone named Gabriel.*/
SELECT distinct H1.name FROM Highschooler H1
INNER JOIN Friend ON
H1.ID = Friend.ID1
INNER JOIN Highschooler H2 ON
Friend.ID2 = H2.ID
WHERE H2.name = "Gabriel"

/*For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.*/
SELECT H1.name, H1.grade, H2.name, H2.grade FROM Highschooler H1
INNER JOIN Likes ON
H1.ID = Likes.ID1
INNER JOIN Highschooler H2 ON
Likes.ID2 = H2.ID
WHERE abs(H1.grade -H2.grade) >= 2

/*For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1
INNER JOIN Likes L1 ON
L1.ID1 = H1.ID
INNER JOIN Highschooler H2 ON
H2.ID = L1.ID2
INNER JOIN Likes L2 ON
L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
WHERE H1.name < H2.name

/*Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.*/
SELECT DT.name, DT.grade FROM
(SELECT * 
FROM Highschooler H1
LEFT JOIN Likes L1 ON
H1.ID = L1.ID1 
WHERE L1.ID1 IS NULL) DT
LEFT JOIN LIKES L2
ON
L2.ID2 = DT.ID
WHERE L2.ID2 is NULL
ORDER BY DT.grade, DT.name

/*For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.*/
SELECT H1.name, H1.grade, H2.name, H2.grade 
FROM Highschooler H1
INNER JOIN Likes L1 ON
H1.ID = L1.ID1
INNER JOIN Highschooler H2 ON
H2.ID = L1.ID2
LEFT JOIN Likes L2 ON
H2.ID = L2.ID1
WHERE L2.ID1 is NULL

/*Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.*/
SELECT H3.name, H3.grade 
FROM Highschooler H3
LEFT JOIN
(SELECT *
FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
INNER JOIN Highschooler H2 ON
F1.ID2 = H2.ID
WHERE H1.grade != H2.grade) DT
ON
DT.ID1 = H3.ID
WHERE DT.ID1 is NULL
ORDER BY H3.grade ASC, H3.name

/*For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.*/
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Likes L1
LEFT JOIN Friend F1 ON
L1.ID2 = F1.ID1 AND L1.ID1 = F1.ID2
INNER JOIN Friend F2 ON
F2.ID1 = L1.ID1
INNER JOIN FRIEND F3 ON
F3.ID1 = L1.ID2
INNER JOIN Highschooler H1 ON
L1.ID1 = H1.ID
INNER JOIN Highschooler H2 ON
L1.ID2 = H2.ID
INNER JOIN Highschooler H3 ON
F2.ID2 = H3.ID
WHERE F1.ID1 is NULL AND F2.ID2 = F3.ID2

/*Find the difference between the number of students in the school and the number of different first names.*/

SELECT a.student - b.name FROM
(
SELECT COUNT(H1.ID) AS student FROM Highschooler H1) AS a,
(
SELECT COUNT(distinct H2.name) AS name FROM Highschooler H2
) AS b

/*Find the name and grade of all students who are liked by more than one other student.*/
SELECT H1.name, H1.grade
FROM Highschooler H1
INNER JOIN Likes L1 ON
H1.ID = L1.ID2
GROUP BY L1.ID2
HAVING COUNT(*) >1

/************Social Network Query Exercises Extras**************/

/*For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.*/
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade FROM
Highschooler H1 
INNER JOIN Likes L1 ON
H1.ID = L1.ID1
INNER JOIN Highschooler H2 ON
H2.ID = L1.ID2
INNER JOIN Likes L2 ON
H2.ID = L2.ID1
INNER JOIN Highschooler H3 ON
H3.ID = L2.ID2
WHERE L1.ID2 != L2.ID2 AND H1.ID != H3.ID

/*Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.*/

SELECT H3.name, H3.grade
FROM Highschooler H3
LEFT JOIN
(
SELECT *
FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
INNER JOIN Highschooler H2 ON
F1.ID2 = H2.ID
WHERE H1.grade = H2.grade
) DT
ON 
DT.ID1 = H3.ID
WHERE DT.ID1 is NULL

/*What is the average number of friends per student? (Your result should be just one number.)*/

SELECT AVG(a.friends) FROM
(SELECT COUNT(*) AS friends 
FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
GROUP BY H1.ID) AS a

/*Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.*/
SELECT COUNT(*)
FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
INNER JOIN Highschooler H2 ON
F1.ID2 = H2.ID
INNER JOIN Friend F2 ON
H2.ID = F2.ID1
INNER JOIN Highschooler H3 ON
F2.ID2 = H3.ID
WHERE (H2.name = "Cassandra" 
OR H3.name = "Cassandra")
AND (H1.ID != H3.ID)

/*Find the name and grade of the student(s) with the greatest number of friends.*/

SELECT name, grade 
FROM
(
SELECT H1.ID, H1.name, H1.grade, COUNT(*) AS friends 
FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
GROUP BY H1.ID
HAVING friends = (
SELECT MAX(friends) FROM (
SELECT H2.ID, H2.name, H2.grade, COUNT(*) AS friends 
FROM Highschooler H2
INNER JOIN Friend F2 ON
H2.ID = F2.ID1
GROUP BY H2.ID)))

/*************SQL Movie-Rating Modification Exercises*************/

/*Add the reviewer Roger Ebert to your database, with an rID of 209.*/
INSERT INTO Reviewer VALUES (209,"Roger Ebert")

/*Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.*/
INSERT INTO Rating (rID, mID, stars, ratingDate)
    SELECT Reviewer.rID, Movie.mID, 5, NULL FROM Movie
    LEFT JOIN Reviewer ON
    Reviewer.name = "James Cameron"

/*For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)*/
UPDATE Movie
SET year = year + 25
WHERE mID in (
SELECT mID FROM (SELECT mID, year, AVG(stars) AS avg_rating FROM Rating R1
WHERE mID = R1.mID
GROUP BY mID
HAVING avg_rating >= 4))

/*Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.*/
DELETE FROM Rating 
WHERE exists(SELECT * FROM Movie 
WHERE Movie.mID = Rating.mID AND (year<1970 OR year>2000)
AND stars < 4)

/*************SQL Movie-Rating Modification Exercises*************/

/*It's time for the seniors to graduate. Remove all 12th graders from Highschooler.*/

DELETE FROM Highschooler
WHERE grade=12

/*If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.*/

DELETE FROM Likes 
WHERE Likes.ID2 IN (SELECT L1.ID2 FROM Friend F1
INNER JOIN Likes L1 ON
F1.ID1=L1.ID1 AND F1.ID2 = L1.ID2 
LEFT JOIN Likes L2 ON
L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
WHERE L2.ID1 is NULL)
AND Likes.ID1 IN (SELECT L1.ID1 FROM Friend F1
INNER JOIN Likes L1 ON
F1.ID1=L1.ID1 AND F1.ID2 = L1.ID2 
LEFT JOIN Likes L2 ON
L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
WHERE L2.ID1 is NULL)

/*For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)*/

INSERT INTO Friend
SELECT distinct H1.ID, H3.ID FROM Highschooler H1
INNER JOIN Friend F1 ON
H1.ID = F1.ID1
INNER JOIN Highschooler H2 ON
F1.ID2 = H2.ID
INNER JOIN Friend F2 ON
H2.ID = F2.ID1
INNER JOIN Highschooler H3 ON
F2.ID2 = H3.ID
LEFT JOIN Friend F3 ON
H1.ID = F3.ID1 AND H3.ID =F3.ID2
WHERE H1.ID != H3.ID AND F3.ID1 is NULL

