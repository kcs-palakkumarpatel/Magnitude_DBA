-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Questions List for Web API Using CaptureId
-- Call:					dbo.APIGetCaptureFormQuestionsByActivityId '404,406,411,399,434,435'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureFormQuestionsByActivityId]
    (
      @activityId NVARCHAR(MAX) = ''
    )
AS
    BEGIN
        SET NOCOUNT OFF;
        SELECT		
				0 AS CaptureId,
				Id AS QuestionId ,
                QuestionTypeId ,
                ISNULL(QuestionTitle, '') AS QuestionTitle ,
                [Required] AS QuestionRequired ,
                '' AS Answer,
				ShortName AS ShortName
        FROM    dbo.SeenClientQuestions
        WHERE   SeenClientId = ( Select top 1 SeenClientId from EstablishmentGroup where Id = @activityId )
                AND IsActive = 1
                AND IsDeleted = 0
                AND QuestionTypeId NOT IN ( 16, 23 )
        ORDER BY Position ASC;
    END;
