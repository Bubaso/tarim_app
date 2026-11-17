# 8 · Computer vision and targeted spraying

> **Summary.** A camera looks at the field, a model tells weeds from crop, and herbicide goes only where the weed is. Peer-reviewed field trials show it works: herbicide falls by **35%** in sugarcane and by **47%** with early application in maize, while weed control stays equal to broadcast spraying. Vendors' figures are larger. The real gap lies elsewhere: a disease model that reaches **99.35%** in the lab falls to **just above 31%** on images taken under other conditions.

## What it does

Conventional spraying applies the same dose to the whole field; this is called broadcast spraying. Targeted spraying breaks the field into individual plants. A camera on the sprayer, or one carried by a drone, captures images; a model decides what in the image is crop and what is weed; and the nozzle opens only as it passes over the weed.

There are two distinct situations, and no figure can be read without separating them. **Green weeds on bare soil** — in fallow, before sowing — is a comparatively easy problem: anything green on brown ground is a weed. **Green weeds within a green crop** is a hard problem: a green plant must be told from a green plant, leaves overlap, light and shade shift. The highest figures in vendor brochures come mostly from the first situation.

## What the field trials say

The peer-reviewed field trials below measured two things together: whether herbicide use actually fell and whether weed control suffered.

| Trial | Crop | Measured | Standing |
|---|---|---|---|
| Australia, 25 hectares (published 2025) | Sugarcane | Herbicide down **35%**; **97%** of broadcast spraying's effectiveness | Peer-reviewed |
| Same trial, low weed-pressure strips | Sugarcane | Herbicide down by up to **65%** | Peer-reviewed |
| Same trial, 3-6 days after spraying | Sugarcane | Herbicide concentration in runoff **39%** lower, total load **54%** lower | Peer-reviewed |
| Germany, on-farm trial (published 2024) | Maize | **94%** of weeds correctly identified; efficacy up to **86%**, equal to broadcast; herbicide down **47%** with early application | Peer-reviewed |

The most important finding of the Australian trial is not the average but how the average arises: herbicide use is proportional to weed density, so the saving grows as weeds become sparser. In a lightly weeded strip two thirds of the herbicide is removed; in a heavily weeded strip targeted spraying approaches broadcast spraying — because herbicide is needed nearly everywhere anyway. The return on targeted spraying depends less on the technology than on the field itself.

The same trial measured one more thing: herbicide in the water leaving the field in the days after spraying. Agrochemicals reaching streams and groundwater is a problem independent of what the herbicide costs. Targeted spraying makes a measurable difference there too.

In the German maize trial the camera is not on the sprayer: a drone first maps the field at high resolution, and the sprayer then follows the map. A different method, with results pointing the same way.

## What the vendors say

One of the most widespread commercial systems is John Deere's See & Spray. The company's own figures:

| Year | Area | Company statement | Standing |
|---|---|---|---|
| 2024 | More than 1 million acres | Average herbicide saving of **59%** | Vendor statement |
| 2025 | More than 5 million acres | Average reduction of nearly **50%** in non-residual herbicide | Vendor statement |

Placed side by side the two figures suggest a decline, but it cannot be read as a trend: the 2025 figure explicitly refers to non-residual herbicide, and whether the 2024 figure measures the same thing is unclear.


## The gap between lab and field

One of the most cited successes of computer vision in agriculture was published in 2016. Researchers trained a model on **54,306** leaf images covering 14 crops and 26 diseases and reached **99.35%** accuracy on held-out test images.

The less cited part of the same paper is this: when the model was tested on images taken under different conditions, accuracy fell to **31.40%** and **31.69%**. The training images were single leaves photographed under controlled conditions against a plain background; the test images were collected from trusted online sources such as agricultural extension services. The authors write that a real-world application would have to recognise a disease as it presents itself directly on the plant. 31% is far better than random guessing — **2.6%** across 38 classes — but nowhere near 99%. The authors' own conclusion is plain: a more diverse set of training data is needed.

The distance between those two figures shows the question every success rate in this field should face: **measured on which images?**

## Türkiye

In Türkiye, weed detection by computer vision is studied mostly at university thesis level. A master's thesis at Pamukkale University detects weeds in maize with a view to local spraying; there is a doctoral thesis at Tokat Gaziosmanpaşa University on weed detection in wheat. TAGEM, meanwhile, started a project in 2025 to build a prototype precision sprayer for maize and cotton that locates weeds with cameras and opens its nozzles only over the target (§23). A review article on drone-based weed detection has also been published in the Turkish literature.

What is missing is **a published Turkish trial measuring herbicide savings in the field.** The step from a detection model to a reduction of herbicide on the field is the step the trials above measured.

## How this page is kept up to date

This page watches for new peer-reviewed field trials of targeted spraying. New information is added to the page after an editor's approval.
