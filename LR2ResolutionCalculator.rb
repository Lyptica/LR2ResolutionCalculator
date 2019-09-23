require 'pp'

# 何の解像度で作られたモニタで、実際のmmはいくらなのか、1ピクセルあたりのmmはいくらか？
class Monitor
  def initialize(inch, ratioString, xy)
    # mmの世界
    @mm = {
      :inch           => inch.to_f,
      :width          => 0.to_f,
      :height         => 0.to_f,
      :widthPerPixel  => 0.to_f,
      :heightPerPixel => 0.to_f,
      :ratioString    => ratioString
    }
    # pxの世界
    @px = {
      :x => xy[0].to_f,
      :y => xy[1].to_f
    }
    # インチサイズから縦横のmmを算出
    calcSizeFromInch()
  end

  def calcSizeFromInch()
    # 現在のインチ数から対角線のmmを算出
    oneInchDMm = 25.4
    thisInch = @mm[:inch]
    thisInchDMm = oneInchDMm * thisInch

    # モニタは直角三角形なので、三平方の定理を使って縦横を出す
    @mm[:width],@mm[:height] = pythagorasTheorem(@mm[:ratioString], thisInchDMm)

    # 1pxあたりのmmを出す
    @mm[:widthPerPixel] = @mm[:width]/@px[:x]
    @mm[:heightPerPixel] = @mm[:height]/@px[:x]
  end

  def pythagorasTheorem(ratioString, d)
    # p "比(ratioString): #{ratioString}"
    # p "対角線の長さ(d): #{d}"
    # p ""
    # # 与える
    # p "[導出] d^2 = x^2 + y^2"
    # p "[導出] 16:9 = x:y"
    # p "[導出] -> y = 9x/16"
    # p "[導出] -> d^2 = x^2 + (9/16)^2*x^2"
    # p ""
    d2 = d*d
    ratioArray = parseRatioFromString(ratioString)
    r = Rational(ratioArray[1],ratioArray[0])
    r2 = r*r
    # p "対角線の長さの2乗(d2): #{d}^2 = #{d2}"
    # p "比の逆の2乗(r2): #{r}^2 = #{r2}"
    # p ""
    # p "[導出] d2 = (1+r2)*x^2"
    # p "[導出] x^2 = d2/(1+r2)"
    # p "[導出] 横幅(x) = √(d2/(1+r2))"
    # p "[再掲] 高さ(y) = 9x/16"
    # p ""
    x = Math.sqrt(d2/(1+r2))
    y = getYFromXByCalcurateRatio(ratioString, x)
    # p "横幅(x): #{x}"
    # p "高さ(y): #{y}"
    # p ""
    # p "[検算] x^2 * y^2 = r^2"
    # p "#{x*x} + #{y*y} = #{(x*x)+(y*y)} == #{d*d}"
    # p ""

    return x,y
  end

  def parseRatioFromString(ratio)
    ratio = ratio.split(":")
    ratio[0] = ratio[0].to_f
    ratio[1] = ratio[1].to_f
    return ratio
  end

  def getYFromXByCalcurateRatio(ratio, x)
    # ratio[0]:ratio[1] = x:?
    ratio = parseRatioFromString(ratio)
    y = (ratio[1]*x)/ratio[0]
    return y
  end

  def getXFromYByCalcurateRatio(ratio, y)
    # ratio[0]:ratio[1] = ?:y
    ratio = parseRatioFromString(ratio)
    x = (ratio[0]*y)/ratio[1]
    return x
  end

  def showMe()
    pp @mm
    pp @px
  end

  def getPx()
    return @px
  end

  def getMm()
    return @mm
  end
end

# 何の解像度向けに作られたフレームで、フレーム内外のサイズは何pxなのか？
class IIDXFrame
  def initialize(frameLength, size)
    # フレーム内の解像度
    @frame = {
      :frame_length => 0.0.to_f,
      :frame_other  => 0.0.to_f,
      :width        => size[0],
      :height       => size[1]
    }

    # frameのpxを出しておく
    @frame[:frame_length] = (frameLength[1]-frameLength[0]).to_f

    # frame以外のpxも出しておく
    @frame[:frame_other] = (@frame[:width] - @frame[:frame_length]).to_f
  end

  def getFrame()
    return @frame
  end

  def showMe()
    pp @frame
  end
