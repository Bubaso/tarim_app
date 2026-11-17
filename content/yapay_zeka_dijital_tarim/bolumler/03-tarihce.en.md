# 3 · A short history

In 1977 an estimate made with satellite data put the Soviet wheat harvest within about **1%** of the official figure. That estimate came from the first of three older strands that meet today in agricultural AI: monitoring crops from satellites, under way since 1972. The other two are letting computers make decisions, with the expert systems of the 1980s, and knowing position in the field, with GPS and precision farming in the 1990s. Then came three developments: Landsat and Sentinel data became free, deep learning made a leap in image recognition, and AI chatbots began answering farmers' questions. In Türkiye the story rests on a register: the farmer registry that the World Bank calls Türkiye's basic rural database.

[[grafik:b03-donum-noktalari]]

## Monitoring crops from satellites (1972-1978)

Landsat 1 was launched on 23 July 1972. According to NASA, the US, unaware of a worldwide shortage, sold **15** million tons of wheat to the Soviet Union at a large discount; after this sale, known as the Great Grain Robbery, the government recognised the need for an accurate, up-to-date system to track crops globally and turned to the newly launched Landsat 1.

LACIE, a joint experiment of NASA, the US Department of Agriculture and the National Oceanic and Atmospheric Administration (NOAA), began in 1974 and was completed on 30 June 1978. The goal was for production estimates at harvest to fall within ±**10** percent of true country production **90%** of the time; LACIE met this goal in the US Great Plains and in the Soviet Union for two consecutive years. In August 1977 it gave an early indication of the shortfall in Soviet spring wheat; its final estimate was **91.4** million tons, against the Soviets' official figure of **92.0** million tons. Application in Canada was less successful. According to NASA, LACIE marked a shift from interpreting satellite images by eye to digital image processing; by 1978 a US Department of Agriculture system based on the technology had begun operation.

## Letting computers decide: expert systems (1980-1988)

In 1980 Michalski and Chilausky compared two ways of acquiring knowledge for an expert system that diagnoses soybean diseases: encoding an expert's rules, and having the computer induce rules from examples. According to a 1983 paper by Michalski and Baskin, the feasibility of the program that induces rules from examples for an expert system was proven in this soybean disease system. The study's dataset entered the UCI Machine Learning Repository in 1988, which calls it Michalski's famous soybean disease database.

In the same years the US Department of Agriculture's research service developed COMAX for cotton. As Lemmon described it in Science in 1986, the system's knowledge base had three parts: a cotton plant simulation model (GOSSYM, developed over twelve years), if-then rules and an inference engine. Sensors in the field reported weather conditions to the system automatically, and COMAX re-evaluated its recommendations every day; the system advised growers on nitrogen, irrigation and growth regulators. In 1988 close to **150** farmers from California to North Carolina used the model; the US Department of Agriculture had chosen GOSSYM-COMAX as the initial crop simulation model to implement on the farm.

## Position in the field: GPS and precision farming (1983-2000)

Precision farming rests on position from satellites. On 16 September 1983, in a statement on the Soviet attack on a Korean civilian airliner, the US announced that it was prepared to make the Global Positioning System (GPS) available to civilian aircraft when it became operational in 1988. GPS was declared operational in 1995. On 1 May 2000 President Clinton announced that the intentional degradation of public GPS signals would stop from midnight that night; civilian users would be able to pinpoint locations up to ten times more accurately than before.

The first international conference dedicated to precision agriculture met in July 1992 in St. Paul, Minnesota, chaired by Pierre Robert. According to Lowenberg-DeBoer and Erickson, the first commercially successful grain yield monitors were also introduced in 1992; guidance with satellite positioning was commercialised in the late 1990s, first in Australia and shortly after in North America. The US Department of Agriculture's Economic Research Service (ERS) dates the commercialisation of the yield monitor to 1993 and that of variable-rate equipment to 1995.

## Open data and deep learning (2008-2019)

In 2008 the US made the Landsat archive free; according to NASA, data use increased **20**-fold. In a regulation of 12 July 2013, the EU made access to the data of the Sentinel satellites free, full and open; Sentinel-2A was launched on 23 June 2015.

In 2012 a deep convolutional neural network won the ImageNet image recognition competition with a top-five error rate of **15.3%**; the second-best entry's error rate was **26.2%** (Krizhevsky, Sutskever and Hinton). The method soon reached agriculture: in 2016 Mohanty and colleagues published that their model, built on Krizhevsky's work, reached **99.35%** accuracy on test images held out from **54,306** leaf images taken in controlled conditions, and called this a first step towards plant disease diagnosis with a smartphone; on images taken in other conditions, accuracy stayed just above **31%**.

[[grafik:b03-imagenet-2012]]

In September 2017 John Deere announced that it would acquire Blue River Technology, which had developed technology that uses computer vision and machine learning to spray herbicide only where weeds are present. According to the company's 2019 report, this technology, called See & Spray, had not yet been fully commercialised at the time.

## Forecasts and language (2022-2025)

ChatGPT was opened to the public on 30 November 2022. AI chatbots then entered farm advisory work: India's voice-enabled AI chatbot Kisan e-Mitra began answering questions about government schemes in 2023; according to a non-peer-reviewed paper by its developers, Digital Green's FarmerChat, a chatbot powered by generative AI, reached more than **15,000** farmers in four countries. In weather forecasting, GraphCast outperformed the most accurate operational systems on **90%** of **1,380** verification targets in 2023; the European Centre for Medium-Range Weather Forecasts put its own AI model into operation on 25 February 2025.

## Türkiye

According to the World Bank, the National Registry of Farmers was created together with direct income support after a pilot in five villages in the 2000 agricultural year. The registration system was given a legal basis by a Council of Ministers decision published in the Official Gazette on 14 June 2002; the Farmer Registration System Regulation of 16 April 2005 provided for updating the system that had been set up. The ministry's first winter wheat yield forecast bulletin, prepared with FAO and based on a simulation method that uses climate data, covered October 2005 to January 2006; the series continues today as an agricultural monitoring bulletin supported by remote sensing.

Türkiye's first optical remote sensing satellite, BİLSAT, was launched in 2003 through technology transfer. RASAT, the first domestic Earth observation satellite, designed and built by TÜBİTAK UZAY, was launched on 17 August 2011 and provided data for many fields including agriculture for about **11** years; İMECE, with sub-metre resolution, was launched on 15 April 2023.

According to the ministry's page, the Agricultural Monitoring and Information System (TARBİL) started in 2008, under the direction of the State Planning Organisation, as a three-year pilot named the "Tarımsal Rekolte Tahmin ve Kuraklık İzleme" project (TARİT, crop yield forecasting and drought monitoring); the first **25** stations were set up in Şanlıurfa, and by 2012 the number of stations had reached **100**. According to a 2025 report by FAO and the EBRD, however, the project was not completed, and interviews in the field showed that many of the stations set up were not working.

Public programmes for AI in agriculture are recent: the first call of TÜBİTAK's AI ecosystem programme opened in 2022, with smart agriculture, food and livestock among its priority areas; the ministry's research arm TAGEM started three AI projects in 2025.
