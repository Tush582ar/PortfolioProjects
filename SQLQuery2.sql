/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[Per_Country_Vaccinations_till_date]
  FROM [Portfolio_Project].[dbo].[PercentPopulationVaccinated]