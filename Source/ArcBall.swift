import Foundation
import simd
import UIKit

var arcBall = ArcBall()

extension float3x3 {
    static let identity: float3x3 = matrix_identity_float3x3

    init(quaternion q1: float4) {
        let n:Float = (q1.x * q1.x) + (q1.y * q1.y) + (q1.z * q1.z) + (q1.w * q1.w)
        let s:Float = (n > 0) ? (2 / n) : 0
        let xs:Float = q1.x * s
        let ys:Float = q1.y * s
        let zs:Float = q1.z * s
        let wx:Float = q1.w * xs
        let wy:Float = q1.w * ys
        let wz:Float = q1.w * zs
        let xx:Float = q1.x * xs
        let xy:Float = q1.x * ys
        let xz:Float = q1.x * zs
        let yy:Float = q1.y * ys
        let yz:Float = q1.y * zs
        let zz:Float = q1.z * ys

        let c0 = float3(1 - (yy + zz),xy + wz,xz - wy)
        let c1 = float3(xy - wz,1 - (xx + zz),yz + wx)
        let c2 = float3(xz + wy,yz - wx,1 - (xx + yy))

        var ans = float3x3()
        ans.columns = (c0,c1,c2)
        self = ans
    }
}

extension float4x4 {
    static let identity: float4x4 = matrix_identity_float4x4


}

extension float3 {
    var length: Float {
        return simd.length(self)
    }
}

class ArcBall {
    private(set) var transformMatrix = float4x4()
    private(set) var startPosition = float3x3()
    private(set) var endPosition = float3x3()
    private(set) var startVertex = float3()
    private(set) var endVertex = float3()
    private(set) var adjustWidth = Float()
    private(set) var adjustHeight = Float()
    private(set) var width = Float()
    private(set) var height = Float()

    func initialize(_ newWidth:Float, _ newHeight:Float) {
        width = newWidth
        height = newHeight
        transformMatrix = .identity
        startPosition = .identity
        endPosition = .identity
        transformMatrix = copyMatrixToQuaternion(transformMatrix,endPosition)
        adjustWidth  = 1 / ((newWidth  - 1) * 0.5)
        adjustHeight = 1 / ((newHeight - 1) * 0.5)
    }

    func copyMatrixToQuaternion(_ oldQuat:float4x4,_ m1:float3x3) -> float4x4 {
        var ans = oldQuat
        for i in 0 ..< 3 {
            ans[i].x = m1[i].x;
            ans[i].y = m1[i].y;
            ans[i].z = m1[i].z;
        }

        return ans
    }

    func mapToSphere(_ cgPt:CGPoint) -> float3 {
        var tempPt = float2(Float(cgPt.x),Float(cgPt.y))
        tempPt.x  = (tempPt.x * adjustWidth ) - 1
        tempPt.y  = -((tempPt.y * adjustHeight) - 1)

        let length:Float = (tempPt.x * tempPt.x) + (tempPt.y * tempPt.y)

        var ans = float3()

        if(length > 1) {
            let norm:Float = 1 / sqrtf(length)
            ans.x = tempPt.x * norm
            ans.y = tempPt.y * norm
            ans.x = 0
        }
        else {   // Else it's on the inside
            ans.x = tempPt.x
            ans.y = tempPt.y
            ans.z = sqrtf(1 - length)
        }

        return ans
    }

    func mouseDown(_ cgPt:CGPoint) {
        startVertex = mapToSphere(cgPt)
        startPosition = endPosition
        //Swift.print("ArcBall down = ",cgPt.x,cgPt.y)
    }

    let Epsilon = Float(0.00001)

    func mouseMove(_ cgPt:CGPoint) {
        endVertex = mapToSphere(cgPt)

        //Swift.print("ArcBall move = ",cgPt.x,cgPt.y)

        var Perp = cross(startVertex, endVertex)

        var newRot = float4()

        if Perp.length > Epsilon {
            newRot.x = Perp.x
            newRot.y = Perp.y
            newRot.z = Perp.z
            newRot.w = dot(startVertex, endVertex)
        }

        endPosition = float3x3(quaternion: newRot) * startPosition
        transformMatrix = copyMatrixToQuaternion(transformMatrix,endPosition)
    }
}

