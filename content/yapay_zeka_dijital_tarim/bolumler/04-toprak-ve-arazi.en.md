# 4 · Soil and land

> **Summary.** Soil cannot be measured everywhere: it is sampled at a few points and a model fills the gaps between them. In digital soil mapping, that model relates the measurements to satellite, terrain and climate data; AI sits inside the model. At global scale the example is SoilGrids: using machine learning, from measurements at about **240,000** locations it maps the whole world in **250**-metre cells, and for each cell it also says how unsure it is. It captures broad patterns well and can be wrong at field scale. In Türkiye, the 2027 programme plans to continue detailed soil surveys on **3.5** million hectares of farmland in **15** provinces; in December 2025 the ministry opened a tender, financed by a World Bank loan, for detailed digital soil maps.

## What it does

In a conventional soil survey, a surveyor goes into the field, digs profiles, takes samples and draws the boundaries between soil types on the map by expert judgement. Digital soil mapping starts from the same measurements but leaves the drawing to a model. The model relates a soil property measured at sampled points — organic carbon, pH, clay content — to environmental data at those points, such as vegetation, slope, climate and geology, and then produces a prediction for every cell without a measurement.

AI sits in the model. The method SoilGrids uses is quantile regression forests: because it keeps the predictions of many decision trees together, it yields a distribution rather than a single value. For each cell, alongside the prediction, it computes an interval within which the true value is expected to fall with **90%** probability. That matters to anyone using the map: it shows where the map is confident and where it is not. The authors present this to users as both a measure and a warning.

## How good the global map is

The paper describing version 2.0 of SoilGrids (Poggio and colleagues, 2021) reports how the map was made and how well it holds up:

| Measure | SoilGrids 2.0 |
|---|---|
| Cell size | **250** m — one cell is **6.25** hectares |
| Measurement locations | about **240,000** |
| Environmental data layers | more than **400** |
| Depth | **6** standard intervals, down to **200** cm |
| Accuracy score | **0.31** to **0.74**, depending on the property |

The accuracy score (MEC) shows how much of the variation in measured values the model explains; **1** means a perfect prediction. The weakest prediction is for the share of coarse fragments (stones and gravel) in the soil. Accuracy falls with depth.

The authors' own assessment cuts both ways. Broad patterns are well reproduced, but the uncertainty map shows that more soil measurements are needed, especially at high latitudes. Europe and North America have more than four soil profiles per **10** km²; in large Asian countries such as Kazakhstan, India and Mongolia, the number of profiles is still quite limited.

At field scale the map can be wrong. In the United States, a preliminary comparison with a national soil database built on detailed field surveys showed that SoilGrids can miss local transitions in parent material; the local particle-size pattern was off at times by around **20-30%** of a particle-size class. The authors describe global and wide-area regional applications as the real test of the product.

One cell is a square of **6.25** hectares. The 2027 Programme describes the land structure of farms in Türkiye as small-scale, fragmented and scattered; on such land a single cell of the global map can cover more than one field. The global map is a strong starting point for understanding a region's soils; it should not be expected to replace local measurement for a decision at field scale — variable-rate fertilisation (§6), for example. The predictions are openly available under a CC BY 4.0 licence.

## Türkiye

National-scale soil data are not new in Türkiye. According to a 2017 announcement by TAGEM, the Soil, Fertilizer and Water Resources Central Research Institute produced maps of pH, salinity, lime, available phosphorus and potassium, cation exchange capacity and texture for the country's farmland, together with maps of organic carbon distribution and the carbon budget, in an FAO-supported project run in 2012-2015. The maps were made available, through standard map services, on the National Soil Information System portal.

The 2027 Annual Programme treats soil data as the basis for land-use decisions and sets a timetable for detailed soil surveys. In 2024, detailed soil surveys and mapping were completed on **755** thousand hectares; another **2.4** million hectares are expected to be finished by the end of 2026. Of the **6.8** million-hectare project area where work continues, **3.5** million hectares are expected to be completed in 2027 and the remaining **3.3** million in 2028. As a 2027 measure, survey and mapping work will continue on **3.5** million hectares of farmland in **15** provinces. For scale: Türkiye had **24** million hectares of agricultural land as of 2025.

The programme also plans an annual national land-cover map, and work on the data infrastructure and methodology for analysing water erosion and sediment yield based on climate projections.

In December 2025 the ministry invited bids for soil survey and classification, soil analyses and the preparation of detailed digital soil maps under the Türkiye Climate Smart and Competitive Agricultural Growth Project, financed by a World Bank loan. The tender covers **5.16** million hectares of farmland in **13** provinces (the full project boundary is **12.3** million hectares); the work is divided into **10** lots and runs for **600** days. How the maps will be produced, and whether machine learning will be used, has not been announced.

Researchers in Türkiye work with these methods too: a 2022 study by Kaya and colleagues predicted and mapped soil texture classes in northwestern Türkiye with different machine learning algorithms.

What is missing is **a published assessment measuring how a soil map produced with AI changes decisions in a field in Türkiye.**

## How this page is kept up to date

This page watches three things: new peer-reviewed studies on digital soil mapping, soil organic carbon and land suitability; the General Directorate of Agrarian Reform's announcements on detailed soil surveys and land-use planning; and new releases of the sources behind the figures here — a new annual programme, a new version of SoilGrids. New information is added to the page after an editor's approval.
