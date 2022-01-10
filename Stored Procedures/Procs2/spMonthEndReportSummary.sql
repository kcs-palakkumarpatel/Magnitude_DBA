-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Sep 2015>
-- Description:	<Description,,>
-- Call SP:		spMonthEndReportSummary 1 , '2,3,7,8,11', '01 Jan 2015', '10 Sep 2015'
-- =============================================
CREATE PROCEDURE [dbo].[spMonthEndReportSummary]
    @EstablishmentId BIGINT ,
    @GroupId NVARCHAR(MAX) ,
    @FromDate DATETIME ,
    @ToDate DATETIME
AS
    BEGIN
        DECLARE @Count BIGINT ,
            @ActivityName NVARCHAR(MAX);

        SELECT  @Count = COUNT(1)
        FROM    dbo.AnswerMaster AS Am
        WHERE   IsDeleted = 0
                AND EstablishmentId = @EstablishmentId
                AND CAST(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @ToDate;        
		
        SELECT  @ActivityName = COALESCE(@ActivityName + ' | ', '')
                + Eg.EstablishmentName
        FROM    dbo.Establishment AS Eg
        WHERE   Eg.Id IN ( SELECT   Data
                           FROM     dbo.Split(@GroupId, ',') )
                AND Eg.IsDeleted = 0;

        SELECT  ISNULL(@Count, 0) AS FeedBackCount ,
                ISNULL(@ActivityName, '') AS ActivityName ,
                dbo.ChangeDateFormat(@FromDate, 'MM/dd/yyyy') AS FromDate ,
                dbo.ChangeDateFormat(@ToDate, 'MM/dd/yyyy') AS ToDate ,
                EstablishmentName
        FROM    dbo.Establishment
        WHERE   Id = @EstablishmentId;
    END;