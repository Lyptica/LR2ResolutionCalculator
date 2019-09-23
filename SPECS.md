# SPECS.md

## 基本情報

```txt
緑数字: 365
LR2基本スピード: 100
レーンカバー(SD): 30
レーンカバー(HD): 10
DX+(SD): 2780x2085
DX+(HD): 3431x1929
```

## 説明

```txt
#DST_LINE.h: 1   ←小節の高さ(関係なくね？)
#DST_LINE.y: 320 ←下端の終端pixel
#DST_LINE.w: 144 ←フレーム左端から数え始めたときの終端pixel
```

## [MONITOR]AC(SD)

```txt
inch:   37
aspect: 16:9
x,y:    640x480
```

## [MONITOR]家のモニタ

```txt
inch:   31.5
aspect: 16:9
x,y:    3840x2160
```

## [FRAME]AC(SD)✅

```txt
解像度: 640x480
フレーム左端〜右端: 25~168(143)
フレーム上端〜下端(赤ラインの下): 0~320(320)
#DST_LINE.h: 1
#DST_LINE.w: 144
#DST_LINE.y: 320
レーンカバーMAX: 999
```

## [FRAME]CS(SD)✅

```txt
解像度: 640x480
フレーム左端〜右端: 33~224(191)
フレーム上端〜下端(赤ラインの下): 0~320(320)
#DST_LINE.h: 1
#DST_LINE.w: 234
#DST_LINE.y: 320
レーンカバーMAX: 20
```

## [FRAME]AC(HD)✅

```txt
解像度: 1280x720
フレーム左端〜右端: 50~337(287)
フレーム上端〜下端(赤ラインの下): 0~481(481)
#DST_LINE.h: 2
#DST_LINE.w: 288
#DST_LINE.y: 480
レーンカバーMAX: 999
```

## [FRAME]bigPlay(SD)

```txt
解像度: 640x480
フレーム左端〜右端: 47~334(287)
フレーム上端〜下端(赤ラインの下): 0~426(426)
#DST_LINE.h: 2
#DST_LINE.w: 288
#DST_LINE.y: 427
レーンカバーMAX: 20
```

## [FRAME]DX+(9+)(SD)✅

```txt
解像度: 640x480
フレーム左端〜右端: 41~273(232)
フレーム上端〜下端(赤ラインの下): 0~322(322)
#DST_LINE.h: 1
#DST_LINE.w: 234
#DST_LINE.y: 320
レーンカバーMAX: 20
```

## [FRAME]bigPlay(W-MIX)(HD)✅

```txt
解像度: 1280x720
フレーム左端〜右端: 48~424(376)
フレーム上端〜下端(赤ラインの下): 0~481(481)
#DST_LINE.h: 2
#DST_LINE.w: 377
#DST_LINE.y: 480
レーンカバーMAX: 10
```
