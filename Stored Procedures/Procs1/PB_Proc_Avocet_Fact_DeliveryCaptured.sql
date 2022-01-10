
CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_DeliveryCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_DeliveryCaptured','Avocet_Fact_DeliveryCaptured Start','Avocet'

	Truncate table dbo.Avocet_Fact_DeliveryCaptured

	
	Insert into Avocet_Fact_DeliveryCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,[Customer],
[Order Type],[Invoice | Job Card],[Invoice | Job Card | Delivery Note Number],[Delivery Date],
[Any additional req],RepeatCount,[Order Type Detail],[Order Type - waiti],[Labels],
[Stock Code],[Quantity],[Description],Latitude,Longitude,ResolvedDate,ResponseDate, 
ResponseReferenceNo,[Response User],[GRV / Store Stamp ],[Delivery Done],[Any comments regar],
[Pricing Good],[Issues],[If yes, please exp],[Please sign off],ResponseLatitude,ResponseLongitude,Technician)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,[Customer],
[Order Type],[Invoice | Job Card],[Invoice | Job Card | Delivery Note Number],[Delivery Date],
[Any additional req],RepeatCount,[Order Type Detail],[Order Type - waiti],[Labels],
[Stock Code],[Quantity],[Description],Latitude,Longitude,ResolvedDate,ResponseDate, 
ResponseReferenceNo,[Response User],[GRV / Store Stamp ],[Delivery Done],[Any comments regar],
[Pricing Good],[Issues],[If yes, please exp],[Please sign off],ResponseLatitude,ResponseLongitude,Technician
	 from [PB_VW_Avocet_Fact_DeliveryCaptured]

	Select @Desc = 'Avocet_Fact_DeliveryCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_DeliveryCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_DeliveryCaptured',@Desc,'Avocet'

	Set NoCount OFF;
END
