
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,16 Oct 2015>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetOptionNameByQuestionId]
    (
      @QuestionId BIGINT ,
      @Details NVARCHAR(50) ,
      @IsOut BIT
    )
RETURNS NVARCHAR(50)
AS
    BEGIN
	-- Declare the return variable here
        IF @IsOut = 0
            BEGIN
                SELECT  @Details = Name
                FROM    dbo.Options
                WHERE   QuestionId = @QuestionId
                        AND Value = @Details;
            END;
        ELSE
            BEGIN
                SELECT  @Details = Name
                FROM    dbo.SeenClientOptions
                WHERE   QuestionId = @QuestionId
                        AND Value = @Details;
            END;
	-- Return the result of the function
        RETURN ISNULL(@Details, '');
    END;