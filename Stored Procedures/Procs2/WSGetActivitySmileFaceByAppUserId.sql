-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActivitySmileFaceByAppUserId 314
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActivitySmileFaceByAppUserId] @AppUserId BIGINT
AS
    BEGIN
        SELECT  Eg.Id AS ActivityId ,
                Eg.EstablishmentGroupName AS ActivityName ,
                dbo.GetSmileFaceByActivityId(Eg.Id, Eg.SmileOn, @AppUserId) AS SmileType,
				(SELECT dbo.GetBadgeCountForActivity(@AppUserId,Eg.Id)) AS BadgeCount,
				CASE ISNULL(Eg.AttachmentLimit,0) WHEN 0 THEN 10 ELSE Eg.AttachmentLimit end AS AttachmentLimit,
				Eg.AutoSaveLimit AS AutoSaveLimit
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
        WHERE   UE.IsDeleted = 0
                AND AppUserId = @AppUserId
        GROUP BY Eg.Id ,
                Eg.EstablishmentGroupName ,
                Eg.SmileOn,
				Eg.AttachmentLimit,
				Eg.AutoSaveLimit;
    END;
