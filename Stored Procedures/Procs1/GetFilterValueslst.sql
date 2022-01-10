-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
--Call SP		:	dbo.GetFilterValueslst 314,919,1,1
-- =============================================
CREATE PROCEDURE [dbo].[GetFilterValueslst]
    @AppUserId BIGINT ,
    @ActivityId BIGINT ,
    @FilterChart INT,
    @inOutSwitch BIT
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        SELECT  dbo.FilterValues.Id ,
                dbo.FilterValues.UserId ,
                dbo.FilterValues.ActivityId ,
                dbo.FilterValues.FilterType,
				dbo.FilterValues.EstablishmentId,
				dbo.FilterValues.SelectedUserId,
				dbo.FilterValues.FromDate,
				dbo.FilterValues.ToDate,
				dbo.FilterValues.FromQuestion,
				dbo.FilterValues.Status,
				dbo.FilterValues.ReadUnread,
				dbo.FilterValues.inOutSwitch
        FROM    dbo.FilterValues
        WHERE   dbo.FilterValues.ActivityId = @ActivityId
                AND dbo.FilterValues.UserId = @AppUserId
                AND dbo.FilterValues.FilterType = @FilterChart
				AND dbo.FilterValues.inOutSwitch=@inOutSwitch;
    END;
