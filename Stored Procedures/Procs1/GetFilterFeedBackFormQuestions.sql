-- =============================================
-- Author:			
-- Create date:	16-Nov-2017
-- Description:	Get FeedBack Form Questions List by Capture ID For Advanced filter
-- Call:					GetFilterFeedBackFormQuestions
-- =============================================
CREATE PROCEDURE [dbo].[GetFilterFeedBackFormQuestions]
    (
      @FeedBackFormId BIGINT
    )
AS
    BEGIN

        SELECT  QuestionnaireId AS FeedBackFormId ,
                Id AS QuestionId ,
                QuestionTypeId ,
                ShortName AS QuestionName ,
                [Required] ,
                Position ,
                ISNULL(Hint, '') AS Hint ,
                IsDecimal ,
                IsRepetitive ,
                [MaxLength] ,
                MaxWeight ,
                [Weight] ,
                WeightForNo ,
                WeightForYes
        FROM    dbo.Questions
        WHERE   QuestionTypeId NOT IN ( 16, 17, 25, 27, 23 )
                AND IsDeleted = 0
                AND IsActive = 1
                AND QuestionnaireId = @FeedBackFormId
        ORDER BY Position ASC;

    END;
