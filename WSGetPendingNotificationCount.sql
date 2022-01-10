-- =============================================
-- Author:			D#3
-- Create date:	11-Feb-2018
-- Description:	Get All App User List by ActivityId
-- Call: dbo.WSGetPendingNotification 1243,'Me','','0','','All','All','All','1999-01-07 00:00:00','2019-08-01 23:59:59',1,50,'1'
-- Drop Procedure WSGetPendingNotificationCount
-- =============================================
CREATE PROCEDURE WSGetPendingNotificationCount
    @AppUserId BIGINT,              /* login User Id  */
    @Sortby VARCHAR(50) = '',       /* Sortby For me and Everyone Notification */
    @ActivityId VARCHAR(8000) = '0', /* Select Activity */
    @UserId VARCHAR(8000) = '0',     /* Select User Id who has sent Notification. */
    @Type VARCHAR(10),              /* Notification Type OUT,IN,Action  */
    @FormStatus VARCHAR(15),        /* Form Status Resolve, Unresolved  */
    @IsRead VARCHAR(10),            /* View, Unview Notification */
    @Flag VARCHAR(10) = '',
    @UserFilter VARCHAR(10) = '',   /* Select Row No  */
    @isOld BIT = 0
AS
BEGIN
    DECLARE @SqlString VARCHAR(MAX),
            @SqlString2 VARCHAR(MAX),
            @Filter VARCHAR(MAX) = '',
            @FilterDate VARCHAR(8000) = '',
            @FilterTextSearch VARCHAR(MAX) = '',
            @FilterUser VARCHAR(8000) = '',
            @UserFilterCondition VARCHAR(MAX) = '';

    CREATE TABLE #result
    (
		TotalRecord BIGINT
	)
	
	IF (@UserFilter = '0')
    BEGIN
        SET @UserFilterCondition = ' AND P.AppUserId =  ' + CONVERT(VARCHAR(10), @AppUserId) + ' ';
    END;

    IF ISNULL(@Sortby, '') = 'Me'
    BEGIN
        SET @FilterDate += ' AND P.ModuleId IN ( 12, 11 ) AND P.[Message] NOT LIKE ''%@EveryOne%'' ';
    END;


    IF (@ActivityId = '0')
    BEGIN
        DECLARE @listStr NVARCHAR(MAX);
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES
		INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = ES.Id
			AND dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityId = @listStr;
    END;
    
	---First Case
	IF (@isOld = 0)
    BEGIN
		
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
                    --PRINT 2;
                    SET @FilterUser += ' AND (P.AppuserId IN (' + @UserId + ') OR P.CreatedBy IS NULL)';
                END;
                ELSE
                BEGIN
                    --PRINT 111;
                    SET @UserId = @UserId + ',' + CONVERT(VARCHAR(10), @AppUserId);
                    SET @FilterUser += ' AND (P.AppuserId IN (SELECT Data FROM Split(''' + @UserId
                                       + ''','','')) OR P.CreatedBy IS NULL)';
                END;
            END;
        END;
        /* User Filter */
        
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
            SET @Filter += ' AND F.IsFlag = 1 ';
        END;
        ELSE IF (@IsRead = '0')
        BEGIN
            SET @Filter += ' AND P.IsRead = 0 ';
        END;
        /* Read Filter */

        SET @SqlString2 = N'SELECT COUNT(*) AS TotalRecord FROM dbo.PendingNotificationWeb P
        INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.AnswerMaster AM ON P.RefId = AM.Id AND ( P.ModuleId In (2,5,7,11)) AND AM.IsDeleted = 0
        LEFT JOIN dbo.Establishment E ON (E.Id = AM.EstablishmentId)  AND E.IsDeleted = 0
		LEFT JOIN dbo.EstablishmentGroup EG ON (EG.Id = e.EstablishmentGroupId)
		LEFT JOIN dbo.PendingEstablishmentReminder PE ON PE.AppUserId = P.AppUserId AND PE.Message = P.Message
		LEFT JOIN dbo.Establishment EE ON pe.EstablishmentId=Ee.Id
		LEFT JOIN dbo.EstablishmentGroup EGG ON egg.Id=ee.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId AND F.NotificationId = 0
		LEFT JOIN dbo.FlagMaster F1 ON F1.NotificationId <> 0 AND F1.NotificationId = P.Id AND F1.AppUserId = P.AppUserId
		WHERE CASE WHEN p.RefId <> 0 THEN eg.EstablishmentGroupType ELSE egg.EstablishmentGroupType END  IS NOT NULL ' 
		+ @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch + @FilterUser + ' 
		'+ CHAR(13) + ' and(E.EstablishmentGroupId IN ('+ @ActivityId + ')) ' + @Filter + '';
		

		SET @SqlString = N'SELECT COUNT(*) AS TotalRecord FROM dbo.PendingNotificationWeb P
		INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.SeenClientAnswerMaster SAM ON P.RefId = SAM.Id AND ( P.ModuleId IN (3,6,8,12)) AND SAM.IsDeleted = 0
        LEFT JOIN dbo.Establishment E1 ON (E1.Id = SAM.EstablishmentId) AND E1.IsDeleted = 0
		LEFT JOIN dbo.EstablishmentGroup EG1 ON (EG1.Id = e1.EstablishmentGroupId)
		LEFT JOIN dbo.PendingEstablishmentReminder PE ON PE.AppUserId = P.AppUserId AND PE.Message = P.Message
		LEFT JOIN dbo.Establishment EE ON pe.EstablishmentId=Ee.Id
		LEFT JOIN dbo.EstablishmentGroup EGG ON egg.Id=ee.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId AND F.NotificationId = 0
		LEFT JOIN dbo.FlagMaster F1 ON F1.NotificationId <> 0 AND F1.NotificationId = P.Id AND F1.AppUserId = P.AppUserId
		WHERE CASE WHEN p.RefId <> 0 THEN eg1.EstablishmentGroupType ELSE egg.EstablishmentGroupType END  IS NOT NULL ' 
		+ @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch + @FilterUser + ' 
		'+ CHAR(13) + ' and(E1.EstablishmentGroupId IN ('+ @ActivityId + ')) ' + @Filter + '';


		--PRINT (@SqlString2)
		--PRINT (@SqlString)
		
		INSERT INTO #Result
		EXECUTE (@SqlString2);

		INSERT INTO #Result
		EXECUTE (@SqlString);

		SELECT SUM(TotalRecord) As TotalRecord FROM #Result

    END;
    ELSE------------------Second Case
    BEGIN
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
                    --PRINT 2;
                    SET @FilterUser += ' AND (P.AppuserId IN (' + @UserId + ') OR P.CreatedBy IS NULL)';
                END;
                ELSE
                BEGIN
                    --PRINT 111;
                    SET @UserId = @UserId + ',' + CONVERT(VARCHAR(10), @AppUserId);
                    SET @FilterUser += ' AND (P.AppuserId IN (SELECT Data FROM Split(''' + @UserId
                                       + ''','','')) OR P.CreatedBy IS NULL)';
                END;
            END;
        END;
        /* User Filter */

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

        SET @SqlString2 = N'SELECT COUNT(*) AS TotalRecord FROM dbo.PendingNotificationWeb P
        INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.AnswerMaster AM ON P.RefId = AM.Id AND (P.ModuleId IN (2,5,7,11)) AND AM.IsDeleted = 0
		LEFT JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
		LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = e.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId AND F.NotificationId = 0
		LEFT JOIN dbo.FlagMaster F1 ON F1.NotificationId <> 0 AND F1.NotificationId = P.Id AND F1.AppUserId = P.AppUserId
		WHERE E.IsDeleted = 0' + @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch + @FilterUser + ' 
		'+ CHAR(13) + ' and E.EstablishmentGroupId IN (' + @ActivityId + ') ' + @Filter + '';

        SET @SqlString = N'SELECT COUNT(*) AS TotalRecord FROM dbo.PendingNotificationWeb P
		INNER JOIN dbo.AppUser A ON P.AppUserId = A.Id and P.IsDeleted = 0 AND (P.ScheduleDate <= GETUTCDATE())
		LEFT JOIN dbo.SeenClientAnswerMaster SAM ON P.RefId = SAM.Id AND (P.ModuleId IN (3,6,8,12)) AND SAM.IsDeleted = 0
		LEFT JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
		LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = e.EstablishmentGroupId
		LEFT JOIN dbo.FlagMaster F ON F.ReportId = P.RefId AND P.ModuleId IN (2,3) AND F.AppUserId = P.AppUserId AND F.NotificationId = 0
		LEFT JOIN dbo.FlagMaster F1 ON F1.NotificationId <> 0 AND F1.NotificationId = P.Id AND F1.AppUserId = P.AppUserId
		WHERE E.IsDeleted = 0' + @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13) + @FilterTextSearch + @FilterUser + ' 
		'+ CHAR(13) + ' and E.EstablishmentGroupId IN (' + @ActivityId + ') ' + @Filter + '';

		--PRINT @SqlString + @SqlString2

		INSERT INTO #Result
		EXECUTE (@SqlString2);

		INSERT INTO #Result
		EXECUTE (@SqlString);

		SELECT SUM(TotalRecord) As TotalRecord FROM #Result

        
    END;
END;