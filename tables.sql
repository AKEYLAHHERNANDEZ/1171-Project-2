--Project 2 creating a database and queries from a list of real data
DROP TABLE IF EXISTS Courses CASCADE;
DROP TABLE IF EXISTS Programs CASCADE;
DROP TABLE IF EXISTS Student_information CASCADE;
DROP TABLE IF EXISTS Grades CASCADE;
DROP TABLE IF EXISTS Feeder CASCADE;
DROP TABLE IF EXISTS Courses_Programs CASCADE;


--Table 1

CREATE TABLE Courses
(
course_id INT PRIMARY KEY,
course_code CHAR ( 50) NOT NULL,
course_title TEXT NOT NULL,
course_credits INT NOT NULL
);

--Table 2
CREATE TABLE Programs
(
program_id INT PRIMARY KEY,
program_code VARCHAR(50) NOT NULL,
program_name TEXT NOT NULL,
degree_type TEXT NOT NULL
);

--Table 3
CREATE TABLE Courses_Programs
(
co_pro INT PRIMARY KEY,
program_id INT,
course_id INT,
FOREIGN KEY (program_id)
REFERENCES Programs (program_id),
FOREIGN KEY (course_id )
REFERENCES Courses (course_id )
);

--Table 4
CREATE TABLE Feeder
(
feeder_id INT PRIMARY KEY,
school_name VARCHAR(100),
management TEXT,
municipality1 TEXT,
municipality2 TEXT,
area VARCHAR(100),
funding TEXT
);


--Table 5
CREATE TABLE Student_information
(
student_id INT PRIMARY KEY,
gender CHAR(1),
ethnicity TEXT,
city TEXT,
district TEXT,
programEnd VARCHAR(100),
grad_date VARCHAR(100),
program_status VARCHAR(100),
program_start CHAR(100),
feeder_id INT,
FOREIGN KEY (feeder_id) REFERENCES Feeder(feeder_id)
);

--Table 6

CREATE TABLE Grades
(
grade_id INT PRIMARY KEY,
semester VARCHAR(50),
course_grade VARCHAR(10),
course_points DECIMAL,
student_id INT NOT NULL,
course_id INT NOT NULL,
FOREIGN KEY (student_id )  
REFERENCES Student_information (student_id),
FOREIGN KEY (course_id )
REFERENCES Courses (course_id )
);


--Link data files 

--1.
\COPY Programs 
FROM '/home/akeylah/Project2/Programs.csv'
DELIMITER ','
CSV HEADER;

--2. 

\COPY Courses
FROM '/home/akeylah/Project2/Courses.csv'
DELIMITER ','
CSV HEADER;

--3. 
\COPY Courses_Programs
FROM '/home/akeylah/Project2/Courses_Programs.csv'
DELIMITER ','
CSV HEADER;


--4.
\COPY Feeder
FROM '/home/akeylah/Project2/Feeder.csv'
DELIMITER ','
CSV HEADER;

--5.
\COPY Student_information
FROM '/home/akeylah/Project2/Student_information.csv'
DELIMITER ','
CSV HEADER;

--6.
\COPY Grades
FROM '/home/akeylah/Project2/Grades.csv'
DELIMITER ','
CSV HEADER;




--Display tables
--1. 
SELECT*
FROM Programs;

--2. 
SELECT*
FROM Courses;

--3. 
SELECT*
FROM Courses_Programs;

--4. 
SELECT*
FROM Feeder;

--5. 
SELECT*
FROM Student_information;

--6. 
SELECT*
FROM Grades;


--My QUERIES

--1.Find all courses that have a course code starting with "MATH":
SELECT *
FROM Courses WHERE course_code LIKE 'MATH%';


--2. Find all programs that are offered as a associates degree:
SELECT * 
FROM Programs WHERE degree_type = 'Associate Degree';

--3. Select only the student_id and ethnicity columns for all rows
 SELECT student_id, ethnicity, gender FROM Student_information;


--4.Retrieve all courses with their program associations.
SELECT c.course_title, p.program_name 
FROM Courses_Programs cp 
JOIN Courses c ON cp.course_id = c.course_id 
JOIN Programs p ON cp.program_id = p.program_id;


     
--5.Retrieve all courses associated with a specific program.
SELECT c.course_title 
FROM Courses_Programs cp 
JOIN Courses c ON cp.course_id = c.course_id 
WHERE cp.program_id =1;


--6.Retrieve all feeder schools with their associated students.
SELECT f.school_name, COUNT(si.student_id) 
FROM Feeder f 
LEFT JOIN Student_information si ON f.feeder_id = si.feeder_id 
GROUP BY f.feeder_id;


--7.Find the total number of credits for all courses in the Computer Science program.
SELECT SUM(c.course_credits) 
FROM Courses c 
JOIN Courses_Programs cp ON c.course_id = cp.course_id 
JOIN Programs p ON p.program_id = cp.program_id;


--8. Find all feeder schools located in the municipality of .
SELECT * FROM Feeder WHERE municipality1 = 'Benque';


--9.List the most difficult courses based on their grades (C+ and below). 
SELECT c.course_code,c. course_title,g.course_grade
FROM courses AS c
INNER JOIN grades AS g
ON c.course_id=g.course_id
WHERE g.course_grade > 'D';


--10.Retrieve the semester, course grade, and course points for all courses taken by the student with grade_id = 12

SELECT g.semester, g.course_grade, g.course_points,g.course_id
FROM Grades g
WHERE g.grade_id = 12;






--Project 2 Sir. Queries 


--1.Find the total number of students and average course points by feeder institutions.
SELECT COUNT(s.student_id),AVG(g.course_points),f.feeder_id,f.school_name
FROM feeder AS f
INNER JOIN student_information AS s
ON f.feeder_id=s.feeder_id
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY f.feeder_id,f.school_name;

--2.Find the total number of students and average course points by gender.
SELECT COUNT(s.student_id),AVG(g.course_points),s.gender
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.gender;


--3.Find the total number of students and average course points by ethnicity.
SELECT COUNT(s.student_id),AVG(g.course_points),s.ethnicity
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.ethnicity;

--4.Find the total number of students and average course points by city.
SELECT COUNT(s.student_id),AVG(g.course_points),s.city
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.city;

--5.Find the total number of students and average course points by district.
SELECT COUNT(s.student_id),AVG(g.course_points),s.district
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.district;

--6.Find the total number and percentage of students by program status.
SELECT COUNT(s.student_id) AS total_students,
(COUNT(s.student_id) * 100.0 / SUM(COUNT(s.student_id)) OVER ()) AS percentage,  s.program_status
FROM student_information AS s
INNER JOIN grades AS g ON s.student_id = g.student_id
GROUP BY s.program_status;


--7.Find the letter grade breakdown (how many A, A-,B,B+,...)for each of the following courses:
--Fundamentals of Computing 
--Principles of Programming I 
--Algebra 
--Trigonometry 
--College English I 

SELECT COUNT(g.course_grade), c.course_id, c.course_code, c.course_title, g.course_grade
FROM courses AS c
INNER JOIN grades AS g
ON c.course_id=g.course_id
WHERE c.course_title IN ('FUNDAMENTALS OF COMPUTING', 'PROGRAMMING I', 'ALGEBRA 1', 'TRIGONOMETRY 1', 'COLLEGE ENGLISH I')
GROUP BY c.course_id, c.course_code, c.course_title, g.course_grade;


