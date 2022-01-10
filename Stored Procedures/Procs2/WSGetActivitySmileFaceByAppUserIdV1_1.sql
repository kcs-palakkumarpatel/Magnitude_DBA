-- =============================================
-- Author:		<Author,,Vasu Patel>
-- Create date: <Create Date,,20 Sep 2017>
-- Description:	<Description,,>
-- Call SP:		WSGetActivitySmileFaceByAppUserIdV1 366,'1269|50'
-- =============================================
CREATE PROCEDURE dbo.WSGetActivitySmileFaceByAppUserIdV1_1
		@AppUserId BIGINT,
		@ActivityLastDay VARCHAR(1000)
AS
    BEGIN

    DECLARE @tbl TABLE ( ActiviyId INT, [Days] INT );
    INSERT  INTO @tbl
     SELECT  LEFT(Data, CHARINDEX('|', Data) - 1) AS ActivityId ,
            RIGHT(Data, CHARINDEX('|', REVERSE(Data)) - 1) AS [Days]
    FROM    dbo.Split(@ActivityLastDay, ',')
    

        SELECT  Eg.Id AS ActivityId ,
                Eg.EstablishmentGroupName AS ActivityName ,
                dbo.GetSmileFaceByActivityId(Eg.Id, Eg.SmileOn, @AppUserId) AS SmileType,
				(SELECT dbo.GetBadgeCountForActivity(@AppUserId,Eg.Id)) AS BadgeCount,
				CASE ISNULL(Eg.AttachmentLimit,0) WHEN 0 THEN 10 ELSE Eg.AttachmentLimit end AS AttachmentLimit,
				Eg.AutoSaveLimit AS AutoSaveLimit,
				(CASE WHEN UE.EstablishmentType = 'Sales' THEN (SELECT COUNT(DISTINCT Id) FROM dbo.SeenClientAnswerMaster WHERE IsResolved = 'Unresolved' AND EstablishmentId IN (SELECT E.id FROM dbo.Establishment AS E INNER JOIN dbo.AppUserEstablishment UE ON E.Id = UE.EstablishmentId AND UE.AppUserId = @AppUserId WHERE EstablishmentGroupId = eg.Id AND UE.IsDeleted = 0 AND E.IsDeleted = 0) AND IsDeleted = 0)
				ELSE (SELECT COUNT(1) FROM dbo.AnswerMaster WHERE IsResolved = 'Unresolved' AND EstablishmentId IN (SELECT E.id FROM dbo.Establishment AS E INNER JOIN dbo.AppUserEstablishment UE ON E.Id = UE.EstablishmentId AND UE.AppUserId = @AppUserId WHERE EstablishmentGroupId = Eg.Id AND UE.IsDeleted = 0 AND E.IsDeleted = 0) AND IsDeleted = 0) END) AS Unresolved,
				(select dbo.GetBadgeCountINOUT(@AppUserId,Eg.Id,[T].[days],1)) AS OUTCount,
				(select dbo.GetBadgeCountINOUT(@AppUserId,Eg.Id,[T].[days],0)) AS InCount
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
				INNER JOIN @tbl AS T ON Eg.Id = T.ActiviyId
        WHERE   UE.IsDeleted = 0
                AND AppUserId = @AppUserId
        GROUP BY Eg.Id ,
                Eg.EstablishmentGroupName ,
                Eg.SmileOn,
				Eg.AttachmentLimit,
				Eg.AutoSaveLimit,
				--E.Id,
				UE.EstablishmentType,
				T.[Days];
    END;
