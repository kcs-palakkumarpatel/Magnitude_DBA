-- =============================================  
-- Author:   Ankit Mistry  
-- Create date: 18-Apr-2019  
-- Description: <Get all Routing Conditions by Questionnaire Id>  
-- Call SP    :  dbo.GetRoutingConditionsByQuestionnaireId 1825  
-- =============================================  
CREATE PROCEDURE [dbo].[GetRoutingConditionsByQuestionnaireId] @QuestionnaireId BIGINT
AS
BEGIN
    SELECT QI.Id AS [QuestionId],
           RL.OptionId,
           OPT.[Name] AS [OptionName],
           RL.QueueQuestionId,
           Q.QuestionTitle AS [QueueQuestionTitle],
           RL.CreatedBy,
           ISNULL(RL.UpdatedBy,0) AS UpdatedBy,
           RL.IsDeleted,
		  ISNULL(RL.DeletedBy, 0)  AS DeletedBy
    FROM RoutingLogic RL
        INNER JOIN Options OPT
            ON RL.OptionId = OPT.Id
               AND OPT.IsDeleted = 0
        INNER JOIN dbo.Questions QI
            ON OPT.QuestionId = QI.Id
               AND QI.IsDeleted = 0
        INNER JOIN Questions Q
            ON RL.QueueQuestionId = Q.Id
               AND Q.IsDeleted = 0
    WHERE 
	--RL.IsDeleted = 0
 --         AND 
		  Q.QuestionnaireId = @QuestionnaireId;

END;
