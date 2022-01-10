-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <17 Feb 2016>
-- Description:	<Insert on Timer Flag Table for Test Type>
-- =============================================
CREATE PROCEDURE [dbo].[InsertTimerFlag]
	@RefId BIGINT,
	@ChildId BIGINT,
	@link NVARCHAR(max)
AS
BEGIN
	INSERT INTO dbo.TimerFlag
	        ( RefId, Flag,childId,Link, CreatedOn )
	VALUES  ( @RefId, -- RefId - bigint
	          1,-- Flag - int
			  @ChildId,
			  @link,
	          GETUTCDATE()  -- CreatedOn - datetime
	          )
	END