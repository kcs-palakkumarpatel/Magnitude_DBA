-- =============================================
-- Author:			Developer D3
-- Create date:	31-MAY-2017
-- Description:	Get Contact Answers Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetContactAnswersDataByAnswerMasterId 170
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactAnswersDataByAnswerMasterId]
    (
      @AnswerMasterId ContactAnswersDataTableType READONLY
	)
AS
    BEGIN
        SET NOCOUNT OFF;

    
        SELECT  ISNULL(CD.ContactMasterId, 0) AS AnswerMasterId ,
                ISNULL(CD.ContactQuestionId, 0) AS QuestionId ,
                ISNULL(QT.QuestionTypeName, '') AS QuestionType ,
                ISNULL(CQ.QuestionTitle, '') AS Question ,
                ISNULL(CD.Detail, '') AS Answer
        FROM    dbo.ContactDetails AS CD
                INNER JOIN dbo.QuestionType AS QT ON QT.Id = CD.QuestionTypeId
                LEFT JOIN dbo.ContactQuestions AS CQ ON CQ.Id = CD.ContactQuestionId
                LEFT JOIN dbo.AppUser AS AU ON AU.Id = CD.CreatedBy
        WHERE  CQ.QuestionTypeId NOT IN (16, 23) AND CD.ContactMasterId IN (
                SELECT  AnswerMasterId
                FROM    @AnswerMasterId );

    END;
