-- =============================================
-- Author:		Krishna Panchal
-- Create date:	31-Dec-2021
-- Description:	<GetRepetitiveQuestionGroupListByQuestionnaireId>
-- Call SP    :	GetSectionListByQuestionnaireId 1037
-- =============================================
CREATE PROC dbo.GetSectionListByQuestionnaireId @QuestionnaireId BIGINT
AS
BEGIN
    SELECT SectionNo,
           SectionName,
           ISNULL(IsRoutingOnSection, 0) AS IsRoutingOnSection
    FROM dbo.Questions
    WHERE QuestionnaireId = @QuestionnaireId
          AND ISNULL(IsSection, 0) = 1
          AND IsDeleted = 0
    GROUP BY SectionNo,
             SectionName,
             ISNULL(IsRoutingOnSection, 0);
END;
