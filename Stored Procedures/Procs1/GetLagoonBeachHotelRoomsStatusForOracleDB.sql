-- =============================================
-- Author:		<Author,,MATTHEW GRINAKER>
-- Create date: <Create Date,, 22 Nov 2019>
-- Description:	<Description,,GetLagoonBeachHotelRoomsStatusForOracleDB>
-- Call SP    :	GetLagoonBeachHotelRoomsStatusForOracleDB
-- =============================================
CREATE PROCEDURE [dbo].[GetLagoonBeachHotelRoomsStatusForOracleDB]
AS
BEGIN
SELECT	
           [RoomNumber],
            MAX(p.StatusName) as [RoomStatus]
           FROM(Select SeenClientAnswerMasterId as ReferenceNumber, [38264] as RoomNumber FROM
(
Select  SeenClientAnswerMasterId,QuestionId, Detail from SeenClientAnswers where QuestionId = 38264 and CreatedOn > DATEADD(HOUR, -10, GETDATE())  AND IsDeleted = 0
) d PIVOT
(MAX([Detail]) FOR QuestionId in ([38264])) AS TAB) TAB INNER JOIN dbo.StatusHistory INNER JOIN
                         dbo.EstablishmentStatus as p ON dbo.StatusHistory.EstablishmentStatusId = p.Id ON tab.ReferenceNumber = dbo.StatusHistory.ReferenceNo INNER JOIN
                         dbo.SeenClientAnswerMaster ON TAB.ReferenceNumber = dbo.SeenClientAnswerMaster.Id AND dbo.StatusHistory.Id = dbo.SeenClientAnswerMaster.StatusHistoryId
WHERE SeenClientAnswerMaster.UpdatedOn >  DATEADD(minute, -20, GETDATE())
GROUP BY RoomNumber;
END;
