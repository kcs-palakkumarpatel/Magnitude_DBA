-- =============================================
-- Author:		<Disha Patel>
-- Create date: <10-AUG-2015>
-- Description:	<Get pending bulk sms list & send sms>
-- SendPendingSMSListByModule 2
-- =============================================
/*
Drop procedure SendPendingSMSListByModule_101120
*/
CREATE PROCEDURE dbo.SendPendingSMSListByModule
	@ModuleId BIGINT
AS
BEGIN
	
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @PendingSmsTable TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        PendingSmsId BIGINT,
        ModuleId INT,
        MobileNo NVARCHAR(1000),
        SMSText NVARCHAR(MAX),
        ReportId BIGINT DEFAULT 0,
        ActivityId BIGINT DEFAULT 0,
        IsOut BIT DEFAULT 0,
        AppUserId BIGINT DEFAULT 0,
        SMSType INT DEFAULT 0
    );

	
    UPDATE dbo.PendingSMS
    SET IsDeleted = 1
    WHERE IsDeleted = 0
    AND MobileNo = ''
    OR MobileNo IS NULL
    OR LEN(MobileNo) < 9
	OR LEN(MobileNo) > 20;

    DECLARE @IndianGroup VARCHAR(100);
    
	SELECT @IndianGroup = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'IndianGroup';
    
	IF (@ModuleId = 3 OR @ModuleId = 8)
    BEGIN
        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            MobileNo,
            SMSText,
            SCAM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 1) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.SeenClientAnswerMaster SCAM ON dbo.PendingSMS.RefId = SCAM.Id
        INNER JOIN dbo.Establishment E ON SCAM.EstablishmentId = E.Id
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 8
        AND Counter < 2
		AND InProcess = 0;
    END;
    ELSE IF (@ModuleId = 2 OR @ModuleId = 7)
    BEGIN
        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            MobileNo,
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.AnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId NOT IN ( @IndianGroup )
        WHERE (IsSent = 0)
		AND (ScheduleDateTime <= GETUTCDATE())
		AND (dbo.PendingSMS.IsDeleted = 0)
		AND ModuleId = @ModuleId
		AND MobileNo <> ''
		AND LEN(MobileNo) > 8
		AND Counter < 2
		AND InProcess = 0;

        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            '91' + RIGHT(MobileNo, 10),
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.AnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId IN ( @IndianGroup )
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 9
        AND Counter < 2
		AND InProcess = 0;
    END;
    ELSE IF (@ModuleId = 10)
    BEGIN
        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
			MobileNo,
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.AnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId NOT IN ( @IndianGroup )
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 8
        AND Counter < 2
		AND InProcess = 0;

        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            MobileNo,
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.SeenClientAnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId NOT IN ( @IndianGroup )
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 8
        AND Counter < 2
		AND InProcess = 0;

        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            '91' + RIGHT(MobileNo, 10),
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.AnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId IN ( @IndianGroup )
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 9
        AND Counter < 2
		AND InProcess = 0;

        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            '91' + RIGHT(MobileNo, 10),
            SMSText,
            AM.Id AS 'ReportId',
            E.EstablishmentGroupId AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            dbo.PendingSMS.CreatedBy AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        INNER JOIN dbo.SeenClientAnswerMaster AM ON dbo.PendingSMS.RefId = AM.Id
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id AND E.GroupId IN ( @IndianGroup )
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 9
        AND Counter < 2
		AND InProcess = 0;
    END;
    ELSE
    BEGIN
        INSERT INTO @PendingSmsTable
        SELECT TOP 1000
            dbo.PendingSMS.Id,
            ModuleId,
            MobileNo,
            SMSText,
            CONVERT(BIGINT, 0) AS 'ReportId',
            CONVERT(BIGINT, 0) AS 'ActivityId',
            CONVERT(BIT, 0) AS 'IsOut',
            CONVERT(BIGINT, 0) AS 'AppUserId',
            dbo.PendingSMS.SMSType AS SMSType
        FROM dbo.PendingSMS
        WHERE (IsSent = 0)
        AND (ScheduleDateTime <= GETUTCDATE())
        AND (dbo.PendingSMS.IsDeleted = 0)
        AND ModuleId = @ModuleId
        AND MobileNo <> ''
        AND LEN(MobileNo) > 8
        AND Counter < 2
		AND InProcess = 0;
    END;


	--UPDATE 
	--dbo.PendingSMS
	--SET InProcess = 0
	--WHERE IsSent = 0 AND InProcess = 1 AND IsDeleted = 0
	--AND DATEDIFF(MINUTE, ScheduleDateTime, GETUTCDATE()) > 30;

	UPDATE PS 
	SET PS.InProcess = 1 
	FROM dbo.PendingSMS PS
	INNER JOIN @PendingSmsTable PT
	ON PT.PendingSmsId = PS.Id;

    --SMS Text
    DECLARE @START INT,
            @COUNT INT;
    
	SET @START = 1;
	SELECT @COUNT = COUNT(*) FROM @PendingSmsTable
   
    SET @COUNT = @COUNT + 1;

    DECLARE @UrlTable AS TABLE
    (
        url NVARCHAR(MAX),
        Id INT IDENTITY(1, 1),
        PendingId INT,
        ReportId BIGINT DEFAULT 0,
        ActivityId BIGINT DEFAULT 0,
        IsOut BIT DEFAULT 0,
        AppUserId BIGINT DEFAULT 0,
        SMSType int DEFAULT 0
    );

    WHILE (@START < @COUNT)
    BEGIN
        DECLARE @PendingSMSId BIGINT;
        DECLARE @MobileNo NVARCHAR(1000);
        DECLARE @SMSText NVARCHAR(MAX);
        DECLARE @ReportId BIGINT;
        DECLARE @ActivityId BIGINT;
        DECLARE @IsOut BIT;
        DECLARE @AppUserId BIGINT;
        DECLARE @SMSType INT;
        
		SELECT @PendingSMSId = PendingSmsId,
               @MobileNo = MobileNo,
               @SMSText = SMSText,
               @ReportId = ReportId,
               @ActivityId = ActivityId,
               @IsOut = IsOut,
               @AppUserId = AppUserId,
               @SMSType = SMSType
        FROM @PendingSmsTable
        WHERE Id = @START;

        IF (@MobileNo IS NOT NULL)
        BEGIN
            INSERT INTO @UrlTable
            (
                url
            )
            EXEC SendBulkSMS @SMSText, @MobileNo;
            UPDATE @UrlTable
            SET PendingId = @PendingSMSId,
                ReportId = @ReportId,
                ActivityId = @ActivityId,
                IsOut = @IsOut,
                AppUserId = @AppUserId,
                SMSType = @SMSType
            WHERE Id = @START;
        END;

        SET @START = @START + 1;
    END;

    SELECT [url],
           PendingId,
           ReportId,
           ActivityId,
           IsOut,
           AppUserId,
           ISNULL(SMSType, 0) AS SMSType
    FROM @UrlTable;
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
         'dbo.SendPendingSMSListByModule',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @ModuleId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH

END;

