-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-03-2017
-- Description:	<Description,,>
-- Call SP:		WSGetContactForSeenClientFormById_101120 29
-- =============================================
/*
Drop procedure WSGetContactForSeenClientFormById_101120
*/
CREATE PROCEDURE [dbo].[WSGetContactForSeenClientFormById_101120]
	@EstablishmentGroupId BIGINT,
	@ContactMasterId BIGINT,
	@IsFromWeb BIT
AS
BEGIN
    SELECT Q.Id AS QuestionId,
           Q.QuestionTitle,
           Q.QuestionTypeId,
           CASE WHEN @IsFromWeb = 1 THEN
				CASE WHEN Q.QuestionTypeId = 8 THEN
				(CASE WHEN ISNULL(Detail,'') = '' THEN ''
					ELSE dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy') END
				)
				WHEN Q.QuestionTypeId = 9 THEN
				(CASE WHEN ISNULL(Detail,'')  = '' THEN ''
					ELSE dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')END
				)
                WHEN Q.QuestionTypeId = 22 THEN
				(CASE WHEN ISNULL(Detail,'') =  '' THEN ''
                ELSE dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM') END
				)
                ELSE ISNULL(Detail, '') END
				ELSE ISNULL(Detail, '') END AS Detail,
           IsDisplayInDetail,
           IsDisplayInSummary AS IsDisplayInList
    FROM dbo.ContactDetails AS cd
	INNER JOIN dbo.ContactQuestions AS Q ON cd.ContactQuestionId = Q.Id AND Q.IsDeleted = 0
    WHERE ContactMasterId = @ContactMasterId
	AND ( @EstablishmentGroupId = 0
			OR Q.Id IN ( SELECT ColumnValue AS ContactQuestionId
					FROM dbo.ConvertStringToTable(
                    ( SELECT ContactQuestion FROM dbo.EstablishmentGroup WHERE Id = @EstablishmentGroupId),','))
		)
    ORDER BY Q.Position ASC;
END;