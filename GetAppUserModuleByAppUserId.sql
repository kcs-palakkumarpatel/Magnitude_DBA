/*
 =============================================
 Author:		<Author,,Gd>
 Create date: <Create Date,, 09 Jun 2015>
 Description:	<Description,,GetAppUserModuleById>
 Updated Date: Disha - 25-OCT-2016 - to get Module Alias Names from EstablishmentGroupModuleAlias table
 Call SP    :	GetAppUserModuleByAppUserId 1, '4,10029,10030', 1
 =============================================
*/

CREATE PROCEDURE [dbo].[GetAppUserModuleByAppUserId]
    @AppUserId BIGINT ,
    @ActivityId NVARCHAR(MAX) ,
    @CopyMode BIT
AS
    BEGIN
        SELECT  ROW_NUMBER() OVER ( ORDER BY Eg.EstablishmentGroupName ) AS RowNo ,
                M.Id AS ModuleId ,
                CASE @CopyMode
                  WHEN 0 THEN ISNULL(UM.Id, 0)
                  ELSE 0
                END AS Id ,
                ModuleName ,
                ISNULL(MA.AliasName, ISNULL(UM.AliasName, ModuleName)) AS AliasName ,
                ISNULL(CASE WHEN @CopyMode = 0
                                 AND @AppUserId = 0 THEN CAST(1 AS BIT)
                            ELSE IsSelected
                       END, 0) AS IsSelected ,
                ISNULL(Eg.Id, 0) AS EstablishmentGroupId ,
                ISNULL(Eg.EstablishmentGroupName, '') AS EstablishmentGroupName
        FROM    dbo.AppModule AS M
                OUTER APPLY ( SELECT DISTINCT
                                        Data
                              FROM      dbo.Split(@ActivityId, ',')
                            ) AS Activity
                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = Activity.Data
                LEFT OUTER JOIN dbo.EstablishmentGroupModuleAlias MA ON MA.EstablishmentGroupId = Eg.Id
                                                              AND MA.AppModuleId = M.Id
                LEFT OUTER JOIN dbo.AppUserModule AS UM ON M.Id = UM.AppModuleId
                                                           AND AppUserId = @AppUserId
                                                           AND UM.EstablishmentGroupId = Eg.Id
                                                           AND ISNULL(UM.IsDeleted,
                                                              0) = 0
        WHERE   ISNULL(UM.IsDeleted, 0) = 0
                AND M.IsDeleted = 0
                AND CONVERT(NVARCHAR(5), M.Id) + Eg.EstablishmentGroupType <> '4Customer';
    END;