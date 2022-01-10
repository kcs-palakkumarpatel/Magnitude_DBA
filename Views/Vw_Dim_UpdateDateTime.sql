

CREATE view [dbo].[Vw_Dim_UpdateDateTime]
as
	Select Replace(Convert(Varchar,dateadd(MINUTE,120,GetDate()),106),' ','-') as FullDateTime, dateadd(MINUTE,120,GetDate()) as UpdatedDateTime
