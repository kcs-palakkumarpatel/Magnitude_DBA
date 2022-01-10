-- =============================================  

-- Author:  Sandeep Bhadauirya

-- Create date: 09 Sept 2014

-- Description: Get establishment local time

-- =============================================  

CREATE FUNCTION [dbo].[GetEstablishMentLocalTime] ( -- Add the parameters for the function here  

                                                 @Id BIGINT )

RETURNS DATETIME

AS 

    BEGIN  

        DECLARE @retval DATETIME = GETUTCDATE()  

        SELECT  @retval = DATEADD(minute, TimeOffSet, @retval)

        FROM    Establishment

        WHERE   Id = @Id  

        RETURN @retval  

    END