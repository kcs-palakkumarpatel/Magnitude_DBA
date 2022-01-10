--=============================================
--Author		:		VASUDEV
--Create date	:	29-JUNE-2017
--Description	:	Mobile Api Search Feedback List Page.
--Call SP		:	dbo.AdvanceSearchFormData '0', '0', 1753, 50, 1, '', '11/1/2017 00:00:00', '03/13/2018 00:00:00', '','', 1776,0,'Unresolved','','False','False','','','False','','','','','',''
/*
EXEC dbo.AdvanceSearchFormData @EstablishmentId = '0', -- varchar(max)
    @UserId = '0', -- varchar(max)
    @ActivityId = 2011, -- bigint
    @Rows = 50, -- int
    @Page = 1, -- int
    @Status = N'', -- nvarchar(50)
    @FromDate = '2015-05-25 06:18:39', -- datetime
    @ToDate = '2018-09-11 23:18:39', -- datetime
    @FilterOn = N'', -- nvarchar(50)
    @QuestionSearch = N'', -- nvarchar(max)
    @AppuserId = 1615, -- int
    @ReportId = 0, -- int
    @FormStatus = 'Unresolved', -- varchar(10)
    @ReadUnread = '', -- varchar(10)
    @isResend = '', -- varchar(5)
    @isRecursion = '', -- varchar(5)
    @isAction = '', -- varchar(5)
    @ActionSearch = '', -- varchar(50)
    @isTransfer = '', -- varchar(5)
    @TemplateId = '', -- varchar(1000)
    @PIFilter = '', -- varchar(50)
    @IsEdited = '', -- varchar(5)
    @Search = 'blu', -- varchar(1000)
    @OrderBy = '', -- varchar(200)
    @isFromActivity = '', -- varchar(5)
    @IsResponse = '', -- varchar(5)
    @ResponseType = '' -- varchar(15)
	*/

--=============================================
CREATE PROCEDURE [dbo].[AdvanceSearchFormData_02Aug2018]
    @EstablishmentId VARCHAR(MAX) ,
    @UserId VARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Rows INT ,
    @Page INT ,
    @Status NVARCHAR(50) ,		/*	----- 1 strstatustype */
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50) ,		/* For Question Search FormType (In Or OUt) */
    @QuestionSearch NVARCHAR(MAX) ,		/* For $ seprater String. */
    @AppuserId INT ,
    @ReportId INT ,
    @FormStatus VARCHAR(10) ,		/* Resolved, Unresolved AnswerStatus */
    @ReadUnread VARCHAR(10) ,		/* Unread, Read  IsOutStanding */
    @isResend VARCHAR(5) ,			/* IsResend = true or False  IsResend */
    @isRecursion VARCHAR(5) ,			/* isRecursion = true or False  */
    @isAction VARCHAR(5) ,
    @ActionSearch VARCHAR(50) ,
    @isTransfer VARCHAR(5) ,
    @TemplateId VARCHAR(1000) ,
    @PIFilter VARCHAR(50) ,
    @IsEdited VARCHAR(5) ,
    @Search VARCHAR(1000) ,
    @OrderBy VARCHAR(200) ,
    @isFromActivity VARCHAR(5) = '' ,
    @IsResponse VARCHAR(5) = 'false' ,
    @ResponseType VARCHAR(15) = 'All'
