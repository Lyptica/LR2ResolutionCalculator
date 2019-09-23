require 'pp'

# 何の解像度で作られたモニタで、実際のmmはいくらなのか、1ピクセルあたりのmmはいくらか？
class Monitor
  def initialize(name, inch, ratioString, xy)
    # mmの世界
    @mm = {
      :name           => name,
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

  def printAll()
    print "モニタ名: #{@mm[:name]}\n"
    print " -> #{@mm[:inch]} (インチ)\n"
    print " -> #{@mm[:ratioString]} (アスペクト比)\n"
    print " -> #{@px[:x].floor}x#{@px[:y].floor} (pixel)\n"
    print " -> #{@mm[:width].floor}x#{@mm[:height].floor} (mm)\n"
    print " -> #{@mm[:widthPerPixel].floor(2)}x#{@mm[:heightPerPixel].floor(2)} (mm/pixel)\n"
    # print " -> #{@mm[:]}\n"
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
  def initialize(name, frame, size, hs, lanecover)
    # フレーム内の解像度
    @frame = {
      :name        => name,
      :frame_width => 0.0.to_f,
      :frame_height => 0.0.to_f,
      :frame_other  => 0.0.to_f,
      :width        => size[0].to_f,
      :height       => size[1].to_f,
      :high_speed   => hs.to_f,
      :lanecover    => lanecover.to_f
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

  def printAll()
    print "フレーム名: #{@frame[:name]}\n"
    print " -> #{@frame[:width].floor}x#{@frame[:height].floor} (フレーム全体の解像度)(pixel)\n"
    print " -> #{@frame[:frame_width].floor}x#{@frame[:frame_height].floor} (ノートレーンのみの解像度)(pixel)\n"
    print " -> #{@frame[:high_speed]} (ハイスピード)(BMSフレームのみ)\n" if @frame[:high_speed] != 0.0
    print " -> #{@frame[:lanecover]} (レーンカバー)(BMSフレームのみ)\n" if @frame[:lanecover] != 0.0
  end
end

# サービス
class LR2ResolutionCalculator
  def initialize()
    # コレクション
    initializeMonitorAndFrames()
    # LR2のウィンドウサイズをいくつにしたらACのフレーム幅再現できるか計算
    # IIDXの白数字いくつにすれば、自宅のLR2の縦幅を再現できるか計算
    getAllInfo(@acOrg40v30Monitor,@cindyMonitor,@iidxHdFrame,@wMixHdFrame)
    getAllInfo(@acOrg40v30Monitor,@cindyMonitor,@iidxHdFrame,@ninePlusSdFrame)
  end

  def initializeMonitorAndFrames()
    #                                    name,                    inch,aspect,resolution
    @acMonitor             = Monitor.new("acMonitor",             37,  "16:9",[640,480])
    @acOrg40v30Monitor     = Monitor.new("acOrg40v30Monitor",     40,  "16:9",[1280,720])
    @acOrg40v30JustMonitor = Monitor.new("acOrg40v30JustMonitor", 39.8,"16:9",[1280,720])
    @acHdMonitor           = Monitor.new("acHdMonitor",           37,  "16:9",[1280,720])
    @cindyMonitor          = Monitor.new("cindyMonitor",          31.5,"16:9",[3840,2160])
    #                                      name,              mmAspect, resolution, HS, LANECOVER
    @iidxSdFrame           = IIDXFrame.new("iidxSdFrame",     [143,320],[640,480],  0,  0)
    @iidxCsSdFrame         = IIDXFrame.new("iidxCsSdFrame",   [191,320],[640,480],  0,  0)
    @iidxHdFrame           = IIDXFrame.new("iidxHdFrame",     [287,481],[1280,720], 0,  0)
    @bigPlaySdFrame        = IIDXFrame.new("bigPlaySdFrame",  [287,426],[640,480],  0,  0)
    @ninePlusSdFrame       = IIDXFrame.new("ninePlusSdFrame", [232,322],[640,480],  220,15)
    @wMixHdFrame           = IIDXFrame.new("wMixHdFrame",     [376,481],[1280,720], 350,10)
  end

  def getAllInfo(acMonitor, userMonitor, iidxFrame, userFrame)
    print "==========================================\n"

    # インプット情報表示

    # AC IIDXのモニタ
    # acMonitor.showMe
    acMonitor.printAll

    # 家のモニタ
    # userMonitor.showMe
    userMonitor.printAll

    # ACフレーム
    # iidxFrame.showMe
    iidxFrame.printAll

    # BMSフレーム
    # userFrame.showMe
    userFrame.printAll

    # ウィンドウサイズ算出
    finalAmp = getLR2WindowSizeForSimulateACWidthSize(acMonitor,userMonitor,iidxFrame,userFrame)

    # 白数字算出
    getIIDXWhiteNumberFromLR2FrameAndWindowSize(finalAmp, acMonitor, userMonitor, iidxFrame, userFrame)

    # LR2で設定しているハイスピード設定をACで再現するためには、緑数字をいくらにしたらいいのか計算

    print "⭐#{userFrame.getFrame[:name]}のハイスピード:#{userFrame.getFrame[:high_speed]}, シャッター:#{userFrame.getFrame[:lanecover]}を緑数字に換算⭐\n"
    # skinの設定
    dstLineYH=userFrame.getFrame[:frame_height]
    # デフォルトのスピード
    lr2ScrollSpeed=100.0
    # LR2のレーンカバーの数字
    laneCover=userFrame.getFrame[:lanecover]
    # いつものLR2のハイスピ設定
    lr2HighSpeed=userFrame.getFrame[:high_speed]
    lr2ToIIDX(lr2HighSpeed,dstLineYH,lr2ScrollSpeed,laneCover)
    print "\n"

    # # IIDXの緑数字
    # greenNumber=350
    # iidxToLR2(greenNumber,dstLineY,lr2ScrollSpeed,laneCover)

  end

  def getLR2WindowSizeForSimulateACWidthSize(acMonitor,userMonitor,acFrame,userFrame)
    # [モニタ] インチ数、アスペクト比[横:縦]、内部解像度[width,height]はそれぞれ導出不可能な値なので、与える

    # acMonitorでacFrameを表示した時の幅を、
    # userMonitorでuserFrameを使った時に再現するには、
    # LR2設定でを何Pixelに設定すればいいのか？

    print "\n"
    print "⭐ACフレームの横幅をBMSで再現⭐\n"
    # acMonitorでacFrameをフルスクリーン表示した時の幅(mm)
    acWidthOnAcMonitor = acMonitor.getMm()[:widthPerPixel] * acFrame.getFrame()[:frame_width]
    # print "#{acMonitor.getMm[:name]}(#{acMonitor.getPx[:x]}x#{acMonitor.getPx[:y]}@#{acMonitor.getMm[:inch]}inch)で#{acFrame.getFrame[:name]}(#{acFrame.getFrame[:width]}x#{acFrame.getFrame[:height]})を表示した時のフレーム幅(mm): #{acWidthOnAcMonitor}\n"
    print " -> #{acMonitor.getMm[:name]}で#{acFrame.getFrame[:name]}を表示した時のフレーム幅(mm): #{acWidthOnAcMonitor.floor(2)}\n"
    # userMonitorでuserFrameを表示した時の長さ
    bmsWidthOnUserMonitor = userMonitor.getMm()[:widthPerPixel] * userFrame.getFrame()[:frame_width]
    # print "#{userMonitor.getMm[:name]}(#{userMonitor.getPx[:x]}x#{userMonitor.getPx[:y]}@#{userMonitor.getMm[:inch]}inch)で#{userFrame.getFrame[:name]}(#{userFrame.getFrame[:width]}x#{userFrame.getFrame[:height]})を表示した時のフレーム幅(mm): #{bmsWidthOnUserMonitor}\n"
    print " -> #{userMonitor.getMm[:name]}で#{userFrame.getFrame[:name]}を表示した時のフレーム幅(mm): #{bmsWidthOnUserMonitor.floor(2)}\n"
    # userMonitorでuserFrameを表示した時の長さ * x = acWidthOnAcMonitor となるようなxを探る
    finalAmp = acWidthOnAcMonitor / bmsWidthOnUserMonitor
    print "   -> #{userMonitor.getMm[:name]}で#{userFrame.getFrame[:name]}を使った時に#{acFrame.getFrame[:name]}のフレーム横幅を再現するには、LR2の解像度を#{finalAmp.floor(2)}倍すればいい\n"
    # 実際に何ピクセルなのか表示
    print "   -> ✅LR2のウィンドウサイズ = #{(userFrame.getFrame[:width]*finalAmp).round}x#{(userFrame.getFrame[:height]*finalAmp).round} にすれば#{userFrame.getFrame[:name]}で#{acFrame.getFrame[:name]}のフレーム横幅を再現できる。\n"
    print "\n"

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

  def getIIDXWhiteNumberFromLR2FrameAndWindowSize(finalAmp, acMonitor, userMonitor, iidxFrame, userFrame)
    print "⭐#{finalAmp.floor(2)}倍に大きくした#{userFrame.getFrame[:name]}の縦幅を#{iidxFrame.getFrame[:name]}で再現するための白数字の算出⭐\n"

    # 1. IIDXのフレームy分のmmを測る
    print " -> #{iidxFrame.getFrame[:name]}周り\n"
    acSdHeight = acMonitor.getMm[:heightPerPixel]*iidxFrame.getFrame[:frame_height]
    print "   -> #{iidxFrame.getFrame[:name]}のレーンの高さ: #{acSdHeight.floor(2)} mm\n"
    # 2. 白数字1つあたりの高さ(mm)を求める
    heightPerWhiteNumber = acSdHeight/999
    print "   -> #{iidxFrame.getFrame[:name]}の白数字1つあたりの高さ: #{heightPerWhiteNumber.floor(2)} mm\n"

    # 3. LR2の好きなフレームの高さを測る
    print " -> #{userFrame.getFrame[:name]}周り\n"
    # bmsFrameにfinalAmpをかけた高さをcindyMonitorで表示したときのmmを測る
    bmsFrameHeightOnUserMonitor = (userFrame.getFrame[:frame_height]*finalAmp)*userMonitor.getMm[:heightPerPixel]
    print "   -> #{finalAmp.floor(2)}倍に大きくした#{userFrame.getFrame[:name]}のレーンの高さ: #{bmsFrameHeightOnUserMonitor.floor(2)} mm\n"

    # 4. iidxの高さとの差分を測る
    print " -> 差分を測る\n"
    sabunHeight = (acSdHeight - bmsFrameHeightOnUserMonitor)
    print "   -> #{iidxFrame.getFrame[:name]}と#{userFrame.getFrame[:name]}の高さ差分: #{sabunHeight.floor(2)} mm\n"
    whiteNumberForFillSabun = sabunHeight/heightPerWhiteNumber
    print "   -> ✅#{iidxFrame.getFrame[:name]}と#{userFrame.getFrame[:name]}の高さ差分を埋めるための白数字: #{whiteNumberForFillSabun.floor}\n"

    # 5. BMSのシャッターの白数字換算を数える
    print " -> シャッターを考慮した場合の白数字を計算\n"
    # print "シャッターが10分割の場合の高さ: #{bmsFrameHeightOnUserMonitor/10} mm\n"
    # print "シャッターが20分割の場合の高さ: #{bmsFrameHeightOnUserMonitor/20} mm\n"
    # print "シャッターが10分割の場合の高さを白数字換算: #{(bmsFrameHeightOnUserMonitor/10)/heightPerWhiteNumber}\n"
    # print "シャッターが20分割の場合の高さを白数字換算: #{(bmsFrameHeightOnUserMonitor/20)/heightPerWhiteNumber}\n"
    print "   -> ✅更にシャッターを#{userFrame.getFrame[:lanecover].floor}/100降ろした場合の高さを白数字換算: #{((((bmsFrameHeightOnUserMonitor/100)*userFrame.getFrame[:lanecover])/heightPerWhiteNumber)+whiteNumberForFillSabun).floor}\n"
    print "\n"
  end

  def lr2ToIIDX(lr2HighSpeed,dstLineYH,lr2ScrollSpeed,laneCover)
    chip1=(2173*10.0*10.0*10.0*10.0)/725
    # p chip1
    chip2=((dstLineYH)/(lr2HighSpeed*lr2ScrollSpeed))*(1.0-(laneCover/100.0))
    # p chip2
    g=chip1*chip2
    print " -> HS: #{lr2HighSpeed}\n"
    print " -> シャッター: #{laneCover} (%)\n"
    print "   -> ✅算出される緑数字: #{g.floor}\n"
  end

end
LR2ResolutionCalculator.new()
