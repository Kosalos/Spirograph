import UIKit
import MetalKit

var gDevice: MTLDevice!
var spirograph = Spirograph()
var sControl = SpirographControl()

class ViewController: UIViewController {
    var timer = Timer()

    @IBOutlet var mtkViewL: MTKView!
    @IBOutlet var mtkViewR: MTKView!
    var rendererL: Renderer!
    var rendererR: Renderer!

    @IBOutlet var infoButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var gControl1: GearControl!
    @IBOutlet var gControl2: GearControl!
    @IBOutlet var gControl3: GearControl!
    @IBOutlet var gControl4: GearControl!
    var gList:[GearControl]! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        gDevice = MTLCreateSystemDefaultDevice()
        mtkViewL.device = gDevice
        mtkViewR.device = gDevice

        guard let newRenderer = Renderer(metalKitView: mtkViewL, 0) else { fatalError("Renderer cannot be initialized") }
        rendererL = newRenderer
        rendererL.mtkView(mtkViewL, drawableSizeWillChange: mtkViewL.drawableSize)
        mtkViewL.delegate = rendererL

        guard let newRenderer2 = Renderer(metalKitView: mtkViewR, 1) else { fatalError("Renderer cannot be initialized") }
        rendererR = newRenderer2
        rendererR.mtkView(mtkViewR, drawableSizeWillChange: mtkViewR.drawableSize)
        mtkViewR.delegate = rendererR

        gList = [ gControl1,gControl2,gControl3,gControl4 ]
        for (n, g) in gList.enumerated() { g.initialize(n) }

        spirograph.reset()
        rotated()

        timer = Timer.scheduledTimer(timeInterval: 1.0/20.0, target:self, selector: #selector(timerHandler), userInfo: nil, repeats:true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override var prefersStatusBarHidden: Bool { return true }

    @IBAction func resetPressed(_ sender: UIButton) {
        spirograph.reset()
        for g in gList { g.setNeedsDisplay() }
    }

    //MARK: -

    @objc func rotated() {
        let wxs = view.bounds.width
        let wys = view.bounds.height

        var x = CGFloat()
        var y = CGFloat()

        func frame(_ fxs:CGFloat, _ fys:CGFloat, _ dx:CGFloat, _ dy:CGFloat) -> CGRect {
            let r = CGRect(x:x, y:y, width:fxs, height:fys)
            x += dx; y += dy
            return r
        }

        mtkViewL.frame = CGRect(x:0, y:0, width:wxs/2, height:wys-200)
        mtkViewR.frame = CGRect(x:wxs/2, y:0, width:wxs/2, height:wys-200)

        x = 0
        y = wys-190
        for g in gList { g.frame = frame(170,100,180,0) }
        infoButton.frame = frame(40,40,0,50)
        resetButton.frame = frame(80,40,0,0)

        let hk = mtkViewL.bounds
        arcBall.initialize(Float(hk.size.width),Float(hk.size.height))
    }

    //MARK: -

    @objc func timerHandler() {
        rotateImage(paceRotate.x,paceRotate.y)
    }

    //MARK: -

    var rotateCenter = CGPoint()
    var paceRotate = CGPoint()

    func rotateImage(_ x:CGFloat, _ y:CGFloat) {
        if rotateCenter.x == 0 {
            let hk = mtkViewL.bounds
            rotateCenter.x = hk.size.width/2
            rotateCenter.y = hk.size.height/2
        }

        arcBall.mouseDown(CGPoint(x: rotateCenter.x, y: rotateCenter.y))
        arcBall.mouseMove(CGPoint(x: rotateCenter.x + x, y: rotateCenter.y + y))
    }

    func parseTranslation(_ pt:CGPoint) {
        let scale:Float = 0.01
        translation.x = Float(pt.x) * scale
        translation.y = -Float(pt.y) * scale
    }

    func parseRotation(_ pt:CGPoint) {
        let scale:CGFloat = 0.51
        paceRotate.x = pt.x * scale
        paceRotate.y = pt.y * scale
    }

    var numberPanTouches:Int = 0

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let pt = sender.translation(in: self.view)
        let count = sender.numberOfTouches
        if count == 0 { numberPanTouches = 0 }  else if count > numberPanTouches { numberPanTouches = count }

        switch sender.numberOfTouches {
        case 1 : if numberPanTouches < 2 { parseRotation(pt) } // prevent rotation after releasing translation
        case 2 : parseTranslation(pt)
        default : break
        }
    }

    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        let min:Float = 1
        let max:Float = 1000
        translation.z *= Float(1 + (1 - sender.scale) / 10 )
        if translation.z < min { translation.z = min }
        if translation.z > max { translation.z = max }
    }

    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        paceRotate.x = 0
        paceRotate.y = 0
    }
}
