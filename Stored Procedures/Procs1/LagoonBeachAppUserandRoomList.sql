-- =============================================
-- Author:			Vasu Patel
-- Create date:	12-11-2019
-- Description:	Application manager user as per establishmerights and room list
-- Call: dbo.LagoonBeachAppUserandRoomList '25093', 5464, 'DI', 1
-- =============================================

CREATE PROCEDURE dbo.LagoonBeachAppUserandRoomList
    @EstablishmentId NVARCHAR(MAX),
    @UserId BIGINT,
    @roomStatus NVARCHAR(50),
    @isManager BIT
AS
BEGIN
    --Get Application user List by EstablishmentId
    SELECT AppUserEstablishment.AppUserId,
           Name, --+ CASE IsAreaManager WHEN 0 THEN '' ELSE ' [Manager]' END AS Name
           case when DF.ContactId IS NULL then 0 else DF.ContactId end AS DefaultContactId,
		    case when DF.IsGroup  IS NULL then 0 else DF.IsGroup end AS IsGroup
    FROM dbo.AppUserEstablishment
        INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
        LEFT JOIN dbo.DefaultContact AS DF
            ON DF.AppUserId = AppUserEstablishment.AppUserId
               AND DF.EstablishmentId = AppUserEstablishment.EstablishmentId
               AND DF.EstablishmentId IS NOT NULL AND DF.IsDeleted =0
    WHERE AppUserEstablishment.EstablishmentId IN (
                                                      SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                                                  )
          AND dbo.AppUserEstablishment.IsDeleted = 0
          AND dbo.AppUser.IsDeleted = 0
          AND (
                  IsAreaManager = @isManager
                  OR AppUserEstablishment.AppUserId = @UserId
              )
          AND IsActive = 1
    UNION
    SELECT ManagerUserId AS AppUserId,
           Name, --+ ' [Manager]' AS Name
           0 AS DefaultContactId,
		   0 AS IsGroup
    FROM AppManagerUserRights
        INNER JOIN dbo.AppUser
            ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
               AND AppManagerUserRights.UserId = @UserId
               AND dbo.AppManagerUserRights.EstablishmentId IN (
                                                                   SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                                                               )
               AND AppManagerUserRights.IsDeleted = 0
               AND IsActive = 1
               AND dbo.AppUser.IsDeleted = 0
    GROUP BY ManagerUserId,
             Name
    ORDER BY Name ASC;

    --Get all the data from table
    SELECT DISTINCT 
		[Id],
			[RoomNumber],
           [GuestName],
           [RoomStatus],
		   [RoomGuestStatus],
           [Bed],
           CheckInDate,
           CheckOutDate
    FROM LagoonBeachHotelRooms
    WHERE IsDeleted = 0
	AND RoomStatus LIKE @roomStatus + '%'
	order by RoomNumber;
END;
