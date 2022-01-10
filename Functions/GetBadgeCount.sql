-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetBadgeCount] 
(
 @AppuserId INT
)
RETURNS INT
AS
BEGIN
	RETURN	(SELECT (SELECT  COUNT(1)
        FROM    dbo.PendingNotificationWeb AS PNW 
		INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
		INNER JOIN dbo.SeenClientAnswerMaster SA ON sa.Id = PNW.RefId
        WHERE   PNW.AppUserId = @AppUserId
                AND IsRead = 0
				AND PNW.IsDeleted = 0
				AND SA.IsDeleted = 0
                AND ModuleId IN (8, 12)
				AND (A.IsAreaManager = 1 OR sa.AppUserId = pnw.AppUserId))
+
(SELECT  COUNT(1)
      FROM    dbo.PendingNotificationWeb AS PNW 
		INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
		INNER JOIN dbo.AnswerMaster AM ON AM.Id = PNW.RefId
        WHERE   PNW.AppUserId = @AppUserId
                AND IsRead = 0
				AND PNW.IsDeleted = 0
				AND AM.IsDeleted = 0
                AND ModuleId IN (7, 11)
				AND (AM.AppUserId = 0 OR A.IsAreaManager = 1 OR AM.AppUserId = pnw.AppUserId)))

END
