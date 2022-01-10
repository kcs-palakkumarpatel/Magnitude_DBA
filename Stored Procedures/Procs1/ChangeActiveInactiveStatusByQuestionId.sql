-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,27 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		ChangeActiveInactiveStatusByQuestionId
-- =============================================
CREATE PROCEDURE [dbo].[ChangeActiveInactiveStatusByQuestionId]
    @QuestionId BIGINT ,
    @IsOut BIT
AS
    BEGIN
        IF @IsOut = 0
            BEGIN
                UPDATE  dbo.Questions
                SET     IsActive = ~IsActive
                WHERE   Id = @QuestionId;
            END;
        ELSE
            BEGIN
                UPDATE  dbo.SeenClientQuestions
                SET     IsActive = ~IsActive
                WHERE   Id = @QuestionId;
            END;
    END;