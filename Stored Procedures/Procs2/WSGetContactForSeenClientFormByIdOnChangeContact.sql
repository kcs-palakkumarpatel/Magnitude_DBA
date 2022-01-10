-- =============================================
-- Author:			Anant bhatt
-- Create date:	09-08-2020
-- Description:	<Description,,>
-- Call SP:	WSGetContactForSeenClientFormByIdOnChangeContact 8243,38502,1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactForSeenClientFormByIdOnChangeContact]
    @EstablishmentGroupId BIGINT,
    @ContactMasterId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
    SELECT Q.Id AS QuestionId,
           Q.QuestionTitle,
           Q.QuestionTypeId,
           CASE
               WHEN @IsFromWeb = 1 THEN
                   CASE
                       WHEN Q.QuestionTypeId = 8 THEN
           (CASE
                WHEN Detail IS NULL
                     OR Detail = '' THEN
                    ISNULL(Detail, '')
                ELSE
                    dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
            END
           )
                       WHEN Q.QuestionTypeId = 9 THEN
           (CASE
                WHEN Detail IS NULL
                     OR Detail = '' THEN
                    ISNULL(Detail, '')
                ELSE
                    dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
            END
           )
                       WHEN Q.QuestionTypeId = 22 THEN
           (CASE
                WHEN Detail IS NULL
                     OR Detail = '' THEN
                    ISNULL(Detail, '')
                ELSE
                    dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
            END
           )
                       ELSE
                           ISNULL(Detail, '')
                   END
               ELSE
                   ISNULL(Detail, '')
           END AS Detail,
           IsDisplayInDetail,
           IsDisplayInSummary AS IsDisplayInList
    FROM dbo.ContactQuestions AS Q 
     FULL OUTER JOIN dbo.ContactDetails AS cd
            ON cd.ContactQuestionId = Q.Id
               AND Q.IsDeleted = 0
			   AND Cd.ContactMasterId =@ContactMasterId
    WHERE Q.IsDeleted = 0
          AND (Q.Id IN (
                                 SELECT ColumnValue AS ContactQuestionId
                                 FROM dbo.ConvertStringToTable(
                                      (
                                          SELECT ContactQuestion
                                          FROM dbo.EstablishmentGroup
                                          WHERE Id = @EstablishmentGroupId
                                      ),
                                      ','
                                                              )
                             )
              )
    ORDER BY Q.Position ASC;
END;
