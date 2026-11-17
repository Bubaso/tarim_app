# 9 · Crop monitoring and yield forecasting

> **Summary.** Knowing the harvest before it comes is needed for early warning and for market and stock decisions. The European Commission's yield forecasting system does this with a database of crop-model outputs, weather, satellite and soil data: between 1993 and 2015 it published **19,980** forecasts; in the 2006-2015 assessment the median error was **3.73%** in France and **14.37%** in Portugal, and no crop showed a significant improvement over that period. When machine learning was tested against this system, it matched it for some crops and made twice the error for others. In Türkiye, according to the ministry's metadata, official harvest estimates rest on district directorates' records and agricultural technicians' impressions; in 2025 the ministry began identifying what is sown in which field with satellite imagery and machine learning.

## What it does

Crop monitoring asks two separate questions. The first: what is growing in the field? When a satellite images the same field again and again through the season, each crop traces its own curve of greening and yellowing; a model that learns these curves from fields whose crop is known classifies the rest. The second: how much will it yield? Yield forecasting combines crop growth models, weather data and satellite indicators to produce a figure weeks before harvest.

AI stands at a different distance from each question. Finding the crop in a field is the direct business of classification models that learn from labelled examples; studies in Türkiye and the ministry's new system both follow this path. In yield forecasting, by contrast, the European Commission's large-scale system did not use machine learning, according to an assessment published in 2021.

## How good yield forecasts are

The European Commission's MARS Crop Yield Forecasting System (MCYFS) published **19,980** forecasts for EU countries between 1993 and 2015. van der Velde and Nisini (2019) compared the forecasts for soft and durum wheat, grain maize, rapeseed, sunflower, potato and sugar beet with reported yields. The error measure is MAPE: how far, on average and in percent, a forecast deviates from the reported yield.

| Measure (2006-2015) | Result |
|---|---|
| Lowest median error | **3.73%** — France |
| Highest median error | **14.37%** — Portugal |
| Within the season | Both the error and its variability shrink as harvest approaches |
| Year to year | No significant improvement for any crop |

The in-season improvement is clear for cereals and weaker for oilseeds. Forecasts generally fell below reported yields; for soft wheat, rapeseed and sugar beet the underestimation is systematic across all member states. Over the long run, forecasts for rapeseed, potato and sugar beet improved for the first **12** member states between 1993 and 2015; but between 2006 and 2015 no crop showed a significant improvement across the **27** member states. The authors observe increasing volatility in yield statistics and say renewed effort is needed to improve operational yield forecasting.

## Where AI stands

Paudel and colleagues (2021) built a machine learning model from the crop-model outputs, weather, satellite and soil data in the same system's database. They forecast yields at regional level for five crops in the Netherlands, Germany and France, aggregated the results to national level and compared them with the system's past forecasts. Two examples from early-season forecasts, **30** days after planting (normalised error, NRMSE; lower is better):

| Crop and country | Machine learning | MARS system |
|---|---|---|
| Soft wheat, Netherlands | **7.87** | **6.32** |
| Sugar beet, Germany | **8.21** | **8.79** |

Early in the season the two were comparable for all crops in the Netherlands, for all but soft wheat in Germany, and for soft wheat, spring barley and sunflower in France. For soft wheat in Germany and for sugar beet and potatoes in France, however, the machine learning error was twice the system's. At the end of the season they were still comparable in the Netherlands, but machine learning was worse in Germany and France. The authors present the work as a baseline, to be improved with new data sources, better features and other algorithms. In this comparison, machine learning did not overtake the established system in large-scale yield forecasting.

For identifying crops, satellites are now a legal requirement. Regulation (EU) 2021/2116, which governs the financing and monitoring of the EU's common agricultural policy, requires member states to set up an area monitoring system: regular and systematic observation, tracking and assessment of agricultural activity with Copernicus Sentinel satellite data or other data of at least equivalent value. The system had to be operational from 1 January 2023 and fully operational in all member states by 1 January 2024; countries assess its quality every year against a methodology set at Union level. The regulation requires satellites, not a method: it does not mention machine learning or artificial intelligence.

## Türkiye

