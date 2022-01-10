
--EXEC dbo.WsGetContactGroupDetilsForSeenClientById 8243,1827,1
CREATE PROCEDURE [dbo].[WsGetContactGroupDetilsForSeenClientById]
    @EstablishmentGroupId BIGINT,
    @ContactGroupId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT -1 AS QuestionId,
           -1 AS QuestionTypeId,
           'Group Name' AS QuestionTitle,
           ContactGropName AS Detail,
           LastUsedOn
    FROM dbo.ContactGroup WITH
        (NOLOCK)
    WHERE Id = @ContactGroupId
    UNION
    SELECT Cq.Id AS QuestionId,
           Cq.QuestionTypeId,
           Cq.QuestionTitle,
           CASE
               WHEN @IsFromWeb = 1 THEN
                   dbo.GetContactDetailsForGroupWeb(@ContactGroupId, Cq.Id)
               ELSE
                   dbo.GetContactDetailsForGroup(@ContactGroupId, Cq.Id)
           END AS Detail,
           NULL AS LastUsedOn
    FROM dbo.ContactGroupRelation AS CGR WITH
        (NOLOCK)
        INNER JOIN dbo.ContactMaster AS Cm WITH
        (NOLOCK)
            ON CGR.ContactMasterId = Cm.Id
        INNER JOIN dbo.ContactDetails AS Cd WITH
        (NOLOCK)
            ON Cm.Id = Cd.ContactMasterId
               AND
               (
                   @EstablishmentGroupId = 0
                   OR Cd.ContactQuestionId IN
                      (
                          SELECT ColumnValue AS ContactMasterId
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
        INNER JOIN dbo.ContactQuestions AS Cq WITH
        (NOLOCK)
            ON Cd.ContactQuestionId = Cq.Id
    WHERE Cd.IsDeleted = 0
          AND CGR.IsDeleted = 0
          AND Cm.IsDeleted = 0
          AND Cq.IsDeleted = 0
          AND Cq.IsDisplayInSummary = 1
          AND CGR.ContactGroupId = @ContactGroupId
    GROUP BY Cq.Id,
             Cq.QuestionTypeId,
             Cq.QuestionTitle;
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
         'dbo.WsGetContactGroupDetilsForSeenClientById',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ContactGroupId,0),
         @EstablishmentGroupId+','+@ContactGroupId+','+@IsFromWeb,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
