
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,20 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		CaptureFormQuestionOptionList 609
-- =============================================
CREATE PROCEDURE [dbo].[CaptureFormQuestionOptionList_111721] @QuestionnaireFormId BIGINT
AS
BEGIN
    SELECT O.Id AS OptionId,
           RTRIM(LTRIM(O.Name)) AS OptionName,
           O.DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           RTRIM(LTRIM(O.Value)) AS OptionValue
    FROM dbo.SeenClientOptions AS O
        INNER JOIN dbo.SeenClientQuestions AS Q
            ON O.QuestionId = Q.Id
    WHERE Q.SeenClientId = @QuestionnaireFormId
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.QuestionTypeId != 26
    ORDER BY Q.Id,
             O.Position;

    SELECT SeenClientId AS CaptureFormId,
           Id AS QuestionId,
           QuestionTypeId,
           ShortName AS QuestionName,
           [Required],
           ISNULL(ContactQuestionId, 0) AS ContactQuestionId,
           Position,
           ISNULL(Hint, '') AS Hint,
           IsDecimal,
           IsRepetitive,
           [MaxLength],
           MaxWeight,
           [Weight],
           WeightForNo,
           WeightForYes
    FROM dbo.SeenClientQuestions
    WHERE QuestionTypeId NOT IN ( 16, 17, 25, 27, 23 )
          AND IsDeleted = 0
          AND IsActive = 1
          AND SeenClientId = @QuestionnaireFormId
    ORDER BY Position ASC;
END;
