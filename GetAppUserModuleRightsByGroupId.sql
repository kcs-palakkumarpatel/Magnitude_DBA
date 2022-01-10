/*
 =============================================
 Author:		Mitesh Kachhadiya
 Create date: <Create Date,, 16 Dec 2021>
 Description:	<Description,,GetAppUserModuleRightsByGroupId>
 Call SP    :	GetAppUserModuleRightsByGroupId 743 
 =============================================
*/

CREATE PROCEDURE dbo.GetAppUserModuleRightsByGroupId @GroupId BIGINT
AS
BEGIN
    SELECT DISTINCT
        aum.Id, --AS AppUserModuleId,
        aum.AppUserId,
        au.UserName,
        au.Name,
        aum.EstablishmentGroupId,
        EG.EstablishmentGroupName,
        aum.AppModuleId,
        AM.ModuleName,
        aum.AliasName,
        aum.IsSelected
    --,aum.*
    FROM dbo.AppUser au --WHERE au.UserName = 'workforce covid'
        INNER JOIN AppUserModule aum
            ON aum.AppUserId = au.Id
        INNER JOIN dbo.AppModule AM
            ON AM.Id = aum.AppModuleId
        INNER JOIN dbo.EstablishmentGroup EG
            ON EG.Id = aum.EstablishmentGroupId
        INNER JOIN dbo.AppUserEstablishment aue
            ON aue.AppUserId = au.Id
        INNER JOIN dbo.Establishment e
            ON e.Id = aue.EstablishmentId
               AND e.EstablishmentGroupId = EG.Id
    --INNER JOIN dbo.AppUserEstablishment aue ON aue.AppUserId = au.Id
    WHERE aue.IsDeleted != 1
          AND au.GroupId = @GroupId -- --65 record -- 49 correct

    ORDER BY aum.AppUserId,
             aum.EstablishmentGroupId,
             aum.AppModuleId;
END;
