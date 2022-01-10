-- =============================================
-- Author:		Matthew Grinaker
-- Create date: 2020/05/11
-- Description:	<Description,,>
-- Call SP:		IsContactInGroup 226296, 'KCS'
-- =============================================
CREATE PROCEDURE [dbo].[IsContactInGroup]
    @ContactMasterId BIGINT ,
    @ContactGroupId BIGINT
AS 
    BEGIN
		Declare @inGroup INT;
		SET @inGroup = (Select 1 from ContactGroupRelation where ContactMasterId = 37319 and ContactGroupId = 1708)
		Select isNUll(@inGroup,0) as InContactGroup;
    END