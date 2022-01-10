


CREATE Procedure [dbo].[PB_Proc_Fact_AustroMachineCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroMachineCaptured','Fact_AustroMachineCaptured Start','Austro'

	--Truncate table dbo.Fact_AustroMachineCaptured

	delete from dbo.Fact_AustroMachineCaptured where Flag=0

	Insert into Fact_AustroMachineCaptured(EstablishmentName,CapturedDate ,ReferenceNo ,IsPositive ,Status ,PI ,UserId ,UserName ,ResolvedDate ,Longitude ,Latitude ,[Meeting Perception] ,
[Opportunities] ,[What Opportunity] ,[Resistance ] ,[Resistance Type] ,[Other Resistance Type] ,[Application of the] ,[Today you met with] ,
[Meeting Chemistry ],[Meeting Summary ],[Next steps agreed], [Target date for ne] ,[Quote] ,[Fit Requirements ] ,[Plan],[General Comments ],[Quote Description ],[New Customer],
[Company OR private],[Company VAT No.],[Company Registrati],[Identification Num],[Postal Address ],[Delivery Address], [Postal Code ],[Email Address], [Tel Number ],[Fax Number],
[Web address],[Nature of business],[Materials Used ],[Business Size ],[Referred to Austro],[Value (ZAR) ],[Price (ZAR) ] ,[Product] ,[Name],[Mobile],[Email],[Company] ,[Industry:],[Biesse Callout],[Trevor Present ],Customer,Flag)
	select EstablishmentName,CapturedDate ,ReferenceNo ,IsPositive ,Status ,PI ,UserId ,UserName ,ResolvedDate ,Longitude ,Latitude ,[Meeting Perception] ,
[Opportunities] ,[What Opportunity] ,[Resistance ] ,[Resistance Type] ,[Other Resistance Type] ,[Application of the] ,[Today you met with] ,
[Meeting Chemistry ],[Meeting Summary ],[Next steps agreed], [Target date for ne] ,[Quote] ,[Fit Requirements ] ,[Plan],[General Comments ],[Quote Description ],[New Customer],
[Company OR private],[Company VAT No.],[Company Registrati],[Identification Num],[Postal Address ],[Delivery Address], [Postal Code ],[Email Address], [Tel Number ],[Fax Number],
[Web address],[Nature of business],[Materials Used ],[Business Size ],[Referred to Austro],[Value (ZAR) ],[Price (ZAR) ] ,[Product] ,[Name],[Mobile],[Email],[Company] ,[Industry:],[Biesse Callout],[Trevor Present ],customer,0 As Flag
	 from [PB_VW_Fact_AustroMachineCaptured]

	Select @Desc = 'Fact_AustroMachineCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroMachineCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroMachineCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
