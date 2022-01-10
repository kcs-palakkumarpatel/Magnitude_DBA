-- =============================================
-- Author:				Sunil Vaghasiya
-- Create date:		21-June-2017
-- Description:	Get feedback IN by SeenClientAnswerMasterId
-- Call SP:			dbo.WSGetTaskMobiViewByReportId 976333, 1246
-- =============================================
CREATE PROCEDURE [dbo].[WSGetTaskMobiViewByReportId]
    @ReportId BIGINT,
	@AppuserId BIGINT,
	@Page INT = 1, /* Select Page No  */
    @Rows INT = 20
AS
    BEGIN

	
    IF @Rows <> ''
       AND @Rows IS NULL
    BEGIN
        SET @Rows = 20;
    END;

    IF @Page <> ''
       AND @Page IS NULL
    BEGIN
        SET @Page = 1;
    END;

	SELECT
		  Am.Id as MobiId,
		  Am.EstablishmentId,
		  AM.PI as PI,
		  E.EstablishmentName as EstablishmentName,
		  Eg.EstablishmentGroupName as ActivityName,
		  Eg.Id as ActivityId,
		  Eg.SeenClientId,
		  Eg.SadTo,
		  Eg.NeutralTo,
		  '' AS PIColourCode,
		  U.Name as CapturedBy,
		  dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'DD/MM/yy HH:mm') AS CaptureDate,
		  /*(SELECT ISNULL(
            (
                SELECT TOP 1
                    SUM(   CASE
                               WHEN IsRead = 0 THEN
                                   1
                               ELSE
                                   0
                           END
                       ) OVER () AS Unread
                FROM dbo.PendingNotificationWeb
                WHERE RefId = @ReportId
                      AND AppUserId = @AppUserId
                      AND ModuleId IN ( 11, 12 )
            ),
            0
                  )) AS ChatCount
		   (SELECT ISNULL(
					(Select top 1 Conversation from ChatDetails 
					Where SeenClientAnswerMasterId = @ReportId
					Order By ChatId Desc 
				), '')) as LastChat,
		  (SELECT ISNULL(
					(Select top 1 CustomerName from ChatDetails 
					Where SeenClientAnswerMasterId = @ReportId
					Order By ChatId Desc 
				), '')) as LastChatBy
				*/
		  CAST(0 AS INT) AS Total,
          CAST(0 AS BIGINT) AS RowNum
		  FROM AnswerMaster as AM
		  INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
		  INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
		  LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
		  Where AM.SeenClientAnswerMasterId = @ReportId
          ORDER BY AM.CreatedOn ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

		 Select top 1 ISNULL(Conversation,'') As LastChat, ISNULL(CustomerName, '') as LastChatBy, 
		  (SELECT ISNULL((
                SELECT TOP 1
                    SUM(   CASE
                               WHEN IsRead = 0 THEN
                                   1
                               ELSE
                                   0
                           END
                       ) OVER () AS Unread
                FROM dbo.PendingNotificationWeb
                WHERE RefId = @ReportId
                      AND AppUserId = @AppUserId
                      AND ModuleId IN ( 11, 12 )
            ),0)) AS ChatCount
			from ChatDetails 
					Where SeenClientAnswerMasterId = @ReportId
					Order By ChatId Desc 

		 Select Id as Id, Name as PIName, ColourCode as PIColourCode From PiColourCodes
END


