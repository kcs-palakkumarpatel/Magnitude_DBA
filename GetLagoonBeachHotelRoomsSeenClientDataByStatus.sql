-- =============================================
-- Author:		<Author, Matthew Grinaker>
-- Create date: <Create Date, 12 Nov 2019>
-- Description:	<Description,,GetLagoonBeachHotelRoomByStatus>
-- Call SP    :	GetLagoonBeachHotelRoomsSeenClientDataByStatus  'Dirty'
-- =============================================
CREATE PROCEDURE [dbo].[GetLagoonBeachHotelRoomsSeenClientDataByStatus]
(
    @FilterRoomStatus NVarChar(50)
)
AS
BEGIN
    --Get all the data from table
SELECT SeenClientAnswerMasterId AS [Id],
       [38264] AS RoomNumber,
       [41939] AS GuestName,
       [RoomStatus],
       [38266] AS CheckInDate,
       [38267] AS CheckOutDate,
       [38280] AS Bed,
       UpdatedOn,
	   AppUserId,
       AppUserName as "Name",
	   DefualtContactId,
	   IsGroup
FROM
(
    SELECT DISTINCT SCA.SeenClientAnswerMasterId,
           SCA.QuestionId,
           SCA.Detail,
           p.StatusName AS [RoomStatus],
           AU.Name AS "AppUserName",
		   AU.id As "AppUserId",
           CAST(SCAM.UpdatedOn AS TIME(0)) AS UpdatedOn,
			DF.ContactId AS "DefualtContactId",
			DF.IsGroup AS "IsGroup"
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
               AND SCA.CreatedOn > DATEADD(HOUR, -16, GETDATE())
               AND SCA.QuestionId IN ( 38264, 38266, 38267, 38280, 41939 )
               AND SCA.IsDeleted = 0
        INNER JOIN dbo.StatusHistory SH
            ON SH.Id = SCAM.StatusHistoryId
               AND SCA.SeenClientAnswerMasterId = SH.ReferenceNo
        INNER JOIN dbo.EstablishmentStatus AS p
            ON p.Id = SH.EstablishmentStatusId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = SCAM.AppUserId
			INNER JOIN dbo.DefaultContact AS DF
			ON DF.AppUserId = SCAM.AppUserId
			AND DF.EstablishmentId =  SCAM.EstablishmentId
			WHERE 
			DF.EstablishmentId IS NOT NULL 
			AND DF.IsDeleted = 0
) d
PIVOT
(
    MAX([Detail])
    FOR QuestionId IN ([38264], [38266], [38267], [38280], [41939])
) AS TAB
WHERE RoomStatus = @FilterRoomStatus
ORDER BY AppUserName ASC;
END