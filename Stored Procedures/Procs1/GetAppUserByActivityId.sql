-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <03 Nov 2016>
-- Description:	<Get Appuser By Activity Id From AppuserEstablishment Table>
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserByActivityId] 
	@ActivityId BIGINT
AS
BEGIN
    SELECT  a.AppUserId ,
            d.Name
    FROM    dbo.AppUserEstablishment a
            INNER JOIN dbo.Establishment b ON a.EstablishmentId = b.Id
            INNER JOIN dbo.EstablishmentGroup C ON C.Id = b.EstablishmentGroupId
            INNER JOIN dbo.AppUser d ON d.Id = a.AppUserId
    WHERE   C.Id = @ActivityId
            AND a.IsDeleted = 0
            AND b.IsDeleted = 0
            AND C.IsDeleted = 0
    GROUP BY a.AppUserId ,
            d.Name;
END