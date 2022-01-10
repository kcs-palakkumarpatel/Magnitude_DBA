CREATE PROCEDURE [dbo].[ExportFeedbackDataWeb_Repeatetive_Filter]
(
        @EstablishmentId VARCHAR(MAX),
        @UserId VARCHAR(MAX),
        @ActivityId BIGINT,
		@StatusId VARCHAR(MAX) ='0', 
        @Rows INT,
        @Page INT,
        @SmileyTypesSortby NVARCHAR(50), /* ----- 1 strstatustype */
        @FromDate DATETIME,
        @ToDate DATETIME,
        @FilterOn NVARCHAR(50),          /* For Question Search FormType (In Or OUt) */
        @QuestionSearch NVARCHAR(MAX),   /* For $ seprater String. */
        @AppuserId INT,
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
        @isFromActivity VARCHAR(5) = '',
        @isResponseLink VARCHAR(5) = '',
        @ResponseType VARCHAR(15) = '',
        @isFlag VARCHAR(5),
        @PIFormTypeValue VARCHAR(15) = 'false'
)
AS
BEGIN

--SET @EstablishmentId = '0'; -- varchar(max)
--SET @UserId = '0'; -- varchar(max)
--SET @ActivityId = 7151; -- bigint
--SET @Rows = 0; -- int
--SET @Page = 1; -- int
--SET @SmileyTypesSortby = N''; -- nvarchar(50)
--SET @FromDate = '2020-09-16 00:00:00'; -- datetime
--SET @ToDate = '2021-09-16 23:59:59'; -- datetime
--SET @FilterOn = N'1'; -- nvarchar(50)
--SET @QuestionSearch = N''; -- nvarchar(max)
--SET @AppuserId = 6994; -- int
--SET @ReportId = 0; -- int
--SET @FormType = 'All'; -- varchar(10)
--SET @FormStatus = 'Unresolved'; -- varchar(10)
--SET @ReadUnread = ''; -- varchar(10)
--SET @isResend = ''; -- varchar(5)
--SET @isRecursion = ''; -- varchar(5)
--SET @isAction = ''; -- varchar(5)
--SET @ActionSearch = ''; -- varchar(50)
--SET @isTransfer = ''; -- varchar(5)
--SET @TemplateId = ''; -- varchar(1000)
--SET @PIFilter = ''; -- varchar(50)
--SET @IsEdited = ''; -- varchar(5)
--SET @Search = ''; -- varchar(1000)
--SET @OrderBy = ''; -- varchar(200)
--SET @isFromActivity = ''; -- varchar(5)
--SET @isResponseLink = '';
--SET @ResponseType = 'All';
--SET @isFlag = '';
--SET @PIFormTypeValue = 'false';

DECLARE @ResultReportId TABLE
(
    ReportId BIGINT,
    FromType VARCHAR(MAX),
    IsOut BIT,
    CreatedOn DATETIME
);
DECLARE @ResultReportIdJoin TABLE
(
    ReportId BIGINT,
    RepetativeCount INT
);
DECLARE @URLImage VARCHAR(2000) = '';
DECLARE @ActivityType1 NVARCHAR(50),
        @SeenClientID BIGINT;
SELECT @ActivityType1 = EstablishmentGroupType,
       @SeenClientID = SeenClientId
FROM dbo.EstablishmentGroup
WHERE Id = @ActivityId;

IF (@PIFormTypeValue = 'true' AND @PIFilter = '')
BEGIN
    SET @PIFormTypeValue = 'false';
END;
IF (@Search != '')
BEGIN
    SET @FormType = 'All'; -- varchar(10)
END;
IF (@FormStatus = '')
BEGIN
    SET @FormStatus = 'All';
END;
IF (@ResponseType = 'NotResponded')
BEGIN
    SET @FormType = '';
END;
IF OBJECT_ID('tempdb..#temp', 'u') IS NOT NULL
    DROP TABLE #temp;
CREATE TABLE #temp ([SeenClientAnswerMasterId] [BIGINT] NOT NULL);
IF OBJECT_ID('tempdb..#UserId', 'U') IS NOT NULL
    DROP TABLE #UserId;
CREATE TABLE #UserId (UserId VARCHAR(MAX));
IF OBJECT_ID('tempdb..#ActionFilterId', 'u') IS NOT NULL
    DROP TABLE #ActionFilterId;
CREATE TABLE #ActionFilterId (Id BIGINT);
IF OBJECT_ID('tempdb..#PIFilterTable', 'U') IS NOT NULL
    DROP TABLE #PIFilterTable;
CREATE TABLE #PIFilterTable
(
    Id INT IDENTITY(1, 1),
    Comparetype VARCHAR(150)
);
IF OBJECT_ID('tempdb..#sp_PIBenchmarkCalculationForGraph', 'U') IS NOT NULL
    DROP TABLE #sp_PIBenchmarkCalculationForGraph;
CREATE TABLE #sp_PIBenchmarkCalculationForGraph (Comparevalue NVARCHAR(MAX));

IF OBJECT_ID('tempdb..#AdvanceQuestionId', 'U') IS NOT NULL
    DROP TABLE #AdvanceQuestionId;

CREATE TABLE #AdvanceQuestionId
(
    Id INT IDENTITY(1, 1),
    QuestionId BIGINT,
    QuestionTypeId BIGINT
);

IF OBJECT_ID('tempdb..#AdvanceQuestionOperator', 'U') IS NOT NULL
    DROP TABLE #AdvanceQuestionOperator;
CREATE TABLE #AdvanceQuestionOperator
(
    Id INT IDENTITY(1, 1),
    Operator NVARCHAR(10)
);

IF OBJECT_ID('tempdb..#AdvanceQuestionSearch', 'U') IS NOT NULL
    DROP TABLE #AdvanceQuestionSearch;
CREATE TABLE #AdvanceQuestionSearch
(
    Id INT IDENTITY(1, 1),
    SEARCH NVARCHAR(MAX)
);
IF OBJECT_ID('tempdb..#StatusId', 'U') IS NOT NULL  
	DROP TABLE #StatusId  
CREATE TABLE #StatusId (StatusId VARCHAR(MAX))  
 
 IF (@StatusId<>'0')  
BEGIN  
 INSERT INTO #StatusId 
 SELECT Data FROM dbo.Split(@StatusId,',')  
END 
IF OBJECT_ID('tempdb..#temptable', 'U') IS NOT NULL
    DROP TABLE #temptable;

CREATE TABLE #temptable
(
    [Id] BIGINT,
    [ReportId] BIGINT,
    [EstablishmentId] BIGINT,
    [EstablishmentName] NVARCHAR(MAX),
    [AppUserId] BIGINT,
    [UserName] NVARCHAR(MAX),
    [SenderCellNo] NVARCHAR(MAX),
    [IsOutStanding] BIT,
    [AnswerStatus] NVARCHAR(MAX),
    [TimeOffSet] INT,
    [CreatedOn] DATETIME,
    [UpdatedOn] NVARCHAR(MAX),
    [PI] DECIMAL(18, 2),
    [SmileType] NVARCHAR(MAX),
    [QuestionnaireType] NVARCHAR(MAX),
    [FormType] VARCHAR(MAX),
    [IsOut] BIT,
    [QuestionnaireId] BIGINT,
    [ReadBy] BIGINT,
    [ContactMasterId] BIGINT,
    [Latitude] NVARCHAR(MAX),
    [Longitude] NVARCHAR(MAX),
    [IsTransferred] BIT,
    [TransferToUser] NVARCHAR(MAX),
    [TransferFromUser] NVARCHAR(MAX),
    [SeenClientAnswerMasterId] BIGINT,
    [ActivityId] BIGINT,
    [IsActioned] BIT,
    [TransferByUserId] BIGINT,
    [TransferFromUserId] BIGINT,
    [DisplayText] NVARCHAR(MAX),
    [ContactDetails] NVARCHAR(MAX),
    [CaptureDate] NVARCHAR(MAX),
    [IsDisabled] BIT,
    [ContactGroupName] NVARCHAR(MAX),
    [IsResend] BIT,
    [CreatedUserId] BIGINT,
    [UnreadAction] INT,
    [AlertUnreadCountCount] INT,
    [IsRecursion] INT,
    [MobiLink] VARCHAR(MAX),
    [GroupType] VARCHAR(MAX),
    [ActionDate] DATETIME,
    [ActionDateEveryone] DATETIME,
    [ActionTo] INT,
    [FormColor] VARCHAR(MAX),
    [ContactData] NVARCHAR(MAX),
    [LastChat] VARCHAR(MAX),
    [LastChatBy] NVARCHAR(MAX),
    [IsFlag] BIT,
    [StatusId] BIGINT,
    [StatusName] NVARCHAR(100),
    [StatusImage] NVARCHAR(100),
    [StatusTime] NVARCHAR(100),
    [StatusCounter] NVARCHAR(100)
);

IF OBJECT_ID('tempdb..#View_AllAnswerMaster', 'U') IS NOT NULL
    DROP TABLE #View_AllAnswerMaster;

CREATE TABLE #View_AllAnswerMaster
(
    [ReportId] BIGINT,
    [EstablishmentId] BIGINT,
    [EstablishmentName] NVARCHAR(500),
    [UserId] BIGINT,
    [UserName] NVARCHAR(100),
    [SenderCellNo] NVARCHAR(50),
    [IsOutStanding] BIT,
    [AnswerStatus] NVARCHAR(10),
    [TimeOffSet] INT,
    [CreatedOn] DATETIME,
    [UpdatedOn] DATETIME,
    [EI] DECIMAL(18, 2),
    [PI] DECIMAL(18, 2),
    [SmileType] NVARCHAR(20),
    [QuestionnaireType] NVARCHAR(10),
    [FormType] VARCHAR(10),
    [IsOut] BIT,
    [QuestionnaireId] BIGINT,
    [ReadBy] BIGINT,
    [ContactMasterId] BIGINT,
    [ContactGroupId] BIGINT,
    [Latitude] NVARCHAR(50),
    [Longitude] NVARCHAR(50),
    [IsTransferred] BIT,
    [TransferToUser] NVARCHAR(100),
    [TransferFromUser] NVARCHAR(100),
    [SeenClientAnswerMasterId] BIGINT,
    [ActivityId] BIGINT,
    [IsActioned] BIT,
    [TransferByUserId] BIGINT,
    [TransferFromUserId] BIGINT,
    [IsDisabled] BIT,
    [CreatedUserId] BIGINT,
    [IsFlag1] BIT,
    [StatusId] BIGINT,
    [StatusName] NVARCHAR(100),
    [StatusImage] NVARCHAR(100),
    [StatusTime] NVARCHAR(100),
    [StatusCounter] NVARCHAR(100),
    ContactMasterId1 BIGINT,
    ID BIGINT,
    Quesummary VARCHAR(20)
);

IF OBJECT_ID('tempdb..#EstablishmentId', 'U') IS NOT NULL
    DROP TABLE #EstablishmentId;
CREATE TABLE #EstablishmentId (id BIGINT);

DECLARE @var VARCHAR(MAX);
DECLARE @OutId BIGINT = 0;
DECLARE @ActivityType NVARCHAR(50);
DECLARE @Url VARCHAR(50);
DECLARE @GroupType INT;
DECLARE @groupid NVARCHAR(MAX);
DECLARE @a NVARCHAR(MAX);
DECLARE @IsOut BIT;
DECLARE @ActionFilter NVARCHAR(MAX) = '';
DECLARE @CompareType VARCHAR(150);
DECLARE @Value VARCHAR(150);
DECLARE @PIFilterNo NVARCHAR(MAX);
DECLARE @Comparevalue DECIMAL(18, 2) = 0.00;
DECLARE @IsPIOut BIT;
DECLARE @PIQuestionnaireid BIGINT;
DECLARE @SqlSelect1 VARCHAR(MAX) = '';
DECLARE @SqlSelect11 VARCHAR(MAX) = '';
DECLARE @sqlSelect11_1 VARCHAR(MAX) = '';
DECLARE @SqlSelect12 VARCHAR(MAX) = '';
DECLARE @SqlSelect2 VARCHAR(MAX) = '';
DECLARE @SqlSelect3 VARCHAR(MAX) = '';
DECLARE @Filter VARCHAR(MAX) = '';
DECLARE @S INT = 1;
DECLARE @E INT;
DECLARE @QuestionId NVARCHAR(10);
DECLARE @Operator NVARCHAR(10);
DECLARE @SearchText NVARCHAR(MAX);
DECLARE @QuestionTypeId BIGINT;
DECLARE @PIDispaly VARCHAR(5) = '0';
DECLARE @PIDisplayIn VARCHAR(5) = '0';
DECLARE @OrderBYFilter NVARCHAR(MAX) = '';
DECLARE @SqlselectCount NVARCHAR(MAX) = '';
DECLARE @groupby NVARCHAR(MAX) = '';
DECLARE @groupby1 NVARCHAR(MAX) = '';


