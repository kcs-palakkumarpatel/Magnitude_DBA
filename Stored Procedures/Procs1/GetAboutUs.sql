-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,27 May 2015>
-- Description:	<Description,,>
-- Call SP:		GetAboutUs
-- =============================================
CREATE PROCEDURE [dbo].[GetAboutUs]
AS 
    BEGIN
        SELECT  Id ,
                AboutUs ,
                VideoUrl ,
                SignupUrl ,
                TNCUrl ,
                TimeoffSet ,
                TimeOffSetId,
				CommonFeedbackThankYouMessage
        FROM    AboutUs
    END