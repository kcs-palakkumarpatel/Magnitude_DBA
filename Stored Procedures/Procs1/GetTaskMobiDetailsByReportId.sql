-- =============================================
-- Author:				Sunil Vaghasiya
-- Create date:		21-June-2017
-- Description:	Get feedback IN by SeenClientAnswerMasterId
-- Call SP:			dbo.GetTaskMobiDetailsByReportId 976333,877442, 1246
-- =============================================
CREATE PROCEDURE [dbo].[GetTaskMobiDetailsByReportId]
    @ReportId BIGINT,
    @MobiReportId BIGINT,
    @AppuserId BIGINT
AS
BEGIN
    SELECT AM.Id AS MobiId,
           AM.EstablishmentId,
           AM.PI AS PI,
           E.EstablishmentName AS EstablishmentName,
           Eg.EstablishmentGroupName AS ActivityName,
           Eg.Id AS ActivityId,
           Eg.SeenClientId,
           Eg.SadTo,
           Eg.NeutralTo,
           '' AS PIColourCode,
           U.Name AS CapturedBy,
           ISNULL(U.Mobile, '') AS AppUserContactNo,
           ISNULL(U.Email, '') AS AppUserEmailId,
           dbo.ChangeDateFormat(DATEADD(MINUTE, AM.TimeOffSet, AM.CreatedOn), 'dd/MMM/yy HH:mm') AS CaptureDate,
           (
               SELECT ISNULL(
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
                                AND AppUserId = @AppuserId
                                AND ModuleId IN ( 11, 12 )
                      ),
                      0
                            )
           ) AS ChatCount,
           (
               SELECT ISNULL(
                      (
                          SELECT TOP 1
                                 Conversation
                          FROM ChatDetails
                          WHERE SeenClientAnswerMasterId = @ReportId
                          ORDER BY ChatId DESC
                      ),
                      ''
                            )
           ) AS LastChat,
           (
               SELECT ISNULL(
                      (
                          SELECT TOP 1
                                 CustomerName
                          FROM ChatDetails
                          WHERE SeenClientAnswerMasterId = @ReportId
                          ORDER BY ChatId DESC
                      ),
                      ''
                            )
           ) AS LastChatBy,
		   ISNULL(AM.IsDisabled,0) AS IsDisabled,
		   ISNULL(U.AllowExportData,0) AS AllowExportData,
		   ISNULL(U.AllowDeleteFeedback,0) AS AllowDeleteFeedback,
		   Eg.InFormRefNumber
    FROM AnswerMaster AS AM
        INNER JOIN dbo.Establishment AS E
            ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        LEFT OUTER JOIN dbo.AppUser AS U
            ON AM.AppUserId = U.Id
    WHERE AM.Id = @MobiReportId
          AND ISNULL(AM.IsDeleted, 0) = 0;
END;
/*
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
					*/