SELECT @ActivityType = EstablishmentGroupType
FROM dbo.EstablishmentGroup WITH (NOLOCK)
WHERE Id = @ActivityId;

SELECT @Url = KeyValue
FROM dbo.AAAAConfigSettings WITH (NOLOCK)
WHERE KeyName = 'FeedbackUrl';

SELECT @groupid = KeyValue
FROM dbo.AAAAConfigSettings WITH (NOLOCK)
WHERE KeyName = 'ExcludeGroupId';

IF OBJECT_ID('tempdb..#GroupId', 'u') IS NOT NULL
    DROP TABLE #GroupId;
CREATE TABLE #GroupId (id BIGINT);

SELECT @GroupType = au.Id
FROM dbo.AppUser au
    INNER JOIN #GroupId G
        ON G.id = au.GroupId
           AND au.Id = @ActivityId;

DECLARE @OrderBy1 VARCHAR(1000);

DECLARE @order VARCHAR(100);
IF (@OrderBy = 'LastChat')
    SET @order = ' ORDER BY ActionDate DESC';
IF (@OrderBy = 'LastChatAll')
    SET @order = ' ORDER BY ActionDateEveryone DESC';
IF (@OrderBy = 'LastForm')
    SET @order = '  ORDER BY CreatedOn DESC';
IF (@OrderBy = 'ResponseForm')
    SET @order = 'ORDER BY MobiLink DESC';
IF (@OrderBy = '' OR @OrderBy IS NULL)
    SET @order = '  ORDER BY CreatedOn DESC';

IF (@OrderBy = 'LastChat')
    SET @OrderBy1
        = ' ORDER BY DATEADD(   MINUTE,A.TimeOffSet,(SELECT TOP 1 CreatedOn FROM dbo.PendingNotificationWeb WITH (NOLOCK) WHERE IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 )  
AND ISNULL(AppUserId, 0) = ' + CONVERT(VARCHAR(10), @AppuserId) + ' ORDER BY CreatedOn DESC ) ) DESC';
IF (@OrderBy = 'LastChatAll')
    SET @OrderBy1
        = ' Order By DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM      dbo.PendingNotificationWeb with (NOlOCK) WHERE  
     IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 ) ORDER BY  CreatedOn DESC ))DESC ';
IF (@OrderBy = 'ResponseForm')
    SET @OrderBy1
        = 'ORDER BY dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10), @AppuserId)
          + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END)  DESC';
IF (@OrderBy = '' OR @OrderBy IS NULL)
    SET @OrderBy1 = '  ORDER BY A.CreatedOn DESC';
IF (@OrderBy = 'LastForm')
    SET @OrderBy1 = '  ORDER BY A.CreatedOn DESC';

IF (@OrderBy = 'LastChat')
    SET @OrderBy = ' ORDER BY ActionDate DESC';
IF (@OrderBy = 'LastChatAll')
    SET @OrderBy = ' ORDER BY ActionDateEveryone DESC';
IF (@OrderBy = 'LastForm')
    SET @OrderBy = '  ORDER BY A.CreatedOn DESC';
IF (@OrderBy = 'ResponseForm')
    SET @OrderBy = 'ORDER BY MobiLink DESC';
IF (@OrderBy = '' OR @OrderBy IS NULL)
    SET @OrderBy = '  ORDER BY A.CreatedOn DESC';
IF @QuestionSearch IS NULL
    SET @QuestionSearch = '';
IF @UserId IS NULL
    SET @UserId = '0';
IF (@FormType = 'Out')
    SET @IsOut = 1;
IF (@FormType = 'In')
    SET @IsOut = 0;
IF (@FormType = 'All' AND @PIFormTypeValue = 'false')
    SET @IsOut = 1;
IF (@EstablishmentId = '0')
BEGIN
    INSERT INTO #EstablishmentId
    SELECT EST.Id
    FROM dbo.Establishment AS EST WITH (NOLOCK)
        INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
            ON EST.EstablishmentGroupId = @ActivityId
               AND AppUserEstablishment.AppUserId = @AppuserId
               AND AppUserEstablishment.EstablishmentId = EST.Id
               AND AppUserEstablishment.IsDeleted = 0;
END;
ELSE
BEGIN
    INSERT INTO #EstablishmentId
    SELECT Data
    FROM dbo.Split(@EstablishmentId, ',');
END;

INSERT INTO #View_AllAnswerMaster
SELECT ReportId,
       EstablishmentId,
       EstablishmentName,
       UserId,
       UserName,
       SenderCellNo,
       IsOutStanding,
       AnswerStatus,
       TimeOffSet,
       CreatedOn,
       UpdatedOn,
       EI,
       PI,
       SmileType,
       QuestionnaireType,
       FormType,
       IsOut,
       QuestionnaireId,
       ReadBy,
       ContactMasterId,
       ContactGroupId,
       Latitude,
       Longitude,
       IsTransferred,
       TransferToUser,
       TransferFromUser,
       SeenClientAnswerMasterId,
       ActivityId,
       IsActioned,
       TransferByUserId,
       TransferFromUserId,
       IsDisabled,
       CreatedUserId,
       IsFlag1,
       StatusId,
       StatusName,
       StatusImage,
       StatusTime,
       StatusCounter,
       IIF(ContactMasterId = 0, ContactGroupId, ContactMasterId),
       IIF(ISNULL(SeenClientAnswerMasterId, 0) = 0, ReportId, SeenClientAnswerMasterId),
       CASE IsOut
           WHEN 0 THEN
               'Answers'
           ELSE
               'SeenClientAnswers'
       END AS Quesummary
FROM View_AllAnswerMaster (NOLOCK)
WHERE ActivityId = @ActivityId AND ISNULL(IsUnAllocated,0) = 0
      AND CAST(CreatedOn AS DATE)
      BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
	  AND( AnswerStatus = @FormStatus OR @FormStatus = 'All')
	AND( StatusId IN (SELECT * FROM #StatusId) OR @StatusId = '0');

IF (@UserId <> '0')
BEGIN
    INSERT INTO #UserId
    SELECT Data
    FROM dbo.Split(@UserId, ',');
END;

IF (@UserId = '0' AND @ActivityType != 'Customer')
BEGIN

    DECLARE @Count BIGINT = 0;
    DECLARE @IsManager BIT;

    SELECT @IsManager = IsAreaManager
    FROM dbo.AppUser
    WHERE Id = @AppuserId;


    IF EXISTS
    (
        SELECT 1
        FROM dbo.AppUserEstablishment
            INNER JOIN dbo.AppUser
                ON AppUser.Id = AppUserEstablishment.AppUserId
                   AND IsAreaManager = 0
                   AND IsActive = 1
                   AND AppUser.IsDeleted = 0
                   AND dbo.AppUserEstablishment.IsDeleted = 0
            INNER JOIN dbo.Vw_Establishment AS E
                ON E.Id = AppUserEstablishment.EstablishmentId
                   AND E.EstablishmentGroupId = @ActivityId
        UNION
        SELECT 1
        FROM dbo.AppUserEstablishment
            INNER JOIN dbo.AppUser
                ON AppUser.Id = AppUserEstablishment.AppUserId
                   AND AppUserId = @AppuserId
                   AND AppUser.IsDeleted = 0
                   AND IsActive = 1
                   AND dbo.AppUserEstablishment.IsDeleted = 0
            INNER JOIN dbo.Vw_Establishment AS E
                ON E.Id = AppUserEstablishment.EstablishmentId
                   AND E.EstablishmentGroupId = @ActivityId
    )
    BEGIN
        SET @Count = 1;
    END;

    IF @Count = 0
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM AppManagerUserRights
                INNER JOIN dbo.AppUser
                    ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                       AND AppManagerUserRights.UserId = @AppuserId
                       AND AppManagerUserRights.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN #EstablishmentId e
                    ON e.id = AppManagerUserRights.EstablishmentId
        )
        BEGIN
            SET @Count = 1;
        END;
    END;

    IF (@IsManager = 1)
    BEGIN
        IF (@Count > 0)
        BEGIN
            INSERT INTO #UserId
            SELECT AppUserId
            FROM dbo.AppUserEstablishment
                INNER JOIN dbo.AppUser
                    ON AppUser.Id = AppUserEstablishment.AppUserId
                       AND AppUserId = @AppuserId
                       AND AppUser.IsDeleted = 0
                       AND dbo.AppUserEstablishment.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN #EstablishmentId e
                    ON e.id = dbo.AppUserEstablishment.EstablishmentId
            UNION
            SELECT AppUserId
            FROM dbo.AppUserEstablishment
                INNER JOIN dbo.AppUser
                    ON AppUser.Id = AppUserEstablishment.AppUserId
                       AND IsAreaManager = 0
                       AND AppUser.IsDeleted = 0
                       AND dbo.AppUserEstablishment.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN #EstablishmentId e
                    ON e.id = dbo.AppUserEstablishment.EstablishmentId
            UNION
            SELECT ManagerUserId
            FROM AppManagerUserRights
                INNER JOIN dbo.AppUser
                    ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                       AND AppManagerUserRights.UserId = @AppuserId
                       AND AppUser.IsDeleted = 0
                       AND AppManagerUserRights.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN #EstablishmentId e
                    ON e.id = AppManagerUserRights.EstablishmentId
                INNER JOIN dbo.AppUserEstablishment
                    ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId;

        END;
        ELSE
        BEGIN
            INSERT INTO #UserId
            SELECT DISTINCT
                U.Id AS UserId
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS LoginUser
                    ON UE.AppUserId = LoginUser.Id
                       AND LoginUser.Id = @AppuserId
                       AND LoginUser.IsDeleted = 0
                       AND UE.IsDeleted = 0
                INNER JOIN dbo.Vw_Establishment AS E
                    ON UE.EstablishmentId = E.Id
                       AND E.IsDeleted = 0
                INNER JOIN dbo.EstablishmentGroup AS Eg
                    ON Eg.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS AppUser
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U
                    ON AppUser.AppUserId = U.Id
                       AND (
                               U.IsAreaManager = 0
                               OR U.Id = @AppuserId
                           )
                       AND U.IsDeleted = 0
                       AND AppUser.IsDeleted = 0;

        END;

    END;
    ELSE
    BEGIN
        INSERT INTO #UserId
        SELECT U.Id AS UserId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
                   AND LoginUser.Id = @AppuserId
                   AND LoginUser.IsDeleted = 0
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON Eg.Id = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppuserId
                       )
        WHERE U.Id = @AppuserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0;
    END;


END;

IF (@TemplateId != '')
BEGIN
    IF OBJECT_ID('tempdb..#TemplateId', 'u') IS NOT NULL
        DROP TABLE #TemplateId;
    CREATE TABLE #TemplateId (TemplateId BIGINT);

    INSERT INTO #TemplateId
    SELECT Data
    FROM dbo.Split(@TemplateId, ',');


    INSERT INTO #ActionFilterId
    SELECT ISNULL(AnswerMasterId, SeenClientAnswerMasterId)
    FROM dbo.CloseLoopTemplate CT
        INNER JOIN #TemplateId T
            ON T.TemplateId = CT.Id
               AND CT.EstablishmentGroupId = @ActivityId
        INNER JOIN CloseLoopAction ca
            ON ca.Conversation LIKE '%' + CT.TemplateText + '%';



    SELECT @ActionFilter = N' inner join #ActionFilterId afi on afi.id=a.reportid ';
END;

IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
BEGIN
    INSERT INTO #AdvanceQuestionId
    (
        QuestionId
    )
    SELECT Data
    FROM dbo.Split(@QuestionSearch, '$')
    WHERE Id % 3 = 1;

    INSERT INTO #AdvanceQuestionOperator
    (
        Operator
    )
    SELECT Data
    FROM dbo.Split(@QuestionSearch, '$')
    WHERE Id % 3 = 2;

    INSERT INTO #AdvanceQuestionSearch
    (
        SEARCH
    )
    SELECT Data
    FROM dbo.Split(@QuestionSearch, '$')
    WHERE Id % 3 = 0;

    IF @FormType = 'In'
    BEGIN
        UPDATE AQ
        SET AQ.QuestionTypeId = Q.QuestionTypeId
        FROM #AdvanceQuestionId AS AQ
            INNER JOIN dbo.Questions AS Q WITH (NOLOCK)
                ON Q.Id = AQ.QuestionId;
    END;
    ELSE IF @FormType = 'Out'
    BEGIN
        UPDATE AQ
        SET AQ.QuestionTypeId = Q.QuestionTypeId
        FROM #AdvanceQuestionId AS AQ
            INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
                ON Q.Id = AQ.QuestionId;
    END;
END;

INSERT INTO #PIFilterTable
SELECT Data
FROM dbo.Split(@PIFilter, '$');

SELECT @CompareType = Comparetype
FROM #PIFilterTable
WHERE Id = 1;

SELECT @Value = Comparetype
FROM #PIFilterTable
WHERE Id = 2;

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
FROM dbo.EstablishmentGroup WITH (NOLOCK);

IF (@PIFormTypeValue = 'false')
BEGIN
    IF (@CompareType = 'Range')
    BEGIN
        SET @PIFilterNo = N' And Round(PI,0) ' + @Value + N' And A.IsOut = 1';
    END;
    ELSE
    BEGIN
        SET @PIFilterNo
            = N' And Round(PI,0) ' + @Value + N' ' + CONVERT(VARCHAR(150), @Comparevalue) + N' And A.IsOut = 1 ';
    END;
END;
ELSE
BEGIN
    IF (@CompareType = 'Range')
    BEGIN
        SET @PIFilterNo = N' And Round(PI,0) ' + @Value + N' And A.IsOut = 0 ';
    END;
    ELSE
    BEGIN
        SET @PIFilterNo
            = N' And Round(PI,0) ' + @Value + N' ' + CONVERT(VARCHAR(150), @Comparevalue) + N' And A.IsOut = 0 ';
    END;
END;

SELECT @E = COUNT(1)
FROM #AdvanceQuestionId;

IF (
   (
       SELECT COUNT(sc.Id)
       FROM dbo.SeenClientQuestions sc
           INNER JOIN EstablishmentGroup EG
               ON sc.SeenClientId = EG.SeenClientId
                  AND EG.Id = @ActivityId
                  AND QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                  AND sc.IsDeleted = 0
   ) > 0
   )
    SET @PIDispaly = '1';

IF (
   (
       SELECT COUNT(1)
       FROM dbo.Questions q WITH (NOLOCK)
           INNER JOIN EstablishmentGroup eg
               ON q.QuestionnaireId = eg.QuestionnaireId
                  AND eg.Id = @ActivityId
                  AND q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                  AND eg.IsDeleted = 0
   ) > 0
   )
    SET @PIDisplayIn = '1';

