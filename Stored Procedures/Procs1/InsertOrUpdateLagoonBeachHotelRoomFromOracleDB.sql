-- =============================================
-- Author:		<Author,,MATTHEW GRINAKER>
-- Create date: <Create Date,, 22 Nov 2019>
-- Description:	<Description,,GetLagoonBeachHotelRoomsSeenClientSummaryData>
-- Call SP    :	GetLagoonBeachHotelRoomsSeenClientSummaryData
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateLagoonBeachHotelRoomFromOracleDB]
(@LagoonBeachHotelRoomsTableType LagoonBeachHotelRoomsTableType READONLY)
AS

DECLARE @LagoonBeachHotelRoomsTableTypeRunTime LagoonBeachHotelRoomsTableType;
INSERT INTO @LagoonBeachHotelRoomsTableTypeRunTime
SELECT DISTINCT RoomNumber,
           GuestName,
		   --Traces,
		   --ReservationStatus,
           RoomStatus,
		   RoomGuestStatus,
		   CheckInDate,
		   CheckOutDate,
		   Bed
FROM @LagoonBeachHotelRoomsTableType;
BEGIN
     DELETE FROM LagoonBeachHotelRooms;
    INSERT INTO LagoonBeachHotelRooms
    (
        [RoomNumber],
        [GuestName],
		--[Traces],
		--[ReservationStatus],
        [RoomStatus],
		[RoomGuestStatus],
        [CheckInDate],
        [CheckOutDate],
        [Bed],
        [IsDeleted],
        [CreatedOn]
    )
    SELECT DISTINCT RoomNumber,
           GuestName,
		   --Traces,
		   --ReservationStatus,
           RoomStatus,
		   RoomGuestStatus,
		   CheckInDate,
		   CheckOutDate,
		   Bed,
           '0',
           GETDATE()
    FROM @LagoonBeachHotelRoomsTableTypeRunTime;
    INSERT INTO LagoonBeachHotelRoomsHistory
    (
        [RoomNumber],
        [GuestName],
        [RoomStatus],
		[RoomGuestStatus],
        [CheckInDate],
        [CheckOutDate],
        [Bed],
        [IsDeleted],
        [CreatedOn]
    )
    SELECT RoomNumber,
           GuestName,
           RoomStatus,
		   RoomGuestStatus,
		   CheckInDate,
		   CheckOutDate,
           Bed,
           '0',
           GETDATE()
    FROM @LagoonBeachHotelRoomsTableTypeRunTime;
END;
EXEC RemoveLagoonBeachDuplicates;
--EXEC dbo.InsertOrUpdateLagoonBeachHotelRoomFromOracleDB @LagoonBeachHotelRoomsTableTypeRunTime
