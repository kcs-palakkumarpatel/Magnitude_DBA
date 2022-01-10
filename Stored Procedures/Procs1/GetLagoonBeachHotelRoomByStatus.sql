-- =============================================
-- Author:		<Author, Matthew Grinaker>
-- Create date: <Create Date, 12 Nov 2019>
-- Description:	<Description,,GetLagoonBeachHotelRoomByStatus>
-- Call SP    :	GetLagoonBeachHotelRoomByStatus 'Room clean & ready for inspection'
-- =============================================
CREATE PROCEDURE [dbo].[GetLagoonBeachHotelRoomByStatus]
(
    @FilterRoomStatus NVarChar(50)
    
)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT p.StatusName AS RoomStatus,
       COUNT(DISTINCT SCA.SeenClientAnswerMasterId) RoomStatusCount
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
GROUP BY p.StatusName;


SELECT SeenClientAnswerMasterId AS [Id],
       [38264] AS RoomNumber,
       [41939] AS GuestName,
       [RoomStatus],
       [38266] AS CheckInDate,
       [38267] AS CheckOutDate,
       [38280] AS Bed,
       UpdatedOn,
       AppUserName
FROM
(
    SELECT DISTINCT SCA.SeenClientAnswerMasterId,
           SCA.QuestionId,
           SCA.Detail,
           p.StatusName AS [RoomStatus],
           AU.Name AS "AppUserName",
           CAST(SCAM.UpdatedOn AS TIME(0)) AS UpdatedOn
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
) d
PIVOT
(
    MAX([Detail])
    FOR QuestionId IN ([38264], [38266], [38267], [38280], [41939])
) AS TAB
WHERE RoomStatus = @FilterRoomStatus
ORDER BY RoomNumber ASC;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END