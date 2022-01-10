-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,25 Jun 2015>
-- Description:	<Description, ,IsTellUsSubmitted>
-- select dbo.IsTellUsSubmitted(1, 3)
-- =============================================
CREATE FUNCTION [dbo].[IsTellUsSubmitted]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT
    )
RETURNS BIT
AS 
    BEGIN
	-- Declare the return variable here
        DECLARE @IsTellUsSubmitted BIT = 0
        IF EXISTS ( SELECT  1
                    FROM    dbo.AnswerMaster
                    WHERE   AppUserId = @AppUserId
                            AND IsDeleted = 0
                            AND EstablishmentId IN (
                            SELECT  E.Id
                            FROM    dbo.EstablishmentGroup AS Eg
                                    INNER JOIN dbo.EstablishmentGroup AS TellUs ON Eg.EstablishmentGroupId = TellUs.Id
                                    INNER JOIN dbo.Vw_Establishment AS E ON TellUs.Id = E.EstablishmentGroupId
                            WHERE   E.IsDeleted = 0 AND Eg.Id = @ActivityId ) ) 
            BEGIN
                SET @IsTellUsSubmitted = 1
            END
        RETURN @IsTellUsSubmitted

    END

