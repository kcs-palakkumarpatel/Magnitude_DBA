
CREATE Procedure [dbo].[PB_Proc_Dim_Beekman_FoodBeveragesChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_Beekman_FoodBeveragesChats','Dim_Beekman_FoodBeveragesChats Start','Beekman New'

	Truncate table dbo.Dim_Beekman_FoodBeveragesChats

	
	Insert into Dim_Beekman_FoodBeveragesChats(ReferenceNo, Conversation,name,Date)
	select ReferenceNo, Conversation,name,Date
	 from [PB_VW_Dim_Beekman_FoodBeveragesChats]

	Select @Desc = 'Dim_Beekman_FoodBeveragesChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_Beekman_FoodBeveragesChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_Beekman_FoodBeveragesChats',@Desc,'Beekman New'

	Set NoCount OFF;
END
