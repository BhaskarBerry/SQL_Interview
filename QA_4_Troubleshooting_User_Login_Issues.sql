-- =============================================
CREATE TABLE Languages
(
    LanguageID INT PRIMARY KEY,
    LanguageName VARCHAR(50) NOT NULL
);
GO
-- =============================================
CREATE TABLE Users
(
    UserID INT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    IsActive BIT NOT NULL,
    IsLocked BIT NOT NULL,
    FailedLoginAttempts INT NULL,
    LastLoginAt DATETIME2 NULL,
    LanguageID INT NULL,

    CONSTRAINT FK_Users_Languages
        FOREIGN KEY (LanguageID)
        REFERENCES Languages(LanguageID)
);
GO

-- =============================================
CREATE TABLE LoginHistory
(
    LoginID INT PRIMARY KEY,
    UserID INT NOT NULL,
    LoginTime DATETIME2 NOT NULL,
    LoginStatus VARCHAR(20) NOT NULL,
    FailureReason VARCHAR(100) NULL,

    CONSTRAINT FK_LoginHistory_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);
GO
-- =============================================

-- Insert language data
INSERT INTO Languages(LanguageID, LanguageName)
VALUES
    (1, 'English'),
    (2, 'Dutch'),
    (3, 'French'),
    (4, 'German');

-- Insert user data
INSERT INTO Users
(
    UserID, Username, FirstName, LastName,
    IsActive, IsLocked, FailedLoginAttempts,
    LastLoginAt, LanguageID
)
VALUES
(101, 'mira.vandalen',
 'Mira', 'Van Dalen', 1, 1, 5,
 '2026-11-02 09:15:00', 2),

(102, 'john.smith',
 'John', 'Smith', 1, 0, 0,
 '2026-11-03 08:30:00', 1),

(103, 'sara.jones',
 'Sara', 'Jones', 0, 0, NULL,
 NULL, 3),

(104, 'alex.martin',
 'Alex', 'Martin', 1, 0, NULL,
 '2026-11-01 10:00:00', NULL),

(105, 'mira.dalen',
 'Mira', 'Dalen', 1, 0, 1,
 '2026-11-02 11:00:00', 4);

-- Insert login history
INSERT INTO LoginHistory
(
    LoginID, UserID, LoginTime,
    LoginStatus, FailureReason
)
VALUES
(1001, 101, '2026-11-02 09:10:00',
 'FAILED', 'Incorrect password'),

(1002, 101, '2026-11-02 09:12:00',
 'FAILED', 'Incorrect password'),

(1003, 101, '2026-11-02 09:13:00',
 'FAILED', 'Incorrect password'),

(1004, 101, '2026-11-02 09:14:00',
 'FAILED', 'Incorrect password'),

(1005, 101, '2026-11-02 09:15:00',
 'FAILED', 'Account locked'),

(1006, 102, '2026-11-03 08:30:00',
 'SUCCESS', NULL),

(1007, 105, '2026-11-02 11:00:00',
 'FAILED', 'Incorrect password');
GO
--========================================
select * from Languages;
select * from Users;
select * from LoginHistory;
--========================================
-- Approach
--========================================
-- 1 – Identify the user using a partial surname  -- Like 
select * from Users where LastName like '%van%Dal%'

-- 2 – Search using a full name containing spaces
select * from Users where concat(FirstName , ' ', LastName ) Like '%Mira Van Dalen%';

-- 3 – Check account activation and lock status
select * from Users where username = 'mira.vandalen';

-- 4 – Identify failed login attempts
select U.username, count(LH.LoginID) as TotalFailedAttempts from 
Users as U
Inner join LoginHistory as LH
   on U.userId = LH.userID
Where U.username  = 'mira.vandalen'
and LH.LoginStatus = 'Failed'
group by U.username;

-- 5 – Understand NULL values
select username, 
FailedLoginAttempts,
CAse when FailedLoginAttempts IS NULL
  THEN 'Failed attempt is not recorded'
  when FailedLoginAttempts = 0
  THEN 'No records for failed attempt'
  Else 'Failed attempts recorded'
  ENd as FailureAnalysis
from Users

-- 6 – Retrieve the preferred language using LEFT JOIN
select 
   u.userid, u.username,l.languageName
from users as u
Left join Languages as l
on u.languageId = l.languageId
Where u.username = 'mira.vandalen';
-- 7 – Review the user's complete login history

select u.username, lh.logintime,lh.loginstatus, lh.Failurereason
from users as u
left join LoginHistory as lh
on u.userid = lh.userid
where u.username = 'mira.vandalen'
order by lh.loginTime desc
--========================================

SELECT
    U.UserID,
    U.Username,
    CONCAT(U.FirstName, ' ', U.LastName) AS FullName,
    CASE
        WHEN U.IsActive = 0 THEN 'Inactive'
        WHEN U.IsLocked = 1 THEN 'Locked'
        ELSE 'Active and Unlocked'
    END AS AccountStatus,
    U.FailedLoginAttempts,
    CASE
        WHEN U.FailedLoginAttempts IS NULL
            THEN 'Unknown'
        ELSE CAST(U.FailedLoginAttempts AS VARCHAR(10))
    END AS FailedAttemptAnalysis,
    U.LastLoginAt,
    L.LanguageName,
    COUNT(CASE
        WHEN LH.LoginStatus = 'FAILED'
        THEN 1
    END) AS TotalFailedLogins,
    COUNT(CASE
        WHEN LH.LoginStatus = 'SUCCESS'
        THEN 1
    END) AS TotalSuccessfulLogins

FROM Users U
LEFT JOIN Languages L
    ON U.LanguageID = L.LanguageID
LEFT JOIN LoginHistory LH
    ON U.UserID = LH.UserID

WHERE U.Username = 'mira.vandalen'
GROUP BY
    U.UserID,    U.Username,    U.FirstName,
    U.LastName,    U.IsActive,    U.IsLocked,
    U.FailedLoginAttempts,    U.LastLoginAt,    L.LanguageName;
