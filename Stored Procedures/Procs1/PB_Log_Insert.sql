CREATE PRoc [dbo].[PB_Log_Insert]
(@TableName Varchar(50),
@Desc Varchar(1000),
@ProjectName varchar(1000))
As
Begin
	Insert Into dbo.PB_Log (RefreshDate,TableName,[Description],ProjectName)
	Values (GetDate(),@TableName,@Desc,@ProjectName)
END
