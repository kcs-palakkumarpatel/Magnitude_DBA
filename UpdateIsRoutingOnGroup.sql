-- =============================================
-- Author:			Mittal Patel
-- Create date:	23-Jan-2020
-- Description:	<Description,,UpdateIsRoutingOnGroup>
-- Call SP    :	UpdateIsRoutingOnGroup 2238,2,Group2,false
-- =============================================
CREATE PROCEDURE [dbo].[UpdateIsRoutingOnGroup]
(
    @questionnaireId NVARCHAR(50),
    @groupId NVARCHAR(50),
    @groupName NVARCHAR(50),
    @isRoutingOnGroup BIT
)
AS
BEGIN

    UPDATE dbo.Questions
    SET IsRoutingOnGroup = @isRoutingOnGroup
    WHERE QuestionnaireId = @questionnaireId
          AND QuestionsGroupNo = @groupId
          AND QuestionsGroupName = @groupName;

    DECLARE @Position INT = 0;
    SELECT @Position = Position
    FROM dbo.Questions
    WHERE QuestionnaireId = @questionnaireId
          AND QuestionsGroupNo = @groupId
          AND IsDeleted = 0;
    SELECT @Position;

    UPDATE dbo.ConditionLogic
    SET IsDeleted = 1,
        DeletedOn = GETUTCDATE(),
        DeletedBy = 2
    WHERE ConditionQuestionId IN (
                                     SELECT Id
                                     FROM dbo.Questions
                                     WHERE QuestionnaireId = @questionnaireId
                                           AND IsDeleted = 0
                                           AND Position = @Position
                                           AND IsRepetitive = 1
                                 )
								 AND QuestionId=1;

END;
