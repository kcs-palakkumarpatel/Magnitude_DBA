CREATE PROC [dbo].[PB_Proc_UpdateDimensionsUserManagement]
AS
BEGIN
execute sp_executesql [PB_Proc_UM_DimActivity]
execute sp_executesql [PB_Proc_UM_DimEstablishment]
execute sp_executesql [PB_Proc_UM_FactChats]
execute sp_executesql [PB_Proc_UM_FactResolved]
execute sp_executesql [PB_Proc_UM_FactCaptured]
execute sp_executesql [PB_Proc_UM_FactResponses]
execute sp_executesql [PB_Proc_UM_DimAppuser]
execute sp_executesql [PB_Proc_UM_FactUserEstablishment]
execute sp_executesql [PB_Proc_UM_FactUserModule]
execute sp_executesql [PB_Proc_UM_FactManager]
execute sp_executesql [PB_Proc_UM_DimGroup]
END
