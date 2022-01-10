-- =============================================
-- Author:		<Author, Matthew Grinaker>
-- Create date: <Create Date, 12 Nov 2019>
-- Description:	<Description, TempRemoveLagoonBeachDuplicates>
-- Call SP    :	TempRemoveLagoonBeachDuplicates '103'
-- =============================================

CREATE PROCEDURE [dbo].[TempRemoveLagoonBeachDuplicates]
(
    @RoomNumber NVarChar(50)
    
)
AS
BEGIN

Update SeenClientAnswerMaster SET IsDeleted = 1
WHERE ID IN (SELECT TOP (
(SELECT 
       COUNT(DISTINCT SCA.SeenClientAnswerMasterId) As Count
FROM SeenClientAnswers SCA
    INNER JOIN dbo.SeenClientAnswerMaster SCAM
        ON SCAM.Id = SCA.SeenClientAnswerMasterId
           AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
           AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
		   AND SCA.Detail = @RoomNumber
    INNER JOIN dbo.StatusHistory SH
        ON SH.Id = SCAM.StatusHistoryId
           AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
    INNER JOIN dbo.EstablishmentStatus AS p
        ON p.Id = SH.EstablishmentStatusId
GROUP BY SCA.Detail) -1) 
	SeenClientAnswerMasterId
FROM
(
    SELECT DISTINCT SCA.SeenClientAnswerMasterId,
           SCA.QuestionId,
           SCA.Detail,
           p.StatusName AS [RoomStatus],
           AU.Name AS "AppUserName",
           CAST(SCAM.UpdatedOn AS TIME(0)) AS UpdatedOn
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
               AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
               AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
			   AND SCA.Detail = @RoomNumber
        INNER JOIN dbo.StatusHistory SH
            ON SH.Id = SCAM.StatusHistoryId
               AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
        INNER JOIN dbo.EstablishmentStatus AS p
            ON p.Id = SH.EstablishmentStatusId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = SCAM.AppUserId
) d
PIVOT
(
    MAX([Detail])
    FOR QuestionId IN ([38264], [38266], [38267], [38280], [41939])
) AS TAB
WHERE RoomStatus = 'Dirty'
ORDER BY SeenClientAnswerMasterId);


Update SeenClientAnswers SET IsDeleted = 1
WHERE SeenClientAnswerMasterId IN (SELECT TOP (
(SELECT 
       COUNT(DISTINCT SCA.SeenClientAnswerMasterId) As Count
FROM SeenClientAnswers SCA
    INNER JOIN dbo.SeenClientAnswerMaster SCAM
        ON SCAM.Id = SCA.SeenClientAnswerMasterId
           AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
           AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
		   AND SCA.Detail = @RoomNumber
    INNER JOIN dbo.StatusHistory SH
        ON SH.Id = SCAM.StatusHistoryId
           AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
    INNER JOIN dbo.EstablishmentStatus AS p
        ON p.Id = SH.EstablishmentStatusId
GROUP BY SCA.Detail) -1) 
	SeenClientAnswerMasterId
FROM
(
    SELECT DISTINCT SCA.SeenClientAnswerMasterId,
           SCA.QuestionId,
           SCA.Detail,
           p.StatusName AS [RoomStatus],
           AU.Name AS "AppUserName",
           CAST(SCAM.UpdatedOn AS TIME(0)) AS UpdatedOn
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
               AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
               AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
			   AND SCA.Detail = @RoomNumber
        INNER JOIN dbo.StatusHistory SH
            ON SH.Id = SCAM.StatusHistoryId
               AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
        INNER JOIN dbo.EstablishmentStatus AS p
            ON p.Id = SH.EstablishmentStatusId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = SCAM.AppUserId
) d
PIVOT
(
    MAX([Detail])
    FOR QuestionId IN ([38264], [38266], [38267], [38280], [41939])
) AS TAB
WHERE RoomStatus = 'Dirty'
ORDER BY SeenClientAnswerMasterId);

Update SeenClientAnswerChild SET IsDeleted = 1
WHERE SeenClientAnswerMasterId IN (SELECT TOP (
(SELECT 
       COUNT(DISTINCT SCA.SeenClientAnswerMasterId) As Count
FROM SeenClientAnswers SCA
    INNER JOIN dbo.SeenClientAnswerMaster SCAM
        ON SCAM.Id = SCA.SeenClientAnswerMasterId
           AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
           AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
		   AND SCA.Detail = @RoomNumber
    INNER JOIN dbo.StatusHistory SH
        ON SH.Id = SCAM.StatusHistoryId
           AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
    INNER JOIN dbo.EstablishmentStatus AS p
        ON p.Id = SH.EstablishmentStatusId
GROUP BY SCA.Detail) -1) 
	SeenClientAnswerMasterId
FROM
(
    SELECT DISTINCT SCA.SeenClientAnswerMasterId,
           SCA.QuestionId,
           SCA.Detail,
           p.StatusName AS [RoomStatus],
           AU.Name AS "AppUserName",
           CAST(SCAM.UpdatedOn AS TIME(0)) AS UpdatedOn
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
               AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
               AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
			   AND SCA.Detail = @RoomNumber
        INNER JOIN dbo.StatusHistory SH
            ON SH.Id = SCAM.StatusHistoryId
               AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
        INNER JOIN dbo.EstablishmentStatus AS p
            ON p.Id = SH.EstablishmentStatusId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = SCAM.AppUserId
) d
PIVOT
(
    MAX([Detail])
    FOR QuestionId IN ([38264], [38266], [38267], [38280], [41939])
) AS TAB
WHERE RoomStatus = 'Dirty'
ORDER BY SeenClientAnswerMasterId)

END;
