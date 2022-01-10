-- =============================================
-- Author:			MIttal Patel
-- Create date:	27-Feb-2020
-- Description:	<Description,,GetQuestionsByQuestionnaireIdAndGroupNumber>
-- Call SP    :		dbo.GetQuestionListForAPICall 2241,1
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientQuestionListForAPICall]
    @Id BIGINT,
    @GroupId BIGINT,
    @GroupName NVARCHAR(50),
    @IsRepeat BIT
AS
BEGIN
    IF (@IsRepeat = 1)
    BEGIN
        SELECT Id,
               QuestionTitle
        FROM dbo.SeenClientQuestions
        WHERE SeenClientId = @Id
              AND IsRepetitive = 1
              AND QuestionsGroupNo = @GroupId
              AND QuestionsGroupName = @GroupName
              AND IsDeleted = 0
              AND QuestionTypeId NOT IN ( 16, 17, 23, 18, 5, 26);
    END;
    ELSE
    BEGIN
        SELECT Id,
               QuestionTitle
        FROM dbo.SeenClientQuestions
        WHERE SeenClientId = @Id
              AND IsRepetitive = 0
              AND IsDeleted = 0
              AND QuestionTypeId NOT IN ( 16, 17, 23, 18, 5, 26 );
    END;
END;
