
-- =============================================
-- Author:		<Ankit,,ADMIN>
-- Create date: <Create Date,, 22 Apr 2019>
-- Description:	<Description,,GetEmailLinkConfiguration>
-- Call SP    :	GetEmailLinkConfiguration
-- =============================================
CREATE PROCEDURE [dbo].[GetEmailLinkConfiguration]
AS
BEGIN
    SELECT Id,
           ConfigurationName
    FROM dbo.EmailLinkConfiguration
    WHERE IsDeleted = 0;
END;
