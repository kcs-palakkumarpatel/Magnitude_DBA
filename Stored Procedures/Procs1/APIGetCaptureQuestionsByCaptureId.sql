-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Questions List for Web API Using CaptureId
-- Call:					dbo.APIGetCaptureQuestionsByCaptureId '404,406,411,399,434,435'
-- =============================================
CREATE PROCEDURE dbo.APIGetCaptureQuestionsByCaptureId
    (
      @CaptureId NVARCHAR(MAX) = ''
    )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT		
		SeenClientId AS CaptureId,
		Id AS QuestionId ,
                QuestionTypeId ,
                ISNULL(QuestionTitle, '') AS QuestionTitle ,
                [Required] AS QuestionRequired ,
                '' AS Answer,
				ShortName AS ShortName
        FROM    dbo.SeenClientQuestions
        WHERE   SeenClientId IN ( SELECT Data FROM dbo.Split(@CaptureId, ','))
                AND IsActive = 1
                AND IsDeleted = 0
                AND QuestionTypeId NOT IN ( 16, 23 )
        ORDER BY SeenClientId, Position ASC;
    END;
