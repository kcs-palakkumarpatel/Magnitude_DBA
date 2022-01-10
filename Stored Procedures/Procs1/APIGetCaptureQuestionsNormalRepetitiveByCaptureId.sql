-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Questions List for Web API Using CaptureId
-- Call:dbo.APIGetCaptureQuestionsNormalRepetitiveByCaptureId '3102'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureQuestionsNormalRepetitiveByCaptureId]
    (
      @CaptureId NVARCHAR(MAX) = ''
    )
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT		
		SeenClientId AS CaptureId,
		Id AS QuestionId ,
                QuestionTypeId ,
                ISNULL(QuestionTitle, '') AS QuestionTitle ,
                [Required] AS QuestionRequired ,
                '' AS Answer,
				ShortName AS ShortName,
				IsRepetitive AS IsRepetitive,
				QuestionsGroupNo AS QuestionsGroupNo,
				QuestionsGroupName AS QuestionsGroupName, 
				0 AS RepetitiveGroupCount,
				ISNULL(ContactQuestionId,0) AS ContactQuestionId
        FROM    dbo.SeenClientQuestions WITH (NOLOCK)
        WHERE   SeenClientId IN ( SELECT Data FROM dbo.Split(@CaptureId, ','))
                AND IsActive = 1
                AND IsDeleted = 0
                AND QuestionTypeId NOT IN (23 )
        ORDER BY SeenClientId, Position ASC;
	SET NOCOUNT OFF;
    END;
