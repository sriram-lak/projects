DROP DATABASE IF EXISTS College;
GO

CREATE DATABASE College;
GO

USE College;
GO

DROP TABLE IF EXISTS Department;
GO

CREATE TABLE Department(
departmentId INT IDENTITY(1,1) PRIMARY KEY,
departmentName NVARCHAR(50) NOT NULL UNIQUE);
GO

DROP TABLE IF EXISTS StudentClass;
GO

CREATE TABLE StudentClass(
sectionId INT IDENTITY(1,1) PRIMARY KEY,
departmentId INT CONSTRAINT FK_StaffCourse_Department FOREIGN KEY REFERENCES Department(departmentId),
section CHAR
CONSTRAINT UQ_departmentId_section UNIQUE (departmentId,section) NOT NULL);
GO

DROP TABLE IF EXISTS Student;
GO

CREATE TABLE Student(
studentId INT IDENTITY(101,1) PRIMARY KEY,
studentName NVARCHAR(50) NOT NULL,
studentDOB DATE NOT NULL,
sectionId INT CONSTRAINT FK_Student_StudentClass FOREIGN KEY REFERENCES StudentClass(sectionId));
GO

DROP TABLE IF EXISTS Course;
GO

CREATE TABLE Course(
courseId INT IDENTITY(1001,1) PRIMARY KEY,
courseName NVARCHAR(50) NOT NULL);
GO

DROP TABLE IF EXISTS Staff;
GO

CREATE TABLE Staff(
staffId INT IDENTITY(10001,1) PRIMARY KEY,
staffName NVARCHAR(50) NOT NULL);
GO

DROP TABLE IF EXISTS StudentCourse;
GO

CREATE TABLE StudentCourse(
studentId INT CONSTRAINT FK_StudentCourse_Student FOREIGN KEY REFERENCES Student(studentId),
courseId INT CONSTRAINT FK_StudentCourse_Course FOREIGN KEY REFERENCES Course(courseId)
CONSTRAINT PK_StudentCourse PRIMARY KEY (studentId,courseId));
GO

DROP TABLE IF EXISTS StaffCourse;
GO

CREATE TABLE StaffCourse(
courseId INT CONSTRAINT FK_StaffCourse_Course FOREIGN KEY REFERENCES Course(courseId),
sectionId INT CONSTRAINT FK_StaffCourse_StudentClass FOREIGN KEY REFERENCES StudentClass(sectionId),
staffId INT CONSTRAINT FK_StaffCourse_Staff FOREIGN KEY REFERENCES Staff(staffId),
CONSTRAINT PK_StaffCourse PRIMARY KEY (courseId,sectionId,staffId));
GO
