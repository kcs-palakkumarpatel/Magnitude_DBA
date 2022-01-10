-- =============================================
-- Author:		Krishna Panchal
-- Create date: 18-Nov-2020
-- Description:	Get Options By QuestionnaireId For Mobile
-- Call SP:		WSGetSeenClientOptionsBySeenClientIdForMobile 609,'1970-01-01 00:00:00.00'
-- =============================================
/*
drop procedure WSGetSeenClientOptionsBySeenClientId_OfflineAPI

Exec WSGetSeenClientOptionsBySeenClientId_OfflineAPI 609
*/
CREATE PROCEDURE [dbo].[WSGetSeenClientOptionsBySeenClientIdForMobile]
    @SeenClientId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
    SELECT O.Id AS OptionId,
           RTRIM(LTRIM(O.Name)) AS OptionName,
           O.DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           RTRIM(LTRIM(O.Value)) AS OptionValue,
           ISNULL(O.IsHTTPHeader, 0) AS IsHTTPHeader,
           ISNULL(O.ReferenceQuestionId, 0) AS ReferenceQuestionId,
           ISNULL(O.FromRef, 0) AS FromRef,
           (CASE
                WHEN ISNULL(O.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(O.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.SeenClientOptions AS O
        INNER JOIN dbo.SeenClientQuestions AS Q
            ON O.QuestionId = Q.Id
    WHERE (
              ISNULL(O.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.SeenClientId = @SeenClientId
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.QuestionTypeId <> 26
          AND
          (
              ISNULL(O.UpdatedOn, O.CreatedOn) >= @LastServerDate
              OR ISNULL(O.DeletedOn, '') >= @LastServerDate
          )
    ORDER BY Q.Id,
             O.Position;
END;

