-- =============================================
-- Author:		<Disha Patel>
-- Create date: <10-AUG-2015>
-- Description:	<Get pending bulk sms list & send sms>
-- SendPendingSMSListByModule 10
-- =============================================
/*
Drop procedure SendPendingSMSListByModule_101120
*/
CREATE PROCEDURE dbo.SendPendingSMSListByModule_101120
	@ModuleId BIGINT
AS
BEGIN
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
        AND [Counter] < 2;
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
		AND Counter < 2;

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
        AND Counter < 2;
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
        AND Counter < 2;

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
        AND Counter < 2;

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
        AND Counter < 2;

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
        AND Counter < 2;
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
        AND Counter < 2;
    END;

    UPDATE dbo.PendingSMS
    SET IsDeleted = 1
    WHERE IsDeleted = 0
    AND MobileNo = ''
    OR MobileNo IS NULL
    OR LEN(MobileNo) < 9;

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

        --UPDATE  dbo.PendingSMS
        --SET     IsSent = 1 ,
        --        SentDate = GETUTCDATE()
        --WHERE   Id = @PendingSMSId;

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
END;

