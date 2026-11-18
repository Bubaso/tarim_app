# 8 · Computer vision and targeted spraying

The promise of targeted spraying is simple: herbicide goes not on the whole field but only on the weeds. Peer-reviewed field trials show the promise holds: herbicide fell by **35%** in sugarcane and by **47%** with early application in maize, while weed control stayed level with broadcast spraying. Vendors report even larger savings. The real gap lies between the lab and the field: a plant disease model that was nearly flawless under controlled conditions was wrong more often than right on images taken under other conditions.

## What it does

Conventional spraying applies the same dose to the whole field; this is called broadcast spraying. Targeted spraying breaks the field into individual plants. A camera on the sprayer, or one carried by a drone, captures images; a model decides what in the image is crop and what is weed; and the nozzle opens only as it passes over the weed.

[[gorsel:b08-hedefli-ilaclamanin-isleyisi-kamera]]

There are two distinct situations, and no figure can be read without separating them. **Green weeds on bare soil** — in fallow, before sowing — is a comparatively easy problem: anything green on brown ground is a weed. **Green weeds within a green crop** is a hard problem: a green plant must be told from a green plant, leaves overlap, light and shade shift. The highest figures in vendor brochures come mostly from the first situation.

[[gorsel:b08-nadasta-ciplak-toprakta-yesil-ot]]

## What the field trials say

Two peer-reviewed trials, in Australia and Germany, measured two things together: whether herbicide use actually fell and whether weed control suffered.

[[gorsel:b08-autoweed-spot-ilaclama-sistemi]]

| Trial | Crop | Measured | Standing |
|---|---|---|---|
| Australia, 25 hectares (published 2025) | Sugarcane | Herbicide down **35%**; **97%** of broadcast spraying's effectiveness | Peer-reviewed |
| Same trial, low weed-pressure strips | Sugarcane | Herbicide down by up to **65%** | Peer-reviewed |
| Same trial, 3-6 days after spraying | Sugarcane | Herbicide concentration in runoff **39%** lower, total load **54%** lower | Peer-reviewed |
| Germany, on-farm trial (published 2024) | Maize | **94%** of weeds correctly identified; efficacy up to **86%**, equal to broadcast; herbicide down **47%** with early application | Peer-reviewed |

The most important finding of the Australian trial is not the average but how the average arises: herbicide use is proportional to weed density, so the saving grows as weeds become sparser. In a lightly weeded strip two thirds of the herbicide is removed; in a heavily weeded strip targeted spraying approaches broadcast spraying — because herbicide is needed nearly everywhere anyway. The return on targeted spraying depends less on the technology than on the field itself.

[[grafik:b08-hedefli-ilaclama-azalmalar]]

The same trial measured one more thing: herbicide in the water leaving the field in the days after spraying. Agrochemicals reaching streams and groundwater is a problem independent of what the herbicide costs. Targeted spraying makes a measurable difference there too.

[[gorsel:b08-seker-kamisi-hedefli-ilaclama]]

In the German maize trial the camera is not on the sprayer: a drone first maps the field at high resolution, and the sprayer then follows the map. A different method, with results pointing the same way.

[[gorsel:b08-iha-ot-haritasiyla-misirda-spot]]

## What the vendors say

One of the most widespread commercial systems is John Deere's See & Spray. The company's own figures:

[[gorsel:b08-john-deere-see-spray-ultimate]]

| Year | Area | Company statement | Standing |
|---|---|---|---|
| 2024 | More than 1 million acres | Average herbicide saving of **59%** | Vendor statement |
| 2025 | More than 5 million acres | Average reduction of nearly **50%** in non-residual herbicide | Vendor statement |

Placed side by side the two figures suggest a decline, but it cannot be read as a trend: the 2025 figure explicitly refers to non-residual herbicide, and whether the 2024 figure measures the same thing is unclear.

## The gap between lab and field

One of the most cited successes of computer vision in agriculture was published in 2016. Researchers trained a model on **54,306** leaf images covering 14 crops and 26 diseases and reached **99.35%** accuracy on held-out test images.

[[gorsel:b08-plantvillage-veri-setinden-yaprak]]

The less cited part of the same paper is this: when the model was tested on images taken under different conditions, accuracy fell to **31.40%** and **31.69%**. The training images were single leaves photographed under controlled conditions against a plain background; the test images were collected from trusted online sources such as agricultural extension services. The authors write that a real-world application would have to recognise a disease as it presents itself directly on the plant. 31% is far better than random guessing — **2.6%** across 38 classes — but nowhere near 99%. The authors' own conclusion is plain: a more diverse set of training data is needed.

[[grafik:b08-laboratuvar-tarla-dogruluk]]

The distance between those two figures shows the question every success rate in this field should face: measured on which images?

## Türkiye

In Türkiye, weed detection by computer vision is studied mostly at university thesis level. A master's thesis at Pamukkale University detects weeds in maize with a view to local spraying; there is a doctoral thesis at Tokat Gaziosmanpaşa University on weed detection in wheat. A review article on drone-based weed detection has also been published in the Turkish literature. But no published Turkish trial has yet done what the Australian and German trials did: measure in the field the step from a detection model to an actual reduction in herbicide.

The project TAGEM started in 2025, for its part, aims at a prototype precision sprayer: the machine is to locate weeds in maize and cotton with cameras and open its nozzles only over the target.
