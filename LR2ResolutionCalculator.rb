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
    @mm[:heightPerPixel] = @mm[:height]/@px[:y]
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
  def initialize(frame, size)
    # フレーム内の解像度
    @frame = {
      :frame_width => 0.0.to_f,
      :frame_height => 0.0.to_f,
      :frame_other  => 0.0.to_f,
      :width        => size[0],
      :height       => size[1]
    }

    # frameのpxを出しておく
    @frame[:frame_width] = frame[0].to_f
    @frame[:frame_height] = frame[1].to_f

    # frame以外のpxも出しておく
    @frame[:frame_other] = (@frame[:width] - @frame[:frame_width]).to_f
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
    # コレクション
    initializeMonitorAndFrames()
    # LR2のウィンドウサイズをいくつにしたらACのフレーム幅再現できるか計算
    # getLR2WindowSizeForSimulateACWidthSize(@acMonitor,@cindyMonitor,@iidxSdFrame,@bigPlaySdFrame)
    # getLR2WindowSizeForSimulateACWidthSize(@acMonitor,@cindyMonitor,@iidxSdFrame,@ninePlusSdFrame)
    # IIDXの白数字いくつにすれば、自宅のLR2の縦幅を再現できるか計算
    getIIDXWhiteNumberFromLR2FrameAndWindowSize(@acMonitor,@cindyMonitor,@iidxSdFrame,@ninePlusSdFrame)
  end

  def initializeMonitorAndFrames()
    @acMonitor        = Monitor.new(37,"16:9",[640,480])
    @acHdMonitor      = Monitor.new(37,"16:9",[1280,720])
    @cindyMonitor     = Monitor.new(31.5,"16:9",[3840,2160])
    @iidxSdFrame      = IIDXFrame.new([144,320],[640,480])
    @iidxCsSdFrame    = IIDXFrame.new([234,320],[640,480])
    @iidxHdFrame      = IIDXFrame.new([288,480],[1280,720])
    @bigPlaySdFrame   = IIDXFrame.new([288,427],[640,480])
    @ninePlusSdFrame  = IIDXFrame.new([234,320],[640,480])
    @wMixHdFrame      = IIDXFrame.new([234,320],[1280,720])
  end

  def getIIDXWhiteNumberFromLR2FrameAndWindowSize(acMonitor, userMonitor, iidxFrame, userFrame)
    # 1. IIDXのフレームy分のmmを測る
    acSdHeight = acMonitor.getMm[:heightPerPixel]*iidxFrame.getFrame[:frame_height]
    p "IIDXフレームの高さ: #{acSdHeight} mm"
    # 2. 白数字1つあたりの高さ(mm)を求める
    heightPerWhiteNumber = acSdHeight/999
    p "IIDXフレームの白数字1つあたりの高さ: #{heightPerWhiteNumber} mm"

    # 3. LR2の好きなフレームの高さを測る
    # まずは先に倍率を求めておく
    finalAmp = getLR2WindowSizeForSimulateACWidthSize(acMonitor,userMonitor,iidxFrame,userFrame)
    # bmsFrameにfinalAmpをかけた高さをcindyMonitorで表示したときのmmを測る
    bmsFrameHeightOnUserMonitor = (userFrame.getFrame[:frame_height]*finalAmp)*userMonitor.getMm[:heightPerPixel]
    p "ACと同じ横幅になるように調整した時のBMSフレームの高さ: #{bmsFrameHeightOnUserMonitor} mm"

    # 4. iidxの高さとの差分を測る
    sabunHeight = (acSdHeight - bmsFrameHeightOnUserMonitor)
    p "IIDXACとBMSフレームの高さ差分: #{sabunHeight} mm"
    whiteNumberForFillSabun = sabunHeight/heightPerWhiteNumber
    p "IIXDACとBMSフレームの高さ差分を埋めるための白数字: #{whiteNumberForFillSabun}"

    # 5. BMSのシャッターの白数字換算を数える
    # p "シャッターが10分割の場合の高さ: #{bmsFrameHeightOnUserMonitor/10} mm"
    # p "シャッターが20分割の場合の高さ: #{bmsFrameHeightOnUserMonitor/20} mm"
    # p "シャッターが10分割の場合の高さを白数字換算: #{(bmsFrameHeightOnUserMonitor/10)/heightPerWhiteNumber}"
    # p "シャッターが20分割の場合の高さを白数字換算: #{(bmsFrameHeightOnUserMonitor/20)/heightPerWhiteNumber}"
    p "シャッターを1/10降ろした場合の高さを白数字換算: #{(((bmsFrameHeightOnUserMonitor/10)*1)/heightPerWhiteNumber)+whiteNumberForFillSabun}"
    p "シャッターを3/20降ろした場合の高さを白数字換算: #{(((bmsFrameHeightOnUserMonitor/20)*3)/heightPerWhiteNumber)+whiteNumberForFillSabun}"
  end

  def getLR2WindowSizeForSimulateACWidthSize(acMonitor,userMonitor,acFrame,userFrame)
    # [モニタ] インチ数、アスペクト比[横:縦]、内部解像度[width,height]はそれぞれ導出不可能な値なので、与える
    # AC IIDXのモニタ
    acMonitor = acMonitor
    # p "IIDX Monitor"
    # acMonitor.showMe()
    # p ""
    # 家のモニタ
    userMonitor = userMonitor
    # p "Cindy Monitor"
    # userMonitor.showMe()
    # p ""

    # [フレーム] フレーム幅[始まり~終わり]、全体解像度[width,height]はそれぞれ導出不可能な値なので、与える
    # フレーム幅
    acFrame = acFrame
    # p "AC Style Frame"
    # acFrame.showMe
    # p ""
    userFrame = userFrame
    # p "BMS Style Frame"
    # userFrame.showMe
    # p ""

    # acMonitorでacFrameを表示した時の幅を、
    # userMonitorでuserFrameを使った時に再現するには、
    # LR2設定でを何Pixelに設定すればいいのか？

    # acMonitorでacFrameをフルスクリーン表示した時の幅(mm)
    acWidthOnAcMonitor = acMonitor.getMm()[:widthPerPixel] * acFrame.getFrame()[:frame_width]
    p "acMonitor(640x480@37inch)でacFrame(640x480)を表示した時のフレーム幅(mm): #{acWidthOnAcMonitor}"
    # userMonitorでuserFrameを表示した時の長さ
    bmsWidthOnUserMonitor = userMonitor.getMm()[:widthPerPixel] * userFrame.getFrame()[:frame_width]
    p "userMonitor(3840x2160@31.5inch)でuserFrame(640x480)を表示した時のフレーム幅(mm): #{bmsWidthOnUserMonitor}"
    # userMonitorでuserFrameを表示した時の長さ * x = acWidthOnAcMonitor となるようなxを探る
    finalAmp = acWidthOnAcMonitor / bmsWidthOnUserMonitor
    p " -> 自分ちのモニタでBMSフレームを使った時にAC版のフレームサイズ(mm)を再現するには、LR2の解像度を#{finalAmp}倍すればいい"
    # 実際に何ピクセルなのか表示
    p " -> LR2の解像度 xy = #{(userFrame.getFrame[:width]*finalAmp).round},#{(userFrame.getFrame[:height]*finalAmp).round} にすればBMSフレームでACを再現できる。"

    # # 検算する
    # p "[検算]: 自分ちのモニタの1pxあたりのサイズ(mm) * BMSフレームのフレームサイズ(px) * x = ACのモニタのフレーム幅(mm)"
    # # p "[計算]: #{userMonitor.getPx()[:widthPerPixel]} * #{userFrame.getFrame()[:frame_width]} = #{userMonitor.getPx()[:widthPerPixel] * userFrame.getFrame()[:frame_width]} == #{acMonitor.getMm()[:widthPerPixel]*acFrame.getFrame()[:frame_width]}"
    # p "[計算]: #{userMonitor.getMm()[:widthPerPixel]} * #{userFrame.getFrame()[:frame_width]} * #{finalAmp} = #{userMonitor.getMm()[:widthPerPixel] * userFrame.getFrame()[:frame_width] * finalAmp} == #{acMonitor.getMm()[:widthPerPixel]*acFrame.getFrame()[:frame_width]}"
    # p ""

    # [フレーム幅(mm)が正しそうなことの検算]
    # 横全体 = 819mm
    # フレーム幅 = 143px
    # それ以外 = 497px
    # フレーム幅 = 183.01915099987522 mm
    # それ以外(導出) = 3.475524475524476 * 183.01915099987522 = 636.087538789776201
    # 全体(導出) = 183.01915099987522 + 636.087538789776201 = 819.106689789651421

    # [倍率が正しそうなことの検算]
    # BMSフレームをuserMonitorで表示した時の幅 = 52.11946810982082 mm
    # 183.01915099987522 / 52.11946810982082 = 3.511531441845031

    return finalAmp
  end
end
LR2ResolutionCalculator.new()
