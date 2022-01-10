CREATE VIEW dbo.VW_TEST_ACTIVITY
AS

WITH CTE AS 
(
    SELECT DefaultContactId,ContactMasterId,ContactName,ActivityId,ActivityName,
        ROW_NUMBER() OVER (
            PARTITION BY ActivityId
            ORDER BY CreatedOn DESC) AS ROWNUM
	FROM TEST_ACTIVITY
)
SELECT * FROM CTE WHERE ROWNUM = 1

