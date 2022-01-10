-- =============================================
-- Author:			D#3
-- Create date:	11-Feb-2018
-- Description:	Get All App User List by ActivityId
-- Call: dbo.WSGetPendingNotification 1243,'Everyone','','0','','All','All','All','1999-01-07 00:00:00','2019-08-01 23:59:59',1,50,'1'
-- =============================================
CREATE PROCEDURE dbo.WSGetPendingNotification_DBA_BeforeTotalCount
    @AppUserId BIGINT,              /* login User Id  */
    @Sortby VARCHAR(50) = '',       /* Sortby For me and Everyone Notification */
    @TextSearch VARCHAR(500) = '',  /* free text search */
    @ActivityId VARCHAR(MAX) = '0', /* Select Activity */
    @UserId VARCHAR(MAX) = '0',     /* Select User Id who has sent Notification. */
    @Type VARCHAR(10),              /* Notification Type OUT,IN,Action  */
    @FormStatus VARCHAR(15),        /* Form Status Resolve, Unresolved  */
    @IsRead VARCHAR(10),            /* View, Unview Notification */
    @FromDate DATETIME,             /* From Date Schedule date  */
    @ToDate DATETIME,               /* To Date Schedule date  */
    @Page INT = 1,                  /* Select Page No  */
    @Rows INT = 20,
    @Flag VARCHAR(10) = '',
    @UserFilter VARCHAR(10) = '',   /* Select Row No  */
    @isOld BIT = 0
