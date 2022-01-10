

CREATE Procedure [dbo].[PB_Proc_Fact_Beekman_FoodBeverages]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman_FoodBeverages','Fact_Beekman_FoodBeverages Start','Beekman New'

	Truncate table dbo.Fact_Beekman_FoodBeverages

	
	Insert into Fact_Beekman_FoodBeverages(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,Answer,Rating,Question,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,Answer,Rating,Question,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved
	 from [PB_VW_Fact_Beekman_FoodBeverages]

	Select @Desc = 'Fact_Beekman_FoodBeverages Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman_FoodBeverages(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman_FoodBeverages',@Desc,'Beekman New'

	Set NoCount OFF;
END
