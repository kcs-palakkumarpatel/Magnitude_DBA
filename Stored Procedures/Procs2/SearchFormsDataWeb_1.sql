-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	02-May-2017
-- Description:	Get Feedback summary List.
--					dbo.SearchFormsDataWeb '14372', '0', 2321, 4, 100, 1, '', '',  '2017-01-01 00:00:00', '2017-08-02 00:00:00', '', 0, '', 0,''
-- Call SP:			dbo.SearchFormsDataWeb '1356,11647,11648,11649,11650,1357,1313,12700', '313,314,1167,1230', 919, 4, 100, 1, '', '',  '2017-01-01 00:00:00', '2017-05-02 00:00:00', '', 0, '', 314,'Action'
-- =============================================
CREATE PROCEDURE dbo.SearchFormsDataWeb_1
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Period INT ,
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(100) ,
    @Status NVARCHAR(50) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50) ,
    @AdvanceSearch BIT ,
    @QuestionSearch NVARCHAR(MAX),
	@AppuserId INT,
	@Sortby NVARCHAR(50)
AS
    BEGIN
        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIGINT = 0 ,
            @InOutFilter BIT = 0 ,
            @IsOut BIT = 1,
			@IsView BIT = 0,
			@IsAlertRead BIT = 0;

        IF @QuestionSearch <> ''
            AND @QuestionSearch IS NOT NULL
            SET @Search = '';

        IF @Status IS NULL
            BEGIN
                SET @Status = '';
            END;
            
        IF @Search IS NULL
            BEGIN
                SET @Search = '';
            END;			
            
        IF @QuestionSearch IS NULL
            BEGIN
                SET @QuestionSearch = '';
            END;
        
        IF @Status = 'Unresolved'
            BEGIN
                SET @AnsStatus = @Status;
                SET @Status = '';
            END;
        
        IF @AnsStatus = 'Unresolved'
            AND @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = 'None';
                SET @FilterOn = 'None';
            END;
		    
        IF @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = @FilterOn;
            END;
        ELSE
            IF @FilterOn = 'Transferred'
                BEGIN
                    SET @TranferFilter = 1;
                END;
            ELSE
                IF @FilterOn = 'Actioned'
                    BEGIN
                        SET @ActionFilter = 1;
                    END;
				IF @FilterOn = 'UnActioned'
					BEGIN
						SET @ActionFilter = 2;
					END
					IF @FilterOn = 'Neutral'
					BEGIN
						SET @ActionFilter = 3;
					END
                ELSE
                    IF @FilterOn = 'In'
                        BEGIN
                            SET @InOutFilter = 1;
                            SET @IsOut = 0;
                        END;
                    ELSE
                        IF @FilterOn = 'Out'
                            BEGIN
                                SET @InOutFilter = 1;
                                SET @IsOut = 1;
                            END;
						ELSE IF @FilterOn = 'OutStanding'
							BEGIN
								SET @IsView = 1;
							END
						ELSE IF @FilterOn = 'UnreadAction'
						BEGIN
							SET @IsAlertRead = 1;
						END
                            
        DECLARE @Start AS INT ,
            @End INT;
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
              UserId BIGINT NOT NULL ,
              UserName NVARCHAR(100) ,
              SenderCellNo NVARCHAR(50) ,
              IsOutStanding BIT NOT NULL ,
              AnswerStatus NVARCHAR(50) NOT NULL ,
              TimeOffSet INT ,
              CreatedOn DATETIME ,
			  UpdatedOn NVARCHAR(50) ,
              EI DECIMAL(18, 0) NOT NULL ,
              SmileType NVARCHAR(20) NOT NULL ,
              QuestionnaireType NVARCHAR(10) NOT NULL ,
              FormType NVARCHAR(10) NOT NULL ,
              IsOut BIT ,
              QuestionnaireId BIGINT NOT NULL ,
              ReadBy BIGINT NOT NULL ,
              ContactMasterId BIGINT NULL,
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
              TotalPage INT NOT NULL,
			  IsDisable BIT NULL,
			  ContactGropName nvarchar(100) NULL ,
			  IsResend BIT,
			  NotificationCount INT,
			  CreatedUserId INT,
			  ActionDate DATETIME,
			  ActionTo BIGINT
			  );

        DECLARE @SqlSelect1 NVARCHAR(MAX) ,
            @SqlSelect2 NVARCHAR(MAX) = ' ' ,
            @Filter NVARCHAR(MAX)= ' ';
	
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

        DECLARE @S INT = 1 ,
            @E INT ,
            @QuestionId NVARCHAR(10) ,
            @Operator NVARCHAR(10) ,
            @SearchText NVARCHAR(MAX) ,
            @QuestionTypeId BIGINT;

        IF @AdvanceSearch = 1
            AND @QuestionSearch <> ''
            AND @QuestionSearch IS NOT NULL
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

        SELECT  @E = COUNT(1)
        FROM    @AdvanceQuestionId;


        SET @SqlSelect1 = N'SELECT ReportId,
                        EstablishmentId ,EstablishmentName ,UserId ,UserName ,SenderCellNo ,IsOutStanding ,AnswerStatus ,TimeOffSet ,CreatedOn , dbo.ChangeDateFormat(UpdatedOn,''dd/MMM/yyyy hh:mm AM/PM'') AS UpdatedOn,
                        PI ,SmileType ,QuestionnaireType ,FormType ,IsOut ,QuestionnaireId ,ReadBy ,ContactMasterId ,Latitude ,Longitude ,IsTransferred ,
                        TransferToUser ,TransferFromUser ,SeenClientAnswerMasterId ,ActivityId ,IsActioned ,TransferByUserId ,TransferFromUserId ,
						dbo.AnswerDetails(CASE IsOut WHEN 0 THEN ''Answers'' ELSE ''SeenClientAnswers'' END, ReportId) AS DisplayText , 
                        dbo.ConcateString(''ContactSummary'', ContactMasterId) AS ContactDetails , dbo.ChangeDateFormat(CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') AS CaptureDate ,
                        CASE Total / ' + CONVERT(NVARCHAR(10), @Rows) + '
                          WHEN 0 THEN 1
                          ELSE ( Total / ' + CONVERT(NVARCHAR(10), @Rows)
            + ' ) + 1
                        END AS TotalPage,isnull(isdisabled,''false''),
																	ISNULL(
																		(SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN(
																		SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster 
																		WHERE id = ReportId AND R.IsOut=1)),'''') as ContactGropName,
						 (SELECT CASE R.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = R.ReportId),1) ELSE 0 end) AS Resend,
				NotificationCount,
				R.CreatedUserId,
				ActionDate,
				ActionTo
                FROM    ( SELECT    A.* ,
									CASE A.IsOut WHEN 1 THEN (SELECT ((SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE ModuleId = 12 AND RefId = A.ReportId AND IsRead = 0 AND AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + ''')
											+ (SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE ModuleId = 11 AND RefId IN (SELECT Id FROM dbo.AnswerMaster WHERE SeenClientAnswerMasterId = A.ReportId) AND IsRead = 0 AND AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + ''')))
											ELSE
											(SELECT ((SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE ModuleId = 11 
											AND (RefId IN (SELECT id FROM dbo.AnswerMaster WHERE SeenClientAnswerMasterId = (SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE id = A.ReportId))
												OR  RefId = A.ReportId) AND IsRead = 0 AND AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + ''')
											+ (SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE ModuleId = 12 AND RefId IN (SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE Id = A.ReportId) AND IsRead = 0 AND AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + '''))) end AS NotificationCount,
                                    COUNT(*) OVER ( PARTITION BY 1 ) AS Total , 
									ROW_NUMBER() OVER ( ORDER BY '+ IIF(@Sortby = ' Order By R.ActionDate Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '+CONVERT(VARCHAR(10), @AppuserId)+' ORDER BY CreatedOn DESC)))', IIF(@Sortby = ' Order By R.ActionDateEveryone Desc', '(DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotificationWeb WHERE  ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)))', 'A.CreatedOn')) +' DESC ) AS RowNum,
									DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotification WHERE  ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) AND ISNULL(AppUserId, 0) = '+CONVERT(VARCHAR(10), @AppuserId)+' ORDER BY CreatedOn DESC)) AS ActionDate,
									DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM   dbo.PendingNotification WHERE  ISNULL(RefId, 0) = A.ReportId AND ModuleId IN (11, 12) ORDER BY CreatedOn DESC)) AS ActionDateEveryone,
									'+ CONVERT(VARCHAR(10), @AppuserId) +' AS ActionTo
                          FROM  dbo.[View_WebAllFormsList] AS A
                                    INNER JOIN (SELECT * FROM dbo.Split('''+ @EstablishmentId + ''', '','')) AS E ON A.EstablishmentId = E.Data OR ''' + @EstablishmentId + ''' = ''0''
                                    INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR ''' + @UserId + ''' = ''0'' OR A.UserId = 0';

        IF @AdvanceSearch = 1
            AND @QuestionSearch <> ''
            AND @QuestionSearch IS NOT NULL
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

        SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0
                                     LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';

        SET @Filter += CHAR(13) + 'WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST('''+ dbo.ChangeDateFormat(@FromDate, 'dd/MMM/yyyy') + ''' AS DATE) AND CAST('''
            + dbo.ChangeDateFormat(@ToDate, 'dd/MMM/yyyy') + ''' AS DATE) AND A.ActivityId = '+ CONVERT(NVARCHAR(10), @ActivityId);

        IF @Status <> ''
            AND @Status IS NOT NULL
            SET @Filter += ' AND (SmileType = ''' + @Status + ''')';

        IF @AnsStatus <> ''
            AND @AnsStatus IS NOT NULL
            SET @Filter += ' AND (AnswerStatus = ''' + @AnsStatus + ''')';

        IF @AdvanceSearch = 0
            AND @Search <> ''
            AND @Search IS NOT NULL
            BEGIN
                SET @Filter += ' AND (REPLACE(STR(ReportId , 10), SPACE(1), ''0'') like ''%' + @search + '%'' OR A.EstablishmentName LIKE ''%' + @Search
                    + '%'' OR A.PI LIKE ''%' + @Search + '%''
				OR A.UserName LIKE ''%' + @Search
                    + '%'' OR A.SenderCellNo LIKE ''%' + @Search
                    + '%''
				OR Replace(dbo.ChangeDateFormat(A.CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM''),''  '','' '') LIKE ''%'
                    + @Search
                    + '%'' OR CASE WHEN Ans.QuestionTypeId IN (8, 22) THEN dbo.ChangeDateFormat(Ans.Detail, ''dd/MMM/yyyy hh:mm AM/PM'') ELSE ISNULL(Ans.Detail, '''') END LIKE ''%'
                    + @Search
                    + '%''
				 OR CASE WHEN SeenAns.QuestionTypeId IN (8, 22) THEN dbo.ChangeDateFormat(SeenAns.Detail, ''dd/MMM/yyyy hh:mm AM/PM'') ELSE ISNULL(SeenAns.Detail, '''') END LIKE ''%'
                    + @Search + '%'')';
            END;
        ELSE
            IF @AdvanceSearch = 1
                AND @QuestionSearch <> ''
                AND @QuestionSearch IS NOT NULL
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
                                                  WHEN 0 THEN 'Ans'
                                                  ELSE 'SeenAns'
                                                END ) + @QuestionId
                                            + '.Detail+'','' LIKE ''%'
                                            + @SearchText + '%'' )';
                                    END;

                                
                            SET @S += 1;
                        END;
                END;
        IF @TranferFilter = 1
            SET @Filter += ' AND (IsTransferred = 1)';
        IF @ActionFilter = 1
            SET @Filter += ' AND (A.IsActioned = 1)';
		IF @ActionFilter = 2
			SET @Filter += ' AND (A.IsActioned = 0) and A.AnswerStatus= ''UnResolved'' ';
		IF @ActionFilter = 3
			SET @Filter += ' AND SmileType = ''Neutral'' ';
		IF @IsView = 1 
		    SET @Filter += ' AND (ISOutStanding) = 1';
		IF @IsAlertRead = 1
		   SET @Filter += ' AND (CASE A.IsOut WHEN 0 THEN (SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + ''' AND IsRead = 0 AND RefId = A.ReportId AND ModuleId = 11) ELSE 
									(SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId = ''' + CONVERT(VARCHAR(10), @AppuserId) + ''' AND IsRead = 0 AND RefId = A.ReportId AND ModuleId = 12	) end) > 0';
        IF @InOutFilter = 1
            SET @Filter += ' AND (IsOut = ' + CONVERT(NVARCHAR(5), @IsOut)
		        + ')';

        SET @Filter += CHAR(13) +' GROUP BY  ReportId ,
                                    EstablishmentId ,
                                    EstablishmentName ,
                                    UserId ,
                                    UserName ,
									SenderCellNo ,
                                    IsOutStanding ,
                                    AnswerStatus ,
                                    A.TimeOffSet ,
                                    A.CreatedOn ,
									A.UpdatedOn,
                                    EI ,
									PI ,
                                    SmileType ,
                                    QuestionnaireType ,
                                    FormType ,
                                    IsOut ,
                                    QuestionnaireId ,
                                    ReadBy ,
                                    ContactMasterId ,
									ContactGroupId,
                                    Latitude ,
                                    Longitude ,
                                    IsTransferred ,
                                    TransferToUser ,
                                    TransferFromUser ,
                                    A.SeenClientAnswerMasterId ,
                                    ActivityId ,
                                    IsActioned ,
                                    TransferByUserId ,
                                    TransferFromUserId,A.isdisabled,
									CreatedUserId
                        ) AS R
                WHERE   R.RowNum BETWEEN ' + CONVERT(NVARCHAR(5), @Start)
            + ' AND ' + CONVERT(NVARCHAR(5), @End) + '';

				IF @Sortby = 'Action'
				BEGIN
					SET @Filter += CHAR(13) + ' ORDER BY R.ActionDate DESC;';
				END
				 Else IF (@Sortby = 'actionEveryone')
				BEGIN
					SET @Filter += CHAR(13) + 'Order By R.ActionDateEveryone Desc;'
				END
				ELSE
				BEGIN
				   SET @Filter += CHAR(13) + 'ORDER BY R.CreatedOn DESC;';
				END
        SELECT  @SqlSelect1 + @SqlSelect2 + @Filter;

INSERT  INTO @Result
			 EXEC ( @SqlSelect1 + @SqlSelect2 + @Filter );

DECLARE @url VARCHAR(50)
SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WHERE KeyName = 'FeedbackUrl'

        SELECT  *,dbo.GetMObilink(ReportId,@AppuserId, CASE WHEN [@Result].ContactGropName != '' THEN 1 ELSE 0 END) AS Url
        FROM    @Result
    END;
