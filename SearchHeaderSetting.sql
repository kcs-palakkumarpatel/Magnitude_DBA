-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingAll>
-- Call SP    :	SearchHeaderSetting 100, 1, '', '',0,2
-- =============================================
CREATE PROCEDURE dbo.SearchHeaderSetting
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50),
	@GroupId BIGINT ,
	@UserID INT
AS
    BEGIN        DECLARE @Start AS INT , @End INT, 	@AdminRole bigint ,	 @UserRole bigint , @PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1; 

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'HeaderSetting'        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;        SET @End = @Page + @Rows;         DECLARE @Sql NVARCHAR(MAX);	IF @AdminRole = @UserRole
		BEGIN
		      SELECT  RowNum ,
                Total ,          
                GroupId ,
                GroupName ,
				ActivityId ,
				ActivityName             
        FROM    ( SELECT  dbo.[HeaderSetting].[GroupId] AS GroupId ,
                            dbo.[Group].GroupName ,
							dbo.[HeaderSetting].[EstablishmentGroupId] AS ActivityId ,
                            dbo.[EstablishmentGroup].EstablishmentGroupName AS ActivityName ,                      
                            COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY CASE
                                                              WHEN @Sort = 'GroupName ASC'
                                                              THEN dbo.[HeaderSetting].[GroupId]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'GroupName DESC'
                                                              THEN dbo.[HeaderSetting].[GroupId]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'EstablishmentGroupName ASC'
                                                              THEN dbo.[HeaderSetting].[EstablishmentGroupId]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'EstablishmentGroupName DESC'
                                                              THEN dbo.[HeaderSetting].[EstablishmentGroupId]
                                                              END DESC) AS RowNum
                  FROM      dbo.[HeaderSetting]
                            INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[HeaderSetting].GroupId AND dbo.[Group].IsDeleted = 0
							INNER JOIN dbo.[EstablishmentGroup] ON dbo.[EstablishmentGroup].Id =dbo.[HeaderSetting].EstablishmentGroupId AND dbo.[EstablishmentGroup].IsDeleted = 0		
                  WHERE     dbo.[HeaderSetting].IsDeleted = 0
                            AND ( dbo.[Group].GroupName LIKE '%' + @Search+ '%'
                                  OR dbo.[EstablishmentGroup].EstablishmentGroupName LIKE '%' + @Search+ '%')
								AND ( dbo.[Group].Id = @GroupId OR @GroupId = 0)
								GROUP BY HeaderSetting.GroupId, GroupName, HeaderSetting.EstablishmentGroupId, EstablishmentGroupName
                ) AS T
        WHERE   RowNum BETWEEN @Start AND @End;
		END		ELSE		BEGIN
		      SELECT  RowNum ,
                Total ,          
                GroupId ,
                GroupName ,
				ActivityId ,
				ActivityName             
        FROM    ( SELECT  dbo.[HeaderSetting].[GroupId] AS GroupId ,
                            dbo.[Group].GroupName ,
							dbo.[HeaderSetting].[EstablishmentGroupId] AS ActivityId ,
                            dbo.[EstablishmentGroup].EstablishmentGroupName AS ActivityName ,                      
                            COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY CASE
                                                              WHEN @Sort = 'GroupName ASC'
                                                              THEN dbo.[HeaderSetting].[GroupId]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'GroupName DESC'
                                                              THEN dbo.[HeaderSetting].[GroupId]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'EstablishmentGroupName ASC'
                                                              THEN dbo.[HeaderSetting].[EstablishmentGroupId]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'EstablishmentGroupName DESC'
                                                              THEN dbo.[HeaderSetting].[EstablishmentGroupId]
                                                              END DESC) AS RowNum
                  FROM      dbo.[HeaderSetting]
                            INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[HeaderSetting].GroupId AND dbo.[Group].IsDeleted = 0
							INNER JOIN dbo.[EstablishmentGroup] ON dbo.[EstablishmentGroup].Id =dbo.[HeaderSetting].EstablishmentGroupId AND dbo.[EstablishmentGroup].IsDeleted = 0								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
								AND dbo.UserRolePermissions.ActualID = dbo.EstablishmentGroup.Id
								AND dbo.UserRolePermissions.UserID = @UserID
                  WHERE     dbo.[HeaderSetting].IsDeleted = 0
                            AND ( dbo.[Group].GroupName LIKE '%' + @Search+ '%'
                                  OR dbo.[EstablishmentGroup].EstablishmentGroupName LIKE '%' + @Search+ '%')
								AND ( dbo.[Group].Id = @GroupId OR @GroupId = 0)
								GROUP BY HeaderSetting.GroupId, GroupName, HeaderSetting.EstablishmentGroupId, EstablishmentGroupName
                ) AS T
        WHERE   RowNum BETWEEN @Start AND @End;
		END          END;
