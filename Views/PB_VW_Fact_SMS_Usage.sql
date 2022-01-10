CREATE VIEW dbo.PB_VW_Fact_SMS_Usage
as

Select S.Id,S.MobileNo,S.SMStext,S.Counter,dateadd(minute,120,S.Sentdate) as SentDate,S.refid,G.GroupName,EG.EstablishmentGroupName,E.EstablishmentName
from PendingSMS S
inner join SeenclientAnswermaster SAm on SAM.id=S.refid
inner join Establishment E on E.id=SAM.Establishmentid
inner join EstablishmentGroup EG on EG.id=E.establishmentGroupid
inner join [Group] G on G.id=EG.Groupid
where S.issent=1 AND S.IsDeleted=0 --and Convert(date,S.Sentdate,104)>=Convert(date,'01-05-2020',104)
