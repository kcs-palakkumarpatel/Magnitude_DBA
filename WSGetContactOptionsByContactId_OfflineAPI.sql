
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,,>
-- =============================================
/*
drop procedure WSGetContactOptionsByContactId_OfflineAPI

Exec [WSGetContactOptionsByContactId_OfflineAPI] 1
*/
CREATE PROCEDURE [dbo].[WSGetContactOptionsByContactId_OfflineAPI]
    @ContactId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT O.Id AS OptionId,
           Name AS OptionName,
           DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           O.Value AS OptionValue,
           (CASE
                WHEN @LastServerDate = '1970-01-01 00:00:00.00' THEN
                    1
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
			 END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetContactOptionsByContactId_OfflineAPI',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ContactId,0),
         @ContactId+','+@LastServerDate,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
