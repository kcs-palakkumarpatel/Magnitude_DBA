-- =============================================  
-- Author:   D#3  
-- Create date: 09-Feb-2018  
-- Description: Excel Export Feedback List ExportFeedbackDataWeb  
--ExportFeedbackDataWeb_Repeatetive 34
-- =============================================  
CREATE PROCEDURE [dbo].[CreateBiData]
(
  @ActivityId BIGINT,
  @AppUserID BIGINT,
  @IsOut BIT
)
AS
BEGIN

DECLARE
    @EstablishmentId VARCHAR(MAX),
    @UserId VARCHAR(MAX),
    --@ActivityId BIGINT,
    @Rows INT,
    @Page INT,
    @SmileyTypesSortby NVARCHAR(50), /* ----- 1 strstatustype */
    @FromDate DATETIME,
    @ToDate DATETIME,
    @FilterOn NVARCHAR(50),          /* For Question Search FormType (In Or OUt) */
    @QuestionSearch NVARCHAR(MAX),   /* For $ seprater String. */
    --@AppuserId INT,
    @ReportId INT,
    @FormType VARCHAR(10),           /* Resolved, Unresolved AnswerStatus */
    @FormStatus VARCHAR(10),         /* Resolved, Unresolved AnswerStatus */
    @ReadUnread VARCHAR(10),         /* Unread, Read  IsOutStanding */
    @isResend VARCHAR(5),            /* IsResend = true or False  IsResend */
    @isRecursion VARCHAR(5),         /* isRecursion = true or False  */
    @isAction VARCHAR(5),
    @ActionSearch VARCHAR(50),
    @isTransfer VARCHAR(5),
    @TemplateId VARCHAR(1000),
    @PIFilter VARCHAR(50),
    @IsEdited VARCHAR(5),
    @Search VARCHAR(1000),
    @OrderBy VARCHAR(200),
    @isFromActivity VARCHAR(5) = ''
   


--DECLARE 
  
--SELECT GETDATE(),1
--mittal parameter
--SET @EstablishmentId = '0'             -- varchar(max)
--set @UserId = '0'                      -- varchar(max)
--set @ActivityId = 4563                   -- bigint
--set @Rows = 0                         -- int
--set @Page = 1                         -- int
--set @SmileyTypesSortby = N''          -- nvarchar(50)
--set @FromDate = '2019-09-01 00:00:00' -- datetime
--set @ToDate = '2020-12-10 23:59:59'   -- datetime
--set @FilterOn = N''                   -- nvarchar(50)
--set @QuestionSearch = N''             -- nvarchar(max)
--set @AppuserId = 4518                    -- int
--set @ReportId = 0                     -- int
--set @FormType = 'All'                    -- varchar(10)
--set @FormStatus = 'All'                  -- varchar(10)
--set @ReadUnread = ''                  -- varchar(10)
--set @isResend = ''                    -- varchar(5)
--set @isRecursion = ''                 -- varchar(5)
--set @isAction = ''                    -- varchar(5)
--set @ActionSearch = ''                -- varchar(50)
--set @isTransfer = ''                  -- varchar(5)
--set @TemplateId = ''                  -- varchar(1000)
--set @PIFilter = ''                    -- varchar(50)
--set @IsEdited = ''                    -- varchar(5)
--set @Search = ''                      -- varchar(1000)
--set @OrderBy = ''                     -- varchar(200)
--set @isFromActivity = ''              -- varchar(5)
--set @IsOut = 0
DECLARE @OffSet INTEGER = 0;
SET @OffSet = (Select MAX(TimeOffSet) from Establishment Where EstablishmentGroupId = 6145);

set @EstablishmentId = '0' -- varchar(max)
set @UserId = '0' -- varchar(max)
--set = 6145 -- bigint
set @Rows = 0 -- int
set @Page = 1 -- int
set @SmileyTypesSortby = N'' -- nvarchar(50)
set @FromDate = DATEADD(DAY, -7,GETUTCDATE()) -- datetime
set @ToDate = DATEADD(MINUTE, @OffSet,GETUTCDATE()) -- datetime
set @FilterOn = N'' -- nvarchar(50)
set @QuestionSearch = N'' -- nvarchar(max)
--set @AppuserId = 7043 -- int
set @ReportId = 0 -- int
set @FormType = 'All' -- varchar(10)
set @FormStatus = 'All' -- varchar(10)
set @ReadUnread = '' -- varchar(10)
set @isResend = '' -- varchar(5)
set @isRecursion = '' -- varchar(5)
set @isAction = '' -- varchar(5)
set @ActionSearch = '' -- varchar(50)
set @isTransfer = '' -- varchar(5)
set @TemplateId = '' -- varchar(1000)
set @PIFilter = '' -- varchar(50)
set @IsEdited = '' -- varchar(5)
set @Search = '' -- varchar(1000)
set @OrderBy = '' -- varchar(200)
set @isFromActivity = '' -- varchar(5)

    DECLARE @ResultReportId TABLE (ReportId BIGINT);
    DECLARE @ResultReportIdJoin TABLE
    (
        ReportId BIGINT,
        RepetativeCount INT
    );

    DECLARE @URL VARCHAR(2000) = '',
            @SearchQuery VARCHAR(MAX) = '';
    DECLARE @SqlSelect1 VARCHAR(MAX) = '',
            @SqlSelect2 VARCHAR(MAX) = '',
            @SqlSelect3 VARCHAR(MAX) = '';
    DECLARE @cols AS NVARCHAR(MAX) = '',
            @Selectcols AS NVARCHAR(MAX) = '';

    IF @QuestionSearch IS NULL
    BEGIN
        SET @QuestionSearch = '';
    END;

    --IF (@EstablishmentId = '0')
    --BEGIN
    --    SET @EstablishmentId =
    --    (
    --        SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId)
    --    );
    --END;
IF OBJECT_ID('tempdb..#EstablishmentId','U') IS NOT NULL
DROP TABLE #EstablishmentId
CREATE TABLE #EstablishmentId (id BIGINT)

	IF (@EstablishmentId = '0')
BEGIN
    INSERT INTO #EstablishmentId
    SELECT EST.Id
	FROM   dbo.Establishment AS EST  WITH(NOLOCK)
	INNER JOIN dbo.AppUserEstablishment WITH(NOLOCK) ON est.EstablishmentGroupId = @ActivityId 
	AND AppUserEstablishment.AppUserId = @AppUserId 
	AND AppUserEstablishment.EstablishmentId = EST.Id  AND appuserestablishment.IsDeleted = 0  
END
ELSE
BEGIN
     INSERT INTO #EstablishmentId
	 SELECT data FROM dbo.Split(@EstablishmentId,',')
END

    IF @UserId IS NULL
    BEGIN
        SET @UserId = '0';
    END;

    DECLARE @ActivityType NVARCHAR(50),
            @SeenClientID BIGINT;
    SELECT @ActivityType = EstablishmentGroupType,
           @SeenClientID = SeenClientId
    FROM dbo.EstablishmentGroup
    WHERE Id = @ActivityId;

		IF OBJECT_ID('tempdb..#UserId', 'U') IS NOT NULL
		DROP TABLE #UserId
		CREATE TABLE #UserId (UserId bigint)
		--CREATE TABLE #UserId (UserId VARCHAR(MAX))
    
	--IF (@UserId = '0' AND @ActivityType != 'Customer')
    --BEGIN
    --    SET @UserId =
    --    (
    --        SELECT dbo.AllUserSelected(@AppuserId, @EstablishmentId, @ActivityId)
    --    );
    --END;
