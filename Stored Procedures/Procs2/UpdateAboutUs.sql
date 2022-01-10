-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,27 May 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateAboutUs
-- =============================================
CREATE PROCEDURE [dbo].[UpdateAboutUs]
    @Id BIGINT ,
    @AboutUs NVARCHAR(MAX) ,
    @VideoUrl NVARCHAR(500) ,
    @SignupUrl NVARCHAR(500) ,
    @TNCUrl NVARCHAR(500) ,
    @TimeoffSet INT ,
    @TimeOffSetId NVARCHAR(500),
	@CommonFeedbackThankYouMessage VARCHAR(1000)
AS 
    BEGIN
        UPDATE  dbo.AboutUs
        SET     AboutUs = @AboutUs ,
                VideoUrl = @VideoUrl ,
                SignupUrl = @SignupUrl ,
                TNCUrl = @TNCUrl,
				CommonFeedbackThankYouMessage = @CommonFeedbackThankYouMessage
        WHERE   Id = @Id
    END