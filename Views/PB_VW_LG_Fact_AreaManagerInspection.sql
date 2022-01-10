

CREATE VIEW [dbo].[PB_VW_LG_Fact_AreaManagerInspection] AS
WITH cte AS(
SELECT X.*,Y.ResponseDate,Y.[Condition Site, Happy?],
Y.[Please explain],
Y.[Improvement Notes] FROM (
SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,RepeatCount,
[Client Name],
[Site Address],
[Select Month],
CASE WHEN [Select Month]='January' THEN 1 WHEN [Select Month]='February' THEN 2 WHEN [Select Month]='March' THEN 3
WHEN [Select Month]='April' THEN 4 WHEN [Select Month]='May' THEN 5 WHEN [Select Month]='June' THEN 6
WHEN [Select Month]='July' THEN 7 WHEN [Select Month]='August' THEN 8 WHEN [Select Month]='September' THEN 9
WHEN [Select Month]='October' THEN 10 WHEN [Select Month]='November' THEN 11 WHEN [Select Month]='December' THEN 12
ELSE 0 END AS MonthSort,
[Week],
REPLACE([Watering],'%','')AS [Watering],
REPLACE([Pruning],'%','')AS [Pruning],
REPLACE([Fertilizing],'%','')AS [Fertilizing],
REPLACE([Cleaning of Plants],'%','')AS [Cleaning of Plants],
REPLACE([Rotating of Plants],'%','')AS [Rotating of Plants],
REPLACE([Caps],'%','')AS [Caps],
REPLACE([Bark Dressing],'%','')AS [Bark Dressing],
REPLACE([Pest Control],'%','')AS [Pest Control],
REPLACE([Disease Control],'%','')AS [Disease Control],
REPLACE([Overall impression],'%','')AS [Overall impression],
[Clients perception],
[Client Full Name],
[Date and Time IN],
[Plant/Pot Replaced],
[Plant Replacement],
[Plant Description],
[Quantity],
[Location],
[Reason],
[Issue Description],
[Watering Comments],
[Pruning Comments],
[Fertilizing Comments],
[Cleaning of Plants Comments],
[Rotating Comments] as [Rotating of Plants Comments],
[Caps Comments],
[Bark Comments] AS [Bark Dressing Comments],
[Pest Control Comments],
[Diesel Control Comments],
[Watering Image],
[Pruning Image],
[Fertilizing Image],
[Cleaning Image],
[Rotating Image],
[Bark Image],
[Pest Control Image],
[Desease Ctrl Image],
[Caps Image],
[Picture of plant],
[Attach Image],PI,[Managers comments]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status,A.RepeatCount,AM.PI

,Q.shortname AS Question ,U.id AS UserId, u.name AS UserName

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=514 AND EG.Id =5693
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN (46583,46584,46588,46589,47025,47026,47027,47028,47029,47030,47031,47032,47033,47034,47035,
46620,46586,46622,48668,46624,46626,46628,46629,46630,46591,46594,46597,46600,46603,46606,46608,46611,46614,54366,46633,
46627,54316,46592,54315,46595,54303,46598,54296,46601,54295,46604,54294,54339,54292,46609,54291,46612,54287,
46615,54286,54285,46633,46631,67033,67034,67035,67038,67039,67040,67041,67042,67043,64287,48669,64288,64286,46631
,72186,72187,72188,72189)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy

)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Client Name],
[Site Address],
[Select Month],
[Week],
[Watering],
[Pruning],
[Fertilizing],
[Cleaning of Plants],
[Rotating of Plants],
[Caps],
[Bark Dressing],
[Pest Control],
[Disease Control],
[Overall impression],
[Clients perception],
[Client Full Name],
[Date and Time IN],
[Plant/Pot Replaced],
[Plant Replacement],
[Plant Description],
[Quantity],
[Location],
[Reason],
[Issue Description],
[Watering Comments],
[Pruning Comments],
[Fertilizing Comments],
[Cleaning of Plants Comments],
[Rotating Comments],
[Caps Comments],
[Bark Comments],
[Pest Control Comments],
[Diesel Control Comments],
[Watering Image],
[Pruning Image],
[Fertilizing Image],
[Cleaning Image],
[Rotating Image],
[Bark Image],
[Pest Control Image],
[Desease Ctrl Image],
[Caps Image],
[Picture of plant],
[Attach Image],
[Managers comments]
))P
)X
LEFT OUTER JOIN 

