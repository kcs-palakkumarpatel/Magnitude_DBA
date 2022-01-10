-- =============================================
-- Author : Krishna Panchal
-- Create On : 13-May-2021
-- Description : Get App User By Activity Id
-- CheckUserEstablishmentRights 31504,6994
-- =============================================
CREATE PROCEDURE [dbo].[CheckUserEstablishmentRights]
    @EstablishmentId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.AppUserEstablishment
        WHERE AppUserId = @AppUserId
              AND EstablishmentId = @EstablishmentId
    )
    BEGIN
        SELECT 1 AS HasRights;
    END;
    ELSE
    BEGIN
        SELECT 0 AS HasRights;
    END;
SET NOCOUNT OFF;
END;
