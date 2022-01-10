-- =============================================
-- Author:		<Author,,VASUDEV PATEL>
-- Create date: <Create Date,, 12 Nov 2019>
-- Description:	<Description,,SearchLagoonBeachHotelData>
-- Call SP    :	SearchLagoonBeachHotelData 0,'','Single'
-- =============================================
CREATE PROCEDURE [dbo].[SearchLagoonBeachHotelData]
    @flag BIT,
    @type NVARCHAR(50),
    @searchParam NVARCHAR(500)
AS
BEGIN
    --Get all the data from table based on 
    IF (@flag = 1)
    BEGIN
        SELECT [Id],
               [RoomNumber],
               [GuestName],
               [RoomStatus],
               [CheckInDate],
               [CheckOutDate],
               [Bed]
        FROM LagoonBeachHotelRooms
        WHERE IsDeleted = 0
              AND (
                      RoomNumber LIKE '%' + @searchParam + '%'
                      OR GuestName LIKE '%' + @searchParam + '%'
                      OR RoomStatus LIKE '%' + @searchParam + '%'
                      OR Bed LIKE '%' + @searchParam + '%'
                  )
              AND RoomStatus = @type;
    END;
    ELSE
    BEGIN
        SELECT [Id],
               [RoomNumber],
               [GuestName],
               [RoomStatus],
               [CheckInDate],
               [CheckOutDate],
               [Bed]
        FROM LagoonBeachHotelRooms
        WHERE IsDeleted = 0
              AND (
                      RoomNumber LIKE '%' + @searchParam + '%'
                      OR GuestName LIKE '%' + @searchParam + '%'
                      OR RoomStatus LIKE '%' + @searchParam + '%'
                      OR Bed LIKE '%' + @searchParam + '%'
                  );
    END;
END;
