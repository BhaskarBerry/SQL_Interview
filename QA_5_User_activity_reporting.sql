-- ==========================================
CREATE TABLE tblUsers
(
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    EmailAddress VARCHAR(100),
    CreatedAt DATETIME2 NOT NULL,
    LastLoginAt DATETIME2 NULL
);

-- ==========================================
CREATE TABLE tblCountries
(
    CountryID INT PRIMARY KEY,
    CountryCode CHAR(2) NOT NULL,
    CountryName VARCHAR(100) NOT NULL
);
-- ==========================================
CREATE TABLE tblUserCountryActivity
(
    ActivityID INT PRIMARY KEY,
    UserID INT NOT NULL,
    CountryID INT NOT NULL,
    AccessedAt DATETIME2 NOT NULL,

    FOREIGN KEY (UserID)
        REFERENCES tblUsers(UserID),

    FOREIGN KEY (CountryID)
        REFERENCES tblCountries(CountryID)
);
-- ==========================================
-- ==========================================
-- INSERT COUNTRIES
-- ==========================================

INSERT INTO tblCountries
(CountryID, CountryCode, CountryName)
VALUES
(1, 'NL', 'Netherlands'),
(2, 'BE', 'Belgium'),
(3, 'UK', 'United Kingdom'),
(4, 'IN', 'India'),
(5, 'US', 'United States');

-- ==========================================
-- INSERT USERS
-- ==========================================

INSERT INTO tblUsers
(UserID, Username, FirstName, LastName,
 EmailAddress, CreatedAt, LastLoginAt)
VALUES
(1, 'john01', 'John', 'Smith',
 'john@example.com', '2025-01-10', '2026-10-28'),

(2, 'emma02', 'Emma', 'Brown',
 'emma@example.com', '2025-02-15', '2026-10-25'),

(3, 'david03', 'David', 'Wilson',
 'david@example.com', '2025-03-20', '2026-10-20'),

(4, 'sophia04', 'Sophia', 'Taylor',
 'sophia@example.com', '2025-04-10', '2026-09-15'),

(5, 'robert05', 'Robert', 'Martin',
 'robert@example.com', '2025-05-12', '2026-08-20'),

(6, 'olivia06', 'Olivia', 'Davis',
 'olivia@example.com', '2025-06-18', '2026-07-10'),

(7, 'william07', 'William', 'Clark',
 'william@example.com', '2025-07-01', '2026-06-05'),

(8, 'ava08', 'Ava', 'Lewis',
 'ava@example.com', '2025-08-11', NULL),

(9, 'james09', 'James', 'Walker',
 'james@example.com', '2025-09-12', '2026-01-10'),

(10, 'mia10', 'Mia', 'Hall',
 'mia@example.com', '2025-10-05', NULL),

(11, 'lucas11', 'Lucas', 'Young',
 'lucas@example.com', '2025-11-01', '2026-10-29'),

(12, 'amelia12', 'Amelia', 'King',
 'amelia@example.com', '2025-12-01', '2026-03-15');

-- ==========================================
-- INSERT USER ACTIVITY
-- ==========================================

INSERT INTO tblUserCountryActivity
(ActivityID, UserID, CountryID, AccessedAt)
VALUES
-- Netherlands
(1, 1, 1, '2026-10-28'),
(2, 1, 1, '2026-10-27'),
(3, 2, 1, '2026-10-25'),
(4, 3, 1, '2026-10-20'),

-- Belgium
(5, 2, 2, '2026-10-24'),
(6, 4, 2, '2026-09-15'),
(7, 4, 2, '2026-09-10'),

-- United Kingdom
(8, 5, 3, '2026-08-20'),
(9, 6, 3, '2026-07-10'),
(10, 6, 3, '2026-07-05'),

-- India
(11, 7, 4, '2026-06-05'),
(12, 1, 4, '2026-05-15'),
(13, 9, 4, '2026-01-10'),
(14, 9, 4, '2026-01-05'),

-- United States
(15, 11, 5, '2026-10-29'),
(16, 12, 5, '2026-03-15'),

