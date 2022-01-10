-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <10 Oct 2016>
-- Description:	<Get AppUser By EstablishmentId>
-- Call: GetAppuserByEstablishmentid 33322,0,''
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserByEstablishmentId]
    @EstablishmentId NVARCHAR(MAX),
    @RoleId BIGINT = 0
AS
BEGIN
    SELECT AE.AppUserId,
           AU.Name,
           ISNULL(CRD.Id, 0) AS SelectedId
    FROM dbo.AppUserEstablishment AE
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AE.AppUserId
        LEFT OUTER JOIN dbo.ContactRoleDetails CRD
            ON CRD.AppUserId = AU.Id
               AND CRD.ContactRoleId = @RoleId
        LEFT OUTER JOIN dbo.ContactRoleEstablishment CRE
            ON CRE.EstablishmentId = AE.EstablishmentId
               AND CRE.ContactRoleId = CRD.ContactRoleId
               AND CRE.ContactRoleId = @RoleId
    WHERE AE.EstablishmentId IN
          (
              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
          )
          AND AU.IsDeleted = 0
          AND AU.IsActive = 1
          AND AE.IsDeleted = 0
    GROUP BY AE.AppUserId,
             AU.Name,
             CRD.Id;
END;
