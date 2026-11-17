# Remote sensing

Remote sensing is where AI in agriculture works at the widest scale: the tree height of the whole planet can be mapped with a single model, and fishing vessels hidden from public tracking can be found from space; free satellite imagery opened the way. Its limits are clear: optical satellites cannot see beneath cloud, and high accuracy in recognising crops does not carry over easily to yield forecasts or field decisions. In Türkiye the ministry identifies crops and idle land from satellite imagery with machine learning, but has not published how accurate this is.

## What the open archive changed

After the US made Landsat imagery free in 2008, data use rose **20**-fold according to NASA. The USGS put the imagery's benefits to users at an estimated **3.45** billion dollars in 2017, much of it owed to the open data policy; with fees, more than **50%** of users are expected to decline to pay. A 2013 regulation made access to Sentinel data free, full and open in the EU, and satellite data are now a legal requirement in Europe: Regulation (EU) 2021/2116 requires member states to monitor farming with Copernicus Sentinel data or data of at least equivalent value, without prescribing the method of analysis.

## Strong at mapping, cautious in decisions

The most solid results come from finding what is where. A deep learning model fusing the spaceborne GEDI laser's measurements with Sentinel-2 images produced a global canopy height map at **10**-metre resolution for 2020. Satellite imagery, vessel GPS data and deep learning revealed that **72-76%** of industrial fishing vessels are not publicly tracked. In Mardin, crops were separated parcel by parcel from Sentinel-2 images with **96.35%** overall accuracy, though in one region and one year.

When the question becomes yield or rate, the picture changes. Models trained on satellite, soil and terrain variables from **20** on-farm trials predicted yield with an average error of **13.7%**, yet two models of similar accuracy produced very different nitrogen rates (de Lara and colleagues, 2023). A promising measurement on the decision side comes from a single field: in Morocco, irrigation scheduled with Sentinel-2-like images produced almost the same wheat yield with **14%** less water.

## The limits of cloud and ground truth

An optical sensor collects reflected sunlight and cannot see beneath cloud. According to Whitcraft and colleagues (2015), cloud covers the start and middle of the growing season, which matter for identifying crops and forecasting yields, both frequently and extensively: in many important farming areas, fewer than half of **8**-day composite images are even **70%** clear. The authors recommend considering alternatives such as radar; TARSİM, too, has examined flood areas with Sentinel-1 radar images in its research.

Ground data matter as well: collecting enough reference parcels for winter crops before harvest directly affects the success of the ministry's crop identification, and in Yozgat an automatic satellite check of declarations gave wrong results where two crops were sown in one parcel.

## The ministry's satellite work and İMECE

In the 2025 production year the ministry applied crop identification with satellite imagery and machine learning for the first time; it writes that it also detects idle farmland and orchards with deep learning. The accuracy rate of neither has been published. The Agricultural Drought Monitoring System (TAKİS) tracks drought with satellite data at **7**-day intervals; work on forecasting drought **1-4** weeks ahead with AI is planned to begin in 2027. TÜBİTAK UZAY says variable-rate fertilisation with drone and satellite imagery in Southeastern Anatolia cut fertiliser use in test fields by up to **25%**; this is the institute's own claim, with no published method or sample.

İMECE, the domestic Earth observation satellite launched on 15 April 2023, lists agriculture among its uses, but no official channel bringing its images to agricultural institutions or farmers has been announced. According to a report by FAO and the EBRD based on a 2020 ministry survey, fewer than **3%** of farmers use smart farming technologies such as remote sensing, sensors or precision farming. Nor has any published assessment shown how AI working on satellite data has affected production, input use or farm income in Türkiye.
