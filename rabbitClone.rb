class RabbitClone
  def initialize()
    # skinの設定
    dstLineY=320.0
    dstLineH=1.0
    # デフォルトのスピード
    lr2ScrollSpeed=100.0
    # LR2のレーンカバーの数字
    laneCover=30.0
    # いつものLR2のハイスピ設定
    lr2HighSpeed=220.0
    lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    # IIDXの緑数字
    greenNumber=350
    iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
  end

  def lr2ToIIDX(lr2HighSpeed,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    chip1=(2173*10.0*10.0*10.0*10.0)/725
    p chip1
    chip2=((dstLineY+dstLineH)/(lr2HighSpeed*lr2ScrollSpeed))*(1.0-(laneCover/100.0))
    p chip2
    g=chip1*chip2
    p g
  end

  def iidxToLR2(greenNumber,dstLineY,dstLineH,lr2ScrollSpeed,laneCover)
    chip1=(2173*10.0*10.0*10.0*10.0)/725
    p chip1
    chip2=((dstLineY+dstLineH)/(greenNumber*lr2ScrollSpeed))*(1.0-(laneCover/100.0))
    p chip2
    g=chip1*chip2
    p g
  end

end
RabbitClone.new()