
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <05 Feb 2015>
-- Description:	<Get QuestionnierFormTypeByActivityId>
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireFormTypeByActivityId_111721]
	@ActivityId bigint
AS
BEGIN
	SELECT  EstablishmentGroupName ,
        QuestionnaireFormType
FROM    EstablishmentGroup EG
        INNER JOIN Questionnaire Q ON EG.QuestionnaireId = Q.id
WHERE   EG.id = @ActivityId;
END
