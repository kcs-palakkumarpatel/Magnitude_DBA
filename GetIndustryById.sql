
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetIndustryById>
-- Call SP    :	GetIndustryById
-- =============================================
CREATE PROCEDURE [dbo].[GetIndustryById]
@Id BIGINT
AS
BEGIN
SELECT  [Id] AS Id, [IndustryName] AS IndustryName, [AboutIndustry] AS AboutIndustry FROM dbo.[Industry] WHERE [Id] = @Id
END