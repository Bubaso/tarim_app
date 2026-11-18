# Computer vision

In farming, computer vision means a model interpreting what a camera, drone or phone captures: telling weeds from the crop, a diseased leaf from a healthy one, ripe fruit from the branch. Its most concrete measured gain is in targeted spraying: in peer-reviewed trials herbicide fell by **35%** in sugarcane and by **47%** with early application in maize, while weed control stayed level with broadcast spraying. The finding that cuts across fields is the gap between training images and field images: models nearly flawless on controlled images fall back markedly when conditions change. In Türkiye, computer vision is at work in universities, public projects and forest lookout towers, but what is measured is mostly recognition, not the effect on herbicide use, yield or losses in the field.

## Training images, field images

The model Mohanty and colleagues (2016) trained on **54,306** leaf images taken under controlled conditions was **99.35%** accurate on test images held out from the same set; on two small sets taken under other conditions, accuracy stayed at **31.40%** and **31.69%**. The model could only classify single leaves, facing up, against a plain background.

Models moved onto phones faced the same test in the field. In Tanzania, a cassava model's F-1 score for pronounced symptoms fell from **0.79** on the test set to **0.54** in field photos, and for early, mild symptoms it was **0.26** (Ramcharan and colleagues, 2019). PlantVillage Nuru, which works offline, recognised cassava symptoms with **65%** accuracy and beat extension officers (**40-58%**), but for mild symptoms its accuracy fell to **13-37%**; its evaluators included researchers from IITA, one of its developers (Mrisho and colleagues, 2020). A model in the field can outperform people; yet in both studies its weakest point is the early stage, where diagnosis matters most.

[[gorsel:t-goruntu-tanzanya-daki-saha-denemesinde]]

## A good eye, but the field decides

Recognition can be high in the field too: in a German maize trial, **94%** of weeds were correctly identified in drone images (Allmendinger and colleagues, 2024). The return, however, is decided by the field: in the Australian sugarcane trial the saving was proportional to weed density, and in lightly weeded strips herbicide fell by up to **65%** (Rahimi Azghadi and colleagues, 2025).

[[gorsel:t-goruntu-avustralya-seker-kamisi]]

In harvesting robots, too, the eye is the strongest link. Bac and colleagues (2014) reviewed **50** robots: on average, locating the fruit succeeded **85%** of the time, detaching it **75%** and the whole harvest **66%**. The greenhouse pepper robot SWEEPER succeeded **61%** of the time when the crop was grown to suit it and **18%** under the greenhouse's usual conditions (Arad and colleagues, 2020): unless leaves and branches are arranged for the robot, a better eye is not enough.

[[gorsel:t-goruntu-hasat-robotunun-gozu-sweeper-in]]

In forests, cameras change the scale: a prototype in Southern California that scans hundreds of cameras every minute usually caught smoke within **15** minutes of ignition; even so, the authors write, ground cameras cannot see every fire (Govil and colleagues, 2020).

[[gorsel:t-goruntu-guney-kaliforniya-da-dag-kamerasi]]

## Cameras on towers, models in the lab

According to a 2013 TÜBİTAK announcement, the Forest Fire Warning System developed by the General Directorate of Forestry and Bilkent University then used **77** towers and **154** cameras to watch **3.2** million hectares, and detected a small fire in **15-25** seconds. This is the institution's own claim; the system's accuracy has not been independently measured and published.

Figures from academia are high, but they measure recognition: on a laboratory set of **400** images, hazelnuts damaged by the stink bug were separated with **98.75%** accuracy (Gadalla and Öztekin, 2023); in **96** tomato fields in Karacabey, Bursa, a model recognising pests in images reached **98.91%** precision (Şahin and colleagues, 2025). No published study in Türkiye has measured the step that follows recognition: whether herbicide use or losses fell in the field, or whether a robot could pick the fruit.

[[gorsel:t-goruntu-bursa-karacabey-domates-calismasinda]]

All three AI projects TAGEM launched in 2025 rest on images:

- A dataset of disease and pest images from fruit and vineyards, built with **8** research institutes and **2** universities
- Multispectral imaging of dried apricots
- A camera-guided sprayer prototype for maize and cotton

Their results have not yet been published.
