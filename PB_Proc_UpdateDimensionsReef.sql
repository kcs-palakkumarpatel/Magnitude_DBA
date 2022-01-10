


CREATE PROC [dbo].[PB_Proc_UpdateDimensionsReef]
AS
BEGIN

	execute sp_executesql [PB_Proc_Fact_Reef_Feedback]
	execute sp_executesql [PB_Proc_Fact_Reef_Captured]
END
