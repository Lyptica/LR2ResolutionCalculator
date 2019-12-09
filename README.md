# LR2ResolutionCalculator
小さいモニタでも大きなフレームでプレイできるREMI-Sスキンで解像度をいくつにすればAC再現できるのか計算した

## 何がしたいのかな

```txt
家のモニタ: 31.5inch , 4K解像度, 16:9
ACのモニタ: 37inch, VGA解像度, 16:9
　の条件下で、ACのモニタのプレイフレームの大きさを再現するにはLR2の設定を
　どうすればいいのか計算。(ACのフレームサイズ測ってこいとかいう話はナシで)
```

## 知ってる情報

- 既知な情報

```txt
1インチあたりの対角線の長さ: 25.4mm
 -> これでインチ数とアスペクト比さえわかれば縦横の長さ(mm)が出せる
古いACは640x480の解像度で動いてる (LR2のデフォルト解像度と一緒なのでこれ準拠で計算する)
```

- 測ってきた情報

```txt
ACのプレイレーンの左端から右端のpixel: 25~168
REMI-Sのプレイレーンの左端から右端のpixel: 47~334
```

- リンク
 - [詳しい](http://verflucht.blog.fc2.com/blog-entry-2.html)
 - [ここもふむふむなるほどってなる](http://taisa-llma.hatenablog.com/entry/2016/12/10/025953)

## 実行結果

```txt
acMonitor(640x480@37inch)でrealFrame(640x480)を表示した時のフレーム幅(mm): 183.01915099987522 (mm)
cindyMonitor(3840x2160@31.5inch)でremiFrame(640x480)を表示した時のフレーム幅(mm): 52.11946810982082 (mm)
 -> 自分ちのモニタでREMI-Sを使った時にAC版のフレームサイズ(mm)を再現するには、LR2の解像度を3.511531441845031倍すればいい。
 -> LR2の解像度 xy = 2247,1686 にすればREMI-SでACを再現できる。
```

## 感想

- ぶっちゃけpixelの個数測ってる時点でレーンサイズを定規で測るんでもいいかなとか思った。

## 家の左側モニタ

```txt
⭐ACフレームの横幅をBMSで再現⭐
 -> acMonitorでiidxSdFrameを表示した時のフレーム幅(mm): 183.01
 -> kj43x8000eMonitorでninePlusSdFrameを表示した時のフレーム幅(mm): 111.53
   -> kj43x8000eMonitorでninePlusSdFrameを使った時にiidxSdFrameのフレーム横幅を再現するには、LR2の解像度を1.64倍すればいい
   -> ✅LR2のウィンドウサイズ = 1050x788 にすればninePlusSdFrameでiidxSdFrameのフレーム横幅を再現できる。

⭐1.64倍に大きくしたninePlusSdFrameの縦幅をiidxSdFrameで再現するための白数字の算出⭐
 -> iidxSdFrame周り
   -> iidxSdFrameのレーンの高さ: 307.16 mm
   -> iidxSdFrameの白数字1つあたりの高さ: 0.3 mm
 -> ninePlusSdFrame周り
   -> 1.64倍に大きくしたninePlusSdFrameのレーンの高さ: 261.95 mm
 -> 差分を測る
   -> iidxSdFrameとninePlusSdFrameの高さ差分: 45.2 mm
   -> ✅iidxSdFrameとninePlusSdFrameの高さ差分を埋めるための白数字: 147
 -> シャッターを考慮した場合の白数字を計算
   -> ✅更にシャッターを15/100降ろした場合の高さを白数字換算: 274

⭐ninePlusSdFrameのハイスピード:220.0, シャッター:15.0を緑数字に換算⭐
 -> HS: 220.0
 -> シャッター: 15.0 (%)
   -> ✅算出される緑数字: 372
```
