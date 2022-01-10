-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,25 Jun 2015>
-- Description:	<Description, ,IsTellUsSubmitted>
-- select dbo.IsTellUsSubmitted(198, 215)
-- =============================================
CREATE FUNCTION [dbo].[AnswerMaserLastCreatedorUpdatedDate]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT
    )
RETURNS DATETIME
AS 
    BEGIN
	-- Declare the return variable here
        DECLARE @Datetime DATETIME = NULL
        SELECT  @Datetime =  ISNULL(UpdatedOn,CreatedOn)
                    FROM    dbo.AnswerMaster
                    WHERE   AppUserId = @AppUserId
                            AND IsDeleted = 0
                            AND EstablishmentId IN (
                            SELECT  E.Id
                            FROM    dbo.EstablishmentGroup AS Eg
                                    INNER JOIN dbo.EstablishmentGroup AS TellUs ON Eg.EstablishmentGroupId = TellUs.Id
                                    INNER JOIN dbo.Establishment AS E ON TellUs.Id = E.EstablishmentGroupId
                            WHERE   E.IsDeleted = 0 AND Eg.Id = @ActivityId ) 
           
        RETURN @Datetime

    END