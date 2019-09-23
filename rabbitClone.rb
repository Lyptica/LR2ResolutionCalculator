class RabbitClone
  def initialize()
    # skinの設定
    dstLineY=320.0
    dstLineH=1.0
    # デフォルトのスピード
    lr2ScrollSpeed=100.0
    # LR2のレーンカバーの数字
    laneCover=15.0
    # いつものLR2のハイスピ設定
    lr2HighSpeed=220.0
    lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    # IIDXの緑数字
    greenNumber=350
    iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)

    # skinの設定
    dstLineY=480.0
    dstLineH=2.0
    # デフォルトのスピード
    lr2ScrollSpeed=100.0
    # LR2のレーンカバーの数字
    laneCover=10.0
    # いつものLR2のハイスピ設定
    lr2HighSpeed=350.0
    lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    # IIDXの緑数字
    greenNumber=350
    iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)

    # skinの設定
    dstLineY=480.0
    dstLineH=2.0
    # デフォルトのスピード
    lr2ScrollSpeed=100.0
    # LR2のレーンカバーの数字
    laneCover=0.0
    # いつものLR2のハイスピ設定
    lr2HighSpeed=390.0
    lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    # IIDXの緑数字
    greenNumber=371
    iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)


  end

  def lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    p lr2HighSpeed
    p dstLineY
    p dstLineH
    p lr2ScrollSpeed
    p laneCover

    chip1=(2173*10.0*10.0*10.0*10.0)/725
    p chip1
    chip2=((dstLineY+dstLineH)/(lr2HighSpeed*lr2ScrollSpeed))*(1.0-(laneCover/100.0))
    p chip2
    g=chip1*chip2
    p "HS: #{lr2HighSpeed}, シャッター: #{laneCover} の時の緑数字: #{g}"
  end

  def iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    chip1=(2173*10.0*10.0*10.0*10.0)/725
    # p chip1
    chip2=((dstLineY+dstLineH)/(greenNumber*lr2ScrollSpeed))*(1.0-(laneCover/100.0))
    # p chip2
    g=chip1*chip2
    p "緑数字: #{greenNumber}, シャッター: #{laneCover} の時のLR2HS: #{g}"
  end

end
RabbitClone.new()