IF (@UserId = '0' AND @ActivityType != 'Customer')
BEGIN

		DECLARE @Count BIGINT = 0;
        DECLARE @IsManager BIT;
        
        SELECT  @IsManager = IsAreaManager
        FROM    dbo.AppUser
        WHERE   Id = @AppUserId;


			IF EXISTS ( SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  IsAreaManager = 0 AND IsActive = 1
					AND AppUser.IsDeleted = 0 and   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId AND E.EstablishmentGroupId = @ActivityId
                    UNION
					SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  AppUserId = @AppUserId AND AppUser.IsDeleted = 0 
					AND IsActive = 1 AND   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId AND E.EstablishmentGroupId = @ActivityId
                    
                   )
		BEGIN
			SET @Count = 1
		END

		IF @Count = 0
		BEGIN
			IF EXISTS (SELECT 1
                    FROM AppManagerUserRights
                    INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId
					AND AppManagerUserRights.IsDeleted = 0
					AND IsActive = 1
					INNER JOIN #EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId)
            BEGIN
                SET @Count = 1
            END
		END

		IF ( @IsManager = 1 )
						BEGIN
							IF (@Count > 0)
						BEGIN
							INSERT INTO #UserId
							 SELECT  AppUserId
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND AppUserId = @AppUserId AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  AppUserId
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND  IsAreaManager = 0 AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  ManagerUserId 
							 FROM    AppManagerUserRights
							 INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId AND AppUser.IsDeleted = 0
							 AND AppManagerUserRights.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId
							 INNER JOIN dbo.AppUserEstablishment ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
             
						END
						ELSE
						BEGIN
                        INSERT  INTO #UserId
						SELECT U.Id AS UserId
                        FROM    dbo.AppUserEstablishment AS UE
						INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id AND LoginUser.Id = @AppUserId AND LoginUser.IsDeleted = 0
						AND UE.IsDeleted = 0 
                        INNER JOIN dbo.Vw_Establishment AS E ON UE.EstablishmentId = E.Id AND   E.IsDeleted = 0
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
						AND ( UE.EstablishmentType = AppUser.EstablishmentType OR LoginUser.IsAreaManager = 1)
                        INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id AND ( U.IsAreaManager = 0 OR U.Id = @AppUserId) AND U.IsDeleted = 0
						AND AppUser.IsDeleted = 0
                        
						END;

						END
					 ELSE
							BEGIN
							   INSERT  INTO #UserId 
								SELECT U.Id AS UserId
							           FROM    dbo.AppUserEstablishment AS UE
										INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id AND  LoginUser.IsDeleted = 0
										AND UE.IsDeleted = 0 
							           INNER JOIN dbo.Vw_Establishment AS E ON UE.EstablishmentId = E.Id AND   E.IsDeleted = 0
							           INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
							           INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
										AND ( UE.EstablishmentType = AppUser.EstablishmentType OR LoginUser.IsAreaManager = 1)
							           INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id AND ( U.IsAreaManager = 0 OR U.Id = @AppUserId) AND U.IsDeleted = 0
									   AND AppUser.IsDeleted = 0
							END;


END

    DECLARE @ActionFilter NVARCHAR(MAX);
    SET @ActionFilter = '';
    SELECT @ActionFilter = STUFF(
    (
        SELECT '%'' OR Conversation LIKE ''%' + REPLACE(REPLACE(TemplateText, '''', ''''''), '[', '[[]')
        FROM dbo.CloseLoopTemplate
        WHERE EstablishmentGroupId = @ActivityId
              AND Id IN (
                            SELECT Data FROM dbo.Split(@TemplateId, ',')
                        )
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'),
    1   ,
    26  ,
    ''
                                );
								

    SELECT @ActionFilter
        = ' AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId)   
      FROM dbo.CloseLoopAction   
      WHERE isdeleted = 0   
      And (Conversation LIKE ''%' + @ActionFilter + '%''))';
    /* ---------------------------END------------------------------------ */
    /* ---------------------------PI Filter------------------------------ */

	
    DECLARE @PIFilterTable TABLE
    (
        Id INT IDENTITY(1, 1),
        Comparetype VARCHAR(150)
    );

    DECLARE @CompareType VARCHAR(150);
    DECLARE @Value VARCHAR(150);
    DECLARE @PIFilterNo NVARCHAR(MAX);
    DECLARE @Comparevalue DECIMAL(18, 2);

    SET @Comparevalue = 0.00;

    INSERT INTO @PIFilterTable
    SELECT Data
    FROM dbo.Split(@PIFilter, '$');

    SELECT @CompareType = Comparetype
    FROM @PIFilterTable
    WHERE Id = 1;
    SELECT @Value = Comparetype
    FROM @PIFilterTable
    WHERE Id = 2;

    DECLARE @IsPIOut BIT;
    DECLARE @PIQuestionnaireid BIGINT;

    SELECT @IsPIOut = CASE EstablishmentGroupType
                          WHEN 'Sales' THEN
                              1
                          ELSE
                              0
                      END,
           @PIQuestionnaireid = CASE EstablishmentGroupType
                                    WHEN 'Sales' THEN
                                        SeenClientId
                                    ELSE
                                        QuestionnaireId
                                END
    FROM dbo.EstablishmentGroup;

    IF (@CompareType = 'Average')
    BEGIN
        SET @Comparevalue =
        (
            SELECT dbo.PIBenchmarkCalculationForGraph(
                                                         @ActivityId,
                                                         @FromDate,
                                                         @ToDate,
                                                         @PIQuestionnaireid,
                                                         @IsPIOut,
                                                         @UserId,
                                                         @EstablishmentId,
                                                         0
                                                     )
        );
    END;
    ELSE IF (@CompareType = 'Benchmark')
    BEGIN
        IF (@IsPIOut = 0)
        BEGIN
            SELECT @Comparevalue = FixedBenchMark
            FROM dbo.Questionnaire
            WHERE Id = @PIQuestionnaireid;
        END;

        IF (@IsPIOut = 1)
        BEGIN
            SELECT @Comparevalue = FixedBenchMark
            FROM dbo.SeenClient
            WHERE Id = @PIQuestionnaireid;
        END;
    END;

    IF (@CompareType = 'Range')
    BEGIN
        SET @PIFilterNo = ' And Round(PI,0) ' + @Value + '';
    END;
    ELSE
    BEGIN
        SET @PIFilterNo = ' And Round(PI,0) ' + @Value + ' ' + CONVERT(VARCHAR(150), @Comparevalue) + '';
    END;

    DECLARE @SqlSelect11 VARCHAR(MAX),
            @SqlSelect12 VARCHAR(MAX) = ' ',
            @Filter VARCHAR(MAX) = ' ',
            @FilterCount VARCHAR(MAX) = '',
            @SqlselectCount VARCHAR(MAX) = '';

    DECLARE @AdvanceQuestionId TABLE
    (
        Id INT IDENTITY(1, 1),
        QuestionId BIGINT,
        QuestionTypeId BIGINT
    );

    DECLARE @AdvanceQuestionOperator TABLE
    (
        Id INT IDENTITY(1, 1),
        Operator NVARCHAR(10)
    );

    DECLARE @AdvanceQuestionSearch TABLE
    (
        Id INT IDENTITY(1, 1),
        SEARCH NVARCHAR(MAX)
    );

    DECLARE @S INT,
            @E INT,
            @QuestionId NVARCHAR(10),
            @Operator NVARCHAR(10),
            @SearchText NVARCHAR(MAX),
            @QuestionTypeId BIGINT;
    SET @S = 1;
    IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
    BEGIN
        INSERT INTO @AdvanceQuestionId
        (
            QuestionId
        )
        SELECT Data
        FROM dbo.Split(@QuestionSearch, '$')
        WHERE Id % 3 = 1;

        INSERT INTO @AdvanceQuestionOperator
        (
            Operator
        )
        SELECT Data
        FROM dbo.Split(@QuestionSearch, '$')
        WHERE Id % 3 = 2;

        INSERT INTO @AdvanceQuestionSearch
        (
            Search
        )
        SELECT Data
        FROM dbo.Split(@QuestionSearch, '$')
        WHERE Id % 3 = 0;

        IF @FilterOn = 'In'
        BEGIN
            UPDATE AQ
            SET AQ.QuestionTypeId = Q.QuestionTypeId
            FROM @AdvanceQuestionId AS AQ
                INNER JOIN dbo.Questions AS Q
                    ON Q.Id = AQ.QuestionId;
        END;
        ELSE IF @FilterOn = 'Out'
        BEGIN
            UPDATE AQ
            SET AQ.QuestionTypeId = Q.QuestionTypeId
            FROM @AdvanceQuestionId AS AQ
                INNER JOIN dbo.SeenClientQuestions AS Q
                    ON Q.Id = AQ.QuestionId;
        END;
    END;

    SELECT @E = COUNT(1)
    FROM @AdvanceQuestionId;

	IF EXISTS(SELECT 1 FROM #UserId )
	BEGIN
    SET @SqlselectCount
        = N'SELECT  A.ReportId  
        FROM    dbo.View_AllAnswerMaster AS A    
		INNER JOIN #EstablishmentId e ON A.EstablishmentId = E.id 
		INNER JOIN #USERID AS U ON U.UserId = A.UserId OR U.UserId = ISNULL(A.TransferFromUserId, 0) OR A.UserId = 0 '

END	
ELSE 
BEGIN
     SET @SqlselectCount
        = N'SELECT  A.ReportId  
        FROM    dbo.View_AllAnswerMaster AS A    
		INNER JOIN #EstablishmentId e ON A.EstablishmentId = E.id '
END
  --INNER JOIN (SELECT * FROM dbo.Split(''' --+ @EstablishmentId + ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''
         -- + @EstablishmentId + ''' = ''0''  
		-- +'
 -- INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId
   --       + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR ''' + @UserId
  --        + ''' = ''0'' OR A.UserId = 0 ';

    SET @SqlSelect12 += CHAR(13) +	'	INNER JOIN #EstablishmentId e ON A.EstablishmentId = E.id 
		INNER JOIN #USERID AS U ON U.UserId = A.UserId OR U.UserId = ISNULL(A.TransferFromUserId, 0) OR A.UserId = 0 '

	--+ 'INNER JOIN (SELECT * FROM dbo.Split(''' + @EstablishmentId
 --                       + ''', '','')) AS E ON A.EstablishmentId = E.Data OR ''' + @EstablishmentId
 --                       + ''' = ''0''  
 --      INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId
 --                       + ''', '','')) AS U ON U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''
 --                       + @UserId + ''' = ''0'' OR A.UserId = 0 ';

    IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
    BEGIN
        WHILE @S <= @E
        BEGIN
            SELECT @QuestionId = QuestionId
            FROM @AdvanceQuestionId
            WHERE Id = @S;

            IF @IsOut = 0
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans' + @QuestionId + ' ON Ans' + @QuestionId
                                   + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans' + @QuestionId
                                   + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(Ans' + @QuestionId + '.Detail, ''''), '','') AS OAns'
                                   + @QuestionId;
            END;
            ELSE
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns' + @QuestionId + ' ON SeenAns'
                                   + @QuestionId + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns'
                                   + @QuestionId + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(SeenAns' + @QuestionId
                                   + '.Detail, ''''), '','') AS OSeenAns' + @QuestionId;
            END;
            SET @S += 1;
        END;
    END;

    SET @SqlSelect2 += CHAR(13)
                       + ' LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
                       + CHAR(13)
                       + '  LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';

    SET @Filter += CHAR(13) + ' WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST('''
                   + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy') + ''' AS DATE) AND CAST('''
                   + dbo.ChangeDateFormat(@ToDate, 'dd MMM yyyy') + ''' AS DATE) AND A.ActivityId = '
                   + CONVERT(NVARCHAR(10), @ActivityId);
    SET @FilterCount += CHAR(13) + ' WHERE CAST(A.CreatedOn AS DATE) BETWEEN CAST('''
                        + dbo.ChangeDateFormat(@FromDate, 'dd MMM yyyy') + ''' AS DATE) AND CAST('''
                        + dbo.ChangeDateFormat(@ToDate, 'dd MMM yyyy') + ''' AS DATE) AND A.ActivityId = '
                        + CONVERT(NVARCHAR(10), @ActivityId);

    IF (@ReportId > 0)
    BEGIN
        SET @Filter += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = '
                       + CONVERT(NVARCHAR(10), @ReportId);
        SET @FilterCount += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = '
                            + CONVERT(NVARCHAR(10), @ReportId);
    END;

    IF (@FormStatus = 'Resolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''Resolved''';
        SET @FilterCount += ' AND A.AnswerStatus = ''Resolved''';
    END;
    IF (@FormStatus = 'Unresolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''Unresolved''';
        SET @FilterCount += ' AND A.AnswerStatus = ''Unresolved''';
    END;

    IF (@IsOut = 0)
    BEGIN
        SET @Filter += ' AND A.IsOut = 0 ';
        SET @FilterCount += ' AND A.IsOut = 0 ';
    END;

    IF (@IsOut = 1)
    BEGIN
        SET @Filter += ' AND A.IsOut = 1 ';
        SET @FilterCount += ' AND A.IsOut = 1 ';
    END;

    IF (@SmileyTypesSortby <> '' AND @SmileyTypesSortby IS NOT NULL)
    BEGIN
        SET @Filter += ' AND A.SmileType = ''' + @SmileyTypesSortby + '''';
    END;

    IF (@Search != '')
    BEGIN
        IF (ISNUMERIC(@Search) = 1)
        BEGIN
            DECLARE @OutId BIGINT = 0;
            SELECT @OutId = SeenClientAnswerMasterId
            FROM dbo.AnswerMaster
            WHERE Id = CAST(@Search AS BIGINT);
            IF @OutId = 0
            BEGIN
                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
         OR A.SeenClientAnswerMasterId LIKE ''%' + @Search + '%''  
         OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                               + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                               + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )'   ;
                SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                                    + '%''   
         OR A.SeenClientAnswerMasterId LIKE ''%' + @Search + '%''  
         OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                                    + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                                    + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                    + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                                    + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                                    + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )'   ;
            END;
            ELSE
            BEGIN
                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
         OR A.ReportId = '     + CAST(@OutId AS VARCHAR(50)) + '  
         OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                               + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                               + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )'   ;
                SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                                    + '%''   
         OR A.ReportId = '          + CAST(@OutId AS VARCHAR(50)) + '  
         OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                                    + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                                    + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                    + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                                    + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                                    + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )'   ;
            END;

        END;
        ELSE
        BEGIN
            SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                           + '%''   
           OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                           + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                           + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                           + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                           + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                           + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )';
            SET @FilterCount += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                                + '%''   
           OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                   OR A.EI LIKE ''%' + @Search
                                + '%''  
                                   OR A.UserName LIKE ''%' + @Search
                                + '%''  
                                   OR A.SenderCellNo LIKE ''%' + @Search
                                + '%''  
                                   OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%' + @Search
                                + '%''  
                                   OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                                + '%''  
                                   OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
           )';
        END;
    END;

    IF (@ReadUnread = 'Unread')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 1';
        SET @FilterCount += ' And A.Isoutstanding = 1';
    END;
    ELSE IF (@ReadUnread = 'Read')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 0';
        SET @FilterCount += ' And A.Isoutstanding = 0';
    END;

    IF (@isResend = 'true')
    BEGIN
        SET @Filter += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1';
        SET @FilterCount += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1';
    END;

    IF (@isRecursion = 'true')
    BEGIN
        SET @Filter += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
        SET @FilterCount += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
    END;
    IF (@isAction = 'true')
    BEGIN
        SET @Filter += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WHERE Conversation LIKE ''%'
                       + @ActionSearch + '%'')';
        SET @FilterCount += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WHERE Conversation LIKE ''%'
                            + @ActionSearch + '%'')';
    END;
    ELSE IF (@isAction = 'false')
    BEGIN
        SET @Filter += ' AND A.IsActioned = 0';
        SET @FilterCount += ' AND A.IsActioned = 0';
    END;
    IF (@isTransfer = 'true')
    BEGIN
        SET @Filter += ' AND A.IsTransferred = 1';
        SET @FilterCount += ' AND A.IsTransferred = 1';
    END;
    IF (@FilterOn = 'in')
    BEGIN
        SET @Filter += ' AND A.isOut = 0';
        SET @FilterCount += ' AND A.isOut = 0';
    END;
    ELSE IF (@FilterOn = 'out')
    BEGIN
        SET @Filter += ' AND A.isOut = 1';
        SET @FilterCount += ' AND A.isOut = 1';
    END;

    IF (@TemplateId != '')
    BEGIN
        SET @Filter += @ActionFilter;
        SET @FilterCount += @ActionFilter;
    END;
    IF (@IsEdited = 'true')
    BEGIN
        SET @Filter += ' And A.UpdatedOn IS NOT NULL';
        SET @FilterCount += ' And A.UpdatedOn IS NOT NULL';
    END;

    IF (@PIFilterNo != '')
    BEGIN
        SET @Filter += @PIFilterNo;
        SET @FilterCount += @PIFilterNo;
    END;
    IF (@isFromActivity = 'true')
    BEGIN
        SET @SqlSelect12 += CHAR(13)
                            + 'LEFT OUTER JOIN dbo.View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)';
        SET @Filter += CHAR(13)
                       + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                       + CONVERT(VARCHAR(10), @AppuserId)
                       + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId)  AND ModuleId  IN (7, 8, 11, 12))> 0';
        SET @FilterCount += CHAR(13)
                            + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WHERE IsDeleted = 0 AND AppUserId = '
                            + CONVERT(VARCHAR(10), @AppuserId)
                            + ' AND IsRead = 0 AND (RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId OR RefId = RA.ReportId OR RefId = RA.SeenClientAnswerMasterId)  AND ModuleId  IN (7, 8, 11, 12))> 0';
    END;

    IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
    BEGIN
        SET @S = 1;
        WHILE @S <= @E
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @QuestionTypeId = QuestionTypeId
            FROM @AdvanceQuestionId
            WHERE Id = @S;

            SELECT @Operator = Operator
            FROM @AdvanceQuestionOperator
            WHERE Id = @S;

            SELECT @SearchText = Search
            FROM @AdvanceQuestionSearch
            WHERE Id = @S;

            IF @QuestionTypeId IN ( 1, 2, 19 )
            BEGIN
                SET @Filter += ' AND (' + (CASE @IsOut
                                               WHEN 0 THEN
                                                   'Ans'
                                               ELSE
                                                   'SeenAns'
                                           END
                                          ) + @QuestionId + '.Detail ' + @Operator + ' ' + @SearchText + ' )';
            END;
            ELSE IF @QuestionTypeId IN ( 5, 6, 18, 21 )
            BEGIN
                SET @Filter += 'AND (' + (CASE @IsOut
                                              WHEN 0 THEN
                                                  'OAns'
                                              ELSE
                                                  ' OSeenAns'
                                          END
                                         ) + @QuestionId + '.Data IN ( SELECT Data FROM dbo.Split(''' + @SearchText
                               + ''', '','')) )';
                SET @FilterCount += 'AND (' + (CASE @IsOut
                                                   WHEN 0 THEN
                                                       'OAns'
                                                   ELSE
                                                       ' OSeenAns'
                                               END
                                              ) + @QuestionId + '.Data IN ( SELECT Data FROM dbo.Split('''
                                    + @SearchText + ''', '','')) )';
            END;
            ELSE
            BEGIN
                SET @Filter += ' AND ('',''+' + (CASE @IsOut
                                                     WHEN 0 THEN
                                                         'ISNULL(Ans'
                                                     ELSE
                                                         'ISNULL(SeenAns'
                                                 END
                                                ) + @QuestionId + '.Detail,'' '')+'','' LIKE ''%'
                               + CASE @QuestionTypeId
                                     WHEN 22 THEN
                                         dbo.ChangeDateFormat(@SearchText, 'yyyy-MM-dd HH:MM')
                                     ELSE
                (CASE @SearchText
                     WHEN '' THEN
                         ' '
                     ELSE
                         @SearchText
                 END
                )
                                 END + '%'' )';
                SET @FilterCount += ' AND ('',''+' + (CASE @IsOut
                                                          WHEN 0 THEN
                                                              'ISNULL(Ans'
                                                          ELSE
                                                              'ISNULL(SeenAns'
                                                      END
                                                     ) + @QuestionId + '.Detail,'' '')+'','' LIKE ''%'
                                    + CASE @QuestionTypeId
                                          WHEN 22 THEN
                                              dbo.ChangeDateFormat(@SearchText, 'yyyy-MM-dd HH:MM')
                                          ELSE
                (CASE @SearchText
                     WHEN '' THEN
                         ' '
                     ELSE
                         @SearchText
                 END
                )
                                      END + '%'' )';
            END;

            SET @S += 1;
        END;
    END;


    SET @FilterCount += CHAR(13) + ' GROUP BY A.ReportId ';
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    INSERT INTO @ResultReportId
    EXEC (@SqlselectCount + @SqlSelect2 + @FilterCount);
	 --select (@SqlselectCount + @SqlSelect2 + @FilterCount);
	 --SELECT GETDATE(),2
	 --SELECT * FROM @ResultReportId 
	 --END
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    	IF @IsOut = 0
    BEGIN
        SELECT @URL = KeyValue + 'FeedBack/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;
    ELSE
    BEGIN
        SELECT @URL = KeyValue + 'SeenClient/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;
	
    IF @IsOut = 0
    BEGIN
	PRINT '1' 
        --- ## Feedback Form Data ##';  
        SELECT Q.Position,
               Q.Id AS [QuestionID],
               Am.Id AS [AnswerMasterID],
               ISNULL(E.EstablishmentName, '') AS [Establishment Name],
               ISNULL(U.Name, '') AS [Submitted By],
			   CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn) as date) as [Date Created],
			   CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn)  as time) as [Time Created],
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 'dd-MMM-yyyy hh:mm AM/PM') AS [Capture Date],
               ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
               Am.Id AS [Reference No],
               ISNULL(Am.[PI], 0.00) AS [PI],
               CASE Q.SeenClientQuestionIdRef
                   WHEN NULL THEN
                       CQ.ShortName
                   ELSE
                       --Q.ShortName
                       CASE ISNULL(ANS.RepeatCount, 0)
                           WHEN 0 THEN
                               Q.ShortName
                           ELSE
               ('(' + ISNULL(ANS.RepetitiveGroupName, '') + CAST(ISNULL(ANS.RepeatCount, '') AS VARCHAR(20)) + ')'
                + Q.ShortName
               )
                       END
               END AS [Question],
               CASE Q.QuestionTypeId
                   WHEN 8 THEN
               (CASE
                    WHEN ANS.Detail IS NULL
                         OR ANS.Detail = '' THEN
                        ISNULL(ANS.Detail, '')
                    ELSE
                        dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy')
                END
               )
                   WHEN 9 THEN
               (CASE
                    WHEN ANS.Detail IS NULL
                         OR ANS.Detail = '' THEN
                        ISNULL(ANS.Detail, '')
                    ELSE
                        dbo.ChangeDateFormat(ANS.Detail, 'hh:mm AM/PM')
                END
               )
                   WHEN 22 THEN
               (CASE
                    WHEN ANS.Detail IS NULL
                         OR ANS.Detail = '' THEN
                        ISNULL(ANS.Detail, '')
                    ELSE
                        dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                END
               )
                   WHEN 1 THEN
                       dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0)
                   WHEN 17 THEN
               (CASE
                    WHEN ANS.Detail IS NULL THEN
                        ''
                    ELSE
                        REPLACE(   CASE ANS.Detail
                                       WHEN '' THEN
                                           ''
                                       ELSE
                                           @URL + ANS.Detail
                                   END,
                                   ',',
                                   ' | ' + @URL
                               )
                END
               )
                   ELSE
               (CASE
                    WHEN
                    (
                        ISNULL(ANS.Detail, '') = ''
                        AND Q.SeenClientQuestionIdRef IS NOT NULL
                    ) THEN
                    (
                        SELECT Detail
                        FROM dbo.SeenClientAnswers
                        WHERE QuestionId = Q.SeenClientQuestionIdRef
                              AND ISNULL(SeenClientAnswerMasterId, 0) = ISNULL(Am.SeenClientAnswerMasterId, 0)
                              AND ISNULL(SeenClientAnswerChildId, 0) = ISNULL(Am.SeenClientAnswerChildId, 0)
                    )
                    ELSE
                        ISNULL(ANS.Detail, '')
                END
               )
               END AS [Answer],
               ISNULL(Am.IsResolved, 0) AS [Resolve/Unresolved],
			   ISNULL((Select top 1 DATEADD(MINUTE, E.TimeOffSet,CreatedOn) From CloseLoopAction where SeenClientAnswerMasterId = am.id and "Conversation" LIKE 'Resolved %' order by CreatedOn desc),'') as [Resolved On],
               dbo.ConcateString('ResolutionComments', Am.Id) AS [Resolution Comments],
               ISNULL(Am.IsActioned, 0) AS [Is Actioned],
               ISNULL(Am.IsTransferred, 0) AS [Is Transferred],
               CASE Am.IsTransferred
                   WHEN 1 THEN
                       ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, ''))
                   ELSE
                       ''
               END AS [Transfer From User],
               CASE Am.IsTransferred
                   WHEN 1 THEN
                       ISNULL(U.Name, '')
                   ELSE
                       ''
               END AS [Transfer To User],
               ISNULL(Am.IsDisabled, 0) AS [Disabled]
        FROM dbo.AnswerMaster AS Am
            INNER JOIN @ResultReportId AS RID
                ON Am.Id = RID.ReportId
            INNER JOIN dbo.Establishment AS E
                ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.Questionnaire AS Qr
                ON Qr.Id = Am.QuestionnaireId
            INNER JOIN dbo.Questions AS Q
                ON Q.QuestionnaireId = Qr.Id
            LEFT JOIN dbo.SeenClientQuestions AS CQ
                ON CQ.Id = Q.SeenClientQuestionIdRef
                   AND CQ.IsDeleted = 0
            LEFT JOIN dbo.Answers AS ANS
                ON ANS.AnswerMasterId = Am.Id
                   AND ANS.QuestionId = Q.Id
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.ContactAppUserId = U.Id
            LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM
                ON TransferFromAM.Id = Am.AnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser
                ON TransferFromAM.AppUserId = TransferFromUser.Id
            LEFT OUTER JOIN dbo.AppUser AS TransferByUser
                ON Am.CreatedBy = TransferByUser.Id
        WHERE Am.IsDeleted = 0
              AND Q.IsDeleted = 0
              AND Q.QuestionTypeId NOT IN ( 16, 23 )
              AND Q.IsDisplayInDetail = 1
        ORDER BY
            Am.Id,
            ANS.RepeatCount,
            Q.Position ASC;
    END;
    ELSE
    BEGIN
	PRINT '22'

        DECLARE @SeenClientAnswerMasterId VARCHAR(MAX) = '';

        DECLARE @TempTable TABLE (SeenClientAnswerMasterId INT);
        INSERT INTO @TempTable
        --SELECT Data FROM dbo.Split(@SeenClientAnswerMasterId,',')  
        SELECT ReportId
        FROM @ResultReportId;
		--SELECT * FROM @TempTable
	--SELECT GETDATE(),3
        IF OBJECT_ID('tempdb..#temp', 'u') IS NOT NULL
        BEGIN
            DROP TABLE #temp;
        END;
	        SELECT DISTINCT
            sca.SeenClientAnswerMasterId,
            ISNULL(SeenClientAnswerChildId, 0) AS SeenClientAnswerChildId
        INTO #temp
        FROM dbo.SeenClientAnswers sca
		INNER JOIN @TempTable t ON t.SeenClientAnswerMasterId=sca.SeenClientAnswerMasterId AND ISNULL(sca.SeenClientAnswerChildId, 0) = 0
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT * FROM @TempTable
        --                                  )
        --      AND ISNULL(SeenClientAnswerChildId, 0) = 0;

        IF OBJECT_ID('tempdb..#temp1', 'u') IS NOT NULL
        BEGIN
            DROP TABLE #temp1;
        END;

        SELECT DISTINCT
            sca.SeenClientAnswerMasterId,
            ISNULL(SeenClientAnswerChildId, 0) AS SeenClientAnswerChildId
        INTO #temp1
        FROM dbo.SeenClientAnswers sca
		INNER JOIN @TempTable t ON t.SeenClientAnswerMasterId=sca.SeenClientAnswerMasterId  AND ISNULL(SeenClientAnswerChildId, 0) <> 0
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT * FROM @TempTable
        --                                  )
        --      AND ISNULL(SeenClientAnswerChildId, 0) <> 0;
		

        IF OBJECT_ID('tempdb..#temptable', 'u') IS NOT NULL
        BEGIN
            DROP TABLE #temptable;
        END;

        CREATE TABLE #temptable
        (
            [SeenClientAnswerMasterId] BIGINT,
            [QuestionId] BIGINT,
            [Detail] NVARCHAR(MAX),
            [RepetitiveGroupId] INT,
            [RepeatCount] INT,
            RepetitiveGroupName VARCHAR(100),
            shortName NVARCHAR(2000)
        );
		--SELECT GETDATE(),4
		
        INSERT INTO #temptable

        /* Manage Repeatitive count = 1 and null values*/
	
        SELECT X.SeenClientAnswerMasterId,
               X.QuestionId,
               X.Detail,
               X.RepeatitiveGroupID,
               Y.RepeatCount,
               X.QuestionsGroupName,
               X.shortName
        FROM
        (
             SELECT SeenClientAnswerMasterId,
                   QuestionId,
                   NULL AS Detail,
                   NULL AS RepeatitiveGroupID,
                   NULL AS RepeatCount,
                   xx.shortName,
                   xx.QuestionsGroupName
            FROM
            (
                SELECT SeenClientAnswerMasterId,
                       QuestionId,
                       A.shortName,
                       A.QuestionsGroupName
                FROM
                (
                    SELECT Id AS QuestionId,
                           ShortName,
                           QuestionsGroupName
                    FROM dbo.SeenClientQuestions  WITH(NOLOCK)
                    WHERE SeenClientId = @SeenClientID
                          AND IsDeleted <> 1
                          AND IsRepetitive = 1
                ) A
                    CROSS APPLY
                (SELECT * FROM @TempTable) B
                EXCEPT
                SELECT DISTINCT
                    A.SeenClientAnswerMasterId,
                    QuestionId,
                    B.ShortName,
                    B.QuestionsGroupName
                FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
                    JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                        ON A.QuestionId = B.Id
                           AND B.SeenClientId = @SeenClientID
                           AND B.IsDeleted <> 1
						   AND A.IsDeleted <> 1
                      AND RepeatCount <> 0
					INNER JOIN @TempTable t
					ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
                --WHERE SeenClientAnswerMasterId IN (
                --                                      SELECT SeenClientAnswerMasterId FROM @TempTable
                --                                  )
                --      AND A.IsDeleted <> 1
                --      AND RepeatCount <> 0

            --GROUP BY SeenClientAnswerMasterId,QuestionId  
            ) xx
        --) Xy  
        ) X
            CROSS APPLY
        (
            SELECT DISTINCT
                (ISNULL(RepeatCount, 0)) AS RepeatCount,
                SCA.SeenClientAnswerMasterId
            FROM SeenClientAnswers SCA  WITH(NOLOCK)
			INNER JOIN @TempTable t ON t.SeenClientAnswerMasterId=SCA.SeenClientAnswerMasterId
			AND RepeatCount <> 0
            AND IsDeleted = 0
            --WHERE SeenClientAnswerMasterId IN (
            --                                      SELECT SeenClientAnswerMasterId FROM @TempTable
            --                                  )
            --      AND RepeatCount <> 0
            --      AND IsDeleted = 0
        ) Y
        WHERE X.SeenClientAnswerMasterId = Y.SeenClientAnswerMasterId
		
        --UNION ALL

        /* repeatitive count =1 and child id is 0 or null */
		INSERT INTO #temptable
        SELECT A.SeenClientAnswerMasterId,
               QuestionId,
               Detail,
               A.RepetitiveGroupId,
               A.RepeatCount,
               A.RepetitiveGroupName,
               B.ShortName
        FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
            INNER JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
				   AND A.IsDeleted <> 1
					AND RepeatCount <> 0
			INNER JOIN #temp t ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT SeenClientAnswerMasterId FROM #temp
        --                                  )
        --      AND A.IsDeleted <> 1
        --      AND RepeatCount <> 0
		
        --UNION ALL

        /* repeatitive count =1 and child id is not null and <> 0 */
		INSERT INTO #temptable
        SELECT DISTINCT
            A.SeenClientAnswerMasterId,
            QuestionId,
            Detail,
            A.RepetitiveGroupId,
            A.RepeatCount,
            A.RepetitiveGroupName,
            B.ShortName
        FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
            INNER JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
				   AND A.IsDeleted <> 1
				   AND A.RepeatCount <> 0
		INNER JOIN #temp t ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT SeenClientAnswerMasterId FROM #temp1
        --                                  )
        --      AND A.IsDeleted <> 1
        --      AND A.RepeatCount <> 0
        GROUP BY A.SeenClientAnswerChildId,
                 A.SeenClientAnswerMasterId,
                 QuestionId,
                 Detail,
                 A.RepeatCount,
                 RepetitiveGroupId,
                 A.RepetitiveGroupName,
                 B.ShortName --) a  

			


        --UNION ALL
		INSERT INTO #temptable
        SELECT X.SeenClientAnswerMasterId,
               X.QuestionId,
               X.Detail,
               X.RepeatitiveGroupID,
               Y.RepeatCount,
               X.QuestionsGroupName,
               X.shortName
        FROM
        (
            SELECT SeenClientAnswerMasterId,
                   QuestionId,
                   NULL AS Detail,
                   NULL AS RepeatitiveGroupID,
                   0 AS RepeatCount,
                   xx.shortName,
                   xx.QuestionsGroupName
            FROM
            (
                SELECT SeenClientAnswerMasterId,
                       QuestionId,
                       A.shortName,
                       A.QuestionsGroupName
                FROM
                (
                    SELECT Id AS QuestionId,
                           ShortName,
                           QuestionsGroupName
                    FROM dbo.SeenClientQuestions  WITH(NOLOCK)
                    WHERE SeenClientId = @SeenClientID
                          AND IsDeleted <> 1
                          AND IsRepetitive = 0
                ) A
                    CROSS APPLY
                (SELECT * FROM @TempTable) B
                EXCEPT
                SELECT DISTINCT
                    A.SeenClientAnswerMasterId,
                    QuestionId,
                    B.ShortName,
                    B.QuestionsGroupName
                FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
                    JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                        ON A.QuestionId = B.Id
                           AND B.SeenClientId = @SeenClientID
                           AND B.IsDeleted <> 1
						   AND A.IsDeleted <> 1
						  AND ISNULL(RepeatCount, 0) = 0
					INNER JOIN @TempTable t ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
                --WHERE SeenClientAnswerMasterId IN (
                --                                      SELECT SeenClientAnswerMasterId FROM @TempTable
                --                                  )
                --      AND A.IsDeleted <> 1
                --      AND ISNULL(RepeatCount, 0) = 0
            ) xx
        ) X
            CROSS APPLY
        (
            SELECT DISTINCT
                (ISNULL(RepeatCount, 0)) AS RepeatCount,
                SCA.SeenClientAnswerMasterId
            FROM SeenClientAnswers SCA  WITH(NOLOCK)
			INNER JOIN @TempTable t ON t.SeenClientAnswerMasterId=SCA.SeenClientAnswerMasterId
			AND ISNULL(RepeatCount, 0) = 0 AND IsDeleted = 0
            --WHERE SeenClientAnswerMasterId IN (
            --                                      SELECT SeenClientAnswerMasterId FROM @TempTable
            --                                  )
            --      AND ISNULL(RepeatCount, 0) = 0
            --      AND IsDeleted = 0
        ) Y
        WHERE X.SeenClientAnswerMasterId = Y.SeenClientAnswerMasterId
			 --AA
		 
        --UNION ALL
		INSERT INTO #temptable
        SELECT A.SeenClientAnswerMasterId,
               QuestionId,
               Detail,
               A.RepetitiveGroupId,
               ISNULL(A.RepeatCount, 0),
               A.RepetitiveGroupName,
               B.ShortName
        FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
            INNER JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
				   AND A.IsDeleted <> 1
              AND ISNULL(A.RepeatCount, 0) = 0
			INNER JOIN #temp t ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT SeenClientAnswerMasterId FROM #temp
        --                                  )
        --      AND A.IsDeleted <> 1
        --      AND ISNULL(A.RepeatCount, 0) = 0
		
        --UNION ALL
		INSERT INTO #temptable
        SELECT DISTINCT
            A.SeenClientAnswerMasterId,
            QuestionId,
            Detail,
            A.RepetitiveGroupId,
            ISNULL(A.RepeatCount, 0),
            A.RepetitiveGroupName,
            B.ShortName
        FROM dbo.SeenClientAnswers A  WITH(NOLOCK)
            INNER JOIN dbo.SeenClientQuestions B  WITH(NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
				   AND A.IsDeleted <> 1
					AND ISNULL(A.RepeatCount, 0) = 0
			INNER JOIN #temp1 t ON t.SeenClientAnswerMasterId=A.SeenClientAnswerMasterId
        --WHERE SeenClientAnswerMasterId IN (
        --                                      SELECT SeenClientAnswerMasterId FROM #temp1
        --                                  )
        --      AND A.IsDeleted <> 1
        --      AND ISNULL(A.RepeatCount, 0) = 0
        GROUP BY A.SeenClientAnswerChildId,
                 A.SeenClientAnswerMasterId,
                 QuestionId,
                 Detail,
                 ISNULL(A.RepeatCount, 0),
                 A.RepetitiveGroupId,
                 A.RepetitiveGroupName,
                 B.ShortName;
				 --SELECT GETDATE(),5
				 --SELECT COUNT(1) FROM #temptable t
			

        IF OBJECT_ID('tempdb..#Exporttemptable', 'u') IS NOT NULL
        BEGIN
            DROP TABLE #Exporttemptable;
        END;

        CREATE TABLE #Exporttemptable
        (
            [SeenClientAnswerMasterId] BIGINT,
            [QuestionId] BIGINT,
            [Detail] NVARCHAR(MAX),
            [RepetitiveGroupId] INT,
            [RepeatCount] INT,
            RepetitiveGroupName VARCHAR(MAX),
            shortName NVARCHAR(MAX),
            Question NVARCHAR(MAX)
        );

        INSERT INTO #Exporttemptable
        SELECT SeenClientAnswerMasterId,
               QuestionId,
               Detail,
               RepetitiveGroupId,
               ISNULL(RepeatCount, 0),
               RepetitiveGroupName,
               shortName,
               CASE
                   WHEN RepeatCount <> 0 THEN
                       '(' + ISNULL(RepetitiveGroupName, '') + CAST(ISNULL(RepeatCount, 0) AS VARCHAR(20)) + ')'
                       + shortName
                   ELSE
                       shortName
               END AS Question
        FROM #temptable;
		--SELECT GETDATE(),3
													



        SELECT  [Position],
               [AnswerMasterID],
               [QuestionID],
               [Establishment Name],
               [User Name],
               [Date Created],
			   [Time Created],
			   [Capture Date],
               [Out Reference No],
               [Reference No],
               [PI],
               [Contact Group Name],
               [Question],
               [Answer],
               [Resolve/Unresolved],
			   IsNull([Resolved On], '') as [Resolved On],
               ISNULL([Resolution Comments],'' ) AS [Resolution Comments],
               [Is Actioned],
               [Is Transferred],
               [Transfer From User],
               [Transfer To User],
               [Disabled]
        FROM
        (
            SELECT Q.Position,
                   Am.Id AS AnswerMasterID,
                   Q.Id AS QuestionID,
                   E.EstablishmentName AS [Establishment Name],
                   ISNULL(U.Name, '') AS [User Name],
				      CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn) as date) as [Date Created],
				   CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn)  as time) as [Time Created],
                   --dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 'dd-MMM-yyyy hh:mm AM/PM') AS [Capture Date],
				   REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') +' '+
							STUFF(RIGHT( CONVERT(VARCHAR,DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn),100 ) ,7), 6, 0, ' ')  AS [Capture Date],     
				   ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
                   Am.Id AS [Reference No],
                   ISNULL(Am.[PI], 0.00) AS [PI],
				   ISNULL(ContactGropName,'') AS [Contact Group Name],
					ANS.Question,
                   CASE Q.QuestionTypeId
                       WHEN 8 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy')
							CONVERT(NVARCHAR(50), Format(cast(ANS.Detail as date), 'dd/MMM/yyyy'))
                    END
                   )
                       WHEN 9 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'hh:mm AM/PM')
							CONVERT(NVARCHAR(50), Format(cast(ANS.Detail as Time), 'hh:mm tt'))
                    END
                   )
                       WHEN 22 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy hh:mm AM/PM')
							REPLACE(CONVERT(VARCHAR(11), ANS.Detail, 106), ' ', '/') +' '+
							STUFF(RIGHT( CONVERT(VARCHAR,ANS.Detail,100 ) ,7), 6, 0, ' ')
                    END
                   )
                       WHEN 1 THEN
                           dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0)
                       WHEN 17 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL THEN
                            ''
                        ELSE
                            REPLACE(   CASE ANS.Detail
                                           WHEN '' THEN
                                               ''
                                           ELSE
                                               @URL + ANS.Detail
                                       END,
                                       ',',
                                       ' | ' + @URL
                                   )
                    END
                   )
                       ELSE
                           ISNULL(ANS.Detail, '')
                   END AS [Answer],
                   Am.IsResolved AS [Resolve/Unresolved],
				   (Select top 1 DATEADD(MINUTE, E.TimeOffSet,CreatedOn) From CloseLoopAction where SeenClientAnswerMasterId = am.id and "Conversation" LIKE 'Resolved %' order by CreatedOn desc) as [Resolved On],
                   --dbo.ConcateString('ResolutionCommentsSeenClient', Am.Id) AS [Resolution Comments],	 	
			
			(SELECT STUFF((SELECT  ISNULL(ResolutionComments.Comments,'')  
                                            FROM    ( SELECT  ( CONVERT(VARCHAR(50), ROW_NUMBER() OVER ( ORDER BY dbo.CloseLoopAction.Id ASC ))+ ') '  
                                                              + dbo.AppUser.Name  
                                                              + ' - '  +FORMAT(DATEADD(MINUTE, TimeOffSet,  dbo.CloseLoopAction.CreatedOn),'dd/MMM/yyyy  h:mm tt')
                                                            + ' - '  + REPLACE(REPLACE(ISNULL([Conversation],  ''), CHAR(13),  ' '), CHAR(10),  ' ') )  AS Comments  
                                                      FROM    dbo.CloseLoopAction  WITH(NOLOCK)  
                                                              INNER JOIN dbo.SeenClientAnswerMaster  WITH(NOLOCK) ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId  
                                                              INNER JOIN dbo.AppUser  WITH(NOLOCK) ON CloseLoopAction.AppUserId = dbo.AppUser.Id  
															  WHERE   dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.id
															  									  
                                                      )as  ResolutionComments
                                                    FOR XML PATH('')
                                                    ), 1, 0, '') )  AS [Resolution Comments],	
		                   Am.IsActioned AS [Is Actioned],
                   Am.IsTransferred AS [Is Transferred],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, ''))
                       ELSE
                           ''
                   END AS [Transfer From User],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(U.Name, '')
                       ELSE
                           ''
                   END AS [Transfer To User],
                   ISNULL(Am.IsDisabled, 0) AS [Disabled],
                   ISNULL(ANS.RepetitiveGroupId, 0) AS RepetitiveGroupId,
                   ISNULL(ANS.RepeatCount, 0) AS RepeatCount
            FROM dbo.SeenClientAnswerMaster AS Am  WITH(NOLOCK)
                INNER JOIN @ResultReportId AS RID
                    ON Am.Id = RID.ReportId
					 AND Am.IsDeleted = 0
                INNER JOIN dbo.Establishment AS E  WITH(NOLOCK)
                    ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.SeenClient AS Qr  WITH(NOLOCK)
                    ON Qr.Id = Am.SeenClientId
                INNER JOIN dbo.SeenClientQuestions AS Q  WITH(NOLOCK)
                    ON Q.SeenClientId = Am.SeenClientId
                  AND Q.IsDeleted = 0
                  AND Q.QuestionTypeId NOT IN ( 16, 23 )
                  AND Q.IsDisplayInDetail = 1
                  AND ISNULL(Q.QuestionsGroupNo, 0) = 0
                  AND Q.IsActive = 1
                  AND Q.ContactQuestionId IS NULL				  		   
                LEFT JOIN dbo.ContactQuestions AS CQ  WITH(NOLOCK)
                    ON CQ.Id = Q.ContactQuestionId
                       AND CQ.IsDeleted = 0
                LEFT JOIN #Exporttemptable AS ANS
                    ON ANS.SeenClientAnswerMasterId = Am.Id
                       AND ANS.QuestionId = Q.Id
                LEFT OUTER JOIN dbo.AppUser AS U  WITH(NOLOCK)
                    ON Am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM  WITH(NOLOCK)
                    ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
                LEFT OUTER JOIN dbo.AppUser AS TransferFromUser  WITH(NOLOCK)
                    ON TransferFromAM.AppUserId = TransferFromUser.Id
                LEFT OUTER JOIN dbo.AppUser AS TransferByUser  WITH(NOLOCK)
                    ON Am.CreatedBy = TransferByUser.Id
				Left JOIN dbo.ContactGroup cg
				ON Am.ContactGroupId=cg.id --AND Am.Id = Am.Id
                       UNION ALL
            SELECT Q.Position,
                   Am.Id AS AnswerMasterID,
                   Q.Id AS QuestionID,
                   E.EstablishmentName AS [Establishment Name],
                   ISNULL(U.Name, '') AS [User Name],
				      CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn) as date) as [Date Created],
				   CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn)  as time) as [Time Created],
                   --dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 'dd-MMM-yyyy hh:mm AM/PM') AS [Capture Date],
				   REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') +' '+
							STUFF(RIGHT( CONVERT(VARCHAR,DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn),100 ) ,7), 6, 0, ' ')  AS [Capture Date],
				   ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
                   Am.Id AS [Reference No],
                   ISNULL(Am.[PI], 0.00) AS [PI],
				   ISNULL(ContactGropName,'') AS [Contact Group Name],
                   ANS.Question,
                   (CASE
                        WHEN ANS.Detail IS NULL THEN
                            ISNULL(dbo.GetContactDetailsForGroupFeedback(Am.Id, CQ.Id), '')
                        ELSE
                            ANS.Detail
                    END
                   ) AS [Answer],
                   Am.IsResolved AS [Resolve/Unresolved],
				   (Select top 1 DATEADD(MINUTE, E.TimeOffSet,CreatedOn) From CloseLoopAction where SeenClientAnswerMasterId = am.id and "Conversation" LIKE 'Resolved %' order by CreatedOn desc) as [Resolved On],
					(SELECT STUFF((SELECT  ISNULL(ResolutionComments.Comments,'')  
                                            FROM    ( SELECT  ( CONVERT(NVARCHAR(50), ROW_NUMBER() OVER ( ORDER BY dbo.CloseLoopAction.Id ASC ))+ ') '  
                                                              + dbo.AppUser.Name  
                                                              + ' - '  +FORMAT(DATEADD(MINUTE, TimeOffSet,  dbo.CloseLoopAction.CreatedOn),'dd/MMM/yyyy  h:mm tt')
                                                            + ' - '  + REPLACE(REPLACE(ISNULL([Conversation],  ''), CHAR(13),  ' '), CHAR(10),  ' ') )  AS Comments  
                                                      FROM    dbo.CloseLoopAction  WITH(NOLOCK)  
                                                              INNER JOIN dbo.SeenClientAnswerMaster  WITH(NOLOCK) ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId  
                                                              INNER JOIN dbo.AppUser  WITH(NOLOCK) ON CloseLoopAction.AppUserId = dbo.AppUser.Id  
															  WHERE   dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.id
															  
                                                      )as  ResolutionComments
                                                    FOR XML PATH('')
                                                    ), 1, 0, '') )  AS [Resolution Comments],
                   Am.IsActioned AS [Is Actioned],
                   Am.IsTransferred AS [Is Transferred],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, ''))
                       ELSE
                           ''
                   END AS [Transfer From User],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(U.Name, '')
                       ELSE
                           ''
                   END AS [Transfer To User],
                   ISNULL(Am.IsDisabled, 0) AS [Disabled],
                   ISNULL(ANS.RepetitiveGroupId, 0) AS RepetitiveGroupId,
                   ISNULL(ANS.RepeatCount, 0) AS RepeatCount
            FROM dbo.SeenClientAnswerMaster AS Am  WITH(NOLOCK)
                INNER JOIN @ResultReportId AS RID
                    ON Am.Id = RID.ReportId AND Am.IsDeleted = 0
                INNER JOIN dbo.Establishment AS E  WITH(NOLOCK)
                    ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.SeenClient AS Qr  WITH(NOLOCK)
                    ON Qr.Id = Am.SeenClientId
                INNER JOIN dbo.SeenClientQuestions AS Q  WITH(NOLOCK)
                    ON Q.SeenClientId = Am.SeenClientId
					AND Q.IsDeleted = 0
					AND Q.QuestionTypeId NOT IN ( 16, 23 )
					AND Q.IsDisplayInDetail = 1
					AND ISNULL(Q.QuestionsGroupNo, 0) = 0
					AND Q.IsActive = 1
					AND Q.ContactQuestionId IS NOT NULL
                LEFT JOIN dbo.ContactQuestions AS CQ  WITH(NOLOCK)
                    ON CQ.Id = Q.ContactQuestionId
                       AND CQ.IsDeleted = 0
                LEFT JOIN #Exporttemptable AS ANS
                    ON ANS.SeenClientAnswerMasterId = Am.Id
                       AND ANS.QuestionId = Q.Id
                LEFT OUTER JOIN dbo.AppUser AS U  WITH(NOLOCK)
                    ON Am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM  WITH(NOLOCK)
                    ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
                LEFT OUTER JOIN dbo.AppUser AS TransferFromUser  WITH(NOLOCK)
                    ON TransferFromAM.AppUserId = TransferFromUser.Id
                LEFT OUTER JOIN dbo.AppUser AS TransferByUser  WITH(NOLOCK)
                    ON Am.CreatedBy = TransferByUser.Id
				Left JOIN dbo.ContactGroup cg
				ON Am.ContactGroupId=cg.id --AND Am.Id = Am.Id
            UNION ALL
            SELECT Q.Position,
                   Am.Id AS AnswerMasterID,
                   Q.Id AS QuestionID,
                   E.EstablishmentName AS [Establishment Name],
                   ISNULL(U.Name, '') AS [User Name],
				        CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn) as date) as [Date Created],
				   CAST(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn)  as time) as [Time Created],
                   REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') +' '+
							STUFF(RIGHT( CONVERT(VARCHAR,DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn),100 ) ,7), 6, 0, ' ')  AS [Capture Date],
              
				   ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
                   Am.Id AS [Reference No],
                   ISNULL(Am.[PI], 0.00) AS [PI],
				   ISNULL(ContactGropName,'') AS [Contact Group Name],
                   ANS.Question,
                   CASE Q.QuestionTypeId
                       WHEN 8 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy')
							CONVERT(NVARCHAR(50), Format(cast(ANS.Detail as date), 'dd/MMM/yyyy'))
                    END
                   )
                       WHEN 9 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'hh:mm AM/PM')
							CONVERT(NVARCHAR(50), Format(cast(ANS.Detail as Time), 'hh:mm tt'))
                    END
                   )
                       WHEN 22 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL
                             OR ANS.Detail = '' THEN
                            ISNULL(ANS.Detail, '')
                        ELSE
                            --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy hh:mm AM/PM')
							REPLACE(CONVERT(VARCHAR(11), ANS.Detail, 106), ' ', '/') +' '+
							STUFF(RIGHT( CONVERT(VARCHAR,ANS.Detail,100 ) ,7), 6, 0, ' ')
                    END
                   )
                       WHEN 1 THEN
                           dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0)
                       WHEN 17 THEN
                   (CASE
                        WHEN ANS.Detail IS NULL THEN
                            ''
                        ELSE
                            REPLACE(   CASE ANS.Detail
                                           WHEN '' THEN
                                               ''
                                           ELSE
                                               @URL + ANS.Detail
                                       END,
                                       ',',
                                       ' | ' + @URL
                                   )
                    END
                   )
                       ELSE
                           ISNULL(ANS.Detail, '')
                   END AS [Answer],
                   Am.IsResolved AS [Resolve/Unresolved],
				   (Select top 1 DATEADD(MINUTE, E.TimeOffSet,CreatedOn) From CloseLoopAction where SeenClientAnswerMasterId = am.id and "Conversation" LIKE 'Resolved %' order by CreatedOn desc) as [Resolved On],
   							(SELECT STUFF((SELECT  ISNULL(ResolutionComments.Comments,'')  
                                            FROM    ( SELECT  ( CONVERT(NVARCHAR(50), ROW_NUMBER() OVER ( ORDER BY dbo.CloseLoopAction.Id ASC ))+ ') '  
                                                              + dbo.AppUser.Name  
                                                              + ' - '  +FORMAT(DATEADD(MINUTE, TimeOffSet,  dbo.CloseLoopAction.CreatedOn),'dd/MMM/yyyy  h:mm tt')
                                                            + ' - '  + REPLACE(REPLACE(ISNULL([Conversation],  ''), CHAR(13),  ' '), CHAR(10),  ' ') )   AS Comments  
                                                      FROM    dbo.CloseLoopAction  WITH(NOLOCK)  
                                                              INNER JOIN dbo.SeenClientAnswerMaster  WITH(NOLOCK) ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId  
                                                              INNER JOIN dbo.AppUser  WITH(NOLOCK) ON CloseLoopAction.AppUserId = dbo.AppUser.Id  
															  WHERE   dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.id
															  
															  
                                                      )as  ResolutionComments
                                                    FOR XML PATH('')
                                                    ), 1, 0, ''))  AS [Resolution Comments],
                   Am.IsActioned AS [Is Actioned],
                   Am.IsTransferred AS [Is Transferred],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, ''))
                       ELSE
                           ''
                   END AS [Transfer From User],
                   CASE Am.IsTransferred
                       WHEN 1 THEN
                           ISNULL(U.Name, '')
                       ELSE
                           ''
                   END AS [Transfer To User],
                   ISNULL(Am.IsDisabled, 0) AS [Disabled],
                   ISNULL(ANS.RepetitiveGroupId, 0) AS RepetitiveGroupId,
                   ISNULL(ANS.RepeatCount, 0) AS RepeatCount
            FROM dbo.SeenClientAnswerMaster AS Am  WITH(NOLOCK)
                INNER JOIN @ResultReportId AS RID
                    ON Am.Id = RID.ReportId AND Am.IsDeleted = 0
                INNER JOIN dbo.Establishment AS E  WITH(NOLOCK)
                    ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.SeenClient AS Qr  WITH(NOLOCK)
                    ON Qr.Id = Am.SeenClientId
                INNER JOIN dbo.SeenClientQuestions AS Q  WITH(NOLOCK)
                    ON Q.SeenClientId = Am.SeenClientId
					AND Q.IsDeleted = 0
					AND Q.QuestionTypeId NOT IN ( 16, 23 )
					AND Q.IsDisplayInDetail = 1
					AND ISNULL(Q.QuestionsGroupNo, 0) > 0
					AND Q.IsActive = 1
                LEFT JOIN dbo.ContactQuestions AS CQ  WITH(NOLOCK)
                    ON CQ.Id = Q.ContactQuestionId
                       AND CQ.IsDeleted = 0
                LEFT JOIN #Exporttemptable AS ANS
                    ON ANS.SeenClientAnswerMasterId = Am.Id
                       AND ANS.QuestionId = Q.Id
                LEFT OUTER JOIN dbo.AppUser AS U  WITH(NOLOCK)
                    ON Am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM  WITH(NOLOCK)
                    ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
                LEFT OUTER JOIN dbo.AppUser AS TransferFromUser  WITH(NOLOCK)
                    ON TransferFromAM.AppUserId = TransferFromUser.Id
                LEFT OUTER JOIN dbo.AppUser AS TransferByUser  WITH(NOLOCK)
                    ON Am.CreatedBy = TransferByUser.Id
				Left JOIN dbo.ContactGroup cg
				ON Am.ContactGroupId=cg.id --AND Am.Id = Am.Id
        ) AS TM
        WHERE TM.Question IS NOT NULL 
        ORDER BY 
            TM.RepeatCount,
            TM.Position
			--SELECT GETDATE(),3	
		
		
    END;
---- For EXECUTE SQL Query.  
--SELECT (@SqlSelect1 + @SqlSelect2 + @SqlSelect3 + @FilterOn + @SearchQuery + @SqlSelect4 + @SqlSelect5 + @SqlSelect6  + @FilterOn + @SearchQuery +  @SqlSelect7 + @SqlSelect8 + @SqlSelect9 +@FilterOn + @SearchQuery +  'ORDER BY Am.Id, Q.Position ASC') AS QU  
--EXECUTE (@SqlSelect1 + @SqlSelect2 + @SqlSelect3 + @SearchQuery + @SqlSelect4 + @SqlSelect5 + @SqlSelect6  + @SearchQuery +  @SqlSelect7 + @SqlSelect8 + @SqlSelect9 + @SearchQuery +  'ORDER BY Am.Id, Q.Position ASC');  
--SELECT GETDATE(),3
END;




/****** Object:  StoredProcedure [dbo].[ExportFeedbackDataWeb_Repeatetive]    Script Date: 2020/09/03 20:14:16 ******/
SET ANSI_NULLS ON
