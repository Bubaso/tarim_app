# 16 · Markets, prices and supply chain

In forecasting farm prices, deep learning models can get ahead of classical methods, but they are not error-free: in India, even a deep learning model that beat the classical model by a wide margin had a mean percentage error of **10.58%** for tomatoes and **14.59%** for onions. In traceability, blockchain is much discussed in academia. In Türkiye, by contrast, digital traceability for fruit and vegetables is already a regulatory obligation; but the Wholesale Market Registration System that provides it is neither AI nor blockchain: it is a central register.

## What it does

In markets and the supply chain, digital technology serves three purposes: forecasting prices, planning demand and stocks, and tracing a product's path from field to shelf. In the first two, AI extracts patterns from past price and sales series and from outside factors such as weather and stocks; it offers a forecast when a producer decides what to plant, a trader when to sell, or the state when to intervene. In the third, the real work is record keeping: writing down where the goods were produced and who passed them to whom. Blockchain is proposed to make that record unalterable.

## What the field says

A systematic review of forecasting wheat, maize and rice prices with machine learning, deep learning and time-series methods (Theofilou and colleagues, 2025) writes that hybrid deep learning models consistently outperform traditional methods; but it names the interpretability of the models and their reliance on region-specific datasets as important limitations.

In a comparison using daily wholesale prices of **23** products in India from January 2010 to June 2024 (Manogna and colleagues, 2025), the GRU deep learning model did markedly better than the classical ARIMA model: its error measure (RMSE) was **370** against **1,565** for onions and **210** against **1,299** for tomatoes. The authors recommend adding outside factors such as weather data to make forecasts more reliable.

The advantage does not show up everywhere. For the sale prices of an Italian food wholesaler (Menculini and colleagues, 2021), classical ARIMA and LSTM networks performed similarly; the best accuracy came from a model combining two deep learning methods, but it took longer to tune.

On traceability, a review of blockchain in agriculture (Sendros and colleagues, 2022) examined **104** research papers in April 2021: the field is still at an early stage and most studies are at the design stage, while a significant share has moved into implementation or pilots. The use is mostly about the integrity of production records and tracing production steps and products. A recent study comparing European and international pilot implementations (Karkanias and colleagues, 2026) shows that blockchain can strengthen product-level traceability and the verification of sustainability and food safety claims; but also that heterogeneous technical standards, limited interoperability, high deployment costs for smallholders and governance risks in consortium-led platforms persist.

## Where AI stands

In price forecasting, AI brings a measurable improvement, but the size of the gain depends on the product, the market and the data: the large gap in India does not appear at the Italian wholesaler. Because even models that do well make mistakes, a forecast gives a decision-maker a direction, not certainty. In traceability, the obstacle is not the technology itself: it is standards, interoperability and the cost that falls on smallholders.

## Türkiye

Under the Regulation on Fruit and Vegetable Trade and Wholesale Markets (2012; last amended 2023), the Wholesale Market Registration System (HKS) is a central, internet-based registration system set up within the ministry responsible for trade. Goods at or above the notification threshold (**100** kilograms when sold by weight, **150** pieces when sold by the piece, **50** bunches when sold by the bunch) are notified to the system before they are shipped from where they were produced or from the customs gate they entered through. For each notification the system generates a uniquely numbered tag (künye) giving the goods' place of production, type, quantity, the producer they belong to and any certificate information; in wholesale and retail sale the tag must be displayed on the goods where anyone can see it.

The register's data are also used in research. A peer-reviewed machine learning trial from Türkiye (Özden, 2023) compiled by hand, from the Ministry of Trade's official wholesale market website, the trade volumes and prices of potatoes, onions and garlic for **1,791** days from the start of 2018 to November 2022, and tested **10**-day price forecasts. But there is no published assessment showing what AI actually adds to price forecasting, demand planning or traceability in Türkiye.

The 2027 Programme foresees strengthening registration systems, spreading licensed warehousing and developing logistics infrastructure in the fresh fruit and vegetable supply chain, so that farm prices form soundly and the food supply chain works efficiently; registration and information systems are to be designed to serve early warning, market control, production planning and stock management. The number of licensed warehouses, **265** in 2025, is expected to reach **288** in 2026; the 2027 target is **295**. An impact analysis of licensed warehousing support is among the things still to be done. The Programme does not address farm price forecasting; it foresees blockchain only for customs and foreign trade procedures.

The commodity reports of the Institute of Agricultural Economics and Policy Development (TEPGE), which is under the ministry, examine the current year's developments as "Tahmin" (estimate) and the next year's as "Öngörü" (outlook). The 2025 report for wheat does not explain how its forecasts are made. The report's outlook section on Türkiye opens with the forecasts of the US Department of Agriculture (USDA).
