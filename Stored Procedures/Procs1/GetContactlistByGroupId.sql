-- =============================================
-- Author:		Vasudev Patel
-- Create date: 13 Dec 2016
-- Description:	Contact list by Group Id
-- Exec : GetContactlistByGroupId 165
-- =============================================
CREATE PROCEDURE [dbo].[GetContactlistByGroupId] 
	-- Add the parameters for the stored procedure here
    @Groupid BIGINT
AS
    BEGIN
	
        DECLARE @Result TABLE
            (
              Id BIGINT ,
              Name NVARCHAR(MAX) ,
              IsGroup BIT
            );
        INSERT  INTO @Result
                ( Id ,
                  Name ,
                  IsGroup
                )
                SELECT  CM.Id ,
                        dbo.ConcateString('ContactSummary', CM.Id) ,
                        0
                FROM    dbo.ContactMaster AS CM
                        INNER JOIN dbo.ContactDetails AS CD ON CM.Id = CD.ContactMasterId
                        INNER JOIN dbo.ContactQuestions AS CQ ON CD.ContactQuestionId = CQ.Id
                WHERE   CD.IsDeleted = 0
                        AND CM.IsDeleted = 0
                        AND CQ.IsDeleted = 0
                        AND CM.GroupId = @Groupid
                GROUP BY CM.Id;
        
        INSERT  INTO @Result
                ( Id ,
                  Name ,
                  IsGroup
                )
                SELECT DISTINCT
                        cm.Id ,
                        ContactGropName ,
                        1
                FROM    dbo.ContactGroup AS cm
                WHERE   cm.IsDeleted = 0
                        AND cm.GroupId = @Groupid;
			
        SELECT  *
        FROM    @Result;
    END;