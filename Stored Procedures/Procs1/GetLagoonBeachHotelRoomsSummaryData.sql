-- =============================================
-- Author:		<Author,,VASUDEV PATEL>
-- Create date: <Create Date,, 07 Nov 2019>
-- Description:	<Description,,GetLagoonBeachHotelRoomsSummaryData>
-- Call SP    :	GetLagoonBeachHotelRoomsSummaryData
-- =============================================
CREATE PROCEDURE [dbo].[GetLagoonBeachHotelRoomsSummaryData]
AS
BEGIN
    --Get Room Status Count 
    SELECT RoomStatus,
           COUNT(*) AS RoomStatusCount
    FROM dbo.LagoonBeachHotelRooms
    WHERE IsDeleted = 0
    GROUP BY RoomStatus;

    --Get all the data from table
    SELECT [Id],
           [RoomNumber],
           [GuestName],
           [RoomStatus],
           [CheckInDate],
           [CheckOutDate],
           [Bed]
    FROM LagoonBeachHotelRooms
    --WHERE ISDeleted = 0;
END;
