-- =============================================
-- Author:		Krishna Panchal
-- Create date:	19-Jan-2021
-- Description:	Get allocated task list by User ID
-- Call SP    : dbo.GetAllocatedTaskListByAppUserId 7887,33334, 1246
-- =============================================
CREATE PROCEDURE dbo.GetAllocatedTaskListByAppUserId
    @ActivityId BIGINT,
    @EstablishmentId BIGINT,
    @AppUserId BIGINT = 0,
    @Page INT = 1, /* Select Page No  */
    @Rows INT = 50
AS
BEGIN
SET NOCOUNT ON;
    SELECT EG.Id AS ActivityId,
           EG.EstablishmentGroupName AS ActivityName,
           SCAM.EstablishmentId AS EstablishmentId,
           SCAM.Id AS ReportId,
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 4
           ) AS TaskTitle ,
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 3
           ) AS [Description],
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 17
           ) AS Attachment,
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 26
           ) AS [Type],
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 19
           ) AS EstimationHours,
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 21
           ) AS [Priority],
           (
               SELECT TOP 1
                      ISNULL(Detail, '') AS Detail
               FROM dbo.SeenClientAnswers
               WHERE SeenClientAnswerMasterId = SCAM.Id
                     AND QuestionTypeId = 22
           ) AS DueDate,
           ES.Id AS EstablishmentStatusId,
		   ES.[StatusName] AS [Status],
           (
               SELECT Name FROM dbo.AppUser WHERE Id = SCAM.AppUserId
           ) AS ApplicationUserName,
           SCAM.AppUserId,
           SCAM.AppUserId AS UserId
    FROM dbo.SeenClientAnswerMaster AS SCAM
        INNER JOIN dbo.Establishment AS E
            ON SCAM.EstablishmentId = E.Id
        INNER JOIN dbo.SeenClient AS S
            ON SCAM.SeenClientId = S.Id
        INNER JOIN dbo.AppUser AS U
            ON SCAM.AppUserId = U.Id
			AND U.IsDeleted = 0
        INNER JOIN dbo.EstablishmentGroup AS EG
            ON EG.Id = E.EstablishmentGroupId
        LEFT OUTER JOIN dbo.StatusHistory AS SH
            ON SCAM.StatusHistoryId = SH.Id
        LEFT OUTER JOIN dbo.EstablishmentStatus AS ES
            ON SH.EstablishmentStatusId = ES.Id
        LEFT OUTER JOIN dbo.StatusIconImage SII
            ON ES.StatusIconImageId = SII.Id
			INNER JOIN dbo.StatusIconImage AS SSI
            ON SSI.Id = ES.StatusIconImageId
    WHERE EG.Id = @ActivityId
          AND SCAM.EstablishmentId = @EstablishmentId
          AND EG.EstablishmentGroupType = 'Task'
          AND EG.IsDeleted = 0
          AND SCAM.IsDeleted = 0
		  AND SCAM.IsUnAllocated = 0
          AND (SCAM.AppUserId = @AppUserId OR @AppUserId = 0)
    ORDER BY SCAM.CreatedOn DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

SET NOCOUNT OFF;
END;
