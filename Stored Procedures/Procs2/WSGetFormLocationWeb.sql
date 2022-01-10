-- =============================================
-- Author:		<Disha Patel>
-- Create date: <Create Date,, Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetFormLocationWeb '1280', '303', 885, 1, 100, 1, '', '', '31 Mar 2016', '31 Mar 2016', '', 0, ''
-- =============================================
CREATE PROCEDURE [dbo].[WSGetFormLocationWeb]
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
    @QuestionSearch NVARCHAR(MAX)
AS
    BEGIN
        ----IF @ForMobile = 0
        ----    BEGIN
        ----        SET @Rows = 10;
        ----    END;
        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIT = 0 ,
            @InOutFilter BIT = 0 ,
            @IsOut BIT = 1;

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
              ReportId BIGINT NOT NULL ,
              EstablishmentName NVARCHAR(500) NOT NULL ,
              UserName NVARCHAR(100) ,
              FormType NVARCHAR(10) NOT NULL ,
              IsOut BIT ,
              Latitude NVARCHAR(50) ,
              Longitude NVARCHAR(50) ,
              DisplayText NVARCHAR(MAX) ,
              CaptureDate NVARCHAR(50) ,
              TotalPage INT NOT NULL,
			  Total INT NOT NULL,
			  RowNum INT NOT NULL
            );


        DECLARE @SqlSelect1 NVARCHAR(MAX) ,
            @SqlSelect2 NVARCHAR(MAX) = ' ' ,
            @Filter NVARCHAR(MAX)= ' ';
	
        DECLARE @AdvanceQuestionId TABLE
            (
              Id INT IDENTITY(1, 1) ,
              QuestionId BIGINT
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
            @SearchText NVARCHAR(MAX);

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
            END;

        SELECT  @E = COUNT(1)
        FROM    @AdvanceQuestionId;

		SET @SqlSelect1 = N'SELECT  ReportId ,
                        EstablishmentName ,
                        UserName ,
                        FormType ,
                        IsOut ,
                        Latitude ,
                        Longitude ,
                        dbo.AnswerDetails(CASE IsOut
                                            WHEN 0 THEN ''Answers''
                                            ELSE ''SeenClientAnswers''
                                          END, ReportId) AS DisplayText ,
                        dbo.ChangeDateFormat(CreatedOn,
                                             ''MM/dd/yyyy hh:mm AM/PM'') AS CaptureDate ,
                        CASE Total / ' + CONVERT(NVARCHAR(10), @Rows) + '
                          WHEN 0 THEN 1
                          ELSE ( Total / ' + CONVERT(NVARCHAR(10), @Rows)
            + ' ) + 1
                        END AS TotalPage, Total, RowNum
                FROM    ( SELECT    A.ReportId ,A.EstablishmentName ,A.UserName ,A.FormType ,A.IsOut ,A.Latitude ,A.Longitude ,A.CreatedOn ,
                                    COUNT(*) OVER ( PARTITION BY 1 ) AS Total , ROW_NUMBER() OVER ( ORDER BY A.CreatedOn DESC ) AS RowNum
                          FROM      dbo.View_AllAnswerMaster AS A
                                    INNER JOIN (SELECT * FROM dbo.Split('''
            + @EstablishmentId
            + ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''
            + @EstablishmentId + ''' = ''0''
                                    INNER JOIN (SELECT * FROM dbo.Split('''
            + @UserId
            + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''
            + @UserId + ''' = ''0'' OR A.UserId = 0';

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
                            SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans'
                                + @QuestionId + ' ON Ans' + @QuestionId
                                + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans'
                                + @QuestionId + '.QuestionId = ' + @QuestionId;
                        ELSE
                            SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns'
                                + @QuestionId + ' ON SeenAns' + @QuestionId
                                + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns'
                                + @QuestionId + '.QuestionId = ' + @QuestionId;

                        SET @S += 1;
                    END;
            END;
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0
                                     LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';


        SET @SqlSelect2 += 'WHERE     CAST(A.CreatedOn AS DATE) BETWEEN CAST('''
            + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy') + ''' AS DATE)
                                                              AND
                                                              CAST('''
            + dbo.ChangeDateFormat(@ToDate, 'dd MMM yyyy') + ''' AS DATE)
                                    AND A.ActivityId = '
            + CONVERT(NVARCHAR(10), @ActivityId);

        IF @Status <> ''
            AND @Status IS NOT NULL
            SET @Filter += 'AND (SmileType = ''' + @Status + ''')';

        IF @AnsStatus <> ''
            AND @AnsStatus IS NOT NULL
            SET @Filter += 'AND (AnswerStatus = ''' + @AnsStatus + ''')';

        IF @AdvanceSearch = 0
            AND @Search <> ''
            AND @Search IS NOT NULL
            BEGIN
               SET @Filter += 'AND (A.EstablishmentName LIKE ''%' + @Search
                    + '%'' OR A.EI LIKE ''%' + @Search + '%''
				OR A.UserName LIKE ''%' + @Search
                    + '%'' OR A.SenderCellNo LIKE ''%' + @Search
                    + '%''
				OR dbo.ChangeDateFormat(A.CreatedOn, ''MM/dd/yyyy hh:mm AM/PM'') LIKE ''%'
                    + @Search + '%'' OR ISNULL(Ans.Detail, '''') LIKE ''%'
                    + @Search + '%''
				 OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search
                    + '%'')';
            END;
        ELSE
            IF @AdvanceSearch = 1
                AND @QuestionSearch <> ''
                AND @QuestionSearch IS NOT NULL
                BEGIN
                    SET @S = 1;
                    WHILE @S <= @E
                        BEGIN
                            SELECT  @QuestionId = QuestionId
                            FROM    @AdvanceQuestionId
                            WHERE   Id = @S;

                            SELECT  @Operator = Operator
                            FROM    @AdvanceQuestionOperator
                            WHERE   Id = @S;

                            SELECT  @SearchText = Search
                            FROM    @AdvanceQuestionSearch
                            WHERE   Id = @S;

                            IF @IsOut = 0
                                BEGIN
                                    IF @Operator <> ''
                                        SET @Filter += 'AND (Ans'
                                            + @QuestionId + '.Detail '
                                            + @Operator + ' ' + @SearchText
                                            + ' )';
                                    ELSE
                                        SET @Filter += 'AND ('',''+Ans'
                                            + @QuestionId + '.Detail+'','' LIKE ''%'
                                            + @SearchText + '%'' )';

                                END;
                            ELSE
                                BEGIN
                                    IF @Operator <> ''
                                        SET @Filter += 'AND (SeenAns'
                                            + @QuestionId + '.Detail '
                                            + @Operator + ' ' + @SearchText
                                            + ' )';
                                    ELSE
                                        SET @Filter += 'AND ('',''+SeenAns'
                                            + @QuestionId + '.Detail+'','' LIKE ''%'
                                            + @SearchText + '%'' )';
                                    
                                END;
                            SET @S += 1;
                        END;
                    --SET @Filter += 'AND (' + @QuestionSearch + ') ';
                END;
        IF @TranferFilter = 1
            SET @Filter += 'AND (IsTransferred = 1)';
        IF @ActionFilter = 1
            SET @Filter += 'AND (A.IsActioned = 1)';
        IF @InOutFilter = 1
            SET @Filter += 'AND (IsOut = ' + CONVERT(NVARCHAR(5), @IsOut)
                + ')';

        SET @Filter += 'GROUP BY  A.ReportId, A.EstablishmentName, A.UserName, A.FormType, A.IsOut, A.Latitude, A.Longitude, A.CreatedOn
                        ) AS R
                WHERE   R.RowNum BETWEEN ' + CONVERT(NVARCHAR(5), @Start)
            + ' AND ' + CONVERT(NVARCHAR(5), @End) + '
                ORDER BY R.RowNum;';

        --PRINT @SqlSelect1; 
        --PRINT @SqlSelect2;
        --PRINT @Filter;

        
        INSERT  INTO @Result
                EXEC ( @SqlSelect1 + @SqlSelect2 + @Filter
                    );

        SELECT  *
        FROM    @Result WHERE CAST(Latitude AS DECIMAL(18,0)) != 0 AND CAST(Longitude AS DECIMAL(18,0)) != 0;

       ---- SELECT  * ,
       ----         dbo.AnswerDetails(CASE IsOut
       ----                             WHEN 0 THEN 'AnswersDetail'
       ----                             ELSE 'SeenClientAnswersDetail'
       ----                           END, ReportId) AS Detail ,
       ----         CASE Total / @Rows
       ----           WHEN 0 THEN 1
       ----           ELSE ( Total / @Rows ) + 1
       ----         END AS TotalPage ,
       ----         dbo.ChangeDateFormat(CreatedOn, 'MM/dd/yyyy hh:mm AM/PM') AS CaptureDate
       ---- FROM    ( SELECT    
       ----                     A.ReportId ,
							----A.EstablishmentName ,
       ----                     A.UserName ,
       ----                     A.FormType ,
       ----                     A.IsOut ,
       ----                     A.Latitude ,
       ----                     A.Longitude ,
       ----                     A.CreatedOn ,
       ----                     COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
       ----                     ROW_NUMBER() OVER ( ORDER BY A.CreatedOn DESC ) AS RowNum
       ----           FROM      dbo.View_AllAnswerMaster AS A
       ----                     INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
       ----                                                       OR @EstablishmentId = '0'
       ----                     INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
       ----                                                 OR @UserId = '0'
       ----                     LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId
       ----                                                       AND A.IsOut = 0
       ----                     LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId
       ----                                                       AND A.IsOut = 1
       ----           WHERE     CAST(A.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
       ----                                               AND     CAST(@ToDate AS DATE)
       ----                     AND A.ActivityId = @ActivityId
       ----                     AND ( SmileType = @Status
       ----                           OR @Status = ''
       ----                         )
       ----                     AND ( AnswerStatus = @AnsStatus
       ----                           OR @AnsStatus = ''
       ----                         )
       ----                     AND ( A.EstablishmentName LIKE '%' + @Search + '%'
       ----                           OR A.EI LIKE '%' + @Search + '%'
       ----                           OR A.UserName LIKE '%' + @Search + '%'
       ----                           OR A.SenderCellNo LIKE '%' + @Search + '%'
       ----                           OR dbo.ChangeDateFormat(A.CreatedOn,
       ----                                                   'MM/dd/yyyy hh:mm AM/PM') LIKE '%'
       ----                           + @Search + '%'
       ----                           OR ISNULL(Ans.Detail, '') LIKE '%' + @Search
       ----                           + '%'
       ----                           OR ISNULL(SeenAns.Detail, '') LIKE '%'
       ----                           + @Search + '%'
       ----                         )
       ----                     AND ( @TranferFilter = 0
       ----                           OR IsTransferred = 1
       ----                         )
       ----                     AND ( @ActionFilter = 0
       ----                           OR A.IsActioned = 1
       ----                         )
       ----                     AND ( @InOutFilter = 0
       ----                           OR IsOut = @IsOut
       ----                         )
       ----           GROUP BY  A.EstablishmentName ,
       ----                     A.UserName ,
       ----                     --A.CaptureDate ,
       ----                     A.Latitude ,
       ----                     A.Longitude ,
       ----                     A.ReportId ,
       ----                     A.IsOut ,
       ----                     A.FormType ,
       ----                     A.CreatedOn
       ----         ) AS R
       ---- WHERE   R.RowNum BETWEEN @Start AND @End;
    END;