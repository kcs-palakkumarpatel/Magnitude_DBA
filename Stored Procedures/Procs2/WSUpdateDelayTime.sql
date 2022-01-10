-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSUpdateDelayTime
-- =============================================
CREATE PROCEDURE [dbo].[WSUpdateDelayTime]
    @ActivityId NVARCHAR(MAX) ,
    @DelayTime NVARCHAR(10)
AS
    BEGIN
        UPDATE  UE
        SET     DelayTime = @DelayTime
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
        WHERE   E.EstablishmentGroupId = @ActivityId
                AND E.IsDeleted = 0
                AND UE.IsDeleted = 0
        RETURN 1;
    END