(SELECT 
EstablishmentName,ResponseDate ,ReferenceNo,
SeenclientAnswerMasterId,
[Condition Site, Happy?],
[Please explain],
[Improvement Notes]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status,Am.SeenclientAnswerMasterId,

Q.shortname AS Question 

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=514 AND EG.Id =5693
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (31499,31500,31501)

)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Condition Site, Happy?],
[Please explain],
[Improvement Notes]

))P) Y ON X.referenceno=Y.SeenclientAnswermasterid

)

SELECT 
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,B.Status,
B.UserName,A.RepeatCount,
B.[Client Name],
B.[Site Address],
B.[Select Month],
B.MonthSort,
B.[Week],
B.[Watering],
B.[Pruning],
B.[Fertilizing],
B.[Cleaning of Plants],
B.[Rotating of Plants],
B.[Caps],
B.[Bark Dressing],
B.[Pest Control],
B.[Disease Control],
B.[Overall impression],
B.[Clients perception],
B.[Client Full Name],
B.[Date and Time IN],
B.[Plant/Pot Replaced],
B.[Plant Replacement],
A.[Plant Description],
A.[Quantity],
A.[Location],
A.[Reason],
A.[Issue Description],
B.[Watering Comments],
B.[Pruning Comments],
B.[Fertilizing Comments],
B.[Cleaning of Plants Comments],
B.[Rotating of Plants Comments],
B.[Caps Comments],
B.[Bark Dressing Comments],
B.[Pest Control Comments],
B.[Diesel Control Comments],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Watering Image],1,CASE WHEN CHARINDEX(',',B.[Watering Image])=0 THEN LEN(B.[Watering Image])+1 ELSE CHARINDEX(',',B.[Watering Image]) END -1)  AS [Watering Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Pruning Image],1,CASE WHEN CHARINDEX(',',B.[Pruning Image])=0 THEN LEN(B.[Pruning Image])+1 ELSE CHARINDEX(',',B.[Pruning Image]) END -1)AS [Pruning Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Fertilizing Image],1,CASE WHEN CHARINDEX(',',B.[Fertilizing Image])=0 THEN LEN(B.[Fertilizing Image])+1 ELSE CHARINDEX(',',B.[Fertilizing Image]) END -1) AS[Fertilizing Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Cleaning Image],1,CASE WHEN CHARINDEX(',',B.[Cleaning Image])=0 THEN LEN(B.[Cleaning Image])+1 ELSE CHARINDEX(',',B.[Cleaning Image]) END -1)AS [Cleaning Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Rotating Image],1,CASE WHEN CHARINDEX(',',B.[Rotating Image])=0 THEN LEN(B.[Rotating Image])+1 ELSE CHARINDEX(',',B.[Rotating Image]) END -1)AS[Rotating Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Bark Image],1,CASE WHEN CHARINDEX(',',B.[Bark Image])=0 THEN LEN(B.[Bark Image])+1 ELSE CHARINDEX(',',B.[Bark Image]) END -1)AS[Bark Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Pest Control Image],1,CASE WHEN CHARINDEX(',',B.[Pest Control Image])=0 THEN LEN(B.[Pest Control Image])+1 ELSE CHARINDEX(',',B.[Pest Control Image]) END -1)AS[Pest Control Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Desease Ctrl Image],1,CASE WHEN CHARINDEX(',',B.[Desease Ctrl Image])=0 THEN LEN(B.[Desease Ctrl Image])+1 ELSE CHARINDEX(',',B.[Desease Ctrl Image]) END -1)AS[Desease Ctrl Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Caps Image],1,CASE WHEN CHARINDEX(',',B.[Caps Image])=0 THEN LEN(B.[Caps Image])+1 ELSE CHARINDEX(',',B.[Caps Image]) END -1)AS [Caps Image],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(A.[Picture of plant],1,CASE WHEN CHARINDEX(',',A.[Picture of plant])=0 THEN LEN(A.[Picture of plant])+1 ELSE CHARINDEX(',',A.[Picture of plant]) END -1)AS[Picture of plant],
B.ResponseDate,B.[Condition Site, Happy?],
B.[Please explain],
B.[Improvement Notes],
'https://webapi.magnitudefb.com/MGUploadData/SeenClient/'+SUBSTRING(B.[Attach Image],1,CASE WHEN CHARINDEX(',',B.[Attach Image])=0 THEN LEN(A.[Attach Image])+1 ELSE CHARINDEX(',',B.[Attach Image]) END -1)AS[Attach Image],
B.PI,
B.[Managers comments]

 FROM

(SELECT * FROM cte WHERE RepeatCount=0)B LEFT OUTER JOIN (SELECT * FROM cte WHERE Repeatcount<>0)A ON A.ReferenceNo=B.ReferenceNo