AS
    BEGIN
        SET NOCOUNT ON;
		
        DECLARE @Url VARCHAR(50);
        DECLARE @GroupType INT;
        SELECT  @Url = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'FeedbackUrl';
        SELECT  @GroupType = ISNULL(Id, 0)
        FROM    dbo.AppUser
        WHERE   GroupId IN (
                SELECT  Data
                FROM    dbo.Split(( SELECT  KeyValue
                                    FROM    dbo.AAAAConfigSettings
                                    WHERE   KeyName = 'ExcludeGroupId'
                                  ), ',') )
                AND Id = @AppuserId;
		
        IF ( @OrderBy = 'action' )
            BEGIN
                SET @OrderBy = ' Order By R.ActionDate Desc';
            END;

        IF ( @OrderBy = 'actionEveryone' )
            BEGIN
                SET @OrderBy = ' Order By R.ActionDateEveryone Desc';
            END;

        IF ( @OrderBy = 'ResponseForm' )
            BEGIN
                SET @OrderBy = '  ORDER BY R.Mobilink DESC';
            END;

        IF ( @OrderBy = '' )
            BEGIN
                SET @OrderBy = '  ORDER BY R.CreatedOn DESC';
		/*SET @OrderBy = ' Order By  CASE ISNULL(SeenClientAnswerMasterId, 0)
                  WHEN 0 THEN ReportId
                  ELSE SeenClientAnswerMasterId
                END Desc'*/
            END;

        DECLARE @IsOut BIT;
        IF ( @FilterOn = 'In' )
            BEGIN
                SET @IsOut = 0;
            END;
       
        ELSE
            IF ( @FilterOn = 'Out' )
                BEGIN
                    SET @IsOut = 1;
                END;

        IF ( @Rows = 0 )
            BEGIN
                SET @Rows = 50;
            END;
	
        IF @QuestionSearch IS NULL
            BEGIN
                SET @QuestionSearch = '';
            END;
        
        IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                                       );
            END;
        IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0'
             AND @ActivityType != 'Customer'
           )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                            @EstablishmentId,
                                                            @ActivityId)
                              );
            END;
		
        DECLARE @ActionFilter NVARCHAR(MAX);
        SET @ActionFilter = '';
        SELECT  @ActionFilter = STUFF((SELECT   '%'' OR Conversation LIKE ''%'
                                                + REPLACE(REPLACE(TemplateText,
                                                              '''', ''''''),
                                                          '[', '[[]')
                                       FROM     dbo.CloseLoopTemplate
                                       WHERE    EstablishmentGroupId = @ActivityId
                                                AND Id IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@TemplateId,
                                                              ',') )
                FOR                   XML PATH('') ,
                                          TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 26, '');

        SELECT  @ActionFilter = ' AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) 
						FROM dbo.CloseLoopAction 
						WHERE isdeleted = 0 
						And (Conversation LIKE ''%' + @ActionFilter + '%''))';
	/*	---------------------------END------------------------------------ */
	/*	---------------------------PI Filter------------------------------ */

        DECLARE @PIFilterTable TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Comparetype VARCHAR(150)
            );

        DECLARE @CompareType VARCHAR(150);
        DECLARE @Value VARCHAR(150);
        DECLARE @PIFilterNo NVARCHAR(MAX); 
        DECLARE @Comparevalue DECIMAL(18, 2); 

        SET @Comparevalue = 0.00;

        INSERT  INTO @PIFilterTable
                SELECT  Data
                FROM    dbo.Split(@PIFilter, '$');

        SELECT  @CompareType = Comparetype
        FROM    @PIFilterTable
        WHERE   Id = 1;
        SELECT  @Value = Comparetype
        FROM    @PIFilterTable
        WHERE   Id = 2;

        DECLARE @IsPIOut BIT;
        DECLARE @PIQuestionnaireid BIGINT;
            
        SELECT  @IsPIOut = CASE EstablishmentGroupType
                             WHEN 'Sales' THEN 1
                             ELSE 0
                           END ,
                @PIQuestionnaireid = CASE EstablishmentGroupType
                                       WHEN 'Sales' THEN SeenClientId
                                       ELSE QuestionnaireId
                                     END
        FROM    dbo.EstablishmentGroup;
            
        IF ( @CompareType = 'Average' )
            BEGIN
                SET @Comparevalue = ( SELECT    dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @ToDate,
                                                              @PIQuestionnaireid,
                                                              @IsPIOut,
                                                              @UserId,
                                                              @EstablishmentId,
                                                              0)
                                    );
            END;
        ELSE
            IF ( @CompareType = 'Benchmark' )
                BEGIN
                    IF ( @IsPIOut = 0 )
                        BEGIN
                            SELECT  @Comparevalue = FixedBenchMark
                            FROM    dbo.Questionnaire
                            WHERE   Id = @PIQuestionnaireid;
                        END;
                        
                    IF ( @IsPIOut = 1 )
                        BEGIN
                            SELECT  @Comparevalue = FixedBenchMark
                            FROM    dbo.SeenClient
                            WHERE   Id = @PIQuestionnaireid;
                        END;
                END;
			

        IF ( @CompareType = 'Range' )
            BEGIN
                SET @PIFilterNo = ' And Round(PI,0) ' + @Value + '';
            END;
        ELSE
            BEGIN
                SET @PIFilterNo = ' And Round(PI,0) ' + @Value + ' '
                    + CONVERT(VARCHAR(150), @Comparevalue) + '';
            END;
		/*------------------------------------------------------------------*/

        DECLARE @Start AS INT; 
        DECLARE @End INT;
        
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

        
        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            );
        
        INSERT  INTO @Establishment
                ( EstablishemtnId
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> '';

        DECLARE @AppUser TABLE ( AppUserId BIGINT );
        
        INSERT  INTO @AppUser
                ( AppUserId
                )
                SELECT  Data
                FROM    dbo.Split(@UserId, ',')
                WHERE   Data <> '';

        DECLARE @Result TABLE
            (
              ReportId NVARCHAR(15) NOT NULL ,
              EstablishmentId BIGINT NOT NULL ,
              EstablishmentName NVARCHAR(500) NOT NULL ,
              AppUserId BIGINT NOT NULL ,
              UserName NVARCHAR(100) ,
              SenderCellNo NVARCHAR(50) ,
              IsOutStanding BIT NOT NULL ,
              AnswerStatus NVARCHAR(50) NOT NULL ,
              TimeOffSet INT ,
              CreatedOn DATETIME ,
              UpdatedOn NVARCHAR(50) ,
              [PI] DECIMAL(18, 0) NOT NULL ,
              SmileType NVARCHAR(20) NOT NULL ,
              QuestionnaireType NVARCHAR(10) NOT NULL ,
              FormType NVARCHAR(10) NOT NULL ,
              IsOut BIT ,
              QuestionnaireId BIGINT NOT NULL ,
              ReadBy BIGINT NOT NULL ,
              ContactMasterId BIGINT NULL ,
              Latitude NVARCHAR(50) ,
              Longitude NVARCHAR(50) ,
              IsTransferred BIT NOT NULL ,
              TransferToUser NVARCHAR(100) NOT NULL ,
              TransferFromUser NVARCHAR(100) NOT NULL ,
              SeenClientAnswerMasterId BIGINT NOT NULL ,
              ActivityId BIGINT NOT NULL ,
              IsActioned BIT NOT NULL ,
              TransferByUserId BIGINT NOT NULL ,
              TransferFromUserId BIGINT NOT NULL ,
              DisplayText NVARCHAR(MAX) ,
              ContactDetails NVARCHAR(MAX) ,
              CaptureDate NVARCHAR(50) ,
              IsDisable BIT NULL ,
              ContactGropName NVARCHAR(100) NULL ,
              IsResend BIT ,
              UnreadAction INT ,
              IsRecursion BIT ,
              PositiveCount INT ,
              NegativeCount INT ,
              PassiveCount INT ,
              UnresolvedCount INT ,
              ResolvedCount INT ,
              ActionedCount INT ,
              UnActionedCount INT ,
              TransferredCount INT ,
              OutstandingCount INT ,
              AlertUnreadCountCount INT ,
              Id BIGINT ,
              MobiLink VARCHAR(50) ,
              GroupType VARCHAR(10) ,
              TotalRecord INT ,
              RowNum BIGINT ,
              TotalPage INT NOT NULL ,
              ActionDate DATETIME ,
              ActionDateEveryone DATETIME ,
              ActionTo BIGINT ,
              FeedbackSubmitted INT
            );

			/* Table Defilne for Result Count  */

        DECLARE @ResultCount TABLE
            (
              PositiveCount INT ,
              NegativeCount INT ,
              PassiveCount INT ,
              UnresolvedCount INT ,
              ResolvedCount INT ,
              ActionedCount INT ,
              UnActionedCount INT ,
              TransferredCount INT ,
              OutstandingCount INT ,
              AlertUnreadCountCount INT
            );

        DECLARE @SqlSelect1 NVARCHAR(MAX) ,
            @SqlSelect11 NVARCHAR(MAX) ,
            @SqlSelect12 NVARCHAR(MAX) = ' ' ,
            @SqlSelect2 NVARCHAR(MAX) = ' ' ,
            @Filter NVARCHAR(MAX)= ' ' ,
            @SqlselectCount VARCHAR(MAX) = '';
	
        DECLARE @AdvanceQuestionId TABLE
            (
              Id INT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              QuestionTypeId BIGINT
            );
        
        DECLARE @AdvanceQuestionOperator TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Operator NVARCHAR(10)
            );
        
        DECLARE @AdvanceQuestionSearch TABLE
            (
              Id INT IDENTITY(1, 1) ,
              Search NVARCHAR(MAX)
            );

        DECLARE @S INT; 
        DECLARE @E INT; 
        DECLARE @QuestionId NVARCHAR(10); 
        DECLARE @Operator NVARCHAR(10); 
        DECLARE @SearchText NVARCHAR(MAX); 
        DECLARE @QuestionTypeId BIGINT;

        SET @S = 1;

        IF ( @QuestionSearch <> ''
             AND @QuestionSearch IS NOT NULL
           )
            BEGIN
                INSERT  INTO @AdvanceQuestionId
                        ( QuestionId
                        )
                        SELECT  Data
                        FROM    dbo.Split(@QuestionSearch, '$')
                        WHERE   Id % 3 = 1;

                INSERT  INTO @AdvanceQuestionOperator
                        ( Operator
                        )
                        SELECT  Data
                        FROM    dbo.Split(@QuestionSearch, '$')
                        WHERE   Id % 3 = 2;

                INSERT  INTO @AdvanceQuestionSearch
                        ( Search
                        )
                        SELECT  Data
                        FROM    dbo.Split(@QuestionSearch, '$')
                        WHERE   Id % 3 = 0;

                IF @FilterOn = 'In'
                    BEGIN
                        UPDATE  AQ
                        SET     AQ.QuestionTypeId = Q.QuestionTypeId
                        FROM    @AdvanceQuestionId AS AQ
                                INNER JOIN dbo.Questions AS Q ON Q.Id = AQ.QuestionId;
                    END;
                ELSE
                    IF @FilterOn = 'Out'
                        BEGIN
						
                            UPDATE  AQ
                            SET     AQ.QuestionTypeId = Q.QuestionTypeId
                            FROM    @AdvanceQuestionId AS AQ
                                    INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = AQ.QuestionId;
                        END;
            END;
        DECLARE @PIDispaly VARCHAR(5) = '0';
        DECLARE @PIDisplayIn VARCHAR(5) = '0';
        IF ( @IsOut = 1 )
            BEGIN
                IF ( ( SELECT   COUNT(1)
                       FROM     dbo.SeenClientQuestions
                       WHERE    QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                AND SeenClientId = ( SELECT SeenClientId
                                                     FROM   dbo.EstablishmentGroup
                                                     WHERE  Id = @ActivityId
                                                   )
                                AND [Required] = 1
                                AND IsDeleted = 0
                     ) > 0 )
                    BEGIN
                        SET @PIDispaly = '1';
                    END;
            END;
        ELSE
            BEGIN
                IF ( ( SELECT   COUNT(1)
                       FROM     dbo.Questions
                       WHERE    QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                AND QuestionnaireId = ( SELECT
                                                              QuestionnaireId
                                                        FROM  dbo.EstablishmentGroup
                                                        WHERE Id = @ActivityId
                                                      )
                                AND [Required] = 1
                                AND IsDeleted = 0
                     ) > 0 )
                    BEGIN
                        SET @PIDisplayIn = '1';
                    END;
            END;
        
        

        SELECT  @E = COUNT(1)
        FROM    @AdvanceQuestionId;
        SET @SqlselectCount = N'SELECT DISTINCT Sum(CASE WHEN SmileType = ''Positive'' THEN 1 ELSE 0 END) OVER() AS PositiveCount ,Sum(CASE WHEN SmileType = ''Negative'' THEN 1 ELSE 0 END)  OVER() AS NegativeCount ,Sum(CASE WHEN SmileType = ''Neutral'' THEN 1 ELSE 0 END)  OVER() AS PassiveCount ,
				IIF(''' + ISNULL(@ActivityType, '')
            + ''' != ''Customer'', SUM(CASE WHEN (AnswerStatus = ''Unresolved'' AND R.IsOut = 1) THEN 1 ELSE 0 END)  OVER(),SUM(CASE WHEN AnswerStatus = ''Unresolved'' THEN 1 ELSE 0 END)  OVER()) AS UnresolvedCount,
				 Sum(CASE WHEN AnswerStatus = ''Resolved'' THEN 1 ELSE 0 END)  OVER() AS ResolvedCount,
				 Sum(CASE WHEN IsActioned = 1 THEN 1 ELSE 0 END)  OVER() AS ActionedCount ,Sum(CASE WHEN IsActioned = 0 THEN  1 ELSE 0 END)  OVER() AS UnActionedCount ,
				Sum(CASE WHEN IsTransferred = 1 THEN 1 ELSE 0 END)  OVER() AS TransferredCount ,Sum(CASE WHEN IsOutStanding = 1 THEN 1 ELSE 0 END)  OVER() AS OutstandingCount ,
				SUM(CASE WHEN UnreadAction = 1 THEN 1 ELSE 0 END) OVER ( ) AS UnreadAction
				FROM ( SELECT A.SmileType ,A.AnswerStatus,A.IsActioned,A.IsTransferred,A.IsOutStanding,A.IsOut,
				(SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
            + CONVERT(VARCHAR(10), @AppuserId)
            + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId '
            + IIF(@isFromActivity = 'true', 'OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId', '')
            + ')  AND ModuleId  IN (7,8,11, 12)) AS UnreadAction
									FROM      dbo.View_AllAnswerMaster AS A 
									INNER JOIN (SELECT * FROM dbo.Split('''
            + @EstablishmentId
            + ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''
            + @EstablishmentId + ''' = ''0''
                                    INNER JOIN (SELECT * FROM dbo.Split('''
            + @UserId
            + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''
            + @UserId + ''' = ''0'' OR A.UserId = 0
									'
            + IIF(@isFromActivity = 'true', ( CHAR(13)
                                              + 'LEFT OUTER JOIN dbo.View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)' ), '')
            + '';

			/* PI old logic
			case R.Isout When 1 then IIF(''' + @PIDispaly
                    + ''' = ''1'', [PI],IIF([PI] > 0.00,[PI],-1)) else IIF('''
                    + @PIDisplayIn
                    + ''' = ''1'', [PI],IIF([PI] > 0.00,[PI],-1)) end as [PI],
			*/

        IF @Status = ''
            BEGIN
                SET @SqlSelect1 = N'
		SELECT ReportId as ReportId,
        EstablishmentId ,EstablishmentName ,UserId ,UserName ,SenderCellNo ,IsOutStanding ,AnswerStatus ,
        TimeOffSet ,CreatedOn , dbo.ChangeDateFormat(UpdatedOn,''dd/MMM/yyyy hh:mm AM/PM'') AS UpdatedOn, 
		[PI],
		SmileType ,QuestionnaireType ,FormType ,IsOut ,QuestionnaireId ,ReadBy ,CASE ContactMasterId WHEN 0 THEN ContactGroupId ELSE R.ContactMasterId end AS ContactMasterId,
		Latitude ,Longitude ,IsTransferred ,TransferToUser ,TransferFromUser ,SeenClientAnswerMasterId ,ActivityId ,IsActioned ,
		TransferByUserId ,TransferFromUserId ,dbo.AnswerDetails(CASE IsOut WHEN 0 THEN ''Answers'' ELSE ''SeenClientAnswers'' END, ReportId) AS DisplayText , dbo.ConcateString(''ContactSummary'', ContactMasterId) AS ContactDetails ,
                        dbo.ChangeDateFormat(CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'') AS CaptureDate ,
                        isnull(isdisabled,''false'') as Isdisabled, ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster 
						WHERE id = ReportId AND R.IsOut=1)),'''') as ContactGropName, (SELECT CASE R.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = R.ReportId),1) ELSE 0 end) AS Resend,
						UnreadAction, R.IsRecursion,Sum(CASE WHEN SmileType = ''Positive'' THEN 1 ELSE 0 END) OVER() AS PositiveCount ,Sum(CASE WHEN SmileType = ''Negative'' THEN 1 ELSE 0 END)  OVER() AS NegativeCount ,Sum(CASE WHEN SmileType = ''Neutral'' THEN 1 ELSE 0 END)  OVER() AS PassiveCount ,
				IIF(''' + ISNULL(@ActivityType, '')
                    + ''' != ''Customer'', SUM(CASE WHEN (AnswerStatus = ''Unresolved'' AND R.IsOut = 1) THEN 1 ELSE 0 END)  OVER(),SUM(CASE WHEN AnswerStatus = ''Unresolved'' THEN 1 ELSE 0 END)  OVER()) AS UnresolvedCount,
				Sum(CASE WHEN AnswerStatus = ''Resolved'' THEN 1 ELSE 0 END)  OVER() AS ResolvedCount,Sum(CASE WHEN IsActioned = 1 THEN 1 ELSE 0 END)  OVER() AS ActionedCount ,Sum(CASE WHEN IsActioned = 0 THEN  1 ELSE 0 END)  OVER() AS UnActionedCount ,
				Sum(CASE WHEN IsTransferred = 1 THEN 1 ELSE 0 END)  OVER() AS TransferredCount ,Sum(CASE WHEN IsOutStanding = 1 THEN 1 ELSE 0 END)  OVER() AS OutstandingCount ,UnreadAction AS AlertUnreadCountCount ,
				case isnull(SeenClientAnswerMasterId,0) when 0 then ReportId else SeenClientAnswerMasterId end as Id, R.MobiLink, R.GroupType, R.TotalRecord, R.RowNum, R.TotalPage,
				R.ActionDate,
				R.ActionDateEveryone,
				R.ActionTo,				R.FeedbackSubmitted';
                SET @SqlSelect11 = CHAR(13)
                    + N'FROM    ( SELECT    A.* ,
									(SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId '
                    + IIF(@isFromActivity = 'true', 'OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId', '')
                    + ')  AND ModuleId  IN (7,8,11, 12)) AS UnreadAction,
                                   ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) AS IsRecursion,
									dbo.GetMObilink(A.ReportId,'''
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ''', CASE  WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 end) AS MobiLink,
									'''
                    + CONVERT(VARCHAR(10), ISNULL(@GroupType, ''))
                    + ''' AS GroupType ,
									IIF(''' + ISNULL(@ActivityType, '')
                    + ''' = ''Customer'', SUM(CASE WHEN (A.IsOut = 0) THEN 1 ELSE 0 END)  OVER(), SUM(CASE WHEN (A.IsOut = 1) THEN 1 ELSE 0 END)  OVER()) AS TotalRecord,
									ROW_NUMBER() OVER ( ORDER BY '
                    + IIF(@OrderBy = ' Order By R.ActionDate Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' ORDER BY CreatedOn DESC)))', IIF(@OrderBy = ' Order By R.ActionDateEveryone Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  IsDeleted = 0 AND  ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)))', 'A.CreatedOn'))
                    + ' DESC ) AS RowNum,
									CASE COUNT(1) OVER ( PARTITION BY 1 ) / '
                    + CONVERT(NVARCHAR(10), @Rows)
                    + ' WHEN 0 THEN 1 ELSE ( COUNT(1) OVER ( PARTITION BY 1 ) / '
                    + CONVERT(NVARCHAR(10), @Rows)
                    + ' ) + 1 END AS TotalPage,
									DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' ORDER BY CreatedOn DESC)) AS ActionDate,
									DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)) AS ActionDateEveryone,
									' + CONVERT(VARCHAR(10), @AppuserId)
                    + ' AS ActionTo ,
									CASE WHEN A.ContactGroupId != 0 THEN IIF((SELECT IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenclientChildId = (SELECT Id FROM dbo.SeenClientAnswerChild WHERE ContactMasterId = A.ContactMasterId AND
									SeenClientAnswerMasterId = A.ReportId) AND SeenClientAnswerMasterId = A.ReportId) = 1,1,0) ELSE IIF((SELECT TOP 1 IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenClientAnswerMasterId = A.ReportId ORDER BY id DESC) = 1,1,0) end as FeedbackSubmitted '
                    + CHAR(13) + '
									FROM      dbo.View_AllAnswerMaster AS A ';
                SET @SqlSelect12 += CHAR(13)
                    + 'INNER JOIN (SELECT * FROM dbo.Split('''
                    + @EstablishmentId
                    + ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''
                    + @EstablishmentId + ''' = ''0''
                                    INNER JOIN (SELECT * FROM dbo.Split('''
                    + @UserId
                    + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''
                    + @UserId + ''' = ''0'' OR A.UserId = 0 ';
            END;
        ELSE
            BEGIN
                SET @SqlSelect1 = N'
		SELECT ReportId as ReportId,
        EstablishmentId ,EstablishmentName ,UserId ,UserName ,SenderCellNo ,IsOutStanding ,AnswerStatus ,
        TimeOffSet ,CreatedOn , dbo.ChangeDateFormat(UpdatedOn,''dd/MMM/yyyy hh:mm AM/PM'') AS UpdatedOn, 
		[PI] as [PI],
		SmileType ,QuestionnaireType ,FormType ,IsOut ,QuestionnaireId ,ReadBy ,CASE ContactMasterId WHEN 0 THEN ContactGroupId ELSE R.ContactMasterId end AS ContactMasterId,
		Latitude ,Longitude ,IsTransferred ,TransferToUser ,TransferFromUser ,SeenClientAnswerMasterId ,ActivityId ,IsActioned ,
		TransferByUserId ,TransferFromUserId ,dbo.AnswerDetails(CASE IsOut WHEN 0 THEN ''Answers'' ELSE ''SeenClientAnswers'' END, ReportId) AS DisplayText , dbo.ConcateString(''ContactSummary'', ContactMasterId) AS ContactDetails ,
                        dbo.ChangeDateFormat(CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'') AS CaptureDate ,
                        isnull(isdisabled,''false'') as Isdisabled, ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster 
						WHERE id = ReportId AND R.IsOut=1)),'''') as ContactGropName, (SELECT CASE R.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = R.ReportId),1) ELSE 0 end) AS Resend,
						UnreadAction, R.IsRecursion,Sum(CASE WHEN SmileType = ''Positive'' THEN 1 ELSE 0 END) OVER() AS PositiveCount ,Sum(CASE WHEN SmileType = ''Negative'' THEN 1 ELSE 0 END)  OVER() AS NegativeCount ,Sum(CASE WHEN SmileType = ''Neutral'' THEN 1 ELSE 0 END)  OVER() AS PassiveCount ,
				Sum(CASE WHEN AnswerStatus = ''Unresolved'' THEN 1 ELSE 0 END)  OVER() AS UnresolvedCount ,Sum(CASE WHEN AnswerStatus = ''Resolved'' THEN 1 ELSE 0 END)  OVER() AS ResolvedCount,Sum(CASE WHEN IsActioned = 1 THEN 1 ELSE 0 END)  OVER() AS ActionedCount ,Sum(CASE WHEN IsActioned = 0 THEN  1 ELSE 0 END)  OVER() AS UnActionedCount ,
				Sum(CASE WHEN IsTransferred = 1 THEN 1 ELSE 0 END)  OVER() AS TransferredCount ,Sum(CASE WHEN IsOutStanding = 1 THEN 1 ELSE 0 END)  OVER() AS OutstandingCount ,UnreadAction AS AlertUnreadCountCount ,
				case isnull(SeenClientAnswerMasterId,0) when 0 then ReportId else SeenClientAnswerMasterId end as Id, R.MobiLink, R.GroupType, R.TotalRecord, R.RowNum, R.TotalPage,
				R.ActionDate,
				R.ActionDateEveryone,
				R.ActionTo,				R.FeedbackSubmitted';

                SET @SqlSelect11 = CHAR(13)
                    + N'FROM    ( SELECT    A.* , (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId '
                    + IIF(@isFromActivity = 'true', 'OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId', '')
                    + ')  AND ModuleId  IN (7,8,11, 12)) AS UnreadAction,
									( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) AS IsRecursion,
									dbo.GetMObilink(A.ReportId,'''
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ''', CASE  WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 end) AS MobiLink,
									'''
                    + CONVERT(VARCHAR(10), ISNULL(@GroupType, ''))
                    + ''' AS GroupType ,
									IIF(''' + ISNULL(@ActivityType, '')
                    + ''' = ''Customer'', SUM(CASE WHEN (A.IsOut = 0) THEN 1 ELSE 0 END)  OVER(), SUM(CASE WHEN (A.IsOut = 1) THEN 1 ELSE 0 END)  OVER())  AS TotalRecord,
									ROW_NUMBER() OVER ( ORDER BY '
                    + IIF(@OrderBy = ' Order By R.ActionDate Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' ORDER BY CreatedOn DESC)))', IIF(@OrderBy = ' Order By R.ActionDateEveryone Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)))', 'A.CreatedOn'))
                    + ' DESC ) AS RowNum,
									CASE COUNT(1) OVER ( PARTITION BY 1 ) / '
                    + CONVERT(NVARCHAR(10), @Rows)
                    + ' WHEN 0 THEN 1 ELSE ( COUNT(1) OVER ( PARTITION BY 1 ) / '
                    + CONVERT(NVARCHAR(10), @Rows)
                    + ' ) + 1 END AS TotalPage
									,DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotification WHERE  IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' ORDER BY CreatedOn DESC)) AS ActionDate,
									DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)) AS ActionDateEveryone,
									' + CONVERT(VARCHAR(10), @AppuserId)
                    + ' AS ActionTo,
									CASE WHEN A.ContactGroupId != 0 THEN IIF((SELECT IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenclientChildId = (SELECT Id FROM dbo.SeenClientAnswerChild WHERE ContactMasterId = A.ContactMasterId AND
									SeenClientAnswerMasterId = A.ReportId) AND SeenClientAnswerMasterId = A.ReportId) = 1,1,0) ELSE IIF((SELECT TOP 1 IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenClientAnswerMasterId = A.ReportId ORDER BY id DESC) = 1,1,0) end as FeedbackSubmitted 
                          FROM  dbo.View_AllAnswerMaster AS A	 ';

                SET @SqlSelect12 += CHAR(13)
                    + 'INNER JOIN (SELECT * FROM dbo.Split('''
                    + @EstablishmentId
                    + ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''
                    + @EstablishmentId + ''' = ''0''
							INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId
                    + ''', '','')) AS U ON (U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''
                    + @UserId + ''' = ''0'' OR A.UserId = 0) ';
							
            END;
			
        IF ( @QuestionSearch <> ''
             AND @QuestionSearch IS NOT NULL
           )
            BEGIN
                WHILE @S <= @E
                    BEGIN
                        SELECT  @QuestionId = QuestionId
                        FROM    @AdvanceQuestionId
                        WHERE   Id = @S;
                        
                        IF @IsOut = 0
                            BEGIN
                                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans'
                                    + @QuestionId + ' ON Ans' + @QuestionId
                                    + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans'
                                    + @QuestionId + '.QuestionId = '
                                    + @QuestionId;
                                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(Ans'
                                    + @QuestionId
                                    + '.Detail, ''''), '','') AS OAns'
                                    + @QuestionId;
                            END;
                        ELSE
                            BEGIN
                                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns'
                                    + @QuestionId + ' ON SeenAns'
                                    + @QuestionId
                                    + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns'
                                    + @QuestionId + '.QuestionId = '
                                    + @QuestionId;
                                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(SeenAns'
                                    + @QuestionId
                                    + '.Detail, ''''), '','') AS OSeenAns'
                                    + @QuestionId;
                            END;
                        SET @S += 1;
                    END;
            END;
			
        SET @SqlSelect2 += CHAR(13)
            + ' LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
            + CHAR(13)
            + ' 	LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';

        SET @Filter += CHAR(13)
            + ' WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST('''
            + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy')+ ''' AS DATE) 
			And Cast(dbo.ChangeDateFormat((DateAdd(Minute,A.TimeOffset,''' + CONVERT(VARCHAR(25), @ToDate)+''')),''dd MMM yyyy'') as Date)
            AND A.ActivityId = '
            + CONVERT(NVARCHAR(10), @ActivityId); 
        
        IF ( @ReportId > 0 )
            BEGIN
                SET @Filter += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = '
                    + CONVERT(NVARCHAR(10), @ReportId);
            END;

        IF ( @FormStatus = 'Resolved' )
            BEGIN
                SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''';
            END;
        ELSE
            IF ( @FormStatus = 'Unresolved' )
                BEGIN
                    SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus
                        + '''';
                END;

        IF ( @Search != '' )
            BEGIN
                IF ( ISNUMERIC(@Search) = 1 )
                    BEGIN
                        DECLARE @OutId BIGINT = 0;
                        SELECT  @OutId = SeenClientAnswerMasterId
                        FROM    dbo.AnswerMaster
                        WHERE   Id = CAST(@Search AS BIGINT);
                        IF @OutId = 0
                            BEGIN
                                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                                    + @Search + '%'' 
									OR A.SeenClientAnswerMasterId LIKE ''%'
                                    + @Search + '%''
									OR A.EstablishmentName LIKE ''%' + @Search
                                    + '%''
                                   --OR A.EI LIKE ''%' + @Search + '%''
                                   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                    + '%''
                                   --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                                    + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                                    + @Search + '%''
								   )';
                            END;
                        ELSE
                            BEGIN
                                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                                    + @Search + '%'' 
									OR A.ReportId = '
                                    + CAST(@OutId AS VARCHAR(50)) + '
									OR A.EstablishmentName LIKE ''%' + @Search
                                    + '%''
                                   --OR A.EI LIKE ''%' + @Search + '%''
								   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                    + '%''
                                   --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'+ @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                                    + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                                    + @Search + '%''
								   )';
                            END;
					
                    END;
                ELSE
                    BEGIN
                        SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                            + @Search + '%'' 
								   OR A.EstablishmentName LIKE ''%' + @Search
                            + '%''
                                   --OR A.EI LIKE ''%' + @Search + '%''
                                   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                            + '%''
                                   --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'+ @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                            + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                            + @Search + '%''
								   )';
                    END;
            END;
         
        IF ( @ReadUnread = 'Unread' )
            BEGIN
                SET @Filter += ' And A.Isoutstanding = 1';
            END;
        ELSE
            IF ( @ReadUnread = 'Read' )
                BEGIN
                    SET @Filter += ' And A.Isoutstanding = 0';
                END;
        
        IF ( @isResend = 'true' )
            BEGIN
                SET @Filter += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1';
            END;

        IF ( @isRecursion = 'true' )
            BEGIN
                SET @Filter += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
            END;
        IF ( @isAction = 'true' )
            BEGIN
                SET @Filter += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WHERE Conversation LIKE ''%'
                    + @ActionSearch + '%'')';
            END;
        ELSE
            IF ( @isAction = 'false' )
                BEGIN
                    SET @Filter += ' AND A.IsActioned = 0';
                END;
        IF ( @isTransfer = 'true' )
            BEGIN
                SET @Filter += ' AND A.IsTransferred = 1';
            END;
		
        IF ( @FilterOn = 'in' )
            BEGIN
                SET @Filter += ' AND A.isOut = 0';
            END;
        ELSE
            IF ( @FilterOn = 'out' )
                BEGIN
                    SET @Filter += ' AND A.isOut = 1';
                END;
        
        IF ( @TemplateId != '' )
            BEGIN
                SET @Filter += @ActionFilter;
            END;
        IF ( @IsEdited = 'true' )
            BEGIN
                SET @Filter += ' And A.UpdatedOn IS NOT NULL';
            END;

        IF ( @PIFilterNo != '' )
            BEGIN
                SET @Filter += @PIFilterNo;
            END;
        IF ( @isFromActivity = 'true' )
            BEGIN
                SET @SqlSelect12 += CHAR(13)
                    + 'LEFT OUTER JOIN dbo.View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)';
                SET @Filter += CHAR(13)
                    + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId)  AND ModuleId  IN (7, 8, 11, 12))> 0';
            END;
        
        IF ( @QuestionSearch <> ''
             AND @QuestionSearch IS NOT NULL
           )
            BEGIN
                SET @S = 1;
                WHILE @S <= @E
                    BEGIN
                        SELECT  @QuestionId = QuestionId ,
                                @QuestionTypeId = QuestionTypeId
                        FROM    @AdvanceQuestionId
                        WHERE   Id = @S;

                        SELECT  @Operator = Operator
                        FROM    @AdvanceQuestionOperator
                        WHERE   Id = @S;

                        SELECT  @SearchText = Search
                        FROM    @AdvanceQuestionSearch
                        WHERE   Id = @S;

                        IF @QuestionTypeId IN ( 1, 2, 19 )
                            BEGIN
                                SET @Filter += ' AND ('
                                    + ( CASE @IsOut
                                          WHEN 0 THEN 'Ans'
                                          ELSE 'SeenAns'
                                        END ) + @QuestionId + '.Detail '
                                    + @Operator + ' ' + @SearchText + ' )';
                            END;
                        ELSE
                            IF @QuestionTypeId IN ( 5, 6, 18, 21 )
                                BEGIN
                                    SET @Filter += 'AND ('
                                        + ( CASE @IsOut
                                              WHEN 0 THEN 'OAns'
                                              ELSE ' OSeenAns'
                                            END ) + @QuestionId
                                        + '.Data IN ( SELECT Data FROM dbo.Split('''
                                        + @SearchText + ''', '','')) )';
                                END;
                            ELSE
                                BEGIN
                                    SET @Filter += ' AND ('',''+'
                                        + ( CASE @IsOut
                                              WHEN 0 THEN 'ISNULL(Ans'
                                              ELSE 'ISNULL(SeenAns'
                                            END ) + @QuestionId
                                        + '.Detail,'' '')+'','' LIKE ''%'
                                        + CASE @QuestionTypeId
                                            WHEN 22
                                            THEN dbo.ChangeDateFormat(@SearchText,
                                                              'yyyy-MM-dd HH:MM')
                                            ELSE ( CASE @SearchText
                                                     WHEN '' THEN ' '
                                                     ELSE @SearchText
                                                   END )
                                          END + '%'' )';
                                END;

                        SET @S += 1;
                    END;
            END;
        DECLARE @FilterCount VARCHAR(2000);
       

IF ( @ResponseType != 'All' )
    BEGIN
        DECLARE @Temp TABLE
            (
              [SeenClientAnswerMasterId] [BIGINT] NOT NULL
            );

        INSERT  INTO @Temp
                ( SeenClientAnswerMasterId
                )
                EXEC
                    ( 'select A.SeenClientAnswerMasterId FROM  dbo.View_AllAnswerMaster AS A '
                      + @SqlSelect12 + @SqlSelect2 + @Filter
                      + ' Group By A.SeenClientAnswerMasterId'
                    );
				
        DECLARE @var VARCHAR(MAX);
        SET @var = ( SELECT DISTINCT
                            STUFF(( SELECT DISTINCT
                                            ','
                                            + CONVERT(VARCHAR(MAX), p1.[SeenClientAnswerMasterId])
                                    FROM    @Temp p1
                                  FOR
                                    XML PATH('')
                                  ), 1, 1, '') SeenClientAnswerMasterId
                     FROM   @Temp p
                   );
    END;
                   
        IF ( @ResponseType = 'Responded' )
            BEGIN
                SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) in ('
                    + @var + ') ';
            END;
        ELSE
            IF ( @ResponseType = 'NotResponded' )
                BEGIN
                    SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) not in ('
                        + @var + ') ';
                END;
        IF ( @IsResponse = 'true' )
            BEGIN
                SET @Filter += ' AND (CASE WHEN A.ContactGroupId != 0 THEN IIF((SELECT IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenclientChildId = (SELECT Id FROM dbo.SeenClientAnswerChild WHERE ContactMasterId = A.ContactMasterId AND
									SeenClientAnswerMasterId = A.ReportId) AND SeenClientAnswerMasterId = A.ReportId) = 1,1,0) ELSE IIF((SELECT TOP 1 IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenClientAnswerMasterId = A.ReportId ORDER BY id DESC) = 1,1,0) end) = 0 AND dbo.GetMObilink(A.ReportId, '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != ''''';
            END;

					 SELECT  @FilterCount = @Filter + CHAR(13) + '  GROUP BY '
                + IIF(@isFromActivity = 'true', 'RA.ReportId,RA.SeenClientAnswerMasterId, ', '')
                + '  A.ReportId ,A.SeenClientAnswerMasterId, A.SmileType ,
					A.AnswerStatus,
					A.IsActioned,
					A.IsTransferred,
					A.IsOutStanding,
					A.IsOut) AS R';

        IF ( @Status = '' )
            BEGIN
                SET @Filter += CHAR(13) + ' GROUP BY '
                    + IIF(@isFromActivity = 'true', 'RA.ReportId,RA.SeenClientAnswerMasterId, ', '')
                    + ' A.ReportId , A.EstablishmentId ,A.EstablishmentName ,A.UserId ,A.UserName ,A.SenderCellNo ,A.IsOutStanding ,A.AnswerStatus ,A.TimeOffSet ,A.CreatedOn ,A.UpdatedOn,A.EI ,A.[PI], A.SmileType ,A.QuestionnaireType ,A.FormType ,A.IsOut ,A.QuestionnaireId ,A.ReadBy ,A.ContactMasterId ,A.ContactGroupId,A.Latitude ,A.Longitude ,A.IsTransferred ,A.TransferToUser ,A.TransferFromUser ,A.SeenClientAnswerMasterId ,A.ActivityId ,A.IsActioned ,A.TransferByUserId ,A.TransferFromUserId, A.isdisabled, A.CreatedUserId
                        ) AS R Where R.RowNum BETWEEN '
                    + CONVERT(NVARCHAR(10), @Start) + ' AND '
                    + CONVERT(NVARCHAR(10), @End) + @OrderBy;
            END;
        ELSE
            BEGIN
                SET @Filter += ' And (A.SmileType = ''' + @Status
                    + ''' OR A.AnswerStatus = ''' + @Status + ''') GROUP BY '
                    + IIF(@isFromActivity = 'true', 'RA.ReportId,RA.SeenClientAnswerMasterId, ', '')
                    + ' A.ReportId , A.EstablishmentId ,A.EstablishmentName ,A.UserId ,A.UserName ,A.SenderCellNo ,A.IsOutStanding ,A.AnswerStatus ,A.TimeOffSet ,A.CreatedOn ,A.UpdatedOn,A.EI ,A.[PI], A.SmileType ,A.QuestionnaireType ,A.FormType ,A.IsOut ,A.QuestionnaireId ,A.ReadBy ,A.ContactMasterId ,A.ContactGroupId,A.Latitude ,A.Longitude ,A.IsTransferred ,A.TransferToUser ,A.TransferFromUser ,A.SeenClientAnswerMasterId ,A.ActivityId ,A.IsActioned ,A.TransferByUserId ,A.TransferFromUserId, A.isdisabled, A.CreatedUserId
                        ) AS R Where R.RowNum BETWEEN '
                    + CONVERT(NVARCHAR(10), @Start) + ' AND '
                    + CONVERT(NVARCHAR(10), @End) + @OrderBy;
            END;


        INSERT  INTO @ResultCount
                EXEC ( @SqlselectCount + @SqlSelect2 + @FilterCount
                    );
		--SELECT  @SqlselectCount + @SqlSelect2 + @FilterCount
		--SELECT ( @SqlSelect1 + @SqlSelect11 + @SqlSelect12 + @SqlSelect2 + @Filter);
        INSERT  INTO @Result
                EXEC
                    ( @SqlSelect1 + @SqlSelect11 + @SqlSelect12 + @SqlSelect2
                      + @Filter
                    );

        UPDATE  @Result
        SET     PositiveCount = ( SELECT    PositiveCount
                                  FROM      @ResultCount
                                );
        UPDATE  @Result
        SET     NegativeCount = ( SELECT    NegativeCount
                                  FROM      @ResultCount
                                );
        UPDATE  @Result
        SET     PassiveCount = ( SELECT PassiveCount
                                 FROM   @ResultCount
                               );
        UPDATE  @Result
        SET     UnresolvedCount = ( SELECT  UnresolvedCount
                                    FROM    @ResultCount
                                  );
        UPDATE  @Result
        SET     ResolvedCount = ( SELECT    ResolvedCount
                                  FROM      @ResultCount
                                );
        UPDATE  @Result
        SET     ActionedCount = ( SELECT    ActionedCount
                                  FROM      @ResultCount
                                );
        UPDATE  @Result
        SET     UnActionedCount = ( SELECT  UnActionedCount
                                    FROM    @ResultCount
                                  );
        UPDATE  @Result
        SET     TransferredCount = ( SELECT TransferredCount
                                     FROM   @ResultCount
                                   );
        UPDATE  @Result
        SET     OutstandingCount = ( SELECT OutstandingCount
                                     FROM   @ResultCount
                                   );
        UPDATE  @Result
        SET     AlertUnreadCountCount = ( SELECT    AlertUnreadCountCount
                                          FROM      @ResultCount
                                        );
		
        DECLARE @PositiveCount INT; 
        DECLARE @PassiveCount INT;
        DECLARE @NegativeCount INT;
        DECLARE @UnresolvedCount INT;
		
        SELECT  @PositiveCount = PositiveCount ,
                @PassiveCount = PassiveCount ,
                @NegativeCount = NegativeCount ,
                @UnresolvedCount = UnresolvedCount
        FROM    @ResultCount;

        IF @Status <> ''
            BEGIN
                IF ( SELECT COUNT(1) AS TotRec
                     FROM   @Result
                     WHERE  ( SmileType = @Status
                              OR AnswerStatus = @Status
                            )
                   ) > 0
                    BEGIN
                        SELECT  ReportId ,
                                EstablishmentId ,
                                EstablishmentName ,
                                AppUserId ,
                                UserName ,
                                SenderCellNo ,
                                IsOutStanding ,
                                AnswerStatus ,
                                TimeOffSet ,
                                CreatedOn ,
                                UpdatedOn ,
                                PI ,
                                SmileType ,
                                QuestionnaireType ,
                                FormType ,
                                IsOut ,
                                QuestionnaireId ,
                                ReadBy ,
                                ContactMasterId ,
                                Latitude ,
                                Longitude ,
                                IsTransferred ,
                                TransferToUser ,
                                TransferFromUser ,
                                SeenClientAnswerMasterId ,
                                ActivityId ,
                                IsActioned ,
                                TransferByUserId ,
                                TransferFromUserId ,
                                DisplayText ,
                                ContactDetails ,
                                CaptureDate ,
                                IsDisable ,
                                ContactGropName ,
                                IsResend ,
                                UnreadAction ,
                                IsRecursion ,
                                PositiveCount ,
                                NegativeCount ,
                                PassiveCount ,
                                UnresolvedCount ,
                                ResolvedCount ,
                                ActionedCount ,
                                UnActionedCount ,
                                TransferredCount ,
                                OutstandingCount ,
                                AlertUnreadCountCount ,
                                MobiLink ,
                                GroupType ,
                                Id ,
                                TotalRecord ,
                                RowNum ,
                                TotalPage ,
                                ActionDate ,
                                ActionDateEveryone ,
                                ActionTo ,
                                FeedbackSubmitted
                        FROM    @Result;
                    END;
                ELSE
                    BEGIN
                        SELECT  CONVERT(NVARCHAR(15), '') AS ReportId ,
                                CONVERT(BIGINT, 0) AS EstablishmentId ,
                                CONVERT(NVARCHAR(500), '') AS EstablishmentName ,
                                CONVERT(BIGINT, 0) AS AppUserId ,
                                CONVERT(NVARCHAR(100), '') AS UserName ,
                                CONVERT(NVARCHAR(50), '') AS SenderCellNo ,
                                CONVERT(BIT, 0) AS IsOutStanding ,
                                CONVERT(NVARCHAR(50), '') AS AnswerStatus ,
                                CONVERT(INT, 0) AS TimeOffSet ,
                                CONVERT(DATETIME, GETDATE()) AS CreatedOn ,
                                CONVERT(NVARCHAR(50), '') AS UpdatedOn ,
                                CONVERT(DECIMAL(18, 0), 0) AS [PI] ,
                                CONVERT(NVARCHAR(20), '') AS SmileType ,
                                CONVERT(NVARCHAR(10), '') AS QuestionnaireType ,
                                CONVERT(NVARCHAR(10), '') AS FormType ,
                                CONVERT(BIT, 0) AS IsOut ,
                                CONVERT(BIGINT, 0) AS QuestionnaireId ,
                                CONVERT(BIGINT, 0) AS ReadBy ,
                                CONVERT(BIGINT, 0) AS ContactMasterId ,
                                CONVERT(NVARCHAR(50), '') AS Latitude ,
                                CONVERT(NVARCHAR(50), '') AS Longitude ,
                                CONVERT(BIT, 0) AS IsTransferred ,
                                CONVERT(NVARCHAR(100), '') AS TransferToUser ,
                                CONVERT(NVARCHAR(100), '') AS TransferFromUser ,
                                CONVERT(BIGINT, 0) AS SeenClientAnswerMasterId ,
                                CONVERT(BIGINT, 0) AS ActivityId ,
                                CONVERT(BIT, 0) AS IsActioned ,
                                CONVERT(BIGINT, 0) AS TransferByUserId ,
                                CONVERT(BIGINT, 0) AS TransferFromUserId ,
                                CONVERT(NVARCHAR(MAX), '') AS DisplayText ,
                                CONVERT(NVARCHAR(MAX), '') AS ContactDetails ,
                                CONVERT(NVARCHAR(50), '') AS CaptureDate ,
                                CONVERT(BIT, 0) AS IsDisable ,
                                CONVERT(NVARCHAR(100), '') AS ContactGropName ,
                                CONVERT(BIT, 0) AS IsResend ,
                                CONVERT(INT, 0) AS UnreadAction ,
                                CONVERT(BIT, 0) AS IsRecursion ,
                                CONVERT(INT, ISNULL(@PositiveCount, 0)) AS PositiveCount ,
                                CONVERT(INT, ISNULL(@NegativeCount, 0)) AS NegativeCount ,
                                CONVERT(INT, ISNULL(@PassiveCount, 0)) AS PassiveCount ,
                                CONVERT(INT, ISNULL(@UnresolvedCount, 0)) AS UnresolvedCount ,
                                CONVERT(INT, 0) AS ResolvedCount ,
                                CONVERT(INT, 0) AS ActionedCount ,
                                CONVERT(INT, 0) AS UnActionedCount ,
                                CONVERT(INT, 0) AS TransferredCount ,
                                CONVERT(INT, 0) AS OutstandingCount ,
                                CONVERT(INT, 0) AS AlertUnreadCountCount ,
                                CONVERT(VARCHAR(50), '') AS MobiLink ,
                                CONVERT(VARCHAR(10), '0') AS GroupType ,
                                CONVERT(BIGINT, 0) AS Id ,
                                CONVERT(INT, 0) AS TotalRecord ,
                                CONVERT(BIGINT, 0) AS RowNum ,
                                CONVERT(INT, 0) AS TotalPage ,
                                CONVERT(DATETIME, GETDATE()) AS ActionDate ,
                                CONVERT(DATETIME, GETDATE()) AS ActionDateEveryone ,
                                CONVERT(BIGINT, 0) ActionTo ,
                                CONVERT(INT, 0) FeedbackSubmitted;
                    END;
            END;
        ELSE
            BEGIN
                IF ( SELECT COUNT(1) AS TotRec
                     FROM   @Result
                   ) > 0
                    BEGIN
                        SELECT  *
                        FROM    ( SELECT    ReportId ,
                                            EstablishmentId ,
                                            EstablishmentName ,
                                            AppUserId ,
                                            UserName ,
                                            SenderCellNo ,
                                            IsOutStanding ,
                                            AnswerStatus ,
                                            TimeOffSet ,
                                            CreatedOn ,
                                            UpdatedOn ,
                                            PI ,
                                            SmileType ,
                                            QuestionnaireType ,
                                            FormType ,
                                            IsOut ,
                                            QuestionnaireId ,
                                            ReadBy ,
                                            ContactMasterId ,
                                            Latitude ,
                                            Longitude ,
                                            IsTransferred ,
                                            TransferToUser ,
                                            TransferFromUser ,
                                            SeenClientAnswerMasterId ,
                                            ActivityId ,
                                            IsActioned ,
                                            TransferByUserId ,
                                            TransferFromUserId ,
                                            DisplayText ,
                                            ContactDetails ,
                                            CaptureDate ,
                                            IsDisable ,
                                            ContactGropName ,
                                            IsResend ,
                                            UnreadAction ,
                                            IsRecursion ,
                                            PositiveCount ,
                                            NegativeCount ,
                                            PassiveCount ,
                                            UnresolvedCount ,
                                            ResolvedCount ,
                                            ActionedCount ,
                                            UnActionedCount ,
                                            TransferredCount ,
                                            OutstandingCount ,
                                            AlertUnreadCountCount ,
                                            MobiLink ,
                                            GroupType ,
                                            Id ,
                                            TotalRecord ,
                                            RowNum ,
                                            TotalPage ,
                                            ActionDate ,
                                            ActionDateEveryone ,
                                            ActionTo ,
                                            FeedbackSubmitted
                                  FROM      @Result
                                ) AS SS;
                    END;
                ELSE
                    BEGIN
                        SELECT  CONVERT(NVARCHAR(15), '') AS ReportId ,
                                CONVERT(BIGINT, 0) AS EstablishmentId ,
                                CONVERT(NVARCHAR(500), '') AS EstablishmentName ,
                                CONVERT(BIGINT, 0) AS AppUserId ,
                                CONVERT(NVARCHAR(100), '') AS UserName ,
                                CONVERT(NVARCHAR(50), '') AS SenderCellNo ,
                                CONVERT(BIT, 0) AS IsOutStanding ,
                                CONVERT(NVARCHAR(50), '') AS AnswerStatus ,
                                CONVERT(INT, 0) AS TimeOffSet ,
                                CONVERT(DATETIME, GETDATE()) AS CreatedOn ,
                                CONVERT(DECIMAL(18, 0), 0) AS [PI] ,
                                CONVERT(NVARCHAR(20), '') AS SmileType ,
                                CONVERT(NVARCHAR(10), '') AS QuestionnaireType ,
                                CONVERT(NVARCHAR(10), '') AS FormType ,
                                CONVERT(BIT, 0) AS IsOut ,
                                CONVERT(BIGINT, 0) AS QuestionnaireId ,
                                CONVERT(BIGINT, 0) AS ReadBy ,
                                CONVERT(BIGINT, 0) AS ContactMasterId ,
                                CONVERT(NVARCHAR(50), '') AS Latitude ,
                                CONVERT(NVARCHAR(50), '') AS Longitude ,
                                CONVERT(BIT, 0) AS IsTransferred ,
                                CONVERT(NVARCHAR(100), '') AS TransferToUser ,
                                CONVERT(NVARCHAR(100), '') AS TransferFromUser ,
                                CONVERT(BIGINT, 0) AS SeenClientAnswerMasterId ,
                                CONVERT(BIGINT, 0) AS ActivityId ,
                                CONVERT(BIT, 0) AS IsActioned ,
                                CONVERT(BIGINT, 0) AS TransferByUserId ,
                                CONVERT(BIGINT, 0) AS TransferFromUserId ,
                                CONVERT(NVARCHAR(MAX), '') AS DisplayText ,
                                CONVERT(NVARCHAR(MAX), '') AS ContactDetails ,
                                CONVERT(NVARCHAR(50), '') AS CaptureDate ,
                                CONVERT(BIT, 0) AS IsDisable ,
                                CONVERT(NVARCHAR(100), '') AS ContactGropName ,
                                CONVERT(BIT, 0) AS IsResend ,
                                CONVERT(INT, 0) AS UnreadAction ,
                                CONVERT(BIT, 0) AS IsRecursion ,
                                CONVERT(INT, ISNULL(@PositiveCount, 0)) AS PositiveCount ,
                                CONVERT(INT, ISNULL(@NegativeCount, 0)) AS NegativeCount ,
                                CONVERT(INT, ISNULL(@PassiveCount, 0)) AS PassiveCount ,
                                CONVERT(INT, ISNULL(@UnresolvedCount, 0)) AS UnresolvedCount ,
                                CONVERT(INT, 0) AS ResolvedCount ,
                                CONVERT(INT, 0) AS ActionedCount ,
                                CONVERT(INT, 0) AS UnActionedCount ,
                                CONVERT(INT, 0) AS TransferredCount ,
                                CONVERT(INT, 0) AS OutstandingCount ,
                                CONVERT(INT, 0) AS AlertUnreadCountCount ,
                                CONVERT(VARCHAR(50), '') AS MobiLink ,
                                CONVERT(VARCHAR(10), '0') AS GroupType ,
                                CONVERT(BIGINT, 0) AS Id ,
                                CONVERT(INT, 0) AS TotalRecord ,
                                CONVERT(BIGINT, 0) AS RowNum ,
                                CONVERT(INT, 0) AS TotalPage ,
                                CONVERT(DATETIME, GETDATE()) AS ActionDate ,
                                CONVERT(DATETIME, GETDATE()) AS ActionDateEveryone ,
                                CONVERT(BIGINT, 0) ActionTo ,
                                CONVERT(INT, 0) FeedbackSubmitted;
                    END;
            END;
        SET NOCOUNT OFF;
    END;





