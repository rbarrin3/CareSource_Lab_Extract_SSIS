/**************************************************************************************************************************************************
**               AUTHOR : Bob Barringer
**        CREATION DATE : 08/01/2022
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : EMS
**        SQL FILE NAME : GetEMSResponseFields.sql
**          TEMPLATE ID : 
**             TICKET # : 
**
**              PURPOSE : EMS Response Fields for ChangeHealthcare
** BI DOCUMENT LOCATION : https://rocketsutoledo.sharepoint.com/:f:/s/EPICEMRProject-DTAS/EsVS-SnbxwlJu7tB6Jg795ABy5m8_gvMjd7SFyld0eB4SQ?e=yvfM1k
***************************************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			Modified XXXXX.
***************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetEMSResponseFields] (@dbName VARCHAR(50))
AS

USE @dbName
GO

SELECT DISTINCT  
	   CASE WHEN ISNULL(CONVERT(VARCHAR(10), ad.DateValue, 101), '') LIKE '*%' THEN '' ELSE ISNULL(CONVERT(VARCHAR(10), ad.DateValue, 101), '') END AS ArDate,
	   CASE WHEN evf.ArrivalMethod LIKE '*%' THEN '' ELSE evf.ArrivalMethod END AS ArMethod,
	   CASE WHEN pd.FirstName LIKE '*%' THEN '' ELSE pd.FirstName END AS Pat_First_Name,
	   CASE WHEN SUBSTRING(pd.MiddleName, 1, 1) = '*' THEN '' ELSE SUBSTRING(pd.MiddleName, 1, 1) END AS Pat_Name_MI,
	   CASE WHEN pd.LastName LIKE '*%' THEN '' ELSE pd.LastName END AS Pat_Last_Name,
	   CASE WHEN pd.Address LIKE '*%' THEN '' ELSE pd.Address END AS Pat_Addr,
	   '' AS Pat_Addr_2,
	   CASE WHEN pd.City LIKE '*%' THEN '' ELSE pd.City END AS Pat_City,
	   CASE WHEN pd.StateOrProvince LIKE '*%' THEN '' ELSE pd.StateOrProvince END AS Pat_State, 
	   CASE WHEN pd.PostalCode LIKE '*%' THEN '' ELSE pd.PostalCode END AS Pat_Zip, 
	   CASE WHEN ISNULL(CONVERT(VARCHAR(10), pd.BirthDate, 101), '') LIKE '*%' THEN '' ELSE ISNULL(CONVERT(VARCHAR(10), pd.BirthDate, 101), '') END AS Pat_DOB,
	   CASE WHEN pd.Sex LIKE '*%' THEN '' ELSE pd.Sex END AS Pat_Sex,
	   CASE WHEN pd.SSN LIKE '*%' THEN '' ELSE pd.SSN END AS Pat_SSN, 
	   CASE WHEN pd.HomePhoneNumber LIKE '*%' THEN '' ELSE pd.HomePhoneNumber END AS Pat_Phone,
	   CASE WHEN pd.WorkPhoneNumber LIKE '*%' THEN '' ELSE pd.WorkPhoneNumber END AS Pat_Emp_Phone,
	   CASE 
	      WHEN gd.Name LIKE '*%' THEN ''
		  WHEN gd.AccountType = 'Personal/Family' AND gd.Name LIKE '%,%' THEN REPLACE(SUBSTRING(gd.Name, 1, (CHARINDEX(',', gd.Name))), ',', '')
		  ELSE gd.Name
	   END AS RP_Name_First,
	   '' AS RP_Name_MI,
	   CASE 
	      WHEN gd.Name LIKE '*%' THEN ''
		  WHEN gd.AccountType = 'Personal/Family' THEN SUBSTRING(gd.Name, (CHARINDEX(',', gd.Name) + 1), LEN(gd.Name))
		  ELSE gd.Name
	   END AS RP_Name_Last,
	   '' AS RP_SSN,
	   '' AS RP_Relation,
	   CASE WHEN gd.Address LIKE '*%' THEN '' ELSE gd.Address END AS RP_Addr,
	   CASE WHEN gd.City LIKE '*%' THEN '' ELSE gd.City END AS RP_City,
	   CASE WHEN gd.StateOrProvince LIKE '*%' THEN '' ELSE gd.StateOrProvince END AS RP_State,
	   CASE WHEN gd.PostalCode LIKE '*%' THEN '' ELSE gd.PostalCode END AS RP_Zip,
	   CASE WHEN gd.HomePhoneNumber LIKE '*%' THEN '' ELSE gd.HomePhoneNumber END AS RP_Phone,
	   CASE WHEN cd1.PayorName LIKE '*%' THEN '' ELSE cd1.PayorName END AS Ins1_Co_Name,
	   CASE WHEN cd1.PayorEpicId LIKE '*%' THEN '' ELSE cd1.PayorEpicId END AS Ins1_Co_Code,  
	   CASE WHEN cd1.PayorAddress LIKE '*%' THEN '' ELSE cd1.PayorAddress END AS Ins1_Co_Addr,
	   CASE WHEN cd1.PayorCity LIKE '*%' THEN '' ELSE cd1.PayorCity END AS Ins1_Co_City,
	   CASE WHEN cd1.PayorStateOrProvince LIKE '*%' THEN '' ELSE cd1.PayorStateOrProvince END AS Ins1_Co_State,
	   CASE WHEN cd1.PayorPostalCode LIKE '*%' THEN '' ELSE cd1.PayorPostalCode END AS Ins1_Co_Zip,
	   CASE WHEN cd1.PayorPhoneNumber LIKE '*%' THEN '' ELSE cd1.PayorPhoneNumber END AS Ins1_Co_Phone,
	   CASE WHEN cd1.SubscriberNumber LIKE '*%' THEN '' ELSE cd1.SubscriberNumber END AS Ins1_Co_Policy,
	   CASE WHEN cd1.SubscriberGroupNumber LIKE '*%' THEN '' ELSE cd1.SubscriberGroupNumber END AS Ins1_Co_Group,
	   CASE
	      WHEN cd1.SubscriberName LIKE '*%' THEN ''
		  WHEN cd1.SubscriberName LIKE '%,%' THEN REPLACE(SUBSTRING(cd1.SubscriberName, 1, (CHARINDEX(',', cd1.SubscriberName))), ',', '')
		  ELSE cd1.SubscriberName
	   END AS Ins1_Sub_Name_First,
	   '' AS Ins1_Sub_Name_MI,
	   CASE 
	      WHEN cd1.SubscriberName LIKE '*%' THEN ''
		  WHEN cd1.SubscriberName LIKE '%,%' THEN SUBSTRING(gd.Name, (CHARINDEX(',', gd.Name) + 1), LEN(gd.Name))
		  ELSE cd1.SubscriberName
	   END AS Ins1_Sub_Name_Last,
       CASE WHEN ISNULL(CONVERT(VARCHAR(10), cd1.SubscriberDateofBirth_X, 101), '') LIKE '*%' THEN '' ELSE ISNULL(CONVERT(VARCHAR(10), cd1.SubscriberDateofBirth_X, 101), '') END AS Ins1_Sub_DOB,
       CASE WHEN cd1.SubscriberRELtoGUAR_X LIKE '*%' THEN '' ELSE cd1.SubscriberRELtoGUAR_X END AS Ins1_Sub_Relation,
       CASE WHEN cd1.SubscriberAddress LIKE '*%' THEN '' ELSE cd1.SubscriberAddress END AS Ins1_Sub_Addr,
       CASE WHEN cd1.SubscriberCity LIKE '*%' THEN '' ELSE cd1.SubscriberCity END AS Ins1_Sub_City,
       CASE WHEN cd1.SubscriberAddress LIKE '*%' THEN '' ELSE cd1.SubscriberAddress END AS Ins1_Sub_St, 
       CASE WHEN cd1.SubscriberPostalCode LIKE '*%' THEN '' ELSE cd1.SubscriberPostalCode END AS Ins1_Sub_Zip,
	   CASE WHEN cd2.PayorName LIKE '*%' THEN '' ELSE cd2.PayorName END AS Ins2_Co_Name,
	   CASE WHEN cd2.PayorEpicId LIKE '*%' THEN '' ELSE cd2.PayorEpicId END AS Ins2_Co_Code,   
	   CASE WHEN cd2.PayorAddress LIKE '*%' THEN '' ELSE cd2.PayorAddress END AS Ins2_Co_Addr,
	   CASE WHEN cd2.PayorCity LIKE '*%' THEN '' ELSE cd2.PayorCity END AS Ins2_Co_City,
	   CASE WHEN cd2.PayorStateOrProvince LIKE '*%' THEN '' ELSE cd2.PayorStateOrProvince END AS Ins2_Co_State,
	   CASE WHEN cd2.PayorPostalCode LIKE '*%' THEN '' ELSE cd2.PayorPostalCode END AS Ins2_Co_Zip,
	   CASE WHEN cd2.PayorPhoneNumber LIKE '*%' THEN '' ELSE cd2.PayorPhoneNumber END AS Ins2_Co_Phone,
	   CASE WHEN cd2.SubscriberNumber LIKE '*%' THEN '' ELSE cd2.SubscriberNumber END AS Ins2_Co_Policy,
	   CASE WHEN cd2.SubscriberGroupNumber LIKE '*%' THEN '' ELSE cd2.SubscriberGroupNumber END AS Ins2_Co_Group,
	   CASE 
	      WHEN cd2.SubscriberName LIKE '*%' THEN ''
	      WHEN cd2.SubscriberName LIKE '%,%' THEN REPLACE(SUBSTRING(cd2.SubscriberName, 1, (CHARINDEX(',', cd2.SubscriberName))), ',', '')
		  ELSE cd2.SubscriberName
	   END AS Ins2_Sub_Name_First,
	   '' AS Ins2_Sub_Name_MI,
	   CASE 
	      WHEN cd2.SubscriberName LIKE '*%' THEN ''
		  WHEN cd2.SubscriberName LIKE '%,%' THEN SUBSTRING(gd.Name, (CHARINDEX(',', gd.Name) + 1), LEN(gd.Name))
		  ELSE cd2.SubscriberName
	   END AS Ins2_Sub_Name_Last,
	   CASE WHEN ISNULL(CONVERT(VARCHAR(10), cd2.SubscriberDateofBirth_X, 101), '') LIKE '*%' THEN '' ELSE ISNULL(CONVERT(VARCHAR(10), cd2.SubscriberDateofBirth_X, 101), '') END AS Ins2_Sub_DOB,
       CASE WHEN cd2.SubscriberRELtoGUAR_X LIKE '*%' THEN '' ELSE cd2.SubscriberRELtoGUAR_X END AS Ins2_Sub_Relation,
       CASE WHEN cd2.SubscriberAddress LIKE '*%' THEN '' ELSE cd2.SubscriberAddress END AS Ins2_Sub_Addr,
       CASE WHEN cd2.SubscriberCity LIKE '*%' THEN '' ELSE cd2.SubscriberCity END AS Ins2_Sub_City,
       CASE WHEN cd2.SubscriberAddress LIKE '*%' THEN '' ELSE cd2.SubscriberAddress END AS Ins2_Sub_St,
       CASE WHEN cd2.SubscriberPostalCode LIKE '*%' THEN '' ELSE cd2.SubscriberPostalCode END AS Ins2_Sub_Zip,
	   CASE WHEN cd3.PayorName LIKE '*%' THEN '' ELSE cd3.PayorName END AS Ins3_Co_Name,
	   CASE WHEN cd3.PayorEpicId LIKE '*%' THEN '' ELSE cd3.PayorEpicId END AS Ins3_Co_Code,   
	   CASE WHEN cd3.PayorAddress LIKE '*%' THEN '' ELSE cd3.PayorAddress END AS Ins3_Co_Addr,
	   CASE WHEN cd3.PayorCity LIKE '*%' THEN '' ELSE cd3.PayorCity END AS Ins3_Co_City,
	   CASE WHEN cd3.PayorStateOrProvince LIKE '*%' THEN '' ELSE cd3.PayorStateOrProvince END AS Ins3_Co_State,
	   CASE WHEN cd3.PayorPostalCode LIKE '*%' THEN '' ELSE cd3.PayorPostalCode END AS Ins3_Co_Zip,
	   CASE WHEN cd3.PayorPhoneNumber LIKE '*%' THEN '' ELSE cd3.PayorPhoneNumber END AS Ins3_Co_Phone,
	   CASE WHEN cd3.SubscriberNumber LIKE '*%' THEN '' ELSE cd3.SubscriberNumber END AS Ins3_Co_Policy,
	   CASE WHEN cd3.SubscriberGroupNumber LIKE '*%' THEN '' ELSE cd3.SubscriberGroupNumber END AS Ins3_Co_Group,
	   CASE 
		  WHEN cd3.SubscriberName LIKE '*%' THEN ''
		  WHEN cd3.SubscriberName LIKE '%,%' THEN REPLACE(SUBSTRING(cd3.SubscriberName, 3, (CHARINDEX(',', cd3.SubscriberName))), ',', '')
		  ELSE cd3.SubscriberName
	   END AS Ins3_Sub_Name_First,
	   '' AS Ins3_Sub_Name_MI,
	   CASE 
		  WHEN cd3.SubscriberName LIKE '*%' THEN ''
		  WHEN cd3.SubscriberName LIKE '%,%' THEN SUBSTRING(gd.Name, (CHARINDEX(',', gd.Name) + 3), LEN(gd.Name))
		  ELSE cd3.SubscriberName
	   END AS Ins3_Sub_Name_Last,
	   CASE WHEN ISNULL(CONVERT(VARCHAR(10), cd3.SubscriberDateofBirth_X, 101), '') LIKE '*%' THEN '' ELSE ISNULL(CONVERT(VARCHAR(10), cd3.SubscriberDateofBirth_X, 101), '') END AS Ins3_Sub_DOB,
       CASE WHEN cd3.SubscriberRELtoGUAR_X LIKE '*%' THEN '' ELSE cd3.SubscriberRELtoGUAR_X END AS Ins3_Sub_Relation,
       CASE WHEN cd3.SubscriberAddress LIKE '*%' THEN '' ELSE cd3.SubscriberAddress END AS Ins3_Sub_Addr,
       CASE WHEN cd3.SubscriberCity LIKE '*%' THEN '' ELSE cd3.SubscriberCity END AS Ins3_Sub_City,
       CASE WHEN cd3.SubscriberAddress LIKE '*%' THEN '' ELSE cd3.SubscriberAddress END AS Ins3_Sub_St,
       CASE WHEN cd3.SubscriberPostalCode LIKE '*%' THEN '' ELSE cd3.SubscriberPostalCode END AS Ins3_Sub_Zip
FROM CustomRaw.EMS_ER_Patients eep
	LEFT OUTER JOIN PatientDim pd ON ((eep.Pat_Last_Name = pd.LastName AND REPLACE(CAST(eep.Pat_DOB AS DATE),'/', '-') = pd.BirthDate)
									------------------  AND eep.Pat_First_Name = pd.FirstName	
										 OR eep.PAT_SSN = pd.SSN)
	LEFT OUTER JOIN EdVisitFact evf ON (pd.DurableKey = evf.PatientDurableKey AND pd.IsCurrent = 1)
	JOIN DateDim ad ON (evf.ArrivalDateKey = ad.DateKey)
	JOIN EncounterFact ef ON (evf.EncounterKey = ef.EncounterKey)
	JOIN BillingAccountFact baf ON (ef.EncounterKey = baf.PrimaryEncounterKey)	
	JOIN GuarantorDim gd ON (evf.GuarantorDurableKey = gd.DurableKey AND gd.IsCurrent = 1)
	JOIN CoverageDim cd1 ON (baf.PrimaryCoverageKey = cd1.CoverageKey)
	JOIN CoverageDim cd2 ON (baf.SecondCoverageKey = cd2.CoverageKey)
	JOIN CoverageDim cd3 ON (baf.ThirdCoverageKey = cd3.CoverageKey)


