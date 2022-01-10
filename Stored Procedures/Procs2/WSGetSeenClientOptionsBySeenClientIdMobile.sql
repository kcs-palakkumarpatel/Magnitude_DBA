
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,20 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetSeenClientOptionsBySeenClientId 609
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSeenClientOptionsBySeenClientIdMobile] @SeenClientId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT O.Id AS OptionId,
           RTRIM(LTRIM(O.Name)) AS OptionName,
           O.DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           RTRIM(LTRIM(O.Value)) AS OptionValue
    FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON O.QuestionId = Q.Id
    WHERE Q.SeenClientId = @SeenClientId
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.QuestionTypeId <> 26 --CREATE New SP AS GetDatabaseReferenceOptionList
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
         'dbo.WSGetSeenClientOptionsBySeenClientIdMobile',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@SeenClientId,0),
         @SeenClientId,
         GETUTCDATE(),
         N''
        );
END CATCH
  SET NOCOUNT OFF;
END;
