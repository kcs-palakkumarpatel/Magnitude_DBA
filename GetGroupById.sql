-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,GetGroupById>
-- Call SP    :	GetGroupById 1
-- =============================================
CREATE PROCEDURE [dbo].[GetGroupById] @Id BIGINT
AS 
    BEGIN
	SET NOCOUNT ON;
        SELECT  [Id] AS Id ,
                [IndustryId] AS IndustryId ,
                [GroupName] AS GroupName ,
                [AboutGroup] AS AboutGroup ,
                [ThemeId] AS ThemeId,
				ContactId,
				GroupKeyword,
				ISNULL((SELECT COUNT(1) FROM dbo.ContactMaster WITH(NOLOCK) WHERE GroupId = @Id AND IsDeleted = 0 AND ContactId = G.ContactId), 0) AS ContactCount,
				G.SecurityKey AS SecurityKey,
				[PWExpiredDays] AS PWExpiredDays
        FROM    dbo.[Group] AS G WITH(NOLOCK)
        WHERE   [Id] = @Id
SET NOCOUNT OFF;
    END
