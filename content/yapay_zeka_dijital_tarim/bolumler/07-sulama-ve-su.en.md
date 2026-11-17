# 7 · Irrigation and water

> **Summary.** Agriculture uses **72%** of the freshwater withdrawn worldwide; in Türkiye, by FAO's data, the share is **86.93%**. The strongest evidence for digital technology in irrigation comes not from AI but from the soil moisture sensor: a review of two decades of studies in the United States finds that sensor-based scheduling saves on average **38%** of water against traditional methods without lowering yields. Against a good method, though, the gain falls to **1%**, and calibration decides the result above all else. AI making irrigation decisions is still tested mostly in simulation. Türkiye's 2027 programme plans to complete DİSU, a digital irrigation management system, and to bring decision-support systems to irrigation facilities.

## What it does

Digital technology works in irrigation on three layers. In the soil, moisture sensors measure the water in the root zone and tie the timing of irrigation to the soil itself rather than to a calendar. From above, satellite data estimate how much water the crop consumes, at field scale. On top of both, a model or a decision-support system recommends when and how much to irrigate; automation carries that decision to the valve.

AI comes in at the top layer. The two layers beneath it — measuring — work without AI, and most of the field evidence comes from there.

## What the field says

Datta and Taghvaeian (2023) systematically reviewed the soil moisture sensor studies published in the United States over the past two decades. The result has two parts:

| Sensor-based scheduling compared with | Average water saving | Standing |
|---|---|---|
| Scheduling based on canopy temperature | **1%** | Peer-reviewed review |
| Traditional approaches | **38%** | Peer-reviewed review |

Yields were the same as or higher than with the methods compared. The review's most important finding lies elsewhere, though: what most affects a sensor's accuracy is calibration. A sensor installed with factory settings will time irrigation wrongly for as long as it misreads the soil.

The gap between the two figures repeats the lesson of §8: the size of the saving depends less on the technology than on what it is compared with. For a farmer irrigating by the calendar, a sensor makes a large difference; for one who already irrigates by measuring the crop, almost none.

## Where AI stands

Saikai, Peake and Chenu (2023) developed an irrigation rule for irrigated wheat using deep reinforcement learning. Each day the rule looks at soil water, the crop's growth stage and rainfall, and decides how much to irrigate. It was trained on weather data for 1981-2010 and tested separately for each year of 2011-2020: it raised profit over the rule common in the region in every test year, with the largest improvement, **17%**, in 2018.

That result comes not from a field trial but from a crop growth model: the production system was simulated for the Goondiwindi region of Australia with the APSIM-Wheat model. The authors themselves note that research on the technique remains sparse and impractical. This is where AI in irrigation stands today: promising in simulation, still little tested in the field.

## Türkiye

By FAO's data, **86.93%** of the freshwater withdrawn in Türkiye in 2022 went to agriculture; industry's share was **2.01%** and municipalities' **11.06%**. Total withdrawal was **64.47** billion m³.

According to the 2027 Annual Programme, the irrigation rate was **68%** in 2025, an estimated **71%** in 2026, with a target of **72%** for 2027. The gross area opened to irrigation was **7.28** million hectares in 2025, with **7.40** million targeted for 2027. The measures written for 2027: **61** thousand hectares of new irrigation; converting open canals to closed pipes on **16** thousand hectares; grants for sprinkler and drip irrigation on **30** thousand hectares; electronic metering at **100** facilities so that water can be priced by the amount used. In **52** districts of **11** provinces with water constraints, crops that use little water receive extra support.

On the digital side there are two measures. The Digital Irrigation Management System project (DİSU), which will prepare irrigation schedules with remote sensing and geographic information systems, is to be completed in 2027; work will continue on the use of decision-support systems by water user organisations and on the regulations for it. The Agricultural Drought Monitoring System (TAKİS) tracks drought with satellite data at **7**-day intervals; work on forecasting drought **1-4 weeks** ahead with AI methods is planned to begin in 2027.

There are two field studies. A study involving the Potato Research Institute in Niğde (Akın and Ünlenen, 2017) compared different moisture sensors for precise drip irrigation scheduling in a silty loam soil; what it measured was not water saved but which sensor reads reliably. In a joint project of Ege University and Wageningen, a low-cost wireless sensor was tried with **9** growers in the village of Orhanlı. The project leaflet reports water savings of **13-24%** on sensor-managed plots and **12%** in organic production. The company that developed the sensor is among the leaflet's authors; the figures are a project statement.

What is missing is **a published trial measuring, in a field in Türkiye, irrigation decisions made by AI.**

## How this page is kept up to date

This page watches three things: new peer-reviewed studies on sensor-based and AI-based irrigation, official developments on DİSU and decision-support systems, and new releases of FAO's water data. New information is added to the page after an editor's approval.
