-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <09 Sep 2016>
-- Description:	<Get Activity By GroupId>
-- Call : GetActivityByGroupId 276
-- =============================================
CREATE PROCEDURE dbo.GetActivityByGroupId @GroupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EstablishmentGroup.Id AS Id,
           EstablishmentGroupName AS EstablishmentName,
           '' AS ActivityLink,
           ConfigureImagePath AS ImagePath,
           ConfigureImageName AS ImageName,
           BorderColor AS BorderColor,
           BackgroundColor AS BackgroundColor,
           IsConfugureManualImage AS ISConfugureManualImage,
           ISNULL(ConfigureImageSequence, 0) AS [Sequence]
    FROM dbo.EstablishmentGroup WITH (NOLOCK)
        INNER JOIN dbo.[Group] WITH (NOLOCK)
            ON [Group].Id = EstablishmentGroup.GroupId
    WHERE GroupId = @GroupId
          AND EstablishmentGroup.IsDeleted = 0
          AND dbo.EstablishmentGroup.EstablishmentGroupType = 'Customer'
          AND dbo.EstablishmentGroup.EstablishmentGroupId IS NOT NULL
          AND [Group].GroupKeyword IS NOT NULL
          AND dbo.EstablishmentGroup.IsGroupKeyword = 1
    ORDER BY ISNULL(ConfigureImageSequence, 0),
             EstablishmentGroupName ASC;
    SET NOCOUNT OFF;
END;
