-- =============================================
-- Author:			
-- Create date:	16-Nov-2017
-- Description:	Get Capture Form Questions List by Capture ID For Advanced filter
-- Call:					GetFilterCaptureFormQuestions
-- =============================================
CREATE PROCEDURE [dbo].[GetFilterCaptureFormQuestions]
    (
      @CaptureFormId BIGINT
    )
AS
    BEGIN

        SELECT  SeenClientId AS CaptureFormId ,
                Id AS QuestionId ,
                QuestionTypeId ,
                ShortName AS QuestionName ,
                [Required] ,
                ISNULL(ContactQuestionId, 0) AS ContactQuestionId ,
                Position ,
                ISNULL(Hint, '') AS Hint ,
                IsDecimal ,
                IsRepetitive ,
                [MaxLength] ,
                MaxWeight ,
                [Weight] ,
                WeightForNo ,
                WeightForYes
        FROM    dbo.SeenClientQuestions
        WHERE   QuestionTypeId NOT IN ( 16, 17, 25, 27, 23 )
                AND IsDeleted = 0
                AND IsActive = 1
                AND SeenClientId = @CaptureFormId
        ORDER BY Position ASC;

    END;
