-- Stored Procedure

-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		GetPendingEmailListByModule 3
-- =============================================
CREATE PROCEDURE dbo.GetPendingEmailListByModule @ModuleId BIGINT
AS
BEGIN
SET NOCOUNT ON
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    UPDATE dbo.PendingEmail
    SET IsDeleted = 1
    WHERE EmailId = ''
          OR EmailId IS NULL
          OR LEN(EmailId) <= 5;

	UPDATE 
	dbo.PendingEmail
	SET InProcess = 0
	WHERE IsSent = 0 AND InProcess = 1 AND IsDeleted = 0
	AND DATEDIFF(MINUTE, ScheduleDateTime, GETUTCDATE()) > 30;

	IF OBJECT_ID('tempdb..#PendingEmailTemp', 'u') IS NOT NULL  
	DROP TABLE #PendingEmailTemp
	
	CREATE TABLE  #PendingEmailTemp(
		Id BIGINT,
		ModuleId BIGINT,
		EmailId NVARCHAR(1000),
		EmailSubject NVARCHAR(500),
        EmailText NVARCHAR(MAX),
		IsSent bit,
        SentDate DATETIME,
        RefId BIGINT,
        ScheduleDateTime DATETIME,
		ReplyTo NVARCHAR(MAX),
		Counter INT,
		GroupName VARCHAR(500),
		Attachment NVARCHAR(MAX),
		ReportId BIGINT,
		ActivityId BIGINT,
		IsOut BIT,
        AppUserId BIGINT,
		EmailType INT
	);

    IF (@ModuleId = 2 OR @ModuleId = 7)
    BEGIN
	INSERT INTO #PendingEmailTemp 
        SELECT TOP 500 PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               ISNULL(   GroupName,
               (
                   SELECT GroupName
                   FROM dbo.[Group]
                   WHERE Id =
                   (
                       SELECT GroupId
                       FROM dbo.Establishment
                       WHERE Id =
                       (
                           SELECT EstablishmentId
                           FROM dbo.AnswerMaster
                           WHERE Id = dbo.PendingEmail.RefId
                       )
                   )
               )
                     ) AS GroupName,
               PendingEmail.Attachment,
               AM.Id AS 'ReportId',
               E.EstablishmentGroupId AS 'ActivityId',
               CONVERT(BIT, 0) AS 'IsOut',
               dbo.PendingEmail.CreatedBy AS 'AppUserId',
			   dbo.PendingEmail.EmailType AS EmailType
        FROM dbo.PendingEmail
            INNER JOIN dbo.AnswerMaster AM
                ON dbo.PendingEmail.RefId = AM.Id
            INNER JOIN dbo.Establishment E
                ON AM.EstablishmentId = E.Id
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1
			  AND InProcess = 0;

    END
    ELSE IF (@ModuleId = 3 OR @ModuleId = 8)
    BEGIN
		INSERT INTO #PendingEmailTemp 
			SELECT TOP 500 PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               ISNULL(GroupName, 'Magnitude') AS GroupName,
               PendingEmail.Attachment,
               SCAM.Id AS 'ReportId',
               E.EstablishmentGroupId AS 'ActivityId',
               CONVERT(BIT, 1) AS 'IsOut',
               dbo.PendingEmail.CreatedBy AS 'AppUserId',
			   dbo.PendingEmail.EmailType AS EmailType
        FROM dbo.PendingEmail
            INNER JOIN dbo.SeenClientAnswerMaster SCAM
                ON dbo.PendingEmail.RefId = SCAM.Id
            INNER JOIN dbo.Establishment E
                ON SCAM.EstablishmentId = E.Id
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1
			  AND InProcess = 0;

    END;
    ELSE
    BEGIN
       INSERT INTO #PendingEmailTemp 
			SELECT TOP 500 PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               CASE
                   WHEN PendingEmail.CreatedBy = 1 THEN
                       'Magnitude Gold'
                   ELSE
                       ISNULL(   GroupName,
                       (
                           SELECT GroupName
                           FROM dbo.[Group]
                           WHERE Id =
                           (
                               SELECT GroupId
                               FROM dbo.Establishment
                               WHERE Id =
                               (
                                   SELECT EstablishmentId
                                   FROM dbo.AnswerMaster
                                   WHERE Id = dbo.PendingEmail.RefId
                               )
                           )
                       )
                             )
               END AS GroupName,
               PendingEmail.Attachment,
               CONVERT(BIGINT, 0) AS 'ReportId',
               CONVERT(BIGINT, 0) AS 'ActivityId',
               CONVERT(BIT, 1) AS 'IsOut',
               CONVERT(BIGINT, 0) AS 'AppUserId',
			   dbo.PendingEmail.EmailType AS EmailType
        FROM dbo.PendingEmail
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1
			  AND InProcess = 0;

    END;

		UPDATE PE 
		SET PE.InProcess = 1
		FROM dbo.PendingEmail PE
		INNER JOIN #PendingEmailTemp
		ON #PendingEmailTemp.Id = PE.Id;

		SELECT * FROM #PendingEmailTemp;
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
         'dbo.GetPendingEmailListByModule',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ModuleId,
         GETUTCDATE(),
         N''
        );
END CATCH
SET NOCOUNT OFF
END;
