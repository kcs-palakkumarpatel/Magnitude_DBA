
CREATE PROC [dbo].[PB_Proc_UpdateDimensionsOTIS]
AS
BEGIN
execute sp_executesql [PB_Proc_Fact_OTIS_AppxSupport]
execute sp_executesql [PB_Proc_Fact_OTIS_Captured]

END
