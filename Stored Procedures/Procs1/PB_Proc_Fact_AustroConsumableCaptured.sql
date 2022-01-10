CREATE Procedure [dbo].[PB_Proc_Fact_AustroConsumableCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableCaptured','Fact_AustroConsumableCaptured Start','Austro'

	--Truncate table dbo.Fact_AustroConsumableCaptured

	delete From Fact_AustroConsumableCaptured where Flag=0
	
	Insert into Fact_AustroConsumableCaptured(EstablishmentName ,CapturedDate ,ReferenceNo ,IsPositive,Status,PI ,UserId,UserName ,ResolvedDate ,Longitude ,Latitude,Customer,[Products Using],[Equip. at work],[New Customer],
[Quantity] ,[Comments ],[Product Family],[Meeting Perception] ,[Additional Gaps ],[If yes, please out],[Potential financia] ,[Branded Products ],[Resistance ],
[Resistance Type],[If other, please s],[Met With ] ,[Functionality/Fit ],[Outline how you wi],[Meeting Summary ],[Agreed Next Steps],[Type] ,
[Products],[Name],[Mobile],[Email],[Industry:],
[Type of task:],[Description of wor],Flag
)
	select EstablishmentName ,CapturedDate ,ReferenceNo ,IsPositive,Status,PI ,UserId,UserName ,ResolvedDate ,Longitude ,Latitude,Customer,[Products Using],[Equip. at work],[New Customer],
[Quantity] ,[Comments ],[Product Family],[Meeting Perception] ,[Additional Gaps ],[If yes, please out],[Potential financia] ,[Branded Products ],[Resistance ],
[Resistance Type],[If other, please s],[Met With ] ,[Functionality/Fit ],[Outline how you wi],[Meeting Summary ],[Agreed Next Steps],[Type] ,
[Products],[Name],[Mobile],[Email],[Industry:],[Type of task:],[Description of wor],0 as Flag

	 from [PB_VW_Fact_AustroConsumableCaptured]

	Select @Desc = 'Fact_AustroConsumableCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroConsumableCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
