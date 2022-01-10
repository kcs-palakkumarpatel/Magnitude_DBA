      
-- =============================================      
-- Author:			Sunil Vaghasiya
-- Create date:		23-JUNE-2017      
-- Description: <get concated string values>      
-- Calls :				SELECT dbo.[ConcateStringContactDetails] ('Questions',1)     
-- =============================================      
CREATE FUNCTION [dbo].[ConcateStringContactDetails]
    (
      @ContactMasterId BIGINT      
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN      
        DECLARE @listStr NVARCHAR(MAX);    
        DECLARE @AppndChars NVARCHAR(10);      
        DECLARE @NewLineChar AS CHAR(2);       
        DECLARE @listStrQuestion NVARCHAR(MAX);    
    
        SET @NewLineChar = CHAR(13) + CHAR(10);  
        SET @AppndChars = '\n';      
        SELECT  @listStr = COALESCE(@listStr + ', ', '')
                + CONVERT(NVARCHAR(50), ISNULL(Detail, ''))
        FROM    ( SELECT    CASE Cd.QuestionTypeId
                              WHEN 8
                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,
                                                              'MM/dd/yyyy'))
                              WHEN 9
                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,
                                                              'hh:mm AM/PM'))
                              WHEN 22
                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM'))
                              ELSE CONVERT(NVARCHAR(50), ISNULL(Detail, ''))
                            END AS Detail ,
                            Position
                  FROM      dbo.ContactDetails AS Cd
                            INNER JOIN dbo.ContactQuestions AS Cq ON Cd.ContactQuestionId = Cq.Id
                  WHERE     ContactMasterId = @ContactMasterId
                            AND Cd.IsDeleted = 0
                            AND Cq.IsDeleted = 0
                            AND IsDisplayInSummary = 1
                            AND Detail <> ''
                ) AS R
        ORDER BY R.Position;            
        RETURN  ISNULL(@listStr, '');  
    END;
