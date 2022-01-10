--=============================================
--Author		:		D3
--Create date	:	07-FEB-2018
--Description	:	Mobile Api Search Feedback List Page.
--Note. :				If Make Chnages then apply this Mobile AP 'dbo.AdvanceSearchFormData' also.
--=============================================
CREATE PROCEDURE [dbo].[AdvanceSearchFormDataWebCount_02Aug2018]
    @EstablishmentId VARCHAR(MAX) ,
    @UserId VARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Rows INT ,
    @Page INT ,
    @SmileyTypesSortby NVARCHAR(50) ,		/*	----- 1 strstatustype */
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50) = NULL ,		/* For Question Search FormType (In Or OUt) */
    @QuestionSearch NVARCHAR(MAX) ,		/* For $ seprater String. */
    @AppuserId BIGINT ,
    @ReportId BIGINT ,
    @FormType VARCHAR(10) ,		/* Resolved, Unresolved AnswerStatus */
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
    @isFromActivity VARCHAR(5) = '',
    @isResponseLink VARCHAR(5) = 'false' ,
    @ResponseType VARCHAR(15) = 'All'
AS
    BEGIN
        SET NOCOUNT ON;

		DECLARE @ResultCount TABLE (
TotalRecord INT,
PositiveCount INT,
NegativeCount INT,
PassiveCount INT,
UnresolvedCount INT,
ResolvedCount INT,
ActionedCount INT,
UnActionedCount INT,
TransferredCount INT,
OutstandingCount INT,
UnreadActionCount INT );

        DECLARE @Url VARCHAR(50), @GroupType INT;
        SELECT  @Url = KeyValue FROM    dbo.AAAAConfigSettings WHERE   KeyName = 'FeedbackUrl';
        SELECT  @GroupType = ISNULL(Id, 0) FROM    dbo.AppUser WHERE   GroupId IN ( SELECT  Data FROM    dbo.Split(( SELECT  KeyValue FROM    dbo.AAAAConfigSettings WHERE   KeyName = 'ExcludeGroupId' ), ',') ) AND Id = @AppuserId;
		
        DECLARE @IsOut BIT;
        IF (@FormType = 'In' )
        BEGIN
            SET @IsOut = 0;
        END       
        ELSE
        BEGIN
            IF (@FormType = 'Out' )
            BEGIN
                SET @IsOut = 1;
            END
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
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId) );
            END;
        IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0' AND @ActivityType != 'Customer' )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId, @EstablishmentId, @ActivityId) );
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

        DECLARE @PIFilterTable TABLE ( Id INT IDENTITY(1, 1) , Comparetype VARCHAR(150) );

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
                SET @Comparevalue = ( SELECT    dbo.PIBenchmarkCalculationForGraph(@ActivityId, @FromDate, @ToDate, @PIQuestionnaireid, @IsPIOut, @UserId, @EstablishmentId, 0) );
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

        DECLARE @SqlSelect1 VARCHAR(MAX) ,
            @SqlSelect11 VARCHAR(MAX) ,
            @SqlSelect12 VARCHAR(MAX) = ' ' ,
            @SqlSelect2 VARCHAR(MAX) = ' ' ,
            --@Filter VARCHAR(MAX)= ' ' ,
			@FilterCount VARCHAR(MAX) = '',
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
              SEARCH NVARCHAR(MAX)
            );

        DECLARE @S INT , @E INT , @QuestionId NVARCHAR(10), @Operator NVARCHAR(10) , @SearchText NVARCHAR(MAX), @QuestionTypeId BIGINT;
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

                IF @FormType = 'In'
                    BEGIN
                        UPDATE  AQ
                        SET     AQ.QuestionTypeId = Q.QuestionTypeId
                        FROM    @AdvanceQuestionId AS AQ
                                INNER JOIN dbo.Questions AS Q ON Q.Id = AQ.QuestionId;
                    END;
                ELSE
                    IF @FormType = 'Out'
                        BEGIN
                            UPDATE  AQ
                            SET     AQ.QuestionTypeId = Q.QuestionTypeId
                            FROM    @AdvanceQuestionId AS AQ
                                    INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = AQ.QuestionId;
                        END;
            END;

        SELECT  @E = COUNT(1)
        FROM    @AdvanceQuestionId;
        SET @SqlselectCount = N'SELECT  TOP 1
				IIF('''+ @ActivityType + ''' = ''Customer'', SUM(1) OVER ( ), SUM(CASE WHEN ( A.IsOut = 1 ) THEN 1 ELSE 0 END) OVER ( )) AS TotalRecord,
				SUM(CASE WHEN A.SmileType = ''Positive'' THEN 1 ELSE 0 END) OVER ( ) AS PositiveCount ,
                SUM(CASE WHEN A.SmileType = ''Negative'' THEN 1 ELSE 0 END) OVER ( ) AS NegativeCount ,
                SUM(CASE WHEN A.SmileType = ''Neutral'' THEN 1 ELSE 0 END) OVER ( ) AS PassiveCount ,				SUM(CASE WHEN A.AnswerStatus = ''Unresolved'' THEN 1 ELSE 0 END) OVER ( ) AS UnresolvedCount ,
				SUM(CASE WHEN A.AnswerStatus = ''Resolved'' THEN 1 ELSE 0 END) OVER ( ) AS ResolvedCount ,
                SUM(CASE WHEN A.IsActioned = 1 THEN 1 ELSE 0 END) OVER ( ) AS ActionedCount , 
                SUM(CASE WHEN A.IsActioned = 0 THEN 1 ELSE 0 END) OVER ( ) AS UnActionedCount ,
                SUM(CASE WHEN A.IsTransferred = 1 THEN 1 ELSE 0 END) OVER ( ) AS TransferredCount ,
                SUM(CASE WHEN A.IsOutStanding = 1 THEN 1 ELSE 0 END) OVER ( ) AS OutstandingCount,
				(SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = ' + CONVERT(VARCHAR(10), @AppuserId) + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId ' + IIF(@isFromActivity = 'true', 'OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId', '') + ')  AND ModuleId  IN (7,8,11, 12)) AS UnreadAction
        FROM    dbo.View_AllAnswerMaster AS A  
		INNER JOIN (SELECT * FROM dbo.Split('''+ @EstablishmentId + ''', '','')) AS E ON A.EstablishmentId = E.Data OR ''' + @EstablishmentId + ''' = ''0''
		INNER JOIN (SELECT * FROM dbo.Split('''+ @UserId + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR ''' + @UserId + ''' = ''0'' OR A.UserId = 0 ';

        SET @SqlSelect12 += CHAR(13) + 'INNER JOIN (SELECT * FROM dbo.Split(''' + @EstablishmentId + ''', '','')) AS E ON A.EstablishmentId = E.Data OR ''' + @EstablishmentId + ''' = ''0''
							INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR ''' + @UserId + ''' = ''0'' OR A.UserId = 0 ';
        
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

        --SET @Filter += CHAR(13) + ' WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST(''' + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy') + ''' AS DATE) AND CAST(''' + dbo.ChangeDateFormat(@ToDate, 'dd MMM yyyy') + ''' AS DATE) AND A.ActivityId = ' + CONVERT(NVARCHAR(10), @ActivityId); 
		SET @FilterCount += CHAR(13) + ' WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST(''' + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy') + ''' AS DATE) AND CAST(''' + dbo.ChangeDateFormat(@ToDate, 'dd MMM yyyy') + ''' AS DATE) AND A.ActivityId = ' + CONVERT(NVARCHAR(10), @ActivityId); 

        IF ( @ReportId > 0 )
            BEGIN
                --SET @Filter += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = ' + CONVERT(NVARCHAR(10), @ReportId);
				SET @FilterCount += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = ' + CONVERT(NVARCHAR(10), @ReportId);
            END;

        IF ( @FormStatus = 'Resolved' )
            BEGIN
                 --SET @Filter += ' AND A.AnswerStatus = ''Resolved''';
				 		SET @FilterCount += ' AND A.AnswerStatus = ''Resolved''';
            END;
         IF ( @FormStatus = 'Unresolved' )
         BEGIN
              --SET @Filter += ' AND A.AnswerStatus = ''Unresolved''';
			  SET @FilterCount += ' AND A.AnswerStatus = ''Unresolved''';
         END

		IF (@FormType = 'In' )
        BEGIN
            --SET @Filter += ' AND A.IsOut = 0 ';
			  SET @FilterCount += ' AND A.IsOut = 0 ';
        END

		IF (@FormType = 'Out' )
        BEGIN
            --SET @Filter += ' AND A.IsOut = 1 ';
			  SET @FilterCount += ' AND A.IsOut = 1 ';
        END

		 --IF (@SmileyTypesSortby <> '' AND @SmileyTypesSortby IS NOT NULL)
		 --BEGIN
		 --     --SET @Filter += ' AND A.SmileType = '''+@SmileyTypesSortby+'''';
		 --END

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
                                /*SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                                    + @Search + '%'' 
									OR A.SeenClientAnswerMasterId LIKE ''%'
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
								   )';*/
								 SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                                    + @Search + '%'' 
									OR A.SeenClientAnswerMasterId LIKE ''%'
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
                        ELSE
                            BEGIN
                                /*SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                                    + @Search + '%'' 
									OR A.ReportId = '
                                    + CAST(@OutId AS VARCHAR(50)) + '
									OR A.EstablishmentName LIKE ''%' + @Search
                                    + '%''
                                   OR A.EI LIKE ''%' + @Search + '%''
                                   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                    + '%''
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'
                                    + @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                                    + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                                    + @Search + '%''
								   )';*/
								   		SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
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
                      /*  SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                            + @Search + '%'' 
								   OR A.EstablishmentName LIKE ''%' + @Search
                            + '%''
                                   OR A.EI LIKE ''%' + @Search + '%''
                                   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                            + '%''
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'
                            + @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                            + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                            + @Search + '%''
								   )';*/
						SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%'
                            + @Search + '%'' 
								   OR A.EstablishmentName LIKE ''%' + @Search
                            + '%''
                                   --OR A.EI LIKE ''%' + @Search + '%''
                                   OR A.UserName LIKE ''%' + @Search + '%''
                                   OR A.SenderCellNo LIKE ''%' + @Search
                            + '%''
                                  -- OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'+ @Search + '%''
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%'
                            + @Search + '%''
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%'
                            + @Search + '%''
								   )';
                    END;
            END;
         
        IF ( @ReadUnread = 'Unread' )
            BEGIN
             --   SET @Filter += ' And A.Isoutstanding = 1';
						SET @FilterCount += ' And A.Isoutstanding = 1';
            END;
        ELSE
            IF ( @ReadUnread = 'Read' )
                BEGIN
               --    SET @Filter += ' And A.Isoutstanding = 0';
							SET @FilterCount += ' And A.Isoutstanding = 0';
                END;
        
        IF ( @isResend = 'true' )
            BEGIN
              --  SET @Filter += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1';
            		SET @FilterCount += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1';
			END;

        IF ( @isRecursion = 'true' )
            BEGIN
            --    SET @Filter += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
						SET @FilterCount += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
			END;
        IF ( @isAction = 'true' )
            BEGIN
             --   SET @Filter += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WHERE Conversation LIKE ''%' + @ActionSearch + '%'')';
				SET @FilterCount += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WHERE Conversation LIKE ''%' + @ActionSearch + '%'')';
            END;
        ELSE
            IF ( @isAction = 'false' )
                BEGIN
                 --   SET @Filter += ' AND A.IsActioned = 0';
					SET @FilterCount += ' AND A.IsActioned = 0';
                END;
        IF ( @isTransfer = 'true' )
            BEGIN
             --   SET @Filter += ' AND A.IsTransferred = 1';
				SET @FilterCount += ' AND A.IsTransferred = 1';
            END;

			 DECLARE @Temp TABLE
            (
              [SeenClientAnswerMasterId] [BIGINT] NOT NULL
            );

        INSERT  INTO @Temp
                ( SeenClientAnswerMasterId
                )
                EXEC
                    ( 'select A.SeenClientAnswerMasterId FROM  dbo.View_AllAnswerMaster AS A '
                      --+ @SqlSelect12 + @SqlSelect2 + @Filter
					  + @SqlSelect12 + @SqlSelect2 + @FilterCount
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
				   PRINT @var
        IF ( @ResponseType = 'Responded' )
            BEGIN
                --SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) in ('+ @var + ') ';
				SET @FilterCount += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) in ('
                    + @var + ') ';
            END;
        ELSE
            IF ( @ResponseType = 'NotResponded' )
                BEGIN
                --    SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) not in ('+ @var + ') ';
						   SET @FilterCount += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) not in ('
                        + @var + ') ';
                END;

        IF ( @isResponseLink = 'True' )
            BEGIN
                --SET @Filter += ' AND dbo.GetMObilink(A.ReportId, '
                --    + CONVERT(VARCHAR(10), @AppuserId)
                --    + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != ''''';
					 SET @FilterCount += ' AND dbo.GetMObilink(A.ReportId, '
                    + CONVERT(VARCHAR(10), @AppuserId)
                    + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != ''''';
            END;

        
        IF ( @TemplateId != '' )
            BEGIN
                --SET @Filter += @ActionFilter;
						SET @FilterCount += @ActionFilter;
            END;
        IF ( @IsEdited = 'true' )
            BEGIN
                --SET @Filter += ' And A.UpdatedOn IS NOT NULL';
				SET @FilterCount += ' And A.UpdatedOn IS NOT NULL';
            END;

        IF ( @PIFilterNo != '' )
            BEGIN
                --SET @Filter += @PIFilterNo;
				SET @FilterCount += @PIFilterNo;
            END;
        IF ( @isFromActivity = 'true' )
            BEGIN
                SET @SqlSelect12 += CHAR(13)
                    + 'LEFT OUTER JOIN dbo.View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)';
                --SET @Filter += CHAR(13)
                --    + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                --    + CONVERT(VARCHAR(10), @AppuserId)
                --    + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId)  AND ModuleId  IN (7, 8, 11, 12))> 0';
				SET @FilterCount += CHAR(13)
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
                                SET @FilterCount += ' AND ('
                                    + ( CASE @IsOut
                                          WHEN 0 THEN 'Ans'
                                          ELSE 'SeenAns'
                                        END ) + @QuestionId + '.Detail '
                                    + @Operator + ' ' + @SearchText + ' )';
                            END;
                        ELSE
                            IF @QuestionTypeId IN ( 5, 6, 18, 21 )
                                BEGIN
                                    SET @FilterCount += 'AND ('
                                        + ( CASE @IsOut
                                              WHEN 0 THEN 'OAns'
                                              ELSE ' OSeenAns'
                                            END ) + @QuestionId
                                        + '.Data IN ( SELECT Data FROM dbo.Split('''
                                        + @SearchText + ''', '','')) )';
												SET @FilterCount += 'AND ('
                                        + ( CASE @IsOut
                                              WHEN 0 THEN 'OAns'
                                              ELSE ' OSeenAns'
                                            END ) + @QuestionId
                                        + '.Data IN ( SELECT Data FROM dbo.Split('''
                                        + @SearchText + ''', '','')) )';
                                END;
                            ELSE
                                BEGIN
                                    /*SET @Filter += ' AND ('',''+'
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
                                          END + '%'' )';*/
										  		SET @FilterCount += ' AND ('',''+'
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

        
        SET @FilterCount += CHAR(13) + ' GROUP BY A.ReportId , A.EstablishmentId , A.EstablishmentName , A.UserId , A.UserName , A.SenderCellNo , A.IsOutStanding , A.AnswerStatus , A.TimeOffSet ,
                A.CreatedOn , A.UpdatedOn , A.EI , A.[PI] , A.SmileType , A.QuestionnaireType , A.FormType , A.IsOut , A.QuestionnaireId , A.ReadBy , A.ContactMasterId , A.ContactGroupId , A.Latitude ,
                A.Longitude , A.IsTransferred , A.TransferToUser , A.TransferFromUser , A.SeenClientAnswerMasterId , A.ActivityId , A.IsActioned , A.TransferByUserId , A.TransferFromUserId , A.IsDisabled ,
                A.CreatedUserId';
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT  INTO @ResultCount
      EXEC ( @SqlselectCount + @SqlSelect2 + @FilterCount );
--SELECT  ( @SqlselectCount + @SqlSelect2  + @FilterCount);

SELECT TotalRecord ,
          PositiveCount ,
          NegativeCount ,
          PassiveCount ,
          UnresolvedCount ,
          ResolvedCount ,
          ActionedCount ,
          UnActionedCount ,
          TransferredCount ,
          OutstandingCount ,
          UnreadActionCount FROM @ResultCount;

        SET NOCOUNT OFF;
    END;

