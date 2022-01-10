
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,20 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetSeenClientOptionsBySeenClientId 609
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSeenClientOptionsBySeenClientIdMobile_111921] @SeenClientId BIGINT
AS
BEGIN
 SET NOCOUNT ON;
    SELECT O.Id AS OptionId,
           RTRIM(LTRIM(O.Name)) AS OptionName,
           O.DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           RTRIM(LTRIM(O.Value)) AS OptionValue
    FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON O.QuestionId = Q.Id
    WHERE Q.SeenClientId = @SeenClientId
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.QuestionTypeId <> 26 --CREATE New SP AS GetDatabaseReferenceOptionList
    ORDER BY Q.Id,
             O.Position;
END;
