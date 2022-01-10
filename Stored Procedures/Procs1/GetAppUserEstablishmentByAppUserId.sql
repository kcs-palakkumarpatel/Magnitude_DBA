-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 09 Jun 2015>
-- Description:	<Description,,GetAppUserEstablishmentById>
-- Call SP    :	GetAppUserEstablishmentByAppUserId 18056, 698, 'Customer',2
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserEstablishmentByAppUserId]
    @AppUserId BIGINT,
    @GroupId BIGINT,
    @GroupType NVARCHAR(50),
    @UserID INT
AS
BEGIN

    DECLARE @AdminRole BIGINT,
            @UserRole BIGINT,
            @PageID BIGINT,
            @GroupTypes VARCHAR(50);

    IF (@GroupType = 'Sales')
    BEGIN
        SET @GroupTypes = @GroupType + ',' + 'Task';
    END;
    ELSE
    BEGIN
        SET @GroupTypes = @GroupType;
    END;

    SELECT TOP 1
           @AdminRole = Id
    FROM [dbo].[Role]
    WHERE RoleName = 'Admin';
    SELECT TOP 1
           @UserRole = RoleId
    FROM dbo.[User]
    WHERE Id = @UserID;
    SELECT TOP 1
           @PageID = Id
    FROM dbo.Page
    WHERE PageName = 'Establishment';


    BEGIN

        SELECT E.Id AS EstablishmentId,
               E.EstablishmentName,
               ISNULL(UE.EstablishmentType, EstablishmentGroupType) AS EstablishmentType,
               EstablishmentGroupType,
               E.EstablishmentGroupId,
               ISNULL(UE.Id, 0) AS Id
        FROM dbo.Establishment AS E
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON E.EstablishmentGroupId = EG.Id
            LEFT OUTER JOIN dbo.AppUserEstablishment AS UE
                ON E.Id = UE.EstablishmentId
                   AND UE.AppUserId = @AppUserId
                   AND ISNULL(UE.IsDeleted, 0) = 0
        WHERE E.IsDeleted = 0
              AND ISNULL(UE.EstablishmentType, EstablishmentGroupType) IN
                  (
                      SELECT Data FROM dbo.Split(@GroupTypes, ',')
                  )
              AND EG.GroupId = @GroupId
        ORDER BY EG.EstablishmentGroupType,
                 EstablishmentName,
                 E.EstablishmentGroupId;
    END;
END;
