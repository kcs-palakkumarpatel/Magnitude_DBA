-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 18-May-2021
-- Description: Get Unallocated Task List By ActivityId
-- SP call: GetUnallocatedTaskListByActivityId 5819, 6130,'0','',NULL,NULL,0,'',0,1,'',1,50
-- GetProductIssueInfoGraphData 19553, 2101,'','','2020-05-05 09:11:59.103','2021-05-05 09:11:59.103',1,'',''
-- GetAllTableViewDataForGraph 19553,8751,0,0,'','',3,3
-- =============================================
CREATE PROCEDURE dbo.GetAllTableViewDataForGraph
    @AppUserId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId NVARCHAR(MAX),
    @UserId NVARCHAR(MAX),
    @FormStatus VARCHAR(50),
    @FilterOn NVARCHAR(MAX),
    @StatusIds VARCHAR(MAX) = '',
	@DateFilterId INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ServerDate DATETIME = GETUTCDATE(),
            @FromDate DATETIME = '',
            @ToDate DATETIME = '';

    IF (@DateFilterId = 1)
    BEGIN
        SET @FromDate = @ServerDate;
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 2)
    BEGIN
        SET @FromDate = DATEADD(DAY, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 3)
    BEGIN
        SET @FromDate = DATEADD(DAY, -30, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 4)
    BEGIN
        SET @FromDate = DATEADD(MONTH, -6, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 5)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -1, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 6)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 7)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;

    DECLARE @AllIssueInfo AS TABLE
    (
        OptionId BIGINT,
        Name NVARCHAR(1000),
        AllCounts BIGINT,
        OpenCounts BIGINT,
        QuestionId BIGINT,
        Title VARCHAR(1000)
    );
    DECLARE @GraphQuestion AS TABLE
    (
        AutoId INT PRIMARY KEY IDENTITY(1, 1),
        Id BIGINT NOT NULL,
        QuestionTitle NVARCHAR(250) NOT NULL,
        [Count] BIGINT NOT NULL,
        QuestionId BIGINT NOT NULL,
        CurrentDate DATETIME NOT NULL
    );
    INSERT INTO @GraphQuestion
    (
        Id,
        QuestionTitle,
        Count,
        QuestionId,
        CurrentDate
    )
    EXEC dbo.GetTableGraphQuestions @AppuserId = @AppUserId,
                                    @ActivityId = @ActivityId,
                                    @EstablishmentId = @EstablishmentId,
                                    @UserId = @UserId,
                                    @IsOut = 1;

    DECLARE @TotalGraphQuestion INT = 0,
            @Count INT = 1,
            @QuestionId BIGINT,
            @Title VARCHAR(1000);
    SELECT *
    FROM @GraphQuestion;
    SELECT @TotalGraphQuestion = COUNT(*)
    FROM @GraphQuestion;

    WHILE @Count <= @TotalGraphQuestion
    BEGIN

        SELECT @QuestionId = QuestionId,
               @Title = QuestionTitle
        FROM @GraphQuestion
        WHERE AutoId = @Count;

        INSERT INTO @AllIssueInfo
        (
            OptionId,
            Name,
            AllCounts,
            OpenCounts,
            QuestionId,
            Title
        )
        EXEC dbo.GetTableGraphDataByQuestionId @AppUserId = @AppUserId,
                                               @ActivityId = @ActivityId,
                                               @EstablishmentId = @EstablishmentId,
                                               @UserId = @UserId,
                                               @FromDate = @FromDate,
                                               @ToDate = @ToDate,
                                               @FormStatus = @FilterOn,
                                               @QuestionId = @QuestionId,
                                               @Title = @Title;
        SET @Count = @Count + 1;
    END;
    SELECT OptionId,
           Name,
           AllCounts,
           OpenCounts,
           QuestionId,
           Title
    FROM @AllIssueInfo;

SET NOCOUNT OFF;
END;
