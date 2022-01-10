


CREATE PROC [dbo].[PB_Proc_UpdateDimensionsStefnutti]
AS
BEGIN

	execute sp_executesql [PB_Proc_Fact_Stefnutti_Feedback]
	execute sp_executesql [PB_Proc_Fact_Stefnutti_Captured]
END
