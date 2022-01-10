
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <05 Feb 2015>
-- Description:	<Get QuestionnierFormTypeByActivityId>
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireFormTypeByActivityId]
	@ActivityId bigint
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	SELECT  EstablishmentGroupName ,
        QuestionnaireFormType
FROM    EstablishmentGroup EG
        INNER JOIN Questionnaire Q ON EG.QuestionnaireId = Q.id
WHERE   EG.id = @ActivityId;
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
         'dbo.GetQuestionnaireFormTypeByActivityId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ActivityId,
         GETUTCDATE(),
         N''
        );
END CATCH
END
