-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Jun 2015>
-- Description:	<Description, ,GetContactDetailsForGroup>
-- Select dbo.GetContactDetailsForGroup(5, 4)
-- =============================================
CREATE FUNCTION [dbo].[GetContactDetailsForGroup]
    (
      @ContactGroupId BIGINT ,
      @QuestionId BIGINT
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN
	-- Declare the return variable here
        DECLARE @Details NVARCHAR(MAX);

	-- Add the T-SQL statements to compute the return value here
        SELECT  @Details = COALESCE(@Details + ', ', '')
                + CONVERT(NVARCHAR(50), ISNULL(Detail, ''))
        FROM    ( SELECT    Detail AS Detail
                  FROM      dbo.ContactGroupRelation AS CGR
                            INNER JOIN dbo.ContactMaster AS Cm ON CGR.ContactMasterId = Cm.Id
                            INNER JOIN dbo.ContactDetails AS Cd ON Cm.Id = Cd.ContactMasterId
                  WHERE     Cd.IsDeleted = 0
                            AND CGR.IsDeleted = 0
                            AND Cm.IsDeleted = 0
                            AND ContactGroupId = @ContactGroupId
                            AND ContactQuestionId = @QuestionId
                            AND Cd.Detail <> ''
                            AND Cd.Detail IS NOT NULL
                ) AS R;

	-- Return the result of the function
        RETURN ISNULL(@Details, '');

    END;