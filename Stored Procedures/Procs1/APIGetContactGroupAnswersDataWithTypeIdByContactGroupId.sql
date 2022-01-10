-- =============================================
-- Author:			Developer D3
-- Create date:	31-May-2017
-- Description:	Get Contact Group Answers Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetContactGroupAnswersDataByContactGroupId '5225'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactGroupAnswersDataWithTypeIdByContactGroupId]
    (
      @ContactGroupId NVARCHAR(2000) = NULL
	)
AS
    BEGIN
        SET NOCOUNT OFF;
        SELECT  ISNULL(CGD.ContactGroupId, 0) AS ContactGroupId ,
                ISNULL(CGD.ContactQuestionId, 0) AS QuestionId ,
                ISNULL(CGD.QuestionTypeId, '') AS QuestionTypeId ,
                ISNULL(CQ.QuestionTitle, '') AS Question ,
                ISNULL(CGD.Detail, '') AS Answer
        FROM    dbo.ContactGroupDetails AS CGD
                INNER JOIN dbo.QuestionType AS QT ON QT.Id = CGD.QuestionTypeId
                LEFT JOIN dbo.ContactQuestions AS CQ ON CQ.Id = CGD.ContactQuestionId
        WHERE  CQ.QuestionTypeId NOT IN (16, 23) AND CGD.ContactGroupId IN ( SELECT Data FROM dbo.Split(@ContactGroupId, ','))

    END;
