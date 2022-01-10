-- =============================================
-- Author: Matthew Grinaker
-- Create date:	15-01-2020
-- Description:	Remove duplicate rooms from lagoon beach hotel table
-- Call: dbo.RemoveLagoonBeachDuplicates
-- =============================================

CREATE PROCEDURE RemoveLagoonBeachDuplicates
AS
BEGIN
	while (
	(select Count(RoomNumber) as totalRooomDuplicates FROM
	(
	SELECT RoomNumber, COUNT(RoomNumber) as [TotalRoomCount] FROM LagoonBeachHotelRooms group by RoomNumber
	) as TAB WHERE TotalRoomCount > 1) > 0)
	BEGIN
	Delete from LagoonBeachHotelRooms where id = 
	(
	Select MAX(id) from LagoonBeachHotelRooms where RoomNumber =
	(
	Select top(1) RoomNumber as tmpRoomNumber FROM
	(
	SELECT RoomNumber, COUNT(RoomNumber) as [TotalRoomCount] FROM LagoonBeachHotelRooms group by RoomNumber
	) as TAB WHERE TotalRoomCount > 1
	)
	)
	END
END


