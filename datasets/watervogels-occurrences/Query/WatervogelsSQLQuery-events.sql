USE [W0004_00_Waterbirds]
GO

/****** Object:  View [iptdev].[vwGBIF_INBO_Watervogels_events]    Script Date: 20/05/2019 14:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER VIEW [iptdev].[vwGBIF_INBO_Watervogels_events]
AS


SELECT  

  ---RECORD ---

      [type] = N'Event'
   	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://github.com/LifeWatchINBO/norms-for-data-use'
	, [datasetID] = N'http://doi.org/10.15468/lj0udq'
	, [datasetName] = N'Watervogels - Wintering waterbirds in Flanders, Belgium'
	, [institutionCode] = N'INBO'
	, [ownerInstitutionCode] = N'INBO'
	
	
  ---EVENT---	
	
	, [eventID ] = N'INBO:WATERVOGELS:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) ,dsa.SampleKey),10)  
	, [parentEventID] = N'INBO:WATERVOGELS:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) ,di.SurveyKey),10)
	, [basisOfRecord] = N'HumanObservation'
	, [samplingProtocol] = CASE SurveyCode
							WHEN 'ZSCH' THEN 'Survey from boat'
							WHEN 'NOORD' THEN 'Survey from boat'
							ELSE 'Survey from land'
							END
	, [samplingEffort] = case CoverageDescription
							WHEN 'Volledig' THEN 'all waterbirds counted'
							WHEN 'Onvolledig' THEN 'not all waterbirds counted'
							END
	,[eventDate] = SampleDate
	,[eventRemarks] = 
		'{'
		+
		CASE samplecondition
			WHEN 'FAVORABLE' THEN '"samplingConditions":"favourable", ' -- Gunstig / normaal
			WHEN 'UNFAVORABLE' THEN '"samplingConditions":"unfavourable", ' -- Ongunstig
			ELSE '' 
		END
		+
		CASE CoverageCode
			WHEN 'V' THEN '"samplingCoverage":"complete", ' -- Volledig
			WHEN 'O' THEN '"samplingCoverage":"incomplete", ' -- Onvolledig
			WHEN 'N' THEN '' -- Niet geteld;  -> should return no data, as we select on having a scientificName
			WHEN 'X' THEN '' -- Geteld, geen vogels -> should return no data, as we select on having a scientificName
			ELSE ''
		END
		+
		CASE SnowCoverCode 
			WHEN 'N' THEN '"snow":"none", ' -- Geen
			WHEN 'E' THEN '"snow":"everywhere", ' -- Overal
			WHEN 'L' THEN '"snow":"locally", ' -- Plaatselijk
			ELSE ''
		END
		+ CASE IceCoverCode
			WHEN 'N' THEN '"ice":"0%", ' -- Geen
			WHEN 'M' THEN '"ice":">50%", ' -- < 50 %
			WHEN 'L' THEN '"ice":"<50%", ' -- > 50 %
			WHEN 'F' THEN '"ice":"100%", ' -- 100%
			ELSE ''
		END
		+ CASE WaterLevelCode
			WHEN 'N' THEN '"waterLevel":"normal"' -- Normaal
			WHEN 'L' THEN '"waterLevel":"low"' -- Laag
			WHEN 'H' THEN '"waterLevel":"high"' -- Hoog
			ELSE ''
		END
		+
		'}'
	
	---LOCATION
	, [locationID] = N'INBO:WATERVOGELS:LOCATION:' + Right( N'000000000' + CONVERT(nvarchar(20) ,DiL.LocationWVCode),10) 
	, [continent] = N'Europe'
	, [waterbody] = Dil.LocationWVNaam
	, [countryCode] = N'BE'
	, [varbatimLocality] = DiL.LocationWVNaam
	, [locationRemarks] = N'cite centroid' 
	, CONVERT(decimal(10,5), Dil.LocationGeometry.STCentroid().STY) as decimalLatitude
	, CONVERT(decimal(10,5), Dil.LocationGeometry.STCentroid().STX) as decimalLongitude
	, [geodeticDatum] = N'WGS84'

	, Dil.LocationGeometry as LocationGeometry
	, Dil.LocationGeometry.STCentroid() as LocationGeometryCentroid
	, Dil.LocationGeometry.STCentroid().STAsText() as LocationGeometryCentroidTekst


	, SurveyCode
	, SurveyNaam
	--- , dsa.IceCoverDescription

FROM dbo.DimSample dsa 
 INNER JOIN (SELECT DISTINCT(SampleKey), SurveyKey, EventKey, LocationWVKey, SampleDateKey FROM FactTaxonOccurrence Fta WHERE SampleKey > 0) as Sa ON sa.sampleKey = dsa.SampleKey
 INNER JOIN dbo.DimSurvey Di on Di.SurveyKey = Sa.SurveyKey
							AND Di.SurveyCode IN ('ZSCH','NOORD','MIDMA')
 INNER JOIN dbo.DimLocationWV DiL on DiL.LocationWVKey = Sa.LocationWVKey
									
--SELECT  *FROM DimSample
--SELECT  *FROM DimSurvey


GO