In Türkiye, official crop production estimates appear in the statistical bulletin of the ministry's General Directorate of Agrarian Reform: first and second estimates in May and October, final results in December. The ministry's metadata describes the method: data are collected by provincial and district directorates and entered into a web-based statistical system; they consist of the source information held by district directorates, administrative records such as the farmer registry (ÇKS), and agricultural technicians' impressions of their own areas. The method described uses neither satellites nor models.

Model-based yield forecasting is not new in Türkiye. In the 2005-2006 season, an FAO-supported project began issuing agro-meteorological yield forecast bulletins for winter wheat. The FAO simulation method calculated whether the crop's water needs were met through the growing season, related the result to the long-term yield statistics of the State Institute of Statistics, and was rerun every **10** days. The bulletins continued: the May 2020 bulletin of the Central Research Institute for Field Crops gave wheat yield forecasts province by province and put the national average at **232.5** kg per decare, **7.9%** below the long-term average. The bulletin fed the ministry's Monitoring, Early Warning and Forecasting Committee.

All these bulletins are now listed on the AGROSENS page of the Soil, Fertilizer and Water Resources Central Research Institute, and their titles tell the story: until 2020 most of them mention yield forecasting; from 2022, meteorology and crop monitoring; in the latest issues, remote-sensing-supported agricultural monitoring. The April 2026 issue (number **58**) follows crop development from space with NDVI, agricultural stress and photosynthetic activity indicators, alongside rainfall and temperature analyses; for yield it gives a qualitative outlook based on regional observation, not a figure per decare. The May 2024, May 2025 and November 2025 issues give no yield estimate per decare either. The bulletin is also frank about its limits: early-spring values do not decide year-end performance; the decisive period is May to July.

In official use, AI entered Türkiye through crop identification. In the 2025 production year the ministry put its Remote Sensing Crop Identification Work into practice for the first time: reference parcels collected in the field are assessed together with satellite imagery, and machine learning is used to detect and classify the crops sown and to determine production patterns. According to a July 2026 announcement by the General Directorate of Agrarian Reform, **12** regional meetings were held on the system; checks on the accuracy of farmer registry declarations are planned within the same work. The ministry says areas are analysed with high accuracy rates, but has not published an accuracy rate. One point stressed at the meetings is instructive: for winter crops, collecting reference parcels quickly, accurately and densely enough before harvest directly determines the system's success.

The closest indications of how well such a system can work come from research. In Mardin, a random forest algorithm separated maize, wheat, cotton, chickpeas and lentils parcel by parcel using Sentinel-2 images from six dates in 2018; accuracy was measured against farmer registry records, and overall accuracy came out at **96.35%** (Altun and Türker, 2021) — one region, one year. A study by a specialist at the General Directorate of Agrarian Reform ran the **13.5** million physical blocks of the Land Parcel Identification System through the LightGBM algorithm with **370** Sentinel-2 frames, producing a national land cover and land use map for 2021 with an overall accuracy of **86.07%** (Şimşek, 2023). In Yozgat, a system aiming to check wheat and barley declarations fully automatically with satellite data and land registry parcel boundaries was tested against validation data collected in the field; where two different crops were sown in one parcel, the method gave wrong results (Yaşar and Yağcı, 2024).

The 2027 Programme plans regulations for compiling and checking agricultural statistics; a Farm Holding Registry System that records every holding using data from the 2025 General Agricultural Census and updates the records in real time with spatial data; and registry and information systems designed to serve early warning, market controls, production planning and stock management. Satellite monitoring of drought (TAKİS) and its forecasting with AI are covered in §7.

Official harvest estimates and AI-based crop identification sit in the same general directorate, but whether the second feeds into the first has not been disclosed. That is also what is missing: **a published assessment comparing an AI-based harvest forecast in Türkiye with official estimates or with actual production.**

## How this page is kept up to date

This page watches two things: new developments in yield forecasting, crop monitoring and crop classification — peer-reviewed studies and the ministry's crop identification system included; and new releases of the sources behind the figures here: new crop production estimate bulletins and new AGROSENS issues. New information is added to the page after an editor's approval.
