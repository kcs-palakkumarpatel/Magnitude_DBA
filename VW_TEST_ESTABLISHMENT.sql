CREATE VIEW dbo.VW_TEST_ESTABLISHMENT
AS

WITH CTE AS 
(
    SELECT DefaultContactId,ContactMasterId,ActivityId,ActivityName,EstablishmentId,EstablishmentName,ContactName,
        ROW_NUMBER() OVER (
            PARTITION BY EstablishmentId
            ORDER BY CreatedOn DESC) AS ROWNUM
	FROM TEST_ESTABLISHMENT
)
SELECT * FROM CTE WHERE ROWNUM = 1

