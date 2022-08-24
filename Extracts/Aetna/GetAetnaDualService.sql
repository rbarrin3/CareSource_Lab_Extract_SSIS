
/******************************************************************************************************************************
**               AUTHOR : Bob Barringer
**        CREATION DATE : 08/23/2022
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : Aetna Extract
**        SQL FILE NAME : GetAetnaDualService.sql
**          TEMPLATE ID : N/A
**             TICKET # : N/A
**
**              PURPOSE : Get data for Aetna Dual Service extract
** BI DOCUMENT LOCATION : N/A
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			Modified XXXXX.
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetAetnaDualService]
	
AS

-- copied from Humana 
--DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
--DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1'));


SELECT DISTINCT
	   'Epic' AS 'DATA SOURCE',
	   cd.SubscriberNumber AS 'Aetna Cardholder Number ("ME" or "W" Number)',  -- Primary Policy ID Number
	   '' AS 'Medicare HICN or MBI (Health Insurance Claim Number)',  
	   COALESCE(p.SSN, p.PrimaryMRN) AS 'Other Member ID''s: SSN or Medical Record Number (Coventry only)',  
	   p.LastName AS PTLNAME,
	   p.FirstName AS PTFNAME,
	   CONVERT(VARCHAR(8), p.BirthDate, 112) AS PTDOB, 
	   CASE WHEN p.Sex = 'Male' THEN 'M' WHEN p.Sex = 'Female' THEN 'F' END AS PTSEX, 
	   cd.SubscriberGroupNumber AS 'Aetna Group Number', --  PolicyGroupNumber, Patient Insurance Case Policy Group Number
	   CONVERT(VARCHAR(8), d.DateValue, 112) AS 'Service Start Date', 
	   '' AS INPTDSCGDATE, -- blank
	   CASE WHEN do.PrimarySpecialtyTaxonomyCode LIKE '*%' THEN '' ELSE do.PrimarySpecialtyTaxonomyCode END AS 'Rendering Provider Taxonomy Code', -- check clarity, check with Alan Lasu, may be able to import from Clarity   
	   CASE WHEN do.NPI LIKE '*%' THEN '' ELSE do.NPI END AS 'Rendering Provider NPI',  
	   '341127097' AS 'Rendering or Billing Provider Tax ID', -- appears to be hardcoded
	   REPLACE(SUBSTRING(do.Name, 1, CHARINDEX(',', do.Name)), ',', '') AS 'Rendering or Billing Provider Last Name',
	   CASE WHEN CASE WHEN do.Name LIKE '%,%' THEN TRIM(SUBSTRING(do.Name, CHARINDEX(',', do.Name) + 1, LEN(do.Name))) ELSE do.Name END LIKE '*%' THEN '' ELSE do.Name END AS 'Rendering or Billing Provider First Name',
	   dtd.Value AS DIAG1, -- primary diagnosis for the encounter
	   '' AS DIAG2,  -- blank
	   '' AS DIAG3,  -- blank
	   '' AS DIAG4,  -- blank
	   '' AS DIAG5,  -- blank
	   '' AS PROC1, -- blank
	   '' AS CPTCODE, -- encounter service procedure code, optional, blank if diag1 is populated
	   '' AS CPTMOD, -- blank
	   '' AS SNOMEDCD,  -- blank
	   '' AS REVCODE,  -- blank
	   '' AS PROCTYPCD, -- blank
	   '11' AS 'PLACE OF SERVICE',  -- hardcoded
	   '' AS 'MEDICAL RESULT', -- blank
	   '' AS 'PROCEDURE NAME', 
	   'P' AS 'CLAIM TYPE INDICATOR', 
	   'OUTP' AS 'PROVIDER TYPE',  
	   '' AS 'BILL TYPE'-- ,  -- blank
	   -- ISNULL(id.ImmunizationEpicId, '') AS ImmunizationEpicId  -- ADD THIS AFTER GO LIVE
FROM EncounterFact ef
	JOIN PatientDim p ON (ef.PatientDurableKey = p.DurableKey AND p.IsCurrent = 1)
	JOIN CoverageDim cd ON (ef.PrimaryCoverageKey = cd.CoverageKey)   
	JOIN DateDim d ON (ef.DateKey = d.DateKey)
	JOIN ProviderDim do ON (ef.AttendingProviderDurableKey = do.DurableKey AND do.IsCurrent = 1) 
	JOIN DiagnosisDim dd ON (ef.PrimaryDiagnosisKey = dd.DiagnosisKey)
	LEFT OUTER JOIN DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey AND dtd.Type = 'ICD‐10‐CM')
	LEFT OUTER JOIN ImmunizationEventFact ief ON (ef.EncounterKey = ief.EncounterKey)
	LEFT OUTER JOIN ImmunizationDim id ON (ief.ImmunizationKey = id.ImmunizationKey)
WHERE ef.VisitType LIKE '%office%'
	AND cd.BenefitPlanEpicId IN ('45000105', '45000103')  -- Aetna Dual/Medicaid


RETURN 0
