-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 18-May-2021
-- Description: Get Unallocated Task List By ActivityId
-- SP call: GetUnallocatedTaskListByActivityId 5819, 6130,'0','',NULL,NULL,0,'',0,1,'',1,50
-- GetAnalyticsGraphData 18261, 7963,'0','0',3,3
-- GetTableGraphQuestions 19553, 8751,'0','0',1

-- =============================================
CREATE PROCEDURE dbo.GetAnalyticsGraphData
    @AppUserId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId NVARCHAR(MAX) = '0',
    @UserId NVARCHAR(MAX) = '0',
    @FilterOn NVARCHAR(MAX) = '',
    @StatusIds VARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.GetProductIssueInfoGraphData @AppUserId = @AppUserId,
                                          @ActivityId = @ActivityId,
                                          @EstablishmentId = @EstablishmentId,
                                          @UserId = @UserId,
                                          @IsOut = 1,
                                          @FormStatus = '',
                                          @FilterOn = @FilterOn,
                                          @StatusIds = @StatusIds,
                                          @DateFilterId = 3;
    -- Response Form
    EXEC dbo.GetProductIssueInfoGraphData @AppUserId = @AppUserId,
                                          @ActivityId = @ActivityId,
                                          @EstablishmentId = @EstablishmentId,
                                          @UserId = @UserId,
                                          @IsOut = 0,
                                          @FormStatus = '',
                                          @FilterOn = @FilterOn,
                                          @StatusIds = @StatusIds,
                                          @DateFilterId = 3;
    -- Unresolved Product Issue
    EXEC dbo.GetProductIssueInfoGraphData @AppUserId = @AppUserId,
                                          @ActivityId = @ActivityId,
                                          @EstablishmentId = @EstablishmentId,
                                          @UserId = @UserId,
                                          @IsOut = 1,
                                          @FormStatus = 'Unresolved',
                                          @FilterOn = @FilterOn,
                                          @StatusIds = @StatusIds,
                                          @DateFilterId = 3;

    -- All Product Issue Total and open counts
    EXEC dbo.GetAllTableViewDataForGraph @AppUserId = @AppUserId,
                                         @ActivityId = @ActivityId,
                                         @EstablishmentId = @EstablishmentId,
                                         @UserId = @UserId,
                                         @FormStatus = '',
                                         @FilterOn = @FilterOn,
                                         @StatusIds = @StatusIds,
                                         @DateFilterId = 3;

    -- User Activity
    EXEC dbo.GetUserActivityGraphData @AppUserId = @AppUserId,
                                      @ActivityId = @ActivityId,
                                      @EstablishmentId = @EstablishmentId,
                                      @UserId = @UserId,
                                      @FilterOn = @FilterOn,
                                      @StatusIds = @StatusIds,
                                      @DateFilterId = 3;


    -- Work Status Graph

    --IF (@FromDate IS NULL AND @ToDate IS NULL)
    --BEGIN
    --    SET @FromDate = DATEADD(DAY, -7, @ServerDate);
    --    SET @ToDate = @ServerDate;
    --END;

    SELECT 0 AS ReferenceNo,
           '' AS StatusName,
           '' AS StatusDateTime,
           '' AS AppUserName,
           '' AS EstablishmentName;

--SELECT SH.ReferenceNo,
--       ESS.StatusName,
--       SH.StatusDateTime,
--       AU.Name AS AppUserName,
--       E.EstablishmentName
--FROM dbo.StatusHistory SH
--    INNER JOIN dbo.AppUser AU
--        ON AU.Id = SH.UserId
--    INNER JOIN dbo.EstablishmentStatus ESS
--        INNER JOIN dbo.Establishment E
--            ON E.Id = ESS.EstablishmentId
--        ON ESS.Id = SH.EstablishmentStatusId
--WHERE CAST(SH.StatusDateTime AS DATETIME)
--      BETWEEN DATEADD(MINUTE, E.TimeOffSet, @FromDate) AND DATEADD(MINUTE, E.TimeOffSet, @ToDate)
--      AND ISNULL(SH.IsDeleted, 0) = 0
--ORDER BY SH.ReferenceNo DESC;
SET NOCOUNT OFF;
END;