end

# サービス
class LR2ResolutionCalculator
  def initialize()
    # [モニタ] インチ数、アスペクト比[横:縦]、内部解像度[width,height]はそれぞれ導出不可能な値なので、与える
    # AC IIDXのモニタ
    acMonitor = Monitor.new(37,"16:9",[640,480])
    # p "IIDX Monitor"
    # acMonitor.showMe()
    # p ""
    # 家のモニタ
    cindyMonitor = Monitor.new(31.5,"16:9",[3840,2160])
    # p "Cindy Monitor"
    # cindyMonitor.showMe()
    # p ""

    # [フレーム] フレーム幅[始まり~終わり]、全体解像度[width,height]はそれぞれ導出不可能な値なので、与える
    # フレーム幅
    realFrame = IIDXFrame.new([25,168],[640,480])
    # p "AC Style Frame"
    # realFrame.showMe
    # p ""
    remiFrame = IIDXFrame.new([47,334],[640,480])
    # p "REMI-S Style Frame"
    # remiFrame.showMe
    # p ""

    # acMonitorでrealFrameを表示した時の幅を、
    # cindyMonitorでremiFrameを使った時に再現するには、
    # LR2設定でを何Pixelに設定すればいいのか？

    # acMonitorでrealFrameをフルスクリーン表示した時の幅(mm)
    realWidthOnAcMonitor = acMonitor.getMm()[:widthPerPixel] * realFrame.getFrame()[:frame_length]
    p "acMonitor(640x480@37inch)でrealFrame(640x480)を表示した時のフレーム幅(mm): #{realWidthOnAcMonitor}"
    # cindyMonitorでremiFrameを表示した時の長さ
    remiWidthOnCindyMonitor = cindyMonitor.getMm()[:widthPerPixel] * remiFrame.getFrame()[:frame_length]
    p "cindyMonitor(3840x2160@31.5inch)でremiFrame(640x480)を表示した時のフレーム幅(mm): #{remiWidthOnCindyMonitor}"
    # cindyMonitorでremiFrameを表示した時の長さ * x = realWidthOnAcMonitor となるようなxを探る
    finalAmp = realWidthOnAcMonitor / remiWidthOnCindyMonitor
    p " -> 自分ちのモニタでREMI-Sを使った時にAC版のフレームサイズ(mm)を再現するには、LR2の解像度を#{finalAmp}倍すればいい"
    # 実際に何ピクセルなのか表示
    p " -> LR2の解像度 xy = #{(remiFrame.getFrame[:width]*finalAmp).round},#{(remiFrame.getFrame[:height]*finalAmp).round} にすればREMI-SでACを再現できる。"

    # # 検算する
    # p "[検算]: 自分ちのモニタの1pxあたりのサイズ(mm) * REMI-Sのフレームサイズ(px) * x = ACのモニタのフレーム幅(mm)"
    # # p "[計算]: #{cindyMonitor.getPx()[:widthPerPixel]} * #{remiFrame.getFrame()[:frame_length]} = #{cindyMonitor.getPx()[:widthPerPixel] * remiFrame.getFrame()[:frame_length]} == #{acMonitor.getMm()[:widthPerPixel]*realFrame.getFrame()[:frame_length]}"
    # p "[計算]: #{cindyMonitor.getMm()[:widthPerPixel]} * #{remiFrame.getFrame()[:frame_length]} * #{finalAmp} = #{cindyMonitor.getMm()[:widthPerPixel] * remiFrame.getFrame()[:frame_length] * finalAmp} == #{acMonitor.getMm()[:widthPerPixel]*realFrame.getFrame()[:frame_length]}"
    # p ""

    # [フレーム幅(mm)が正しそうなことの検算]
    # 横全体 = 819mm
    # フレーム幅 = 143px
    # それ以外 = 497px
    # フレーム幅 = 183.01915099987522 mm
    # それ以外(導出) = 3.475524475524476 * 183.01915099987522 = 636.087538789776201
    # 全体(導出) = 183.01915099987522 + 636.087538789776201 = 819.106689789651421

    # [倍率が正しそうなことの検算]
    # REMI-SをCindyMonitorで表示した時の幅 = 52.11946810982082 mm
    # 183.01915099987522 / 52.11946810982082 = 3.511531441845031

  end
end
LR2ResolutionCalculator.new()