AS
BEGIN
    DECLARE @SqlString VARCHAR(MAX),
            @SqlString2 VARCHAR(MAX),
            @Filter VARCHAR(MAX) = '',
            @FilterDate VARCHAR(MAX) = '',
            @FilterTextSearch VARCHAR(MAX) = '',
            @FilterUser VARCHAR(MAX) = '',
            @UserFilterCondition VARCHAR(MAX) = '';



    IF (@UserFilter = '0')
    BEGIN
        SET @UserFilterCondition = ' AND P.AppUserId =  ' + CONVERT(VARCHAR(10), @AppUserId) + ' ';
    END;

    DECLARE @Start AS INT;
    DECLARE @End INT;

    IF ISNULL(@Sortby, '') = 'Me'
    BEGIN
        SET @FilterDate += ' AND P.ModuleId IN ( 12, 11 ) AND P.[Message] NOT LIKE ''%@EveryOne%'' ';
    END;


    IF @TextSearch != ''
       AND @TextSearch IS NOT NULL
    BEGIN
        SET @FilterTextSearch += ' AND P.[Message] LIKE ''%' + @TextSearch + '%'' ';
    END;

    IF (@ActivityId = '0')
    BEGIN
        DECLARE @listStr NVARCHAR(MAX);
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES
            INNER JOIN dbo.AppUserEstablishment
                ON AppUserEstablishment.EstablishmentId = ES.Id
        WHERE dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityId = @listStr;
    END;
    IF (@isOld = 0)
    BEGIN
        DECLARE @Result AS TABLE
        (
            RowNum INT,
            NotificationId BIGINT,
            ReportId BIGINT,
            ActivityType VARCHAR(50),
            NotificationHeader VARCHAR(500),
            NotificationText VARCHAR(MAX),
            NotificationType VARCHAR(30),
            ModuleId INT,
            AppUserId BIGINT,
            IsChat BIT,
            IsRead BIT,
            IsFlag BIT,
            CreatedBy VARCHAR(100),
            ActivityId BIGINT,
            FormStatus VARCHAR(12),
            NotificationDate VARCHAR(50),
            TotalPage INT
                DEFAULT (1),
            TotalRecord BIGINT,
            CreateDate DATETIME,
            ReminderEstablishment BIGINT
        );

        IF @Rows <> ''
           AND @Rows IS NULL
        BEGIN
            SET @Rows = 20;
        END;

        IF (DATEPART(YEAR, @FromDate) = 1970)
        BEGIN
            SET @FromDate = '01 Jan 2015';
        END;

        SET @Start = ((@Page * @Rows) - @Rows) + 1;
        SET @End = @Start + @Rows - 1;
        /* Paging */
        /* Type Filter */
        IF (@Type = 'In')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END = ''In'' ';
        END;
        ELSE IF (@Type = 'Out')
        BEGIN
            SET @Filter += 'AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2 OR P.ModuleId = 14) THEN ''In''
				  WHEN ( P.ModuleId = 3 OR P.ModuleId = 13) THEN ''Out'' ELSE ''Out'' END = ''Out'' ';
        END;
        ELSE IF (@Type = 'Chat')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END = ''Chat'' ';
        END;
        /* Type Filter */
        /* Status Filter */
        IF (@FormStatus = 'Unresolved')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved ELSE AM.IsResolved END = ''Unresolved'' ';
        END;
        ELSE IF (@FormStatus = 'Resolved')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved ELSE AM.IsResolved END = ''Resolved'' ';
        END;
        /* Status Filter */

        /* User Filter */
        IF (@UserId != '' AND @UserId IS NOT NULL)
        BEGIN
            IF (@UserId = '0')
            BEGIN
                SET @FilterUser += '';
            END;
            ELSE
            BEGIN
                IF (@Type = 'In')
                BEGIN
                    SET @FilterUser += '';
                END;
                ELSE IF (@Type = 'Out')
                BEGIN
                    SET @FilterUser += ' AND (P.CreatedBy IN (SELECT Data FROM Split(''' + @UserId + ''','','')))';
                END;
                ELSE IF (@UserFilter = '1')
                BEGIN
                    PRINT 2;
                    SET @FilterUser += ' AND (P.AppuserId IN (' + @UserId + ') OR P.CreatedBy IS NULL)';
                END;
                ELSE
                BEGIN
                    PRINT 111;
                    SET @UserId = @UserId + ',' + CONVERT(VARCHAR(10), @AppUserId);
                    SET @FilterUser += ' AND (P.AppuserId IN (SELECT Data FROM Split(''' + @UserId
                                       + ''','','')) OR P.CreatedBy IS NULL)';
                END;
            END;
        END;
        /* User Filter */
        /* Date Filter */
        IF (@FromDate != '' AND @ToDate != '')
        BEGIN
            SET @FilterDate += ' AND P.CreatedOn BETWEEN ''' + CONVERT(VARCHAR(19), @FromDate, 120) + ''' AND '''
                               + CONVERT(VARCHAR(19), DATEADD(d, 1, @ToDate), 120) + ''' ';
        END;
        /* Date Filter */
        /* Read Filter */
        IF (@IsRead = '1')
        BEGIN
            SET @Filter += ' AND P.IsRead = 1 ';
        END;
        ELSE IF (@IsRead = '0')
        BEGIN
            SET @Filter += ' AND P.IsRead = 0 ';
        END;
        /* Read Filter */

        /* Flag Filter */
        IF (@Flag = '1')
        BEGIN
            SET @Filter += ' AND isnull(F.IsFlag,0) = 1 ';
        END;
        ELSE IF (@IsRead = '0')
        BEGIN
            SET @Filter += ' AND P.IsRead = 0 ';
        END;
        /* Read Filter */

        SET @SqlString
            = N'SELECT DISTINCT P.Id ,
							P.RefId AS RefId ,
		--(SELECT TOP 1 EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE Id=E.EstablishmentGroupId) AS ActivityType,
		   CASE WHEN p.RefId<>0
	   THEN eg.EstablishmentGroupType
	   ELSE egg.EstablishmentGroupType
	   END AS ActivityType,

	    CASE WHEN p.RefId<>0
		  THEN
		EG.EstablishmentGroupName + '' ('' + e.EstablishmentName + '') By '' +	CASE WHEN P.ModuleId = 2 THEN(CASE WHEN P.CreatedBy = P.RefId THEN ISNULL(P.CustomerName,'''')ELSE '''' END + dbo.ContactOrContactGroupNameById((SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE Id = P.RefId)))  WHEN P.ModuleId = 3 THEN ((CASE WHEN P.CreatedBy = 1 THEN ISNULL(P.CustomerName +  '','', '''') ELSE(SELECT Name FROM dbo.AppUser WHERE Id = P.CreatedBy)END) + '' TO '' + (dbo.ContactOrContactGroupNameById(P.RefId))) WHEN P.ModuleId IN ( 11, 12, 7, 8, 6 ) THEN(CASE WHEN P.CreatedBy = 1 THEN ISNULL(P.CustomerName +  '','', '''')ELSE(SELECT [Name] FROM dbo.AppUser WHERE Id = P.CreatedBy) END + '' '' )END 
		ELSE
		''Capture Reminder Notification''
		END
		AS [NotificationHeader],
        p.[Message] ,
		CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out''
				  WHEN ( P.ModuleId = 13) THEN ''Capture Reminder''
				  WHEN ( P.ModuleId = 13) THEN ''Feedback Reminder''
				   ELSE ''Out'' END 
		AS NotificationType,
		P.ModuleId,
        P.AppUserId ,
		CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN 1
                  WHEN ( P.ModuleId = 2 OR P.ModuleId = 3 OR P.ModuleId = 13) THEN 0 ELSE 1
		END AS IsChat ,
        P.IsRead ,
		isnull(F.IsFlag,0) as IsFlag ,
		CASE WHEN P.CreatedBy IS NULL THEN ''''
		ELSE (SELECT Name FROM dbo.AppUser WHERE Id= P.CreatedBy)
		END AS CreatedBy,
          CASE WHEN p.RefId<>0
	   THEN E.EstablishmentGroupId
	   ELSE ee.EstablishmentGroupId
	   END AS EstablishmentGroupId ,
		CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved 
				  WHEN ( P.ModuleId = 13 OR P.ModuleId = 14) THEN ''Unresolved''
				  ELSE AM.IsResolved END AS FormStatus,

         CASE WHEN p.RefId<>0
		  THEN
		(SELECT FORMAT( (DATEADD(MINUTE,CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.TimeOffSet
          WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) 
		  THEN SAM.TimeOffSet ELSE AM.TimeOffSet END, P.CreatedOn)), ''dd/MMM/yyyy HH:mm:ss'', ''en-US'' )) 
		    ELSE
          (SELECT FORMAT( (DATEADD(MINUTE, EE.TimeOffSet
		   , PE.SentDate)), ''dd/MMM/yyyy HH:mm:ss'', ''en-US'' ))
		   END		  
		  AS [NotificationDate],
		
		DATEADD(MINUTE, CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.TimeOffSet
                                                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.TimeOffSet  WHEN  P.ModuleId = 13
						  THEN ee.TimeOffSet else   AM.TimeOffSet END, P.CreatedOn) AS CreateDate
		, CASE WHEN p.RefId=0 THEN 		PE.EstablishmentId ELSE 0 END AS ReminderEstablishment';
        PRINT '@@@@@@@@@@@';
        PRINT LEN(@SqlString);
        PRINT '@@@@@@@@@@@';
        SET @SqlString2
            = CHAR(13)
              + N'FROM    dbo.PendingNotificationWeb P
        INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.AnswerMaster AM ON P.RefId = AM.Id AND ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) AND AM.IsDeleted = 0
        LEFT JOIN dbo.SeenClientAnswerMaster SAM ON P.RefId = SAM.Id AND ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) AND SAM.IsDeleted = 0
        LEFT JOIN dbo.Establishment E ON (E.Id = AM.EstablishmentId OR E.Id = SAM.EstablishmentId)  AND E.IsDeleted = 0
		LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = e.EstablishmentGroupId
		LEFT JOIN dbo.PendingEstablishmentReminder PE ON PE.AppUserId = P.AppUserId AND PE.Message = P.Message
		LEFT JOIN dbo.Establishment EE ON pe.EstablishmentId=Ee.Id
	LEFT JOIN dbo.EstablishmentGroup EGG ON egg.Id=ee.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON CASE WHEN F.NotificationId = 0 AND F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId THEN 1 WHEN F.NotificationId <> 0 AND F.NotificationId = P.Id AND F.AppUserId = P.AppUserId THEN 1 ELSE 0 END = 1
        WHERE CASE WHEN p.RefId<>0
	   THEN eg.EstablishmentGroupType
	   ELSE egg.EstablishmentGroupType
	   END  IS NOT NULL ' + @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch + @FilterUser
              + ' 
		'                 + CHAR(13) + ' and( E.EstablishmentGroupId  is null or E.EstablishmentGroupId IN ('
              + @ActivityId + ')) ' + @Filter + '
		'                 + CHAR(13) + 'ORDER BY CreateDate desc OFFSET (' + CAST(@Page AS VARCHAR(200)) + '- 1) *'
              + CAST(@Rows AS VARCHAR(200)) + ' ROWS FETCH NEXT ' + CAST(@Rows AS VARCHAR(200)) + ' ROWS ONLY';
        PRINT @SqlString + @SqlString2;
        INSERT INTO @Result
        (
            -- RowNum,
            NotificationId,
            ReportId,
            ActivityType,
            NotificationHeader,
            NotificationText,
            NotificationType,
            ModuleId,
            AppUserId,
            IsChat,
            IsRead,
            IsFlag,
            CreatedBy,
            ActivityId,
            FormStatus,
            NotificationDate,
            --  TotalPage,
            --   TotalRecord,
            CreateDate,
            ReminderEstablishment
        )
        EXECUTE (@SqlString + @SqlString2);

        SELECT --RowNum,
            NotificationId,
            ReportId,
            ActivityType,
            NotificationHeader,
            NotificationText,
            NotificationType,
            ModuleId,
            AppUserId,
            IsChat,
            IsRead,
            IsFlag,
            CreatedBy,
            ActivityId,
            FormStatus,
            [NotificationDate],
            ReminderEstablishment
        -- TotalPage,
        --TotalRecord
        FROM @Result
        ORDER BY CreateDate DESC;
    END;
    ELSE
    BEGIN
        DECLARE @Result1 AS TABLE
        (
            RowNum INT,
            NotificationId BIGINT,
            ReportId BIGINT,
            ActivityType VARCHAR(50),
            NotificationHeader VARCHAR(500),
            NotificationText VARCHAR(MAX),
            NotificationType VARCHAR(30),
            ModuleId INT,
            AppUserId BIGINT,
            IsChat BIT,
            IsRead BIT,
            IsFlag BIT,
            CreatedBy VARCHAR(100),
            ActivityId BIGINT,
            FormStatus VARCHAR(12),
            NotificationDate VARCHAR(50),
            TotalPage INT
                DEFAULT (1),
            TotalRecord BIGINT,
            CreateDate DATETIME
        );

        IF @Rows <> ''
           AND @Rows IS NULL
        BEGIN
            SET @Rows = 20;
        END;

        IF (DATEPART(YEAR, @FromDate) = 1970)
        BEGIN
            SET @FromDate = '01 Jan 2015';
        END;

        SET @Start = ((@Page * @Rows) - @Rows) + 1;
        SET @End = @Start + @Rows - 1;
        /* Paging */
        /* Type Filter */
        IF (@Type = 'In')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END = ''In'' ';
        END;
        ELSE IF (@Type = 'Out')
        BEGIN
            SET @Filter += 'AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END = ''Out'' ';
        END;
        ELSE IF (@Type = 'Chat')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END = ''Chat'' ';
        END;
        /* Type Filter */
        /* Status Filter */
        IF (@FormStatus = 'Unresolved')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved ELSE AM.IsResolved END = ''Unresolved'' ';
        END;
        ELSE IF (@FormStatus = 'Resolved')
        BEGIN
            SET @Filter += ' AND CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved ELSE AM.IsResolved END = ''Resolved'' ';
        END;
        /* Status Filter */

        /* User Filter */
        IF (@UserId != '' AND @UserId IS NOT NULL)
        BEGIN
            IF (@UserId = '0')
            BEGIN
                SET @FilterUser += '';
            END;
            ELSE
            BEGIN
                IF (@Type = 'In')
                BEGIN
                    SET @FilterUser += '';
                END;
                ELSE IF (@Type = 'Out')
                BEGIN
                    SET @FilterUser += ' AND (P.CreatedBy IN (SELECT Data FROM Split(''' + @UserId + ''','','')))';
                END;
                ELSE IF (@UserFilter = '1')
                BEGIN
                    PRINT 2;
                    SET @FilterUser += ' AND (P.AppuserId IN (' + @UserId + ') OR P.CreatedBy IS NULL)';
                END;
                ELSE
                BEGIN
                    PRINT 111;
                    SET @UserId = @UserId + ',' + CONVERT(VARCHAR(10), @AppUserId);
                    SET @FilterUser += ' AND (P.AppuserId IN (SELECT Data FROM Split(''' + @UserId
                                       + ''','','')) OR P.CreatedBy IS NULL)';
                END;
            END;
        END;
        /* User Filter */
        /* Date Filter */
        IF (@FromDate != '' AND @ToDate != '')
        BEGIN
            SET @FilterDate += ' AND P.CreatedOn BETWEEN ''' + CONVERT(VARCHAR(19), @FromDate, 120) + ''' AND '''
                               + CONVERT(VARCHAR(19), DATEADD(d, 1, @ToDate), 120) + ''' ';
        END;
        /* Date Filter */
        /* Read Filter */
        IF (@IsRead = '1')
        BEGIN
            SET @Filter += ' AND P.IsRead = 1 ';
        END;
        ELSE IF (@IsRead = '0')
        BEGIN
            SET @Filter += ' AND P.IsRead = 0 ';
        END;
        /* Read Filter */

        /* Flag Filter */
        IF (@Flag = '1')
        BEGIN
            SET @Filter += ' AND isnull(F.IsFlag,0) = 1 ';
        END;
        ELSE IF (@IsRead = '0')
        BEGIN
            SET @Filter += ' AND P.IsRead = 0 ';
        END;
        /* Read Filter */

        SET @SqlString
            = N'SELECT  P.Id ,
							P.RefId AS RefId ,
		(SELECT TOP 1 EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE Id=E.EstablishmentGroupId) AS ActivityType,
		EG.EstablishmentGroupName + '' ('' + e.EstablishmentName + '') By '' +	CASE WHEN P.ModuleId = 2 THEN(CASE WHEN P.CreatedBy = P.RefId THEN ISNULL(P.CustomerName,'''')ELSE '''' END + dbo.ContactOrContactGroupNameById((SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE Id = P.RefId)))  WHEN P.ModuleId = 3 THEN ((CASE WHEN P.CreatedBy = 1 THEN ISNULL(P.CustomerName +  '','', '''') ELSE(SELECT Name FROM dbo.AppUser WHERE Id = P.CreatedBy)END) + '' TO '' + (dbo.ContactOrContactGroupNameById(P.RefId))) WHEN P.ModuleId IN ( 11, 12, 7, 8, 6 ) THEN(CASE WHEN P.CreatedBy = 1 THEN ISNULL(P.CustomerName +  '','', '''')ELSE(SELECT [Name] FROM dbo.AppUser WHERE Id = P.CreatedBy) END + '' '' )END AS [NotificationHeader],
        [Message] ,
		CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN ''Chat''
                  WHEN ( P.ModuleId = 2) THEN ''In''
				  WHEN ( P.ModuleId = 3) THEN ''Out'' ELSE ''Out'' END 
		AS NotificationType,
		P.ModuleId,
        P.AppUserId ,
		CASE WHEN ( P.ModuleId = 12 OR P.ModuleId = 11 OR P.ModuleId = 5 OR P.ModuleId = 6 OR P.ModuleId = 7 OR P.ModuleId = 8) THEN 1
                  WHEN ( P.ModuleId = 2 OR P.ModuleId = 3) THEN 0 ELSE 1
		END AS IsChat ,
        P.IsRead ,
		isnull(F.IsFlag,0) as IsFlag ,
		CASE WHEN P.CreatedBy IS NULL THEN ''''
		ELSE (SELECT Name FROM dbo.AppUser WHERE Id= P.CreatedBy)
		END AS CreatedBy,
        E.EstablishmentGroupId ,
		CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.IsResolved
                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.IsResolved ELSE AM.IsResolved END AS FormStatus,
        

		(SELECT FORMAT( (DATEADD(MINUTE,CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.TimeOffSet
          WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.TimeOffSet ELSE AM.TimeOffSet END, P.CreatedOn)), ''dd/MMM/yyyy HH:mm:ss'', ''en-US'' )) AS [NotificationDate],
		
		DATEADD(MINUTE, CASE WHEN ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) THEN AM.TimeOffSet
                                                  WHEN ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) THEN SAM.TimeOffSet ELSE AM.TimeOffSet END, P.CreatedOn) AS CreateDate';
        PRINT '@@@@@@@@@@@';
        PRINT LEN(@SqlString);
        PRINT '@@@@@@@@@@@';
        SET @SqlString2
            = CHAR(13)
              + N'FROM    dbo.PendingNotificationWeb P
        INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.AnswerMaster AM ON P.RefId = AM.Id AND ( P.ModuleId = 2 OR P.ModuleId = 5 OR P.ModuleId = 7 OR P.ModuleId = 11 ) AND AM.IsDeleted = 0
        LEFT JOIN dbo.SeenClientAnswerMaster SAM ON P.RefId = SAM.Id AND ( P.ModuleId = 3 OR P.ModuleId = 6 OR P.ModuleId = 8 OR P.ModuleId = 12 ) AND SAM.IsDeleted = 0
        LEFT JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId OR E.Id = SAM.EstablishmentId
		LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = e.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON CASE WHEN F.NotificationId = 0 AND F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId THEN 1 WHEN F.NotificationId <> 0 AND F.NotificationId = P.Id AND F.AppUserId = P.AppUserId THEN 1 ELSE 0 END = 1
        
		WHERE   E.IsDeleted = 0' + @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch
              + @FilterUser + ' 
		'                 + CHAR(13) + ' and E.EstablishmentGroupId IN (' + @ActivityId + ') ' + @Filter + '
		'                 + CHAR(13) + 'ORDER BY CreateDate desc OFFSET (' + CAST(@Page AS VARCHAR(200)) + '- 1) *'
              + CAST(@Rows AS VARCHAR(200)) + ' ROWS FETCH NEXT ' + CAST(@Rows AS VARCHAR(200)) + ' ROWS ONLY';
        PRINT @SqlString + @SqlString2;
        INSERT INTO @Result1
        (
            -- RowNum,
            NotificationId,
            ReportId,
            ActivityType,
            NotificationHeader,
            NotificationText,
            NotificationType,
            ModuleId,
            AppUserId,
            IsChat,
            IsRead,
            IsFlag,
            CreatedBy,
            ActivityId,
            FormStatus,
            NotificationDate,
            --  TotalPage,
            --   TotalRecord,
            CreateDate
        )
        EXECUTE (@SqlString + @SqlString2);

        SELECT --RowNum,
            NotificationId,
            ReportId,
            ActivityType,
            NotificationHeader,
            NotificationText,
            NotificationType,
            ModuleId,
            AppUserId,
            IsChat,
            IsRead,
            IsFlag,
            CreatedBy,
            ActivityId,
            FormStatus,
            [NotificationDate]
        -- TotalPage,
        --TotalRecord
        FROM @Result1
        ORDER BY CreateDate DESC;
    END;
END;
