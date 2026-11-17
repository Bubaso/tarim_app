# 6 · Sowing and variable-rate application

Variable-rate application means giving seed, fertiliser or chemicals not at the same rate everywhere in a field, but according to what each part needs. The evidence from the field shows consistent savings but not consistent profit, and the technology has reached only a small share of farms. AI is a candidate for writing the rate prescription, but predicting yield well is not the same as finding the right rate. In Türkiye, one study found that the ministry's phosphorus recommendation method gives exactly the same rate to five parts of the same land.

## What it does

In conventional application, a machine crosses a field from end to end on one setting: the same seeding rate, the same fertiliser rate. Yet one part of a field may be fertile and another stony or dry. Variable-rate technology carries this difference into the machine: the amount of seed, fertiliser and chemicals changes as the machine moves across the field.

The rate is set in one of two ways. In the first, a prescription map is prepared in advance: soil maps, past yields and satellite images divide the field into zones. In the second, a sensor on the machine measures the reflectance of the crop canopy and adjusts the nitrogen rate on the spot.

AI's place in this chain is the decision link: working out how much nitrogen or seed each point should receive by learning from the data of on-farm trials in which different rates are tested within a field.

## What the field says

| Study | Comparison | Result |
|---|---|---|
| Aula and colleagues (2020): review of **26** peer-reviewed studies, winter wheat | Sensor-based nitrogen management versus the conventional method | Nitrogen use efficiency about **10.4%** higher; similar yield; nitrogen savings of up to **53** kg per hectare |
| Kortbein and colleagues (2026): Nebraska, **9** non-irrigated maize fields, 2019-2020 | Sensor-based nitrogen versus the grower's own practice | Nitrogen down by an average of **38.7** kg per hectare; no yield penalty in **77%** of fields; profit advantage in **35%** |
| Dalla Betta and colleagues (2026): Nebraska, seeding trials in **11** soybean fields | Most profitable seeding rate | Between **175,000** and **350,000** seeds per hectare from field to field; in **9** of **11** fields seed could have been cut without losing yield or profit |

The savings are real: sensor-based nitrogen cuts fertiliser without lowering yield, and the soybean trials show a similar margin for seed. On profit, however, the result changes: in Nebraska the sensor-based approach was more profitable in only **35%** of the fields. The review's authors say this gain alone may not be enough to drive adoption; the authors of the maize trial note that the spread of sensors has been held back by inconsistent results, potential yield losses and a lack of field-scale trials.

[[grafik:b06-sensorlu-azot-tarlalar]]

## How widespread it is

According to the farm survey of the US Department of Agriculture's Economic Research Service, variable-rate technology stayed below **10%** of planted area for several field crops in the late 1990s and early 2000s. Then it picked up: in maize its share of planted area rose from **11.5%** in 2005 to **37.4%** in 2016, in cotton from **5.4%** in 2007 to **22.7%** in 2019. Winter wheat stood at **18.8%** in 2017 and soybeans at **25.3%** in 2018. Large farms adopt more; according to the Service, this is in part because they can spread the fixed costs over more production.

[[grafik:b06-vrt-ekili-alan]]

Lowenberg-DeBoer and Erickson (2019) reviewed the public data worldwide and drew a sharp distinction: satellite guidance and the automation that comes with it (such as sprayer boom control and row or section shutoff on planters) spread as fast as any major agricultural technology in history, whereas variable-rate technology, as of 2019, rarely exceeded **20%** of farms. In the authors' reading, farmers like the idea but are not convinced of its value. The biggest gap in precision agriculture is small and medium farms in the developing world that do not use motorised mechanisation.

## Where AI stands

The hard part of variable-rate application is not the machine but the prescription: how much, at which point in the field? De Lara and colleagues (2023) fed the data of **20** on-farm trials in wheat and barley, with soil, terrain and satellite variables, to two machine learning methods: a generalised additive model and a random forest. The models predicted yield with an average error of **13.7%**. Yet two models predicting with similar accuracy produced very different economically optimal nitrogen rates. The size and direction of the influential variables changed from field to field; the authors warn that a model trained on data from other fields may recommend unreliable rates in a new field.

## Türkiye

The 2027 Programme counts the efficient use of fertiliser, seed and other inputs through precision agriculture and digital technologies among the priorities of crop production. The programme also records that global fertiliser supply was disrupted in 2026, with urea prices rising in particular. It names the obstacle too: the small-scale, fragmented and scattered land structure of holdings makes effective use of mechanisation and modern production techniques harder.

The programme sets out two concrete measures for 2027: shared machinery parks will be supported in **14** agricultural producer organisations, and domestic production of smart farming software and equipment will be supported. A rural development decision of December 2025 and a communiqué of April 2026 also aim to spread digitalisation, AI, smart farming, robotics and automation technologies; grants cover **50-70%** of the project amount, depending on the type of investment.

Published data on adoption in Türkiye, however, are old. In a survey published in 2016 with **164** agricultural engineers, dealers and farmers in Çukurova, **51.8%** of participants had never heard the term precision agriculture; of those who had, only **29.3%** knew the concept. Satellite positioning was known to **81.7%** of participants; variable-rate application was the least known technology (**33.5%**). At the same time, **97.6%** thought these technologies would be of some benefit to Turkish agriculture, and **88.4%** wanted more detailed training (Keskin and Sekerli, 2016).

[[grafik:b06-cukurova-farkindalik]]

There is a field measurement too. On **300** hectares of sloping land **20** km from the centre of Çankırı, under rainfed wheat for more than **70** years, **155** soil samples were taken (Wardamı, Erşahin and Karahan, 2024). Plant-available phosphorus varied moderately across the land (coefficient of variation **21.3%**), and the land could be divided into three fertilisation zones: low, medium and high. Yet the phosphorus rates calculated with the ministry's recommendation method for five equal-sized sub-regions came out exactly the same: in the authors' reading, the method is insensitive to the phosphorus differences in these soils. The authors themselves note that a more comprehensive study is needed to measure the efficiency and cost-benefit of variable phosphorus application. No published trial has yet measured, in a field in Türkiye, the effect of variable-rate fertiliser or seed application on yield and profit.

There is work on the machinery side as well: a team from Tekirdağ Namık Kemal University developed a multi-fertiliser spreader and a variable-rate controller for olive orchards (Akdemir and colleagues, 2022).
