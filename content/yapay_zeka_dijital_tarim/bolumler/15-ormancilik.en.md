# 15 · Forestry

> **Summary.** Deforestation is slowing worldwide, but according to FAO it still runs at **10.9** million hectares a year. In forestry, AI stands out in two places: mapping forest structure from space and spotting fire early. A global canopy height map built with deep learning measures the whole planet at **10**-metre resolution; a prototype camera system tested in the United States in 2020 usually caught smoke within **15** minutes of ignition, with on average less than one false alarm per camera per day. In Türkiye the fire burden is growing: of the **634,575** hectares burned in 1988-2025, **43.6%** burned in the last five years. The General Directorate of Forestry's camera-based fire warning system had spread to **77** towers by 2013, and its AI-supported decision support system has been in use since 2022; there is no published assessment independently measuring the effect of either.

## What it does

In forestry, digital technology serves three purposes: measuring how much forest there is and what it is like (area, tree height, carbon), catching change (deforestation, fire, pests and disease), and early warning and response to fire. Satellites and spaceborne laser instruments see large areas; AI extracts tree height, burned area or smoke from these data. Cameras on the ground and unmanned aerial vehicles try to catch the first minutes of a fire.

## What the field says

From FAO's 2025 Global Forest Resources Assessment:

| Indicator | Value |
|---|---|
| World forest area | **4.14** billion hectares (**32%** of land) |
| Deforestation, 1990-2000 | **17.6** million hectares a year |
| Deforestation, 2015-2025 | **10.9** million hectares a year |
| Net forest loss, 2015-2025 | **4.12** million hectares a year |
| Land affected by fire | on average **261** million hectares a year, nearly half of it forest |

FAO says deforestation has slowed in every region, but that the current rate is still too high.

Lang and colleagues (2023) produced a global canopy height map at **10**-metre resolution for 2020 with a probabilistic deep learning model that fuses the sparse height data of the spaceborne GEDI laser instrument with Sentinel-2 satellite images; the model also reports the uncertainty of each estimate. According to the map, only **5%** of the global land surface is covered by trees taller than **30** metres, and only **34%** of these tall forests lie within protected areas.

Govil and colleagues (2020) developed a prototype smoke detection system in Southern California that scans hundreds of cameras every minute and recognises images with machine learning. The system usually caught smoke within **15** minutes of ignition, with on average less than one false alarm per camera per day, and it spotted some fires before they were reported or detected by satellite. The authors also write that ground cameras cannot see every fire, which is why they are building a system that combines camera and satellite detection.

## Where AI stands

AI changes the scale of forestry: a single model can extract the tree height of the whole planet, and one piece of software can watch hundreds of cameras at once. But measured success in fire detection depends on where and by what criterion a system is tested; a camera can only catch a fire whose smoke it can see.

## Türkiye

According to the ministry's data, Türkiye's forest area was **23,375,331** hectares in 2025. According to the 2027 Programme, **3,224** fires burned **81,473** hectares in 2025, and **2,009** fires burned **24,451** hectares of forest in the first nine months of 2026. Of the **634,575** hectares burned from 1988, when official statistics began, to 2025, **43.6%** burned in the last five years. The cause of **41.1%** of fires in the last ten years could not be determined. In 2026 fires were fought from the air with **119** helicopters, **28** aircraft and **14** unmanned aerial vehicles; about **28** thousand staff and more than **142** thousand volunteers take part.

Türkiye has a long record in early detection. According to a 2013 TÜBİTAK announcement, the Forest Fire Warning System developed by the General Directorate of Forestry and Bilkent University with TÜBİTAK support processes images from cameras installed on fire lookout towers with software; at the time, **3.2** million hectares were watched by **154** cameras on **77** towers, and the announcement says a small fire is detected in **15-25** seconds. This is the institution's own claim; there is no published assessment independently measuring the system's accuracy and false alarm rate.

According to a 2024 ministry news item, the General Directorate of Forestry has since 2022 used a domestically developed Decision Support System: it combines meteorological data, forest information system (ORBİS) data, UAV and satellite images; it estimates the likelihood and cause of fires and, with AI support, predicts a fire's behaviour and spread. The system was nominated for the World Summit on the Information Society Prizes of the International Telecommunication Union, a UN agency.

There is academic work as well. A study from Karabük University tested fire detection with deep learning embedded on a four-rotor UAV designed by the authors, reporting **96%** accuracy in classification (Shamta and Demir, 2024). A study involving Hacettepe University mapped burned area in a Turkish red pine forest in a Mediterranean ecosystem using radar, optical and thermal satellite data and the random forest method, with **96%** overall accuracy (Abdikan and colleagues, 2022).

What is missing is **a published independent assessment measuring, in Türkiye, the effect of camera-based early warning or the AI-supported decision support system on detection time, burned area or false alarm rate.**

## How this page is kept up to date

This page watches three things: new developments in forest fire, forest inventory, tree species and deforestation — peer-reviewed studies included; the General Directorate of Forestry's announcements on forestry and forest fires; and new releases of the sources behind the figures here, such as the ministry's forestry statistics and FAO's forest resources assessment. New information is added to the page after an editor's approval.
