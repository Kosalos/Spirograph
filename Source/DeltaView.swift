import UIKit
import simd

class DeltaView: UIView {
    var context : CGContext?
    var scenter:Float = 0
    var swidth:Float = 0
    var ident:Int = 0
    var active = true
    var fastEdit = true
    var highLightPoint = CGPoint()
    var valuePointerX:UnsafeMutableRawPointer! = nil
    var valuePointerY:UnsafeMutableRawPointer! = nil
    var deltaValue:Float = 0
    var name:String = "name"

    var mRange = float2(0,256)

    func initializeFloats(_ vx:UnsafeMutableRawPointer, _ vy:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        valuePointerX = vx
        valuePointerY = vy
        mRange.x = min
        mRange.y = max
        deltaValue = delta
        name = iname
        boundsChanged()

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        tap2.numberOfTapsRequired = 2
        addGestureRecognizer(tap2)

        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap3(_:)))
        tap3.numberOfTapsRequired = 3
        addGestureRecognizer(tap3)

        isUserInteractionEnabled = true
    }

    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        fastEdit = !fastEdit

        deltaX = 0
        deltaY = 0
        setNeedsDisplay()
    }

    @objc func handleTap3(_ sender: UITapGestureRecognizer) {
        if valuePointerX == nil || valuePointerY == nil { return }

        let value:Float = 0
        if let valuePointerX = valuePointerX { valuePointerX.storeBytes(of:value, as:Float.self) }
        if let valuePointerY = valuePointerY { valuePointerY.storeBytes(of:value, as:Float.self) }

        deltaX = 0
        deltaY = 0
        setNeedsDisplay()
    }

    func highlight(_ x:CGFloat, _ y:CGFloat) {
        highLightPoint.x = x
        highLightPoint.y = y
    }

    func setActive(_ v:Bool) {
        active = v
        setNeedsDisplay()
    }

    func percentX(_ percent:CGFloat) -> CGFloat { return CGFloat(bounds.size.width) * percent }

    func boundsChanged() {
        swidth = Float(bounds.width)
        scenter = swidth / 2
        setNeedsDisplay()
    }

    //MARK: ==================================

    override func draw(_ rect: CGRect) {
        context = UIGraphicsGetCurrentContext()

        if !active {
            let G:CGFloat = 0.13        // color Lead
            UIColor(red:G, green:G, blue:G, alpha: 1).set()
            UIBezierPath(rect:bounds).fill()
            return
        }

        let limColor = UIColor(red:0.25, green:0.25, blue:0.2, alpha: 1)
        let nrmColorFast = UIColor(red:0.25, green:0.2, blue:0.2, alpha: 1)
        let nrmColorSlow = UIColor(red:0.2, green:0.25, blue:0.2, alpha: 1)

        if fastEdit { nrmColorFast.set() } else { nrmColorSlow.set() }
        UIBezierPath(rect:bounds).fill()

        if isMinValue(0) {  // X coord
            limColor.set()
            var r = bounds
            r.size.width /= 2
            UIBezierPath(rect:r).fill()
        }
        else if isMaxValue(0) {
            limColor.set()
            var r = bounds
            r.origin.x += bounds.width/2
            r.size.width /= 2
            UIBezierPath(rect:r).fill()
        }

        if isMaxValue(1) {  // Y coord
            limColor.set()
            var r = bounds
            r.size.height /= 2
            UIBezierPath(rect:r).fill()
        }
        else if isMinValue(1) {
            limColor.set()
            var r = bounds
            r.origin.y += bounds.width/2
            r.size.height /= 2
            UIBezierPath(rect:r).fill()
        }

        // edge -------------------------------------------------
        let ctx = context!
        ctx.saveGState()
        let path = UIBezierPath(rect:bounds)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(2)
        ctx.addPath(path.cgPath)
        ctx.strokePath()
        ctx.restoreGState()

        UIColor.black.set()
        context?.setLineWidth(2)

        drawVLine(CGFloat(scenter),0,bounds.height)
        drawHLine(0,bounds.width,CGFloat(scenter))

        drawText(10,8,.lightGray,16,name)

//        // values ------------------------------------------
//        if valuePointerX != nil {
//            func formatted(_ v:Float) -> String { return String(format:"%6.4f",v) }
//            func formatted2(_ v:Float) -> String { return String(format:"%7.5f",v) }
//            func formatted3(_ v:Float) -> String { return String(format:"%d",Int(v)) }
//            func formatted4(_ v:Float) -> String { return String(format:"%5.2f",v) }
//
//            func valueColor(_ v:Float) -> UIColor {
//                var c = UIColor.gray
//                if v < 0 { c = UIColor.red } else if v > 0 { c = UIColor.green }
//                return c
//            }
//
//            let vx = percentX(0.60)
//            let xx:Float = valuePointerX.load(as: Float.self)
//            let yy:Float = valuePointerY.load(as: Float.self)
//
//            if self.tag == 1 { // iter
//                drawText(vx, 8,valueColor(xx),16, formatted3(xx))
//                drawText(vx,28,valueColor(yy),16, formatted3(yy))
//            }
//            else {
//                func coloredValue(_ v:Float, _ y:CGFloat) { drawText(vx,y,valueColor(v),16, formatted(v)) }
//
//                coloredValue(xx,8)
//                coloredValue(yy,28)
//            }
//        }

        // cursor -------------------------------------------------
        UIColor.black.set()
        context?.setLineWidth(2)

        let x = valueRatio(0) * bounds.width
        let y = (CGFloat(1) - valueRatio(1)) * bounds.height
        drawFilledCircle(CGPoint(x:x,y:y),15,UIColor.black.cgColor)

        // highlight --------------------------------------

        if highLightPoint.x != 0 {
            let den = CGFloat(mRange.y - mRange.x)
            if den != 0 {
                let vx:CGFloat = (highLightPoint.x - CGFloat(mRange.x)) / den
                let vy:CGFloat = (highLightPoint.y - CGFloat(mRange.x)) / den
                let x = CGFloat(vx) * bounds.width
                let y = (CGFloat(1) - vy) * bounds.height

                drawFilledCircle(CGPoint(x:x,y:y),4,UIColor.lightGray.cgColor)
            }
        }

    }

    func fClamp2(_ v:Float, _ range:float2) -> Float {
        if v < range.x { return range.x }
        if v > range.y { return range.y }
        return v
    }

    var deltaX:Float = 0
    var deltaY:Float = 0
    var touched = false

    //MARK: ==================================

    func getValue(_ who:Int) -> Float {
        switch who {
        case 0 :
            if valuePointerX == nil { return 0 }
            return valuePointerX.load(as: Float.self)
        default:
            if valuePointerY == nil { return 0 }
            return valuePointerY.load(as: Float.self)
        }
    }

    func isMinValue(_ who:Int) -> Bool {
        if valuePointerX == nil { return false }

        return getValue(who) == mRange.x
    }

    func isMaxValue(_ who:Int) -> Bool {
        if valuePointerX == nil { return false }

        return getValue(who) == mRange.y
    }

    func valueRatio(_ who:Int) -> CGFloat {
        let den = mRange.y - mRange.x
        if den == 0 { return CGFloat(0) }
        return CGFloat((getValue(who) - mRange.x) / den )
    }

    //MARK: ==================================

    func update() -> Bool {
        if valuePointerX == nil || valuePointerY == nil || !active || !touched { return false }

        let valueX = fClamp2(getValue(0) + deltaX * deltaValue, mRange)
        let valueY = fClamp2(getValue(1) + deltaY * deltaValue, mRange)

        if let valuePointerX = valuePointerX { valuePointerX.storeBytes(of:valueX, as:Float.self) }
        if let valuePointerY = valuePointerY { valuePointerY.storeBytes(of:valueY, as:Float.self) }

        setNeedsDisplay()
        return true
    }

    //MARK: ==================================

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !active { return }
        if valuePointerX == nil || valuePointerY == nil { return }

        for t in touches {
            let pt = t.location(in: self)

            deltaX = +(Float(pt.x) - scenter) / swidth / 10
            deltaY = -(Float(pt.y) - scenter) / swidth / 10

            if !fastEdit {
                deltaX /= 1000
                deltaY /= 1000
            }

            touched = true
            setNeedsDisplay()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { touchesBegan(touches, with:event) }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
    }

    func drawLine(_ p1:CGPoint, _ p2:CGPoint) {
        context?.beginPath()
        context?.move(to:p1)
        context?.addLine(to:p2)
        context?.strokePath()
    }

    func drawVLine(_ x:CGFloat, _ y1:CGFloat, _ y2:CGFloat) { drawLine(CGPoint(x:x,y:y1),CGPoint(x:x,y:y2)) }
    func drawHLine(_ x1:CGFloat, _ x2:CGFloat, _ y:CGFloat) { drawLine(CGPoint(x:x1, y:y),CGPoint(x: x2, y:y)) }

    func drawFilledCircle(_ center:CGPoint, _ diameter:CGFloat, _ color:CGColor) {
        context?.beginPath()
        context?.addEllipse(in: CGRect(x:CGFloat(center.x - diameter/2), y:CGFloat(center.y - diameter/2), width:CGFloat(diameter), height:CGFloat(diameter)))
        context?.setFillColor(color)
        context?.fillPath()
    }
}














