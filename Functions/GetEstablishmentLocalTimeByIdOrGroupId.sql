-- =============================================      
-- Author:  Sandeep Bhadauirya    
-- Create date: 04 Oct 2014    
-- Description: Get establishment local time    
-- =============================================      

CREATE FUNCTION [dbo].[GetEstablishmentLocalTimeByIdOrGroupId]  
    (  
      @Establishmentid NVARCHAR(MAX) ,  
      @GroupId BIGINT   
    )  
RETURNS DATETIME  
AS   
    BEGIN      

        DECLARE @retval DATETIME = GETUTCDATE()      

        SELECT TOP 1  
                @retval = DATEADD(minute, TimeOffSet, @retval)  
        FROM    Establishment  
        WHERE   ( @EstablishmentId = '0'  
                  AND EstablishmentGroupId = @GroupId  
                )  
                OR ( Id IN ( SELECT Data  
                             FROM   dbo.Split(@EstablishmentId, ',') ) )    
        RETURN ISNULL(@retval,GETUTCDATE())      
    END