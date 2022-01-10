
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Dec 2015>
-- Description:	<Get Establishment Activity Name by Common SMS Key Word>
-- Call: GetActivitybyCommonSMSKeyWord 2397
-- =============================================
CREATE PROCEDURE [dbo].[GetActivitybyCommonSMSKeyWord_111721] @EstablishmentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CommonSMSKeyword NVARCHAR(100);
    SELECT @CommonSMSKeyword = CommonSMSKeyword
    FROM dbo.Establishment WITH (NOLOCK)
    WHERE Id = @EstablishmentId;
    SELECT Establishment.Id AS Id,
           EstablishmentGroupName AS EstablishmentName,
           '' AS ActivityLink,
           ConfigureImagePath AS ImagePath,
           ConfigureImageName AS ImageName,
           BorderColor AS BorderColor,
           BackgroundColor AS BackgroundColor,
           IsConfugureManualImage AS ISConfugureManualImage,
           ISNULL(ConfigureImageSequence, 0) AS [Sequence]
    FROM dbo.Establishment WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentGroup WITH (NOLOCK)
            ON EstablishmentGroup.Id = Establishment.EstablishmentGroupId
    WHERE CommonSMSKeyword = @CommonSMSKeyword
          AND Establishment.IsDeleted = 0
          AND EstablishmentGroup.IsDeleted = 0
          AND dbo.EstablishmentGroup.EstablishmentGroupType = 'Customer'
    ORDER BY ISNULL(ConfigureImageSequence, 0) ASC;
    SET NOCOUNT OFF;
END;
