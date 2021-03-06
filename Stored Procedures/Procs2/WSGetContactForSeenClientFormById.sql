
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-03-2017
-- Description:	<Description,,>
-- Call SP:		WSGetContactForSeenClientFormById 29
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactForSeenClientFormById]
    @EstablishmentGroupId BIGINT,
    @ContactMasterId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
           Q.IsDisplayInDetail,
           Q.IsDisplayInSummary AS IsDisplayInList
    FROM dbo.ContactDetails AS cd WITH
        (NOLOCK)
        INNER JOIN dbo.ContactQuestions AS Q WITH
        (NOLOCK)
            ON cd.ContactQuestionId = Q.Id
               AND Q.IsDeleted = 0
    WHERE cd.ContactMasterId = @ContactMasterId
          AND
          (
              @EstablishmentGroupId = 0
              OR Q.Id IN
                 (
                     SELECT ColumnValue AS ContactQuestionId
                     FROM dbo.ConvertStringToTable(
                          (
                              SELECT ContactQuestion
                              FROM dbo.EstablishmentGroup WITH
                                  (NOLOCK)
                              WHERE Id = @EstablishmentGroupId
                          ),
                          ','
                                                  )
                 )
          )
    ORDER BY Q.Position ASC;
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetContactForSeenClientFormById',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ContactMasterId,0),
         @EstablishmentGroupId+','+@ContactMasterId+','+@IsFromWeb,
         GETUTCDATE(),
		 N''
        );
END CATCH
END;