IF (@ActivityType != 'Customer')
BEGIN
    SET @SqlSelect1
        = N' select * from (  
 SELECT A.Id,  
   A.ReportId ,  
            A.EstablishmentId ,  
            A.EstablishmentName ,  
            ISNULL(A.UserId, 0) AS AppUserId,  
            A.UserName ,  
            A.SenderCellNo ,  
            A.IsOutStanding ,  
            A.AnswerStatus ,  
            A.TimeOffSet ,  
            A.CreatedOn ,  
   Format(A.UpdatedOn,''dd/MMM/yy HH:mm'') AS UpdatedOn,  
            IIF(' + @PIDispaly
          + ' = 1, A.[PI], IIF(A.[PI] >= 0.00, A.[PI], -1)) AS PI ,   
         A.SmileType ,  
            A.QuestionnaireType ,  
            A.FormType ,  
            A.IsOut ,  
            A.QuestionnaireId ,  
            A.ReadBy ,  
   A.ContactMasterId1 AS ContactMasterId,  
            A.Latitude ,  
            A.Longitude ,  
            A.IsTransferred ,  
            A.TransferToUser ,  
            A.TransferFromUser ,  
            A.SeenClientAnswerMasterId ,  
            A.ActivityId ,  
            A.IsActioned ,  
            A.TransferByUserId ,  
            A.TransferFromUserId ,  
   dbo.fn_SummaryQuestionsList(a.Quesummary, A.ReportId) AS DisplayText ,  
   IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup WITH(NOLOCK) WHERE  Id = A.ContactGroupId),  
   case when cnt.ContactName  like '',%''   
   then right(cnt.ContactName,len(cnt.ContactName)-1)  
   else cnt.ContactName  
   end) as ContactDetails,  
   Format(A.CreatedOn, ''dd/MMM/yy HH:mm'') AS CaptureDate,  
            ISNULL(A.IsDisabled, 0) AS IsDisabled ,  
   IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup WITH(NOLOCK) WHERE  Id = A.ContactGroupId), '''') AS ContactGroupName ,  
   CAST(IIF(A.IsOut = 1, ISNULL(( SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 END FROM    dbo.AnswerMaster WITH(NOLOCK) WHERE   SeenClientAnswerMasterId = A.ReportId ), 1), 0) AS BIT) AS IsResend,  
  
   ';

    SET @SqlSelect11
        = CHAR(13)
          + N'  
  
   ISNULL(A.CreatedUserId, 0) AS CreatedUserId,  
            ( SELECT    COUNT(1) FROM      dbo.PendingNotificationWeb (NOLOCK) WHERE     IsDeleted = 0 AND AppUserId = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AND IsRead = 0 AND ( RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId ) AND ModuleId IN ( 7, 8, 11, 12 ) ) AS UnreadActionCount ,  
   ( SELECT    COUNT(1) FROM      dbo.PendingNotificationWeb (NOLOCK) WHERE     IsDeleted = 0 AND AppUserId = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AND IsRead = 0 AND ( RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId ) AND ModuleId IN ( 7, 8, 11, 12 ) ) AS AlertUnreadCountCount ,  
            ( SELECT    CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT  CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WITH(NOLOCK) WHERE   Id = A.ReportId ), 0) ELSE 0 END ) AS IsRecursion ,  
            dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10), @AppuserId)
          + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) AS MobiLink ,  
            '''        + CONVERT(VARCHAR(10), ISNULL(@GroupType, ''))
          + ''' AS GroupType ,  
            DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM      dbo.PendingNotificationWeb WITH(NOLOCK) WHERE     IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 ) AND ISNULL(AppUserId, 0) = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' ORDER BY  CreatedOn DESC )) AS ActionDate ,  
            DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM      dbo.PendingNotificationWeb WITH(NOLOCK) WHERE     IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 ) ORDER BY  CreatedOn DESC )) AS ActionDateEveryone , 
 
            '          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AS ActionTo,  
   (CASE WHEN A.IsDisabled = 1 THEN ''#ff5e52'' ELSE CASE WHEN A.AnswerStatus = ''Resolved'' THEN ''#2cc56a'' WHEN A.IsTransferred = 1 THEN ''#2196F3'' WHEN A.IsActioned = 1 THEN ''#FFC107'' ELSE ''#9e9e9e'' END END) AS FormColor,  
   CASE WHEN A.IsOut = 1 THEN A.UserName + '' To '' + IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup WITH(NOLOCK) WHERE  Id = A.ContactGroupId), ( SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd WITH(NOLOCK)
   INNER JOIN ContactQuestions cq ON cq.Id = cd.ContactQuestionId WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cd.Detail <> '''' 
   order by cq.position))  
   ELSE  (SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd WITH(NOLOCK) WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cd.Detail <> '''' ) + '' To '' + A.UserName   
   END AS ContactData,  
      
   ';

    SET @sqlSelect11_1
        = CHAR(13)
          + '  
  
 '''' AS LastChat,  
 '''' AS LastChatBy,  
     cast(F.IsFlag as BIT) as IsFlag,  
   A.StatusId,  
   A.StatusName,  
   A.StatusImage,  
      (select Format(cast(A.StatusTime as datetime),''dd/MMM/yy HH:mm'',''en-us'')  
   ) AS StatusTime,  
   (SELECT dbo.DifferenceDatefun(ISNULL(A.StatusTime,GETUTCDATE()),DATEADD(MINUTE, A.TimeOffSet,GETUTCDATE()))) AS StatusCounter  
    FROM  #View_AllAnswerMaster (NOLOCK) AS A';

    IF EXISTS (SELECT 1 FROM #EstablishmentId)
    BEGIN
        SET @SqlSelect12 += CHAR(13) + 'INNER JOIN #EstablishmentId e ON A.EstablishmentId = E.id  ';
    END;

    IF EXISTS (SELECT 1 FROM #UserId)
    BEGIN
        SET @SqlSelect12 += CHAR(13)
                            + ' INNER JOIN #USERID AS U ON U.UserId = A.UserId OR U.UserId = ISNULL(A.TransferFromUserId, 0) OR A.UserId = 0 ';
    END;

    IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
    BEGIN
        WHILE @S <= @E
        BEGIN
            SELECT @QuestionId = QuestionId
            FROM #AdvanceQuestionId
            WHERE Id = @S;

            IF @IsOut = 0
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans' + @QuestionId + ' with (nolock) ON Ans'
                                   + @QuestionId + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans' + @QuestionId
                                   + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(Ans' + @QuestionId + '.Detail, ''''), '','') AS OAns'
                                   + @QuestionId;
            END;
            ELSE
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns' + @QuestionId
                                   + ' with (nolock) ON SeenAns' + @QuestionId
                                   + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns' + @QuestionId
                                   + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(SeenAns' + @QuestionId
                                   + '.Detail, ''''), '','') AS OSeenAns' + @QuestionId;
            END;
            SET @S += 1;
        END;
    END;

    IF (@Search != '')
    BEGIN

        IF (ISNUMERIC(@Search) = 1 AND TRY_CAST(@Search AS INT) IS NOT NULL)
        BEGIN

            SELECT @OutId = SeenClientAnswerMasterId
            FROM dbo.AnswerMaster WITH (NOLOCK)
            WHERE Id = CAST(@Search AS BIGINT);

            IF @OutId = 0
            BEGIN

                SET @SqlSelect2 += CHAR(13)
                                   + ' LEFT OUTER JOIN dbo.Answers AS Ans with (nolock) ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
                                   + CHAR(13)
                                   + '  LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns with (nolock) ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';
            END;
            ELSE
            BEGIN

                SET @SqlSelect2 += CHAR(13)
                                   + ' LEFT OUTER JOIN dbo.Answers AS Ans with (nolock) ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
                                   + CHAR(13)
                                   + '  LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns with (nolock) ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';

            END;
        END;
        ELSE
        BEGIN
            SET @SqlSelect2 += CHAR(13)
                               + ' LEFT OUTER JOIN dbo.Answers AS Ans with (nolock) ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
                               + CHAR(13)
                               + '  LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns with (nolock) ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1';
        END;
    END;

    SET @SqlSelect2 += CHAR(13)
                       + '  LEFT OUTER JOIN dbo.FlagMaster AS F with (nolock) ON F.ReportId = A.ReportId AND F.Type IN (1,2) AND F.AppUserId = '
                       + CONVERT(VARCHAR(10), @AppuserId);

    IF (@isAction = 'true')
    BEGIN
        SET @SqlSelect2 += ' INNER JOIN CloseLoopAction cla ON A.ReportId=ISNULL(AnswerMasterId,cla.AnswerMasterId) AND a.IsActioned=1 AND cla.Conversation LIKE ''%'
                           + @ActionSearch + '%'')';

    END;

    IF (@TemplateId != '')
    BEGIN
        SET @SqlSelect2 += @ActionFilter;


    END;

    SET @SqlSelect3 = +CHAR(13) + 'LEFT JOIN dbo.tblContact cnt    ON cnt.ContactMasterId=A.ContactMasterId  
'   ;

    SET @SqlSelect2 += CHAR(13) + '  
  
     ';

    SET @Filter += CHAR(13) + 'where 1=1';

    IF (@ReportId > 0)
        SET @Filter += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = '
                       + CONVERT(NVARCHAR(10), @ReportId);

    IF (@FormStatus = 'Resolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''  '; --And A.IsOut = 1  
    END;

    IF (@FormStatus = 'Unresolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + ''' '; --And A.IsOut = 1   
    END;
    IF (@FormType = 'All' AND @PIFormTypeValue = 'false')
    BEGIN
        SET @Filter += ' AND A.IsOut = 1 ';
    END;
    IF (@FormType = 'In')
    BEGIN
        SET @Filter += ' AND A.IsOut = 0 ';
    END;
    IF (@FormType = 'Out')
    BEGIN
        SET @Filter += ' AND A.IsOut = 1 ';
    END;
    IF (@SmileyTypesSortby <> '' AND @SmileyTypesSortby IS NOT NULL)
    BEGIN
        IF (@SmileyTypesSortby = 'Positive')
        BEGIN
            SET @Filter += ' AND A.SmileType = ''' + @SmileyTypesSortby + '''AND A.IsOut = 1';
        END;
        ELSE
        BEGIN
            SET @Filter += ' AND A.SmileType = ''' + @SmileyTypesSortby + ''' AND A.IsOut = 1';
        END;
    END;

    IF (@Search != '')
    BEGIN

        IF (ISNUMERIC(@Search) = 1 AND TRY_CAST(@Search AS INT) IS NOT NULL)
        BEGIN

            SELECT @OutId = SeenClientAnswerMasterId
            FROM dbo.AnswerMaster WITH (NOLOCK)
            WHERE Id = CAST(@Search AS BIGINT)
                  AND IsDeleted = 0;

            IF @OutId = 0
            BEGIN

                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
        OR A.SeenClientAnswerMasterId LIKE ''%' + @Search + '%''  
  
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                --OR A.EI LIKE ''%' + @Search
                               + '%''  
                                OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'      ;
            END;
            ELSE
            BEGIN

                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
        OR A.ReportId = '      + CAST(ISNULL(@OutId, '') AS VARCHAR(50))
                               + '  
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                --OR A.EI LIKE ''%' + @Search
                               + '%''  
                                OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'      ;

            END;
        END;
        ELSE
        BEGIN
            SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                           + '%''   
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                -- OR A.EI LIKE ''%' + @Search
                           + '%''  
                                OR A.UserName LIKE ''%' + @Search
                           + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                           + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                           + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                           + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'  ;
        END;
    END;

    IF (@ReadUnread = 'Unread')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 1 And A.IsOut = 1';
    END;

    ELSE IF (@ReadUnread = 'Read')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 0 And A.IsOut = 1';
    END;

    IF (@isResend = 'true')
        SET @Filter += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster with (NOlOCK) WHERE   SeenClientAnswerMasterId = A.ReportId and IsDeleted = 0),1) ELSE 0 end) = 1 AND A.IsOut = 1 ';

    IF (@isRecursion = 'true')
        SET @Filter += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster with (NOlOCK) WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';

    ELSE IF (@isAction = 'false')
    BEGIN
        SET @Filter += ' AND A.IsActioned = 0';
    END;

    IF (@isTransfer = 'true')
        SET @Filter += ' AND A.IsTransferred = 1 AND A.IsOut = 1';

    IF (@isFlag = 'true')
        SET @Filter += ' AND F.IsFlag = 1 AND A.IsOut = 1';

    IF (@ResponseType = 'Responded' OR @ResponseType = 'NotResponded')
    BEGIN

        INSERT INTO #temp
        (
            SeenClientAnswerMasterId
        )
        EXEC ('select distinct A.SeenClientAnswerMasterId FROM  #View_AllAnswerMaster AS A ' + @SqlSelect12 + @SqlSelect2 + @SqlSelect3 + @Filter + ' Group By A.SeenClientAnswerMasterId');

        IF (@ResponseType = 'Responded')
        BEGIN
            SET @SqlSelect2 += ' INNER JOIN #temp t ON t.SeenClientAnswerMasterId=A.ID ';

        END;
        ELSE IF (@ResponseType = 'NotResponded')
        BEGIN

            SET @SqlSelect2 += ' left JOIN #temp t ON t.SeenClientAnswerMasterId=A.ID ';
            SET @Filter += ' AND t.SeenClientAnswerMasterId is null ';


        END;
    END;


    IF (@isResponseLink = 'True')
        SET @Filter += ' AND dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10), @AppuserId)
                       + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != ''''';


    IF (@IsEdited = 'true')
        SET @Filter += ' And A.UpdatedOn IS NOT NULL';

    IF (@PIFilterNo != '')
        SET @Filter += @PIFilterNo;

    IF (@isFromActivity = 'true')
    BEGIN
        SET @SqlSelect12 += CHAR(13)
                            + 'LEFT OUTER JOIN #View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)';
        SET @Filter += CHAR(13)
                       + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb with (NOlOCK) WHERE IsDeleted = 0 AND AppUserId = '
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
            FROM #AdvanceQuestionId
            WHERE Id = @S;

            SELECT @Operator = Operator
            FROM #AdvanceQuestionOperator
            WHERE Id = @S;

            SELECT @SearchText = SEARCH
            FROM #AdvanceQuestionSearch
            WHERE Id = @S;

            IF @QuestionTypeId IN ( 1, 2, 19 )
            BEGIN
                SET @Filter += ' AND (' + (CASE @IsOut
                                               WHEN 0 THEN
                                                   'Ans'
                                               ELSE
                                                   'SeenAns'
                                           END
                                          ) + @QuestionId + '.Detail IN ( SELECT Data FROM dbo.Split(''' + @SearchText
                               + ''', '','')) )';
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
                                         FORMAT(CAST(@SearchText AS DATETIME), N'yyyy-MM-dd HH:mm')
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

    SET @groupby += CHAR(13)
                    + N' GROUP BY A.ReportId , A.EstablishmentId , A.EstablishmentName , A.UserId , A.UserName , A.SenderCellNo , A.IsOutStanding , A.AnswerStatus , A.TimeOffSet ,  
            A.CreatedOn , A.UpdatedOn , A.EI , A.[PI] , A.SmileType , A.QuestionnaireType , A.FormType , A.IsOut , A.QuestionnaireId , A.ReadBy , A.ContactMasterId , A.ContactGroupId , A.Latitude ,  
            A.Longitude , A.IsTransferred , A.TransferToUser , A.TransferFromUser , A.SeenClientAnswerMasterId , A.ActivityId , A.IsActioned , A.TransferByUserId , A.TransferFromUserId , A.IsDisabled ,  
            A.CreatedUserId,F.IsFlag,A.StatusId,A.StatusName,A.StatusImage,A.StatusTime,A.StatusCounter,A.ContactMasterId1,A.ID,a.Quesummary ,cnt.ContactName ';
    PRINT '5';
    IF (@isFromActivity = 'true')
    BEGIN
        SET @groupby1 += CHAR(13)
                         + N' GROUP BY A.ReportId , A.EstablishmentId , A.EstablishmentName , A.UserId , A.UserName , A.SenderCellNo , A.IsOutStanding , A.AnswerStatus , A.TimeOffSet ,  
            A.CreatedOn , A.UpdatedOn , A.EI , A.[PI] , A.SmileType , A.QuestionnaireType , A.FormType , A.IsOut , A.QuestionnaireId , A.ReadBy , A.ContactMasterId , A.ContactGroupId , A.Latitude ,  
            A.Longitude , A.IsTransferred , A.TransferToUser , A.TransferFromUser , A.SeenClientAnswerMasterId , A.ActivityId , A.IsActioned , A.TransferByUserId , A.TransferFromUserId , A.IsDisabled ,  
            A.CreatedUserId,F.IsFlag,RA.ReportId,RA.SeenClientAnswerMasterId,A.StatusId,A.StatusName,A.StatusImage,A.StatusTime,A.StatusCounter  
   ,A.ContactMasterId1,A.ID ,a.Quesummary,cnt.ContactName ';

    END;
    ELSE
    BEGIN
        SET @groupby1 = @groupby;
    END;
    SET @OrderBYFilter += CHAR(13) + N' ,cnt.ContactName ) as a';
    INSERT INTO #temptable
    EXEC (@SqlSelect1 + @SqlSelect11 + @sqlSelect11_1 + @SqlSelect12 + @SqlSelect2 + @SqlSelect3 + @Filter + @groupby + @OrderBYFilter + @OrderBy);   
    IF (@PIFormTypeValue = 'true')
        SET @IsOut = 0;
    IF (@PIFormTypeValue = 'false' AND @PIFilter != '')
        SET @IsOut = 1;
    IF (@ResponseType = 'NotResponded')
    BEGIN
        INSERT INTO @ResultReportId
        (
            ReportId,
            FromType,
            IsOut,
            CreatedOn
        )
        EXEC ('SELECT ReportId, 
           FormType,  
           IsOut,
		   a.CreatedOn
         FROM #temptable a  
     LEFT JOIN ChatDetails T ON   
         (  
                                   t.SeenClientAnswerMasterId = IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0,A.ReportId,A.SeenClientAnswerMasterId)  
                                   OR t.AnswerMasterId = A.ReportId)  ' + @order);
    END;
    ELSE IF (@IsOut = 1)
    BEGIN
        PRINT 'Isout 2';
        IF (@FormStatus = 'All')
        BEGIN
		PRINT 'Isout 3';
            INSERT INTO @ResultReportId
            (
                ReportId,
                FromType,
                IsOut,
                CreatedOn
            )
            SELECT tmp.ReportId,
                   tmp.FormType,
                   tmp.IsOut,
                   tmp.CreatedOn
            FROM #temptable tmp
                LEFT JOIN ChatDetails T
                    ON (
                           T.SeenClientAnswerMasterId = IIF(ISNULL(tmp.SeenClientAnswerMasterId, 0) = 0,
                                                            tmp.ReportId,
                                                            tmp.SeenClientAnswerMasterId)
                           OR T.AnswerMasterId = tmp.ReportId
                       )
            UNION
            SELECT DISTINCT
                am.Id,
                'Feedback' FormType,
                CAST(0 AS BIT) AS IsOut,
                t.CreatedOn
            FROM #temptable t
                INNER JOIN AnswerMaster am WITH (NOLOCK)
                    ON am.SeenClientAnswerMasterId = t.Id
                       AND IsDeleted = 0 --AND am.Id=t.ReportId --AND t.IsOut=1  
                INNER JOIN
                (SELECT DISTINCT AnswerMasterId FROM dbo.Answers) a
                    ON am.Id = a.AnswerMasterId
                INNER JOIN dbo.SeenClientAnswerMaster SCM WITH (NOLOCK)
                    ON SCM.Id = am.SeenClientAnswerMasterId
                LEFT JOIN dbo.SeenClientAnswerChild SAC WITH (NOLOCK)
                    ON SAC.Id = am.SeenClientAnswerChildId
                LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.FlagMaster AS F WITH (NOLOCK)
                    ON F.ReportId = am.Id
                       AND F.Type = 1
                       AND F.AppUserId = +CONVERT(VARCHAR(10), @AppuserId)
                LEFT JOIN dbo.tblContact tc
                    ON tc.ContactMasterId = (IIF(ISNULL(SCM.ContactMasterId, 0) = 0,
                                                 SAC.ContactMasterId,
                                                 SCM.ContactMasterId)
                                            )
                LEFT JOIN ChatDetails TT
                    ON (
                           TT.SeenClientAnswerMasterId = IIF(ISNULL(t.SeenClientAnswerMasterId, 0) = 0,
                                                             t.ReportId,
                                                             t.SeenClientAnswerMasterId)
                           OR TT.AnswerMasterId = t.ReportId
                       )
            ORDER BY tmp.CreatedOn DESC;

        END;
        ELSE
        BEGIN
		PRINT 'Isout 4';
            INSERT INTO @ResultReportId
            (
                ReportId,
                FromType,
                IsOut,
                CreatedOn
            )
            SELECT tmp.ReportId,
                   tmp.FormType,
                   tmp.IsOut,
                   tmp.CreatedOn
            FROM #temptable tmp
                LEFT JOIN ChatDetails T
                    ON T.SeenClientAnswerMasterId = IIF(ISNULL(tmp.SeenClientAnswerMasterId, 0) = 0,
                                                        tmp.ReportId,
                                                        tmp.SeenClientAnswerMasterId)
                LEFT JOIN dbo.ChatDetails tt
                    ON tt.AnswerMasterId = tmp.ReportId
            UNION
            SELECT am.Id,
                   'Feedback' FormType,
                   CAST(0 AS BIT) AS IsOut,
                   t.CreatedOn
            FROM #temptable t
                INNER JOIN AnswerMaster am WITH (NOLOCK)
                    ON am.SeenClientAnswerMasterId = t.Id
                       AND IsDeleted = 0 --AND am.Id=t.ReportId  
                INNER JOIN
                (SELECT DISTINCT AnswerMasterId FROM dbo.Answers) a
                    ON am.Id = a.AnswerMasterId
                INNER JOIN dbo.SeenClientAnswerMaster SCM WITH (NOLOCK)
                    ON SCM.Id = am.SeenClientAnswerMasterId
                LEFT JOIN dbo.SeenClientAnswerChild SAC WITH (NOLOCK)
                    ON SAC.Id = am.SeenClientAnswerChildId
                LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.FlagMaster AS F WITH (NOLOCK)
                    ON F.ReportId = am.Id
                       AND F.Type = 1
                       AND F.AppUserId = @AppuserId
                LEFT JOIN dbo.tblContact tc
                    ON tc.ContactMasterId = (IIF(ISNULL(SCM.ContactMasterId, 0) = 0,
                                                 SAC.ContactMasterId,
                                                 SCM.ContactMasterId)
                                            )
                LEFT JOIN ChatDetails TT
                    ON TT.SeenClientAnswerMasterId = IIF(ISNULL(t.SeenClientAnswerMasterId, 0) = 0,
                                                         t.ReportId,
                                                         t.SeenClientAnswerMasterId)
                LEFT JOIN dbo.ChatDetails ttt
                    ON ttt.AnswerMasterId = t.ReportId
            ORDER BY tmp.CreatedOn DESC;
        END;
    END;
    ELSE IF (@IsOut = 0)
    BEGIN
        INSERT INTO @ResultReportId
        (
            ReportId,
            FromType,
            IsOut,
            CreatedOn
        )
        SELECT tmp.ReportId,
               tmp.FormType,
               tmp.IsOut,
               tmp.CreatedOn
        FROM #temptable tmp
            LEFT JOIN ChatDetails Tt
                ON (
                       Tt.SeenClientAnswerMasterId = IIF(ISNULL(tmp.SeenClientAnswerMasterId, 0) = 0,
                                                         tmp.ReportId,
                                                         tmp.SeenClientAnswerMasterId)
                       OR Tt.AnswerMasterId = tmp.ReportId
                   )
        UNION
        SELECT DISTINCT
            am.Id,
            'Seenclient' FormType,
            CAST(1 AS BIT) AS IsOut,
            t.CreatedOn
        FROM #temptable t
            INNER JOIN SeenClientAnswerMaster am WITH (NOLOCK)
                ON am.Id = t.Id
            INNER JOIN
            (
                SELECT DISTINCT
                    SeenClientAnswerMasterId,
                    SeenClientAnswerChildId
                FROM dbo.SeenClientAnswers WITH (NOLOCK)
            ) a
                ON am.Id = a.SeenClientAnswerMasterId
            LEFT JOIN dbo.SeenClientAnswerChild SAC WITH (NOLOCK)
                ON SAC.Id = a.SeenClientAnswerChildId
            LEFT JOIN dbo.AppUser AS U WITH (NOLOCK)
                ON am.AppUserId = U.Id
            LEFT JOIN dbo.tblContact TC
                ON TC.ContactMasterId = (IIF(ISNULL(am.ContactMasterId, 0) = 0, am.ContactGroupId, am.ContactMasterId))
            LEFT JOIN ChatDetails Tt
                ON (
                       Tt.SeenClientAnswerMasterId = IIF(ISNULL(t.SeenClientAnswerMasterId, 0) = 0,
                                                         t.ReportId,
                                                         t.SeenClientAnswerMasterId)
                       OR Tt.AnswerMasterId = t.ReportId
                   )
        ORDER BY tmp.CreatedOn DESC;
    END;
    ELSE
    BEGIN
        PRINT 'isout 4';
        INSERT INTO @ResultReportId
        (
            ReportId,
            FromType,
            IsOut,
            CreatedOn
        )
        EXEC ('SELECT 
            ReportId, 
            FormType,  
            IsOut,
			a.CreatedOn
   FROM #temptable a  
   LEFT JOIN ChatDetails T ON   
         (  
               (T.SeenClientAnswerMasterId = IIF(ISNULL(a.SeenClientAnswerMasterId, 0) = 0,a.ReportId,a.SeenClientAnswerMasterId)  
      AND a.IsOut=1)  
      or  (T.AnswerMasterId = a.ReportId AND a.IsOut=0)  
           ) ' + @order);
    END;
    SET NOCOUNT OFF;
END;
ELSE
BEGIN
    SET @SqlSelect1
        = N' select * from (  
 SELECT
   A.Id,  
   A.ReportId ,  
            A.EstablishmentId ,  
            A.EstablishmentName ,  
            ISNULL(A.UserId, 0) AS AppUserId,  
            A.UserName ,  
            A.SenderCellNo ,  
            A.IsOutStanding ,  
            A.AnswerStatus ,  
            A.TimeOffSet ,  
            A.CreatedOn ,  
   Format(A.UpdatedOn,''dd/MMM/yy HH:mm'') AS UpdatedOn,  
            IIF(' + @PIDispaly
          + ' = 1, A.[PI], IIF(A.[PI] >= 0.00, A.[PI], -1)) AS PI ,   
         A.SmileType ,  
            A.QuestionnaireType ,  
            A.FormType ,  
            A.IsOut ,  
            A.QuestionnaireId ,  
            A.ReadBy ,  
   A.ContactMasterId1 AS ContactMasterId,  
            A.Latitude ,  
            A.Longitude ,  
            A.IsTransferred ,  
            A.TransferToUser ,  
            A.TransferFromUser ,  
            A.SeenClientAnswerMasterId ,  
            A.ActivityId ,  
            A.IsActioned ,  
            A.TransferByUserId ,  
            A.TransferFromUserId ,  
   dbo.fn_SummaryQuestionsList(a.Quesummary, A.ReportId) AS DisplayText ,  
  -- IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup with (NOlOCK) WHERE  Id = A.ContactGroupId),    
   --(STUFF(( SELECT    '','' + R.Detail   
   -- FROM   ( SELECT    CASE Cd.QuestionTypeId  
   --                 WHEN 8  
   --                 THEN CONVERT(NVARCHAR(50), Format(cast(Detail as date), ''dd/MMM/yyyy''))  
   --                 WHEN 9  
   --                 THEN CONVERT(NVARCHAR(50), Format(cast(Detail as Time), ''hh:mm tt''))  
   --                 WHEN 22  
   --                 THEN CONVERT(NVARCHAR(50), Format(cast(Detail as datetime), ''dd/MMM/yy HH:mm''))  
   --                 ELSE CONVERT(NVARCHAR(50), ISNULL(Detail, ''''))  
   --             END AS Detail ,  
   --             Position  
   -- FROM  dbo.ContactDetails AS Cd with (NOlOCK)  
   --             INNER JOIN dbo.ContactQuestions AS Cq with (NOlOCK) ON Cd.ContactQuestionId = Cq.Id  
   -- WHERE     ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND IsDisplayInSummary = 1 AND Detail <> '''' ) AS R  
   -- ORDER BY R.Position FOR XML PATH('''') ), 1, 1, '''') ) ) AS ContactDetails ,  
    case when cnt.ContactName  like '',%''   
   then right(cnt.ContactName,len(cnt.ContactName)-1)  
   else cnt.ContactName  
   end as ContactDetails,  
   Format(A.CreatedOn, ''dd/MMM/yy HH:mm'') AS CaptureDate,  
            ISNULL(A.IsDisabled, 0) AS IsDisabled ,  
   IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup with (NOlOCK) WHERE  Id = A.ContactGroupId), '''') AS ContactGroupName ,  
   CAST(IIF(A.IsOut = 1, ISNULL(( SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 END FROM    dbo.AnswerMaster with (NOlOCK) WHERE   SeenClientAnswerMasterId = A.ReportId and IsDeleted = 0), 1), 0) AS BIT) AS IsResend,  
   --0 AS PositiveCount ,  
   --         0 AS NegativeCount ,  
   --         0 AS PassiveCount ,  
   ';

    SET @SqlSelect11
        = CHAR(13)
          + N'  
  --0 AS UnresolvedCount ,  
  -- 0 AS ResolvedCount ,  
  --          0 AS ActionedCount ,   
  --          0 AS UnActionedCount ,  
  --          0 AS TransferredCount ,  
  --          0 AS OutstandingCount ,  
   ISNULL(A.CreatedUserId, 0) AS CreatedUserId,  
            ( SELECT    COUNT(1) FROM      dbo.PendingNotificationWeb (NOLOCK) WHERE     IsDeleted = 0 AND AppUserId = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AND IsRead = 0 AND ( RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId ) AND ModuleId IN ( 7, 8, 11, 12 ) ) AS UnreadActionCount ,  
   ( SELECT    COUNT(1) FROM      dbo.PendingNotificationWeb (NOLOCK) WHERE     IsDeleted = 0 AND AppUserId = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AND IsRead = 0 AND ( RefId = A.ReportId OR RefId = A.SeenClientAnswerMasterId ) AND ModuleId IN ( 7, 8, 11, 12 ) ) AS AlertUnreadCountCount ,  
            ( SELECT    CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT  CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster WITH(NOLOCK) WHERE   Id = A.ReportId ), 0) ELSE 0 END ) AS IsRecursion ,  
            dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10), @AppuserId)
          + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) AS MobiLink ,  
            '''        + CONVERT(VARCHAR(10), ISNULL(@GroupType, ''))
          + ''' AS GroupType ,  
            DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM      dbo.PendingNotificationWeb with (NOlOCK) WHERE     IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 ) AND ISNULL(AppUserId, 0) = '
          + CONVERT(VARCHAR(10), @AppuserId)
          + ' ORDER BY  CreatedOn DESC )) AS ActionDate ,  
            DATEADD(MINUTE, A.TimeOffSet, ( SELECT TOP 1 CreatedOn FROM      dbo.PendingNotificationWeb with (NOlOCK) WHERE     IsDeleted = 0 AND ISNULL(RefId, 0) = A.ReportId AND ModuleId IN ( 11, 12 ) ORDER BY  CreatedOn DESC )) AS ActionDateEveryone ,
  
            '          + CONVERT(VARCHAR(10), @AppuserId)
          + ' AS ActionTo,  
   (CASE WHEN A.IsDisabled = 1 THEN ''#ff5e52'' ELSE CASE WHEN A.AnswerStatus = ''Resolved'' THEN ''#2cc56a'' WHEN A.IsTransferred = 1 THEN ''#2196F3'' WHEN A.IsActioned = 1 THEN ''#FFC107'' ELSE ''#9e9e9e'' END END) AS FormColor,  
   CASE WHEN A.IsOut = 1 THEN A.UserName + '' To '' + IIF(A.ContactMasterId = 0,   
   ( SELECT ContactGropName FROM   dbo.ContactGroup with (NOlOCK) WHERE  Id = A.ContactGroupId), ( SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd with (NOlOCK) WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 
0 AND Cd.Detail <> '''' ))  
   ELSE  (SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd with (NOlOCK) WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cd.Detail <> '''' ) + '' To '' + A.UserName   
   END AS ContactData,  
     
   CAST(ISNULL((SELECT TOP 1 CLA.[Conversation]  FROM    dbo.CloseLoopAction AS CLA with (NOlOCK) INNER JOIN dbo.AppUser AS AU with (NOlOCK) ON AU.Id = CLA.AppUserId  
            WHERE CLA.AnswerMasterId =A.ReportId ORDER BY CLA.Id DESC), '''') AS VARCHAR(120))  
   AS LastChat,  
      ISNULL((SELECT TOP 1 IIF(CLA.CustomerName is null, Au.Name, CLA.CustomerName)   FROM    dbo.CloseLoopAction AS CLA with (NOlOCK) INNER JOIN dbo.AppUser AS AU with (NOlOCK) ON AU.Id = CLA.AppUserId  
            WHERE CLA.AnswerMasterId = A.ReportId), '''') AS LastChatBy,  
   ';

    SET @sqlSelect11_1
        = CHAR(13)
          + '    
       
   CAST(F.IsFlag as BIT) as IsFlag,  
   A.StatusId,  
   A.StatusName,  
   A.StatusImage,  
      (select Format(cast(A.StatusTime as datetime),''dd/MMM/yy HH:mm'',''en-us'')  
   ) AS StatusTime,  
   (SELECT dbo.DifferenceDatefun(ISNULL(A.StatusTime,GETUTCDATE()),DATEADD(MINUTE, A.TimeOffSet,GETUTCDATE()))) AS StatusCounter  
    FROM  #View_AllAnswerMaster (NOLOCK) AS A ';

    SET @SqlSelect12 += CHAR(13) + 'INNER JOIN #EstablishmentId e ON A.EstablishmentId = E.id ';

    IF (@UserId <> '')
    BEGIN
        IF EXISTS (SELECT 1 FROM #UserId)
        BEGIN
            SET @SqlSelect12 += CHAR(13)
                                + ' INNER JOIN #USERID AS U ON U.UserId = A.UserId OR U.UserId = ISNULL(A.TransferFromUserId, 0) OR A.UserId = 0 ';
        END;
    END;

    IF (@QuestionSearch <> '' AND @QuestionSearch IS NOT NULL)
    BEGIN
        WHILE @S <= @E
        BEGIN
            SELECT @QuestionId = QuestionId
            FROM #AdvanceQuestionId
            WHERE Id = @S;

            IF @IsOut = 0
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.Answers AS Ans' + @QuestionId + ' WITH(NOLOCK) ON Ans'
                                   + @QuestionId + '.AnswerMasterId = A.ReportId AND A.IsOut = 0 AND Ans' + @QuestionId
                                   + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(Ans' + @QuestionId + '.Detail, ''''), '','') AS OAns'
                                   + @QuestionId;
            END;
            ELSE
            BEGIN
                SET @SqlSelect2 += ' LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns' + @QuestionId
                                   + ' WITH(NOLOCK) ON SeenAns' + @QuestionId
                                   + '.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1 AND SeenAns' + @QuestionId
                                   + '.QuestionId = ' + @QuestionId;
                SET @SqlSelect2 += 'OUTER APPLY dbo.Split(ISNULL(SeenAns' + @QuestionId
                                   + '.Detail, ''''), '','') AS OSeenAns' + @QuestionId;
            END;
            SET @S += 1;
        END;
    END;
    SET @SqlSelect2 += CHAR(13)
                       + ' LEFT OUTER JOIN dbo.Answers AS Ans WITH(NOLOCK) ON Ans.AnswerMasterId = A.ReportId AND A.IsOut = 0 '
                       + CHAR(13)
                       + '  LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns WITH(NOLOCK) ON SeenAns.SeenClientAnswerMasterId = A.ReportId AND A.IsOut = 1'
                       + CHAR(13)
                       + '  LEFT OUTER JOIN dbo.FlagMaster AS F WITH(NOLOCK) ON F.ReportId = A.ReportId AND F.Type IN (1,2) AND F.AppUserId = '''
                       + CONVERT(VARCHAR(10), @AppuserId) + '''';

    SET @SqlSelect3 = +CHAR(13) + 'LEFT JOIN dbo.tblContact cnt    ON cnt.ContactMasterId=A.ContactMasterId';

    SET @Filter += CHAR(13) + ' where 1=1 ';

    IF (@ReportId > 0)
    BEGIN
        SET @Filter += ' AND (case isnull(A.SeenClientAnswerMasterId,0) when 0 then A.ReportId else A.SeenClientAnswerMasterId END) = '
                       + CONVERT(NVARCHAR(10), @ReportId);
    END;
    IF (@FormStatus = 'Resolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''';
    END;

    IF (@FormStatus = 'Unresolved')
    BEGIN
        SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''';
    END;

    IF (@FormType = 'In')
    BEGIN
        SET @Filter += ' AND A.IsOut = 0 ';
    END;
    IF (@FormType = 'Out')
    BEGIN
        SET @Filter += ' AND A.IsOut = 1 ';
    END;
    IF (@SmileyTypesSortby <> '' AND @SmileyTypesSortby IS NOT NULL)
    BEGIN
        IF (@SmileyTypesSortby = 'Positive')
        BEGIN
            SET @Filter += ' AND A.SmileType = ''' + @SmileyTypesSortby + '''AND A.IsOut = 0';
        END;
        ELSE
        BEGIN
            SET @Filter += ' AND A.SmileType = ''' + @SmileyTypesSortby + ''' AND A.IsOut = 0';
        END;
    END;
    IF (@Search != '')
    BEGIN
        IF (ISNUMERIC(@Search) = 1 AND TRY_CAST(@Search AS INT) IS NOT NULL)
        BEGIN

            SELECT @OutId = SeenClientAnswerMasterId
            FROM dbo.AnswerMaster WITH (NOLOCK)
            WHERE Id = CAST(@Search AS BIGINT)
                  AND IsDeleted = 0;
            IF @OutId = 0
            BEGIN
                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
        OR A.SeenClientAnswerMasterId LIKE ''%' + @Search + '%''  
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                --OR A.EI LIKE ''%' + @Search
                               + '%''  
                                OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'      ;
            END;
            ELSE
            BEGIN
                SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                               + '%''   
        OR A.ReportId = '      + CAST(@OutId AS VARCHAR(50)) + '  
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                --OR A.EI LIKE ''%' + @Search
                               + '%''  
                                OR A.UserName LIKE ''%' + @Search
                               + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                               + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                               + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'      ;
            END;
        END;
        ELSE
        BEGIN
            SET @Filter += ' AND (REPLACE(STR(A.ReportId , 10), SPACE(1), ''0'') like ''%' + @Search
                           + '%''   
        OR A.EstablishmentName LIKE ''%' + @Search + '%''  
                                -- OR A.EI LIKE ''%' + @Search
                           + '%''  
                                OR A.UserName LIKE ''%' + @Search
                           + '%''  
                                OR A.SenderCellNo LIKE ''%' + @Search
                           + '%''  
                                --OR dbo.ChangeDateFormat(A.CreatedOn,''dd/MMM/yy HH:mm'') LIKE ''%' + @Search
                           + '%''  
                                OR ISNULL(Ans.Detail, '''') LIKE ''%' + @Search
                           + '%''  
                                OR ISNULL(SeenAns.Detail, '''') LIKE ''%' + @Search + '%''  
        )'  ;
        END;
    END;
    IF (@ReadUnread = 'Unread')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 1 And A.IsOut = 0';
    END;
    ELSE IF (@ReadUnread = 'Read')
    BEGIN
        SET @Filter += ' And A.Isoutstanding = 0 And A.IsOut = 0';
    END;
    IF (@isResend = 'true')
    BEGIN
        SET @Filter += ' And (SELECT CASE A.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WITH(NOLOCK) WHERE   SeenClientAnswerMasterId = A.ReportId),1) ELSE 0 end) = 1 AND A.IsOut = 0 AND isDeleted = 0';
    END;
    IF (@isRecursion = 'true')
    BEGIN
        SET @Filter += '  AND ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM    dbo.SeenClientAnswerMaster  WITH(NOLOCK) WHERE   Id = A.ReportId ), 0) ELSE 0 END ) = 1';
    END;
    IF (@isAction = 'true')
    BEGIN
        SET @Filter += ' AND A.IsActioned = 1 AND A.ReportId IN (SELECT ISNULL(AnswerMasterId,SeenClientAnswerMasterId) FROM dbo.CloseLoopAction WITH (NOLOCK) WHERE Conversation LIKE ''%'
                       + @ActionSearch + '%'')';
    END;
    ELSE IF (@isAction = 'false')
    BEGIN
        SET @Filter += ' AND A.IsActioned = 0';
    END;

    IF (@isTransfer = 'true')
        SET @Filter += ' AND A.IsTransferred = 1 AND A.IsOut = 0';

    IF (@isFlag = 'true')
        SET @Filter += ' AND F.IsFlag = 1 AND A.IsOut = 0';

    IF (@ResponseType = 'Responded' OR @ResponseType = 'NotResponded')
    BEGIN
        INSERT INTO #temp
        (
            SeenClientAnswerMasterId
        )
        EXEC ('select A.SeenClientAnswerMasterId FROM  #View_AllAnswerMaster AS A ' + @SqlSelect12 + @SqlSelect2 + @Filter + ' Group By A.SeenClientAnswerMasterId');

        IF (@ResponseType = 'Responded')
        BEGIN
            SET @SqlSelect2 += ' INNER JOIN #temp t ON t.SeenClientAnswerMasterId=A.ID ';

        END;
        ELSE IF (@ResponseType = 'NotResponded')
        BEGIN

            SET @SqlSelect2 += ' left JOIN #temp t ON t.SeenClientAnswerMasterId=A.ID ';
            SET @Filter += ' AND t.SeenClientAnswerMasterId is null ';


        END;
    END;

    IF (@isResponseLink = 'True')
        SET @Filter += ' AND dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10), @AppuserId)
                       + ', CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != ''''';

    IF (@TemplateId != '')
        SET @Filter += @ActionFilter;

    IF (@IsEdited = 'true')
        SET @Filter += ' And A.UpdatedOn IS NOT NULL';

    IF (@PIFilterNo != '')
        SET @Filter += @PIFilterNo;

    IF (@isFromActivity = 'true')
    BEGIN
        SET @SqlSelect12 += CHAR(13)
                            + 'LEFT OUTER JOIN #View_AllAnswerMaster AS RA ON RA.ActivityId = A.ActivityId AND  (RA.ReportId = A.SeenClientAnswerMasterId OR RA.SeenClientAnswerMasterId = A.ReportId)';
        SET @Filter += CHAR(13)
                       + 'AND (SELECT COUNT(1) FROM dbo.PendingNotificationWeb WITH (NOLOCK) WHERE IsDeleted = 0 AND AppUserId = '
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
            FROM #AdvanceQuestionId
            WHERE Id = @S;

            SELECT @Operator = Operator
            FROM #AdvanceQuestionOperator
            WHERE Id = @S;

            SELECT @SearchText = SEARCH
            FROM #AdvanceQuestionSearch
            WHERE Id = @S;

            IF @QuestionTypeId IN ( 1, 2, 19 )
            BEGIN
                SET @Filter += ' AND (' + (CASE @IsOut
                                               WHEN 0 THEN
                                                   'Ans'
                                               ELSE
                                                   'SeenAns'
                                           END
                                          ) + @QuestionId + '.Detail IN ( SELECT Data FROM dbo.Split(''' + @SearchText
                               + ''', '','')) )';;
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
                                         FORMAT(CAST(@SearchText AS DATETIME), 'yyyy-MM-dd HH:MM')
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

    SET @groupby += CHAR(13)
                    + N' GROUP BY A.ReportId , A.EstablishmentId , A.EstablishmentName , A.UserId , A.UserName , A.SenderCellNo , A.IsOutStanding , A.AnswerStatus , A.TimeOffSet ,  
            A.CreatedOn , A.UpdatedOn , A.EI , A.[PI] , A.SmileType , A.QuestionnaireType , A.FormType , A.IsOut , A.QuestionnaireId , A.ReadBy , A.ContactMasterId , A.ContactGroupId , A.Latitude ,  
            A.Longitude , A.IsTransferred , A.TransferToUser , A.TransferFromUser , A.SeenClientAnswerMasterId , A.ActivityId , A.IsActioned , A.TransferByUserId , A.TransferFromUserId , A.IsDisabled ,  
            A.CreatedUserId,F.IsFlag,A.StatusId,A.StatusName,A.StatusImage,A.StatusTime,A.StatusCounter,A.ContactMasterId1,A.ID,  
   a.Quesummary ';

    IF (@isFromActivity = 'true')
    BEGIN
        SET @groupby1 += CHAR(13)
                         + N' GROUP BY A.ReportId , A.EstablishmentId , A.EstablishmentName , A.UserId , A.UserName , A.SenderCellNo , A.IsOutStanding , A.AnswerStatus , A.TimeOffSet ,  
            A.CreatedOn , A.UpdatedOn , A.EI , A.[PI] , A.SmileType , A.QuestionnaireType , A.FormType , A.IsOut , A.QuestionnaireId , A.ReadBy , A.ContactMasterId , A.ContactGroupId , A.Latitude ,  
            A.Longitude , A.IsTransferred , A.TransferToUser , A.TransferFromUser , A.SeenClientAnswerMasterId , A.ActivityId , A.IsActioned , A.TransferByUserId , A.TransferFromUserId , A.IsDisabled ,  
            A.CreatedUserId,F.IsFlag,RA.ReportId,RA.SeenClientAnswerMasterId,A.StatusId,A.StatusName,A.StatusImage,A.StatusTime,A.StatusCounter,  
   A.ContactMasterId1,A.ID ,a.Quesummary,cnt.ContactName ';


    END;
    ELSE
    BEGIN
        SET @groupby1 = @groupby;
    END;

    SET @OrderBYFilter += CHAR(13) + N' ,cnt.ContactName ) as a';

    INSERT INTO #temptable
    EXEC (@SqlSelect1 + @SqlSelect11 + @sqlSelect11_1 + @SqlSelect12 + @SqlSelect2 + @SqlSelect3 + @Filter + @groupby + @OrderBYFilter);
    INSERT INTO @ResultReportId
    (
        ReportId,
        FromType,
        IsOut,
        CreatedOn
    )
    SELECT ReportId,
           FormType,
           IsOut,
           CreatedOn
    FROM #temptable;
END;


DECLARE @UrlFeedBack NVARCHAR(100);
SELECT @UrlFeedBack = KeyValue + 'FeedBack/'
FROM dbo.AAAAConfigSettings
WHERE KeyName = 'DocViewerRootFolderPathWebApp';

DECLARE @UrlSeenClient NVARCHAR(100);
SELECT @UrlSeenClient = KeyValue + 'SeenClient/'
FROM dbo.AAAAConfigSettings
WHERE KeyName = 'DocViewerRootFolderPathWebApp';

SELECT Q.Position,
       Q.Id AS [QuestionID],
       Am.Id AS [AnswerMasterID],
       ISNULL(E.EstablishmentName, '') AS [Establishment Name],
       ISNULL(ISNULL((SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd WITH(NOLOCK) 
		INNER JOIN dbo.ContactQuestions cq WITH(NOLOCK) ON cq.Id = cd.ContactQuestionId WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = (IIF(ISNULL(SCM.ContactMasterId,0) = 0, SAC.ContactMasterId, scm.ContactMasterId)) AND Cd.IsDeleted = 0 AND Cd.Detail <> ''
		ORDER BY cq.position),U.Name),'') AS [Submitted By],
		--ISNULL(U.Name, '') AS [Submitted By],
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
                                   @UrlFeedBack + ANS.Detail
                           END,
                           ',',
                           ' | ' + @UrlFeedBack
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
                SELECT TOP 1
                    Detail
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
           AND RID.FromType = 'Feedback' AND RID.IsOut = 0
	LEFT JOIN dbo.SeenClientAnswerMaster SCM WITH(NOLOCK) ON SCM.Id = am.SeenClientAnswerMasterId
	LEFT JOIN dbo.SeenClientAnswerChild SAC WITH(NOLOCK) ON SAC.Id = am.SeenClientAnswerChildId  
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
        --ON Am.ContactAppUserId = U.Id
		ON U.Id = CASE WHEN Am.ContactAppUserId = 0 OR Am.ContactAppUserId IS NULL THEN Am.AppUserId ELSE Am.ContactAppUserId END
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
ORDER BY Am.Id,
         ANS.RepeatCount,
         Q.Position ASC;

DECLARE @SeenClientAnswerMasterId VARCHAR(MAX) = '';
DECLARE @TempTable TABLE (SeenClientAnswerMasterId INT);
INSERT INTO @TempTable
SELECT ReportId
FROM @ResultReportId WHERE IsOut = 1;

IF OBJECT_ID('tempdb..#tempexcle', 'u') IS NOT NULL
BEGIN
    DROP TABLE #tempexcle;
END;
SELECT DISTINCT
    sca.SeenClientAnswerMasterId,
    ISNULL(SeenClientAnswerChildId, 0) AS SeenClientAnswerChildId
INTO #tempexcle
FROM dbo.SeenClientAnswers sca
    INNER JOIN @TempTable t
        ON t.SeenClientAnswerMasterId = sca.SeenClientAnswerMasterId
           AND ISNULL(sca.SeenClientAnswerChildId, 0) = 0;

IF OBJECT_ID('tempdb..#temp1', 'u') IS NOT NULL
BEGIN
    DROP TABLE #temp1;
END;

SELECT DISTINCT
    sca.SeenClientAnswerMasterId,
    ISNULL(SeenClientAnswerChildId, 0) AS SeenClientAnswerChildId
INTO #temp1
FROM dbo.SeenClientAnswers sca
    INNER JOIN @TempTable t
        ON t.SeenClientAnswerMasterId = sca.SeenClientAnswerMasterId
           AND ISNULL(SeenClientAnswerChildId, 0) <> 0;
IF OBJECT_ID('tempdb..#temptableExcel', 'u') IS NOT NULL
BEGIN
    DROP TABLE #temptableExcel;
END;
CREATE TABLE #temptableExcel
(
    [SeenClientAnswerMasterId] BIGINT,
    [QuestionId] BIGINT,
    [Detail] NVARCHAR(MAX),
    [RepetitiveGroupId] INT,
    [RepeatCount] INT,
    RepetitiveGroupName VARCHAR(100),
    shortName NVARCHAR(2000)
);
IF OBJECT_ID('tempdb..#temptableExcel1', 'u') IS NOT NULL
BEGIN
    DROP TABLE #temptableExcel1;
END;
CREATE TABLE #temptableExcel1
(
    [SeenClientAnswerMasterId] BIGINT,
    [QuestionId] BIGINT,
    [Detail] NVARCHAR(MAX),
    [RepetitiveGroupId] INT,
    [RepeatCount] INT,
    RepetitiveGroupName VARCHAR(100)
);
IF OBJECT_ID('tempdb..#temptableExcel2', 'u') IS NOT NULL
BEGIN
    DROP TABLE #temptableExcel2;
END;
CREATE TABLE #temptableExcel2
(
    [SeenClientAnswerMasterId] BIGINT,
    [QuestionId] BIGINT,
    [Detail] NVARCHAR(MAX),
    [RepetitiveGroupId] INT,
    [RepeatCount] INT,
    RepetitiveGroupName VARCHAR(100)
);
--SELECT GETDATE(),4
INSERT INTO #temptableExcel

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
            FROM dbo.SeenClientQuestions WITH (NOLOCK)
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
        FROM dbo.SeenClientAnswers A WITH (NOLOCK)
            JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
                   AND A.IsDeleted <> 1
                   AND RepeatCount <> 0
            INNER JOIN @TempTable t
                ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId
    ) xx
) X
    CROSS APPLY
(
    SELECT DISTINCT
        (ISNULL(RepeatCount, 0)) AS RepeatCount,
        SCA.SeenClientAnswerMasterId
    FROM SeenClientAnswers SCA WITH (NOLOCK)
        INNER JOIN @TempTable t
            ON t.SeenClientAnswerMasterId = SCA.SeenClientAnswerMasterId
               AND RepeatCount <> 0
               AND IsDeleted = 0
) Y
WHERE X.SeenClientAnswerMasterId = Y.SeenClientAnswerMasterId;
--UNION ALL
/* repeatitive count =1 and child id is 0 or null */

INSERT INTO #temptableExcel
SELECT A.SeenClientAnswerMasterId,
       QuestionId,
       Detail,
       A.RepetitiveGroupId,
       A.RepeatCount,
       A.RepetitiveGroupName,
       B.ShortName
FROM dbo.SeenClientAnswers A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1
           AND A.IsDeleted <> 1
           AND RepeatCount <> 0
    INNER JOIN #tempexcle t
        ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId;
/* repeatitive count =1 and child id is not null and <> 0 */


INSERT INTO #temptableExcel1
SELECT DISTINCT
    A.SeenClientAnswerMasterId,
    QuestionId,
    Detail,
    A.RepetitiveGroupId,
    A.RepeatCount,
    A.RepetitiveGroupName
FROM dbo.SeenClientAnswers A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1
           AND A.IsDeleted <> 1
           AND A.RepeatCount <> 0
    INNER JOIN #tempexcle t
        ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId
GROUP BY A.SeenClientAnswerChildId,
         A.SeenClientAnswerMasterId,
         QuestionId,
         Detail,
         A.RepeatCount,
         RepetitiveGroupId,
         A.RepetitiveGroupName; 

INSERT INTO #temptableExcel
SELECT DISTINCT
    A.SeenClientAnswerMasterId,
    A.QuestionId,
    A.Detail,
    A.RepetitiveGroupId,
    A.RepeatCount,
    A.RepetitiveGroupName,
    B.ShortName
FROM #temptableExcel1 A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1; --) a 		  
--UNION ALL
INSERT INTO #temptableExcel
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
            FROM dbo.SeenClientQuestions WITH (NOLOCK)
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
        FROM dbo.SeenClientAnswers A WITH (NOLOCK)
            JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
                ON A.QuestionId = B.Id
                   AND B.SeenClientId = @SeenClientID
                   AND B.IsDeleted <> 1
                   AND A.IsDeleted <> 1
                   AND ISNULL(RepeatCount, 0) = 0
            INNER JOIN @TempTable t
                ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId
    ) xx
) X
    CROSS APPLY
(
    SELECT DISTINCT
        (ISNULL(RepeatCount, 0)) AS RepeatCount,
        SCA.SeenClientAnswerMasterId
    FROM SeenClientAnswers SCA WITH (NOLOCK)
        INNER JOIN @TempTable t
            ON t.SeenClientAnswerMasterId = SCA.SeenClientAnswerMasterId
               AND ISNULL(RepeatCount, 0) = 0
               AND IsDeleted = 0
) Y
WHERE X.SeenClientAnswerMasterId = Y.SeenClientAnswerMasterId;

--UNION ALL
INSERT INTO #temptableExcel
SELECT A.SeenClientAnswerMasterId,
       QuestionId,
       Detail,
       A.RepetitiveGroupId,
       ISNULL(A.RepeatCount, 0),
       A.RepetitiveGroupName,
       B.ShortName
FROM dbo.SeenClientAnswers A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1
           AND A.IsDeleted <> 1
           AND ISNULL(A.RepeatCount, 0) = 0
    INNER JOIN #tempexcle t
        ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId;

--UNION ALL

INSERT INTO #temptableExcel2
SELECT DISTINCT
    A.SeenClientAnswerMasterId,
    QuestionId,
    Detail,
    A.RepetitiveGroupId,
    ISNULL(A.RepeatCount, 0),
    A.RepetitiveGroupName
FROM dbo.SeenClientAnswers A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1
           AND A.IsDeleted <> 1
           AND ISNULL(A.RepeatCount, 0) = 0
    INNER JOIN #temp1 t
        ON t.SeenClientAnswerMasterId = A.SeenClientAnswerMasterId
GROUP BY A.SeenClientAnswerChildId,
         A.SeenClientAnswerMasterId,
         QuestionId,
         Detail,
         ISNULL(A.RepeatCount, 0),
         A.RepetitiveGroupId,
         A.RepetitiveGroupName;

INSERT INTO #temptableExcel
SELECT DISTINCT
    A.SeenClientAnswerMasterId,
    A.QuestionId,
    A.Detail,
    A.RepetitiveGroupId,
    ISNULL(A.RepeatCount, 0),
    A.RepetitiveGroupName,
    B.ShortName
FROM #temptableExcel2 A WITH (NOLOCK)
    INNER JOIN dbo.SeenClientQuestions B WITH (NOLOCK)
        ON A.QuestionId = B.Id
           AND B.SeenClientId = @SeenClientID
           AND B.IsDeleted <> 1;

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
               '(' + ISNULL(RepetitiveGroupName, '') + CAST(ISNULL(RepeatCount, 0) AS VARCHAR(20)) + ')' + shortName
           ELSE
               shortName
       END AS Question
FROM #temptableExcel;
--SELECT * FROM #temptableExcel WHERE SeenClientAnswerMasterId =807687
--SELECT * FROM #Exporttemptable WHERE SeenClientAnswerMasterId =807687
SELECT [Position],
       [AnswerMasterID],
       [QuestionID],
       [Establishment Name],
       [User Name],
       [Capture Date],
       [Out Reference No],
       [Reference No],
       [PI],
       [Contact Group Name],
       [Question],
       [Answer],
       [Resolve/Unresolved],
       ISNULL([Resolution Comments], '') AS [Resolution Comments],
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
           --dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 'dd-MMM-yyyy hh:mm AM/PM') AS [Capture Date],
           REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') + ' '
           + STUFF(RIGHT(CONVERT(VARCHAR, DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 100), 7), 6, 0, ' ') AS [Capture Date],
           ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
           Am.Id AS [Reference No],
           ISNULL(Am.[PI], 0.00) AS [PI],
           ISNULL(ContactGropName, '') AS [Contact Group Name],
           ANS.Question,
           CASE Q.QuestionTypeId
               WHEN 8 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy')
                    CONVERT(NVARCHAR(50), FORMAT(CAST(ANS.Detail AS DATE), 'dd/MMM/yyyy'))
            END
           )
               WHEN 9 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'hh:mm AM/PM')
                    CONVERT(NVARCHAR(50), FORMAT(CAST(ANS.Detail AS TIME), 'hh:mm tt'))
            END
           )
               WHEN 22 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                    REPLACE(CONVERT(VARCHAR(11), ANS.Detail, 106), ' ', '/') + ' '
                    + STUFF(RIGHT(CONVERT(VARCHAR, ANS.Detail, 100), 7), 6, 0, ' ')
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
                                       @UrlSeenClient + ANS.Detail
                               END,
                               ',',
                               ' | ' + @UrlSeenClient
                           )
            END
           )
               ELSE
                   ISNULL(ANS.Detail, '')
           END AS [Answer],
           Am.IsResolved AS [Resolve/Unresolved],
           --dbo.ConcateString('ResolutionCommentsSeenClient', Am.Id) AS [Resolution Comments],	 	
           (
               SELECT STUFF(
                      (
                          SELECT ISNULL(ResolutionComments.Comments, '')
                          FROM
                          (
                              SELECT (CONVERT(VARCHAR(50), ROW_NUMBER() OVER (ORDER BY dbo.CloseLoopAction.Id ASC))
                                      + ') ' + dbo.AppUser.Name + ' - '
                                      + FORMAT(
                                                  DATEADD(MINUTE, TimeOffSet, dbo.CloseLoopAction.CreatedOn),
                                                  'dd/MMM/yyyy  h:mm tt'
                                              ) + ' - '
                                      + REPLACE(REPLACE(ISNULL([Conversation], ''), CHAR(13), ' '), CHAR(10), ' ')
                                     ) AS Comments
                              FROM dbo.CloseLoopAction WITH (NOLOCK)
                                  INNER JOIN dbo.SeenClientAnswerMaster WITH (NOLOCK)
                                      ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId
                                  INNER JOIN dbo.AppUser WITH (NOLOCK)
                                      ON CloseLoopAction.AppUserId = dbo.AppUser.Id
                              WHERE dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.Id
                          ) AS ResolutionComments
                          FOR XML PATH('')
                      ),
                      1,
                      0,
                      ''
                           )
           ) AS [Resolution Comments],
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
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN @ResultReportId AS RID
            ON Am.Id = RID.ReportId
               AND RID.IsOut = 1
               AND Am.IsDeleted = 0
        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
            ON Qr.Id = Am.SeenClientId
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON Q.SeenClientId = Am.SeenClientId
               AND Q.IsDeleted = 0
               AND Q.QuestionTypeId NOT IN ( 16, 23 )
               AND Q.IsDisplayInDetail = 1
               AND ISNULL(Q.QuestionsGroupNo, 0) = 0
               AND Q.IsActive = 1
               AND Q.ContactQuestionId IS NULL
        LEFT JOIN dbo.ContactQuestions AS CQ WITH (NOLOCK)
            ON CQ.Id = Q.ContactQuestionId
               AND CQ.IsDeleted = 0
        LEFT JOIN #Exporttemptable AS ANS
            ON ANS.SeenClientAnswerMasterId = Am.Id
               AND ANS.QuestionId = Q.Id
        LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM WITH (NOLOCK)
            ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser WITH (NOLOCK)
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.AppUser AS TransferByUser WITH (NOLOCK)
            ON Am.CreatedBy = TransferByUser.Id
        LEFT JOIN dbo.ContactGroup cg
            ON Am.ContactGroupId = cg.Id --AND Am.Id = Am.Id

    UNION ALL
    SELECT Q.Position,
           Am.Id AS AnswerMasterID,
           Q.Id AS QuestionID,
           E.EstablishmentName AS [Establishment Name],
           ISNULL(U.Name, '') AS [User Name],
           --dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 'dd-MMM-yyyy hh:mm AM/PM') AS [Capture Date],
           REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') + ' '
           + STUFF(RIGHT(CONVERT(VARCHAR, DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 100), 7), 6, 0, ' ') AS [Capture Date],
           ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
           Am.Id AS [Reference No],
           ISNULL(Am.[PI], 0.00) AS [PI],
           ISNULL(ContactGropName, '') AS [Contact Group Name],
           ANS.Question,
           (CASE
                WHEN ANS.Detail IS NULL THEN
                    ISNULL(dbo.GetContactDetailsForGroupFeedback(Am.Id, CQ.Id), '')
                ELSE
                    ANS.Detail
            END
           ) AS [Answer],
           Am.IsResolved AS [Resolve/Unresolved],
           (
               SELECT STUFF(
                      (
                          SELECT ISNULL(ResolutionComments.Comments, '')
                          FROM
                          (
                              SELECT (CONVERT(NVARCHAR(50), ROW_NUMBER() OVER (ORDER BY dbo.CloseLoopAction.Id ASC))
                                      + ') ' + dbo.AppUser.Name + ' - '
                                      + FORMAT(
                                                  DATEADD(MINUTE, TimeOffSet, dbo.CloseLoopAction.CreatedOn),
                                                  'dd/MMM/yyyy  h:mm tt'
                                              ) + ' - '
                                      + REPLACE(REPLACE(ISNULL([Conversation], ''), CHAR(13), ' '), CHAR(10), ' ')
                                     ) AS Comments
                              FROM dbo.CloseLoopAction WITH (NOLOCK)
                                  INNER JOIN dbo.SeenClientAnswerMaster WITH (NOLOCK)
                                      ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId
                                  INNER JOIN dbo.AppUser WITH (NOLOCK)
                                      ON CloseLoopAction.AppUserId = dbo.AppUser.Id
                              WHERE dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.Id
                          ) AS ResolutionComments
                          FOR XML PATH('')
                      ),
                      1,
                      0,
                      ''
                           )
           ) AS [Resolution Comments],
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
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN @ResultReportId AS RID
            ON Am.Id = RID.ReportId
               AND Am.IsDeleted = 0
               AND RID.IsOut = 1
        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
            ON Qr.Id = Am.SeenClientId
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON Q.SeenClientId = Am.SeenClientId
               AND Q.IsDeleted = 0
               AND Q.QuestionTypeId NOT IN ( 16, 23 )
               AND Q.IsDisplayInDetail = 1
               AND ISNULL(Q.QuestionsGroupNo, 0) = 0
               AND Q.IsActive = 1
               AND Q.ContactQuestionId IS NOT NULL
        LEFT JOIN dbo.ContactQuestions AS CQ WITH (NOLOCK)
            ON CQ.Id = Q.ContactQuestionId
               AND CQ.IsDeleted = 0
        LEFT JOIN #Exporttemptable AS ANS
            ON ANS.SeenClientAnswerMasterId = Am.Id
               AND ANS.QuestionId = Q.Id
        LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM WITH (NOLOCK)
            ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser WITH (NOLOCK)
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.AppUser AS TransferByUser WITH (NOLOCK)
            ON Am.CreatedBy = TransferByUser.Id
        LEFT JOIN dbo.ContactGroup cg
            ON Am.ContactGroupId = cg.Id --AND Am.Id = Am.Id
    UNION ALL
    SELECT Q.Position,
           Am.Id AS AnswerMasterID,
           Q.Id AS QuestionID,
           E.EstablishmentName AS [Establishment Name],
           ISNULL(U.Name, '') AS [User Name],
           REPLACE(CONVERT(VARCHAR(11), DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 106), ' ', '-') + ' '
           + STUFF(RIGHT(CONVERT(VARCHAR, DATEADD(MINUTE, E.TimeOffSet, Am.CreatedOn), 100), 7), 6, 0, ' ') AS [Capture Date],
           ISNULL(Am.SeenClientAnswerMasterId, '') AS [Out Reference No],
           Am.Id AS [Reference No],
           ISNULL(Am.[PI], 0.00) AS [PI],
           ISNULL(ContactGropName, '') AS [Contact Group Name],
           ANS.Question,
           CASE Q.QuestionTypeId
               WHEN 8 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy')
                    CONVERT(NVARCHAR(50), FORMAT(CAST(ANS.Detail AS DATE), 'dd/MMM/yyyy'))
            END
           )
               WHEN 9 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'hh:mm AM/PM')
                    CONVERT(NVARCHAR(50), FORMAT(CAST(ANS.Detail AS TIME), 'hh:mm tt'))
            END
           )
               WHEN 22 THEN
           (CASE
                WHEN ANS.Detail IS NULL
                     OR ANS.Detail = '' THEN
                    ISNULL(ANS.Detail, '')
                ELSE
                    --dbo.ChangeDateFormat(ANS.Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                    REPLACE(CONVERT(VARCHAR(11), ANS.Detail, 106), ' ', '/') + ' '
                    + STUFF(RIGHT(CONVERT(VARCHAR, ANS.Detail, 100), 7), 6, 0, ' ')
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
                                       @UrlSeenClient + ANS.Detail
                               END,
                               ',',
                               ' | ' + @UrlSeenClient
                           )
            END
           )
               ELSE
                   ISNULL(ANS.Detail, '')
           END AS [Answer],
           Am.IsResolved AS [Resolve/Unresolved],
           (
               SELECT STUFF(
                      (
                          SELECT ISNULL(ResolutionComments.Comments, '')
                          FROM
                          (
                              SELECT (CONVERT(NVARCHAR(50), ROW_NUMBER() OVER (ORDER BY dbo.CloseLoopAction.Id ASC))
                                      + ') ' + dbo.AppUser.Name + ' - '
                                      + FORMAT(
                                                  DATEADD(MINUTE, TimeOffSet, dbo.CloseLoopAction.CreatedOn),
                                                  'dd/MMM/yyyy  h:mm tt'
                                              ) + ' - '
                                      + REPLACE(REPLACE(ISNULL([Conversation], ''), CHAR(13), ' '), CHAR(10), ' ')
                                     ) AS Comments
                              FROM dbo.CloseLoopAction WITH (NOLOCK)
                                  INNER JOIN dbo.SeenClientAnswerMaster WITH (NOLOCK)
                                      ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId
                                  INNER JOIN dbo.AppUser WITH (NOLOCK)
                                      ON CloseLoopAction.AppUserId = dbo.AppUser.Id
                              WHERE dbo.CloseLoopAction.SeenClientAnswerMasterId = Am.Id
                          ) AS ResolutionComments
                          FOR XML PATH('')
                      ),
                      1,
                      0,
                      ''
                           )
           ) AS [Resolution Comments],
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
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN @ResultReportId AS RID
            ON Am.Id = RID.ReportId
               AND Am.IsDeleted = 0
               AND RID.IsOut = 1
        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
            ON Qr.Id = Am.SeenClientId
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON Q.SeenClientId = Am.SeenClientId
               AND Q.IsDeleted = 0
               AND Q.QuestionTypeId NOT IN ( 16, 23 )
               AND Q.IsDisplayInDetail = 1
               AND ISNULL(Q.QuestionsGroupNo, 0) > 0
               AND Q.IsActive = 1
        LEFT JOIN dbo.ContactQuestions AS CQ WITH (NOLOCK)
            ON CQ.Id = Q.ContactQuestionId
               AND CQ.IsDeleted = 0
        LEFT JOIN #Exporttemptable AS ANS
            ON ANS.SeenClientAnswerMasterId = Am.Id
               AND ANS.QuestionId = Q.Id
        LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM WITH (NOLOCK)
            ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser WITH (NOLOCK)
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.AppUser AS TransferByUser WITH (NOLOCK)
            ON Am.CreatedBy = TransferByUser.Id
        LEFT JOIN dbo.ContactGroup cg
            ON Am.ContactGroupId = cg.Id --AND Am.Id = Am.Id
) AS TM
WHERE TM.Question IS NOT NULL
ORDER BY TM.RepeatCount,
         TM.Position;
END
