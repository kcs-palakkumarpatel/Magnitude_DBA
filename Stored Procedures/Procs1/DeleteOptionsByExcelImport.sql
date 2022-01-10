-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <09 Mar 2017>
-- Description:	<Delete Option before Import Excel>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteOptionsByExcelImport]
    @QuestionId BIGINT ,
    @Type VARCHAR(10)
AS
    BEGIN
	
        IF ( @Type = 'Feedback' )
            BEGIN
                DELETE  FROM dbo.Options
                WHERE   QuestionId = @QuestionId; 
            END;
        ELSE IF(@Type = 'Seenclient')
            BEGIN
                DELETE  FROM dbo.SeenClientOptions
                WHERE   QuestionId = @QuestionId; 
            END;
    END;
