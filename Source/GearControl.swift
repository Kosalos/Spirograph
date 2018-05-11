import UIKit
import simd

let wSz:CGFloat = 70

class GearControl : UIView {
    var timer = Timer()
    var index = Int()
    var name = String()
    var widget1 = DeltaView()
    var widget2 = DeltaView()
    var wList:[DeltaView]!
    
    let active: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("A", for: .normal)
        //        btn.setTitleColor(.green, for: .normal)
        btn.addTarget(self, action: #selector(activeTapped), for: .touchUpInside)
        return btn
    }()
    
    let harmonic: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("H", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.addTarget(self, action: #selector(harmonicTapped), for: .touchUpInside)
        return btn
    }()
    
    //MARK: -

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        widget1.frame = CGRect(x:2, y:25, width:wSz, height:wSz)
        widget2.frame = CGRect(x:12 + wSz, y:25, width:wSz, height:wSz)
        wList = [ widget1,widget2]
        
        active.frame = CGRect(x:75, y:0, width:30, height:30)
        harmonic.frame = CGRect(x:120, y:0, width:30, height:30)
        
        addSubview(widget1)
        addSubview(widget2)
        addSubview(active)
        addSubview(harmonic)
    }

    func setActiveButtonColor() {
        let onoff = getActive(&sControl,Int32(index))
        active.setTitleColor(onoff == 1 ? .green : .lightGray, for:.normal)
    }
    
    @objc func activeTapped() {
        let onoff = 1 - getActive(&sControl,Int32(index))
        setActive(&sControl,Int32(index),onoff)
        setActiveButtonColor()
    }

    @objc func harmonicTapped() {
        harmonize(&sControl,Int32(index))
    }

    //MARK: -

    func initialize(_ nIndex:Int) {
        index = nIndex
        name = String(format:"Gear %d",nIndex+1)

        let i32 = Int32(nIndex)
        widget1.initializeFloats(radiusPointer(&sControl,i32), speedPointer(&sControl,i32), -100,100,10,"R,S")
        widget2.initializeFloats(rotateXPointer(&sControl,i32), rotateYPointer(&sControl,i32), -100,100,10,"X,Y")

        timer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target:self, selector: #selector(timerHandler), userInfo: nil, repeats:true)
    }
    
    @objc func timerHandler() {
        for w in wList { _ = w.update() }
        spirograph.update()
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(red:0.135, green:0.13, blue:0.13, alpha: 1).setFill()
        UIBezierPath(rect:rect).fill()
        
        drawText(5,5,.white,16,name)
        
        for w in wList { w.setNeedsDisplay() }
        setActiveButtonColor()
    }
}

// -------------------------------------------------------------------------

func drawText(_ x:CGFloat, _ y:CGFloat, _ color:UIColor, _ sz:CGFloat, _ str:String) {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.alignment = NSTextAlignment.left
    
    let font = UIFont.init(name: "Helvetica", size:sz)!
    
    let textFontAttributes = [
        NSAttributedStringKey.font: font,
        NSAttributedStringKey.foregroundColor: color,
        NSAttributedStringKey.paragraphStyle: paraStyle,
        ]
    
    str.draw(in: CGRect(x:x, y:y, width:800, height:100), withAttributes: textFontAttributes)
}