-- Older activity outside current year
(17, 5, 3, '2025-12-15'),
(18, 7, 4, '2025-11-20');
-- ==========================================
select * from tblUsers ;
select * from tblCountries;
select * from tblUserCountryActivity;
-- ==========================================
--– Retrieve the latest 100 active users
--– Identify users who never logged in
--– Calculate unique users by country
--- Include countries with zero users
--– Understand aggregate functions
--– Difference between WHERE and HAVING
--– Generate a business-friendly account report+
-- ==========================================

DECLARE @QuarterStart DATE =
    DATEADD(
        QUARTER,
        DATEDIFF(QUARTER, 0, GETDATE()),
        0
    );

DECLARE @NextQuarterStart DATE =
    DATEADD(QUARTER, 1, @QuarterStart);

DECLARE @ActiveDate DATETIME2 =
    DATEADD(DAY, -90, GETDATE());

;WITH Latest100Users AS
(
    -- 1. Latest 100 active users

    SELECT TOP (100)
        UserID,
        Username,
        FirstName,
        LastName,
        EmailAddress,
        CreatedAt,
        LastLoginAt
    FROM tblUsers
    WHERE LastLoginAt IS NOT NULL
    ORDER BY LastLoginAt DESC, UserID DESC
),

CountrySummary AS
(
    -- 2. Country-wise unique users

    SELECT
        C.CountryCode,
        C.CountryName,
        COUNT(DISTINCT A.UserID) AS TotalUniqueUsers

    FROM tblCountries C

    LEFT JOIN tblUserCountryActivity A
        ON C.CountryID = A.CountryID
        AND A.AccessedAt >= @QuarterStart
        AND A.AccessedAt < @NextQuarterStart

    WHERE C.CountryCode IN ('NL', 'BE', 'UK', 'IN', 'US')

    GROUP BY
        C.CountryCode,
        C.CountryName
),

AccountDetails AS
(
    -- 3. Account status and login information

    SELECT
        UserID,
        Username,
        FirstName,
        LastName,
        EmailAddress,
        CreatedAt,
        LastLoginAt,

        CASE
            WHEN LastLoginAt IS NULL
                THEN 'Never Logged In'

            WHEN LastLoginAt >= @ActiveDate
                THEN 'Active'

            ELSE 'Inactive'
        END AS AccountStatus,

        CASE
            WHEN LastLoginAt IS NOT NULL
                THEN DATEDIFF(DAY, LastLoginAt, GETDATE())
            ELSE NULL
        END AS DaysSinceLastLogin

    FROM tblUsers
)

-- ============================================
-- FINAL CONSOLIDATED BUSINESS REPORT
-- ============================================

SELECT
    'LATEST 100 USERS' AS ReportSection,
    CAST(NULL AS VARCHAR(2)) AS CountryCode,
    CAST(NULL AS VARCHAR(100)) AS CountryName,
    CAST(NULL AS INT) AS TotalUniqueUsers,

    U.UserID,
    U.Username,
    U.FirstName,
    U.LastName,
    U.EmailAddress,
    U.CreatedAt,
    U.LastLoginAt,

    CASE
        WHEN U.LastLoginAt >= @ActiveDate
            THEN 'Active'
        ELSE 'Inactive'
    END AS AccountStatus,

    DATEDIFF(DAY, U.LastLoginAt, GETDATE())
        AS DaysSinceLastLogin,

    1 AS SortOrder

FROM Latest100Users U

UNION ALL

SELECT
    'COUNTRY SUMMARY',
    C.CountryCode,
    C.CountryName,
    C.TotalUniqueUsers,

    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,

    2 AS SortOrder

FROM CountrySummary C

UNION ALL

SELECT
    'ACCOUNT STATUS',
    NULL,
    NULL,
    NULL,

    A.UserID,
    A.Username,
    A.FirstName,
    A.LastName,
    A.EmailAddress,
    A.CreatedAt,
    A.LastLoginAt,
    A.AccountStatus,
    A.DaysSinceLastLogin,

    3 AS SortOrder

FROM AccountDetails A

ORDER BY
    SortOrder,
    LastLoginAt DESC,
    CountryName;
