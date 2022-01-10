-- =============================================
-- Author:		<Mittal Patel,,GD>
-- Create date: <Create Date,,20 Apr 2021>
-- Description:	<Description,,>
-- Call SP:		TemplateDataWithActivityEstablishmentandSlideImage 1941, 'ThemeMDPI','1970-01-01',1941
-- =============================================
CREATE PROCEDURE dbo.TemplateDataWithActivityEstablishmentandSlideImage
    @ActivityId BIGINT,
    @Resolution NVARCHAR(50),
    @LastDate DATETIME,
    @AppuserId BIGINT
AS
BEGIN
    EXEC dbo.WSActionTemplateUpdated @ActivityId = @ActivityId, -- bigint
                                     @LastDate = @LastDate;     -- datetime
    EXEC dbo.WSGetTodayFeedbackCountByActivityId @ActivityId = @ActivityId, -- bigint
                                                 @AppuserId = @AppuserId;   -- bigint
    EXEC dbo.GetEstablishmentStatusByActivityId @ActivityId = @ActivityId, -- bigint
                                                @LastDate = @LastDate;     -- datetime
    EXEC dbo.WSGetSlideImageByActivityId @ActivityId = @ActivityId, -- bigint
                                         @Resolution = @Resolution; -- nvarchar(50)

END;
