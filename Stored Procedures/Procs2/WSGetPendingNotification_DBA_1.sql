-- =============================================
-- Author:			D#3
-- Create date:	11-Feb-2018
-- Description:	Get All App User List by ActivityId
-- Call: dbo.WSGetPendingNotification_DBA 4177,'Everyone','','0','3331,4562,3800,3311,2500,2182,4567,2218,1835,4016,3032,1839,3958,1249,1829,3634,2234,3127,3630,1776,3082,471,4564,1451,2995,3088,1706,2261,1515,2749,1530,3150,3026,1573,4394,2717,3041,3633,879,3930,3166,3166,3013,3588,3107,2619,3518,3495,4266,4569,1545,3790,1872,3207,2385,3310,2233,3036,3500,1856,2422,2928,4557,3710,2186,1918,3503,3332,3529,2947,2867,3502,4484,2711,3532,2639,3231,995,1245,3334,3801,3929,3929,3981,3000,4011,4178,1733,4383,3493,1311,2386,3183,3028,1709,2499,1542,3055,1723,3230,3340,1815,3538,1707,1758,4147,3116,2285,1583,1444,3019,4568,3094,3196,2595,633,1897,1705,1899,4527,1898,2398,2243,2994,4573,3302,3064,3167,3017,2185,1873,4551,3301,3301,3831,1704,3587,1511,1678,2061,3165,1930,2476,1708,4196,4485,4561,3531,2154,3799,1787,2232,2990,3037,4015,2522,2523,3002,3335,3027,4490,4558,3333,3979,4563,1571,3296,2428,2450,3530,3481,1240,2961,1861,2487,3802,2570,4549,2525,4553,4165,1572,3063,2988,3447,4574,2948,1529,4110,2083,2715,3631,3216,2667,4550,2486,4335,4334,3024,3025,2069,4324,3443,1891,3128,1584,3077,3689,4493,2412,4117,3153,2981,2600,1890,3123,1833,1863,1773,2992,3087,4122,3867,3980,4555,3074,1710,3787,4177,4565,4505,1554,1247,3067,2488,2284,2052,1834,4486,4570,1759,1760,1761,3033,3586,3825,3656,3657,3451,3701,3528,3499,4129,4130,3051,3452,2950,3014,2654,3206,3517,4576,1565,1857,4526,3073,2387,2244,2388,3137,3306,3093,2029,2343,451,4572,1929,3262,2336,450,1889,4323,921,2245,3092,3113,3125,4571,1621,2238,2389,2286,472,3154,2452,3155,1832,2989,3195,1931,4507,1917,1810,464,464,1859,2951,4552,1923,1645,2440,2439,1248,3204,3236,1860,1862,4575,2349,1516,3455,2451,1888,3089,1604,4559,3021,1518,2248,449,3305,2247,3463,2342,3304,2035,4506,3001,2969,3138,3559,3632,1337,3126,3830,1603,2796,3124,1627,1553,2655,2246,3229,3205,1831,3902,2028,3294,1757,3655,1522,1864,4566,1243,1447,4554,4080,4560,1246,880,3136,3141,1809,1896,2746,1156,3237,3446,3295,1567,3872,2217,3170,4556,3494,2249,1858','All','All','All','1999-01-07 00:00:00','2020-01-28 17:59:00',1,50,'1'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetPendingNotification_DBA_1]
    @AppUserId BIGINT,              /* login User Id  */
    @Sortby VARCHAR(50) = '',       /* Sortby For me and Everyone Notification */
    @TextSearch VARCHAR(500) = '',  /* free text search */
    @ActivityId VARCHAR(MAX) = '0', /* Select Activity */
    @UserId VARCHAR(MAX),     /* Select User Id who has sent Notification. */
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
            @FilterTextSearch VARCHAR(2000) = '',
            @FilterUser VARCHAR(2000) = '',
            @UserFilterCondition VARCHAR(50) = '';



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
            = N'SELECT b.Id,b.RefId,b.ActivityType,b.NotificationHeader,b.Message,b.NotificationType,b.ModuleId,b.AppUserId,b.IsChat,b.IsRead,b.IsFlag,b.CreatedBy,
       b.EstablishmentGroupId,b.FormStatus,b.NotificationDate,b.CreateDate,b.ReminderEstablishment  FROM (
SELECT *,ROW_NUMBER() OVER (PARTITION BY Id,CAST(NotificationDate AS DATE) ORDER BY CreateDate DESC) RNum FROM (
			SELECT DISTINCT P.Id ,
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
		'                 + CHAR(13) + ' and (E.EstablishmentGroupId IS NULL or E.EstablishmentGroupId IN ('
              + @ActivityId + ')) ' + @Filter + '
		'                 + CHAR(13) + ' )a		)b WHERE b.RNum=1 ORDER BY CreateDate desc OFFSET (' + CAST(@Page AS VARCHAR(200)) + '- 1) *'
              + CAST(@Rows AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@Rows AS VARCHAR(10)) + ' ROWS ONLY';
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

        SELECT 
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
		--Mittal
        SET @SqlString
            = N'SELECT b.Id,b.RefId,b.ActivityType,b.NotificationHeader,b.Message,b.NotificationType,b.ModuleId,b.AppUserId,b.IsChat,b.IsRead,b.IsFlag,b.CreatedBy,
       b.EstablishmentGroupId,b.FormStatus,b.NotificationDate,b.CreateDate,b.ReminderEstablishment  FROM (
SELECT *,ROW_NUMBER() OVER (PARTITION BY Id,CAST(NotificationDate AS DATE) ORDER BY CreateDate DESC) RNum FROM (			
			SELECT distinct  P.Id ,
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
        
		WHERE   E.IsDeleted = 0' + @UserFilterCondition + CHAR(13) + @FilterDate + CHAR(13)
+ @FilterTextSearch
+ @FilterUser + ' 
		' + CHAR(13) + ' and E.EstablishmentGroupId IN (' + @ActivityId + ') ' 
+ @Filter + '
		'                 + CHAR(13) + ' )a		)b WHERE b.RNum=1 ORDER BY CreateDate desc OFFSET (' + CAST(@Page AS VARCHAR(200)) + '- 1) *'
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

     SELECT 
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
END;


