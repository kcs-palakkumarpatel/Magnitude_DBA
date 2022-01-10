-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Call: Exec InsertAppuserRightByUseridandEstablishmentid '1596,1604,1605,1606,1607,1609,1610,1611,1612,1613,1614,1615,1616,1617,1789,1790,1847,1848,1849,1850,1851,1852,1867,1868,1869,1870,1907,1938,1939,1973,2034,2035,2081,2083,2097,2098,2480,2500,2520,2521,2522,2523,2524,2574,2622,2716,2912,3646,5100,4880,6193','27434,27435,27436,27437,27475,27476'
-- =============================================
CREATE PROCEDURE dbo.InsertAppuserRightByUseridandEstablishmentid
	@AppuserId VARCHAR(MAX),
	@Establishment VARCHAR(MAX)
AS
BEGIN
INSERT INTO dbo.AppUserEstablishment
        ( AppUserId ,
          EstablishmentId ,
          NotificationStatus ,
          EstablishmentType ,
          DelayTime ,
          CreatedOn ,
          CreatedBy ,
          UpdatedOn ,
          UpdatedBy ,
          DeletedOn ,
          DeletedBy ,
          IsDeleted
        )
SELECT  dbo.AppUser.Id ,
        dbo.Establishment.Id ,
        1 ,
        'Sales',
        NULL,
        GETUTCDATE(),
        110,
        NULL,
        NULL,
        NULL,
        NULL,
        0
FROM    dbo.AppUser
        INNER JOIN dbo.Establishment ON AppUser.GroupId = Establishment.GroupId
                                        AND Establishment.Id IN (SELECT data FROM split(@Establishment,','))
                                        AND Establishment.IsDeleted = 0
WHERE   dbo.AppUser.Id IN (SELECT data FROM dbo.Split(@AppuserId,','))
        AND dbo.AppUser.IsDeleted = 0
        AND dbo.Establishment.Id NOT IN (
        SELECT  EstablishmentId
        FROM    dbo.AppUserEstablishment
        WHERE   EstablishmentId IN (SELECT data FROM split(@Establishment,','))
                AND IsDeleted = 0
                AND AppUserId = dbo.AppUser.Id);
END
