import Foundation
import CoreGraphics

struct TSMCPoint {
    var x, y: CGFloat
}

struct TSMCSize {
    var width, height: CGFloat
}

struct TSMCRegion {
    var point: TSMCPoint
    var size: TSMCSize
}