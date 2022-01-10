/*
 =============================================
 Author:		Disha Patel
 Create date:   24-OCT-2016
 Description:	Get all modules by EstablishmentGroupId and EstablishmentGroupType when EstablishmentGroupId=0
 Call SP    :	GetModuleAliasByEstablishmentGroupId 2011,'Customer'
 =============================================
*/

CREATE PROCEDURE [dbo].[GetModuleAliasByEstablishmentGroupId]
    @EstablishmentGroupId BIGINT ,
    @EstablishmentGroupType VARCHAR(20)
AS
    BEGIN
        SET NOCOUNT ON
        IF ( @EstablishmentGroupId = 0 )
            BEGIN
                IF ( LOWER(@EstablishmentGroupType) = 'customer' )
                    BEGIN
                        SELECT  CAST(0 AS BIGINT) AS Id ,
                                M.Id AS ModuleId ,
                                ModuleName ,
                                ModuleName AS AliasName ,
                                @EstablishmentGroupId AS EstablishmentGroupId
                        FROM    dbo.AppModule AS M
                        WHERE   M.IsDeleted = 0
                                AND M.Id <> 4
                    END
                ELSE
                    BEGIN
                        SELECT  CAST(0 AS BIGINT) AS Id ,
                                M.Id AS ModuleId ,
                                ModuleName ,
                                ModuleName AS AliasName ,
                                @EstablishmentGroupId AS EstablishmentGroupId
                        FROM    dbo.AppModule AS M
                        WHERE   M.IsDeleted = 0
                    END
            END
        ELSE
            BEGIN
                IF ( LOWER(@EstablishmentGroupType) = 'customer' )
                    BEGIN
                        SELECT  ISNULL(MA.Id, 0) AS Id ,
                                M.Id AS ModuleId ,
                                ModuleName ,
                                ISNULL(AliasName, ModuleName) AS AliasName ,
                                @EstablishmentGroupId AS EstablishmentGroupId
                        FROM    dbo.AppModule AS M
                                LEFT OUTER JOIN dbo.EstablishmentGroupModuleAlias
                                AS MA ON M.Id = MA.AppModuleId
                                         AND MA.EstablishmentGroupId = @EstablishmentGroupId
                                         AND ISNULL(MA.IsDeleted, 0) = 0
                        WHERE   M.IsDeleted = 0 AND M.Id <> 4
                    END
                ELSE
                    BEGIN
                        SELECT  ISNULL(MA.Id, 0) AS Id ,
                                M.Id AS ModuleId ,
                                ModuleName ,
                                ISNULL(AliasName, ModuleName) AS AliasName ,
                                @EstablishmentGroupId AS EstablishmentGroupId
                        FROM    dbo.AppModule AS M
                                LEFT OUTER JOIN dbo.EstablishmentGroupModuleAlias
                                AS MA ON M.Id = MA.AppModuleId
                                         AND MA.EstablishmentGroupId = @EstablishmentGroupId
                                         AND ISNULL(MA.IsDeleted, 0) = 0
                        WHERE   M.IsDeleted = 0
                    END
            END
        SET NOCOUNT OFF
    END;