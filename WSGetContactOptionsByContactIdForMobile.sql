-- =============================================
-- Author:		Krishna Panchal
-- Create date: 18-Nov-2020
-- Description:	Get Options By QuestionnaireId For Mobile
-- Call SP:		WSGetContactOptionsByContactIdForMobile 1,'1970-01-01 00:00:00.00'
-- =============================================

CREATE PROCEDURE [dbo].[WSGetContactOptionsByContactIdForMobile]
    @ContactId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
    SELECT O.Id AS OptionId,
           Name AS OptionName,
           DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           O.Value AS OptionValue,(CASE
                WHEN ISNULL(O.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(O.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.ContactOptions AS O
        INNER JOIN dbo.ContactQuestions AS Q
            ON O.ContactQuestionId = Q.Id
    WHERE (
              ISNULL(O.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.ContactId = @ContactId
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND
          (
              ISNULL(O.UpdatedOn, O.CreatedOn) >= @LastServerDate
              OR ISNULL(O.DeletedOn, '') >= @LastServerDate
          )
    ORDER BY Q.Id,
             O.Position;
END;
