-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Jun 2015>
-- Description:	<Description, ,GetContactDetailsForGroup>
-- Select dbo.GetContactDetailsForGroupWeb(5, 4)
-- =============================================
CREATE FUNCTION [dbo].[GetContactDetailsForGroupFeedback]
    (
      @SeenClientAnswerMasterId BIGINT ,
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
        FROM    ( SELECT DISTINCT(CGR.ContactMasterId),   CASE Cd.QuestionTypeId
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
                  FROM      dbo.SeenClientAnswerMaster AM
							LEFT JOIN  dbo.SeenClientAnswerChild AC ON AC.SeenClientAnswerMasterId=AM.Id
							left JOIN dbo.ContactGroupRelation AS CGR ON CGR.ContactMasterId = ISNULL(AC.ContactMasterId,AM.ContactMasterId) AND CGR.ContactGroupId = AM.ContactGroupId
							INNER JOIN dbo.ContactMaster AS Cm ON Cm.Id=ISNULL(CGR.ContactMasterId,AM.ContactMasterId)
							INNER JOIN dbo.ContactDetails AS Cd ON Cd.ContactMasterId =Cm.Id
                  WHERE     --Cd.IsDeleted = 0
                            --AND (CGR.ContactGroupId IS NULL OR CGR.IsDeleted = 0)
                            --AND Cm.IsDeleted = 0
                            --AND ContactGroupId = @ContactGroupId
							--AND 
							AM.Id=@SeenClientAnswerMasterId
                            AND ContactQuestionId = @QuestionId
							AND Cd.Detail <> ''
                            AND Cd.Detail IS NOT NULL
                ) AS R;

	-- Return the result of the function
        RETURN @Details;

    END;

