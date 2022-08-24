
/******************************************************************************************************************************
**               AUTHOR : Bob Barringer
**        CREATION DATE : 08/23/2022
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : Aetna Extract
**        SQL FILE NAME : GetAetnaDualLab.sql
**          TEMPLATE ID : N/A
**             TICKET # : N/A
**
**              PURPOSE : Get data for Aetna Dual Lab extract
** BI DOCUMENT LOCATION : N/A
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			Modified XXXXX.
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetAetnaDualLab]
	
AS

-- copied from Humana 
--DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
--DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1'));


SELECT DISTINCT
	   'Epic' AS 'DATA SOURCE',
	   c.SubscriberNumber AS 'Aetna Cardholder Number ("ME" or "W" Number)', -- Primary Policy ID Number
	   '' AS 'Medicare HICN or MBI (Health Insurance Claim Number)',
	   COALESCE(patdim.SSN, patdim.PrimaryMRN) AS 'Other Member ID''s: SSN or Medical Record Number (Coventry only)',
	   patdim.LastName AS PTLNAME,
	   patdim.FirstName AS PTFNAME,
	   CONVERT(VARCHAR(8), patdim.BirthDate, 112) AS PTDOB,
	   CASE WHEN patdim.Sex = 'Male' THEN 'M' WHEN patdim.Sex = 'Female' THEN 'F' END AS PTSEX,
	   c.SubscriberGroupNumber AS 'Aetna Group Number',  --  PolicyGroupNumber, Patient Insurance Case Policy Group Number
	   CONVERT(VARCHAR(8), d.DateValue, 112) AS 'Service Start Date',
	   do.PrimarySpecialtyTaxonomyCode AS 'Ordering Provider Taxonomy Code', -- check clarity, check with Alan Lasu, may be able to import from Clarity
	   do.NPI AS 'Ordering Provider NPI',  
	   '' AS 'Ordering Provider Tax ID',
	   CASE 
	      WHEN do.Name LIKE '%,%' THEN SUBSTRING(do.Name, (CHARINDEX(',', do.Name) + 3), LEN(do.Name))
	      ELSE do.Name
	   END AS 'Ordering Provider Last Name',
	   CASE 
	      WHEN do.Name LIKE '%,%' THEN REPLACE(SUBSTRING(do.Name, 3, (CHARINDEX(',', do.Name))), ',', '')
	      ELSE do.Name
	   END AS 'Ordering Provider First Name',
	   CASE WHEN compdim.LoincCode LIKE '*%' THEN '' ELSE compdim.LoincCode END AS 'LOINC', 
	   pr.Name AS 'TEST NAME',  
	   '' AS 'SNOMEDCD', -- blank
	   ISNULL(lcrf.NumericValue, '') AS 'RESNO', 
	   lcrf.Value AS 'RESTEXT', 	   
	   ISNULL(MAX(CASE WHEN flodim.FlowsheetRowEpicId = '301070' THEN fsdfact.Value END), '') AS BMI,  
	   ISNULL(MAX(CASE WHEN flodim.FlowsheetRowEpicId = '5' THEN SUBSTRING(fsdfact.Value, 1, CHARINDEX('/', fsdfact.Value) - 1) END), '') AS 'SYSTOLIC BP',
	   ISNULL(MAX(CASE WHEN flodim.FlowsheetRowEpicId = '5' THEN SUBSTRING(fsdfact.Value, CHARINDEX('/', fsdfact.Value) + 1, LEN(fsdfact.Value)) END), '') AS 'DIASTOLIC BP'
FROM LabComponentResultFact lcrf 
    JOIN LabComponentDim compdim ON (lcrf.LabComponentKey = compdim.LabComponentKey)
	LEFT OUTER JOIN ProcedureOrderFact o ON (lcrf.LabOrderEpicId = o.ProcedureOrderEpicId)
	LEFT OUTER JOIN ProcedureDim pr ON (o.ProcedureDurableKey = pr.DurableKey AND pr.IsCurrent = 1)	
    JOIN PatientDim patdim ON (lcrf.PatientDurableKey = patdim.DurableKey AND patdim.IsCurrent = 1)    
	JOIN ProviderDim do ON (lcrf.AuthorizedByProviderDurableKey = do.DurableKey AND do.IsCurrent = 1) 
	JOIN EncounterFact e ON (lcrf.EncounterKey = e.EncounterKey)
	JOIN CoverageDim c ON (e.PrimaryCoverageKey = c.CoverageKey)
	JOIN DateDim d ON (e.DateKey = d.DateKey)	
	JOIN FlowsheetValueFact fsdfact ON (e.EncounterKey = fsdfact.EncounterKey)
	JOIN FlowsheetRowDim flodim ON (fsdfact.FlowsheetRowKey = flodim.FlowsheetRowKey)
	JOIN BillingAccountFact baf ON (e.EncounterKey = baf.PrimaryEncounterKey)
	JOIN CodedProcedureFact cpf ON (baf.BillingAccountKey = cpf.BillingAccountKey)
WHERE e.VisitType LIKE '%office%'
	AND c.BenefitPlanEpicId IN ('45000105', '45000103')  -- Aetna Dual/Medicaid
GROUP BY c.PayorEpicId, c.BenefitPlanEpicId, c.PayorName, c.BenefitPlanName, patdim.PrimaryMRN, c.SubscriberNumber, patdim.SSN, patdim.PrimaryMRN, patdim.LastName, patdim.FirstName, patdim.BirthDate, patdim.Sex, c.SubscriberGroupNumber, d.DateValue, 
     	 do.PrimarySpecialtyTaxonomyCode, do.NPI, do.Name, compdim.LoincCode, pr.Name, lcrf.NumericValue, lcrf.Value

RETURN 0
