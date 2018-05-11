import UIKit
import Metal
import simd

let sectionCount = Int(32)
let pointsPerSection = Int(50)

class Spirograph {
    let commandQueue: MTLCommandQueue
    var cBuffer:MTLBuffer! = nil
    var vBuffer:MTLBuffer! = nil
    var pipeLine:MTLComputePipelineState! = nil
    var numThreadgroups2 = MTLSize()
    var threadsPerGroup2 = MTLSize()
    
    init() {
        sControl.sectionCount = Int32(sectionCount)
        sControl.pointsPerSection = Int32(pointsPerSection)
        let numVertex = Int(sectionCount * pointsPerSection)

        commandQueue = gDevice.makeCommandQueue()!
        cBuffer = gDevice?.makeBuffer(length:MemoryLayout<SpirographControl>.stride, options:.storageModeShared)
        vBuffer = gDevice?.makeBuffer(length: numVertex * MemoryLayout<TVertex>.stride, options:.storageModeShared)
        
        reset()
    }
    
    //MARK: -

    func reset() {
        resetSpirograph(&sControl)
        update()
    }

    //MARK: -

    func update() {
        if pipeLine == nil {
            func buildPipeline(_ shaderFunction:String) -> MTLComputePipelineState {
                var result:MTLComputePipelineState!
                
                do {
                    let defaultLibrary = gDevice?.makeDefaultLibrary()
                    let prg = defaultLibrary?.makeFunction(name:shaderFunction)
                    result = try gDevice?.makeComputePipelineState(function: prg!)
                } catch { fatalError("Failed to setup " + shaderFunction) }
                
                return result
            }
            
            pipeLine = buildPipeline("calcSpirographShader")
            let threadExecutionWidth = pipeLine.threadExecutionWidth
            let ntg = Int(ceil(Float(sControl.sectionCount)/Float(threadExecutionWidth)))
            threadsPerGroup2 = MTLSize(width:threadExecutionWidth, height:1, depth:1)
            numThreadgroups2 = MTLSize(width:ntg, height:1, depth:1)
        }

        cBuffer?.contents().copyMemory(from:&sControl, byteCount:MemoryLayout<SpirographControl>.stride)

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!

        commandEncoder.setComputePipelineState(pipeLine)
        commandEncoder.setBuffer(vBuffer, offset:0, index:0)
        commandEncoder.setBuffer(cBuffer, offset:0, index:1)
        commandEncoder.dispatchThreadgroups(numThreadgroups2, threadsPerThreadgroup:threadsPerGroup2)
        commandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        updateRotationAngles(&sControl)
    }

    //MARK: -

    func render(_ renderEncoder:MTLRenderCommandEncoder) {
        if vBuffer != nil {
            renderEncoder.setVertexBuffer(vBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: Int(sControl.sectionCount * sControl.pointsPerSection))
        }
    }
}

