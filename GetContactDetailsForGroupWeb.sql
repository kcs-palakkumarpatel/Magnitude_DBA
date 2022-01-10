-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Jun 2015>
-- Description:	<Description, ,GetContactDetailsForGroup>
-- Select dbo.GetContactDetailsForGroupWeb(18843, 1655)
-- =============================================
CREATE FUNCTION [dbo].[GetContactDetailsForGroupWeb]
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
                + CONVERT(NVARCHAR(500), ISNULL(Detail, ''))
        FROM    ( SELECT    CASE Cd.QuestionTypeId
                              WHEN 8
                              THEN ( CASE WHEN Cd.Detail IS NULL
                                               OR Cd.Detail = ''
                                          THEN ISNULL(Cd.Detail, '')
                                          ELSE dbo.ChangeDateFormat(Cd.Detail,
                                                              'dd/MMM/yyyy')
                                     END )
                              WHEN 9
                              THEN ( CASE WHEN Cd.Detail IS NULL
                                               OR Cd.Detail = ''
                                          THEN ISNULL(Cd.Detail, '')
                                          ELSE dbo.ChangeDateFormat(Cd.Detail,
                                                              'hh:mm AM/PM')
                                     END )
                              WHEN 22
                              THEN ( CASE WHEN Cd.Detail IS NULL
                                               OR Cd.Detail = ''
                                          THEN ISNULL(Cd.Detail, '')
                                          ELSE dbo.ChangeDateFormat(Cd.Detail,
                                                              'dd/MMM/yyyy hh:mm AM/PM')
                                     END )
                              ELSE ISNULL(Detail, '')
                            END AS Detail
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
        RETURN @Details;
    END;

