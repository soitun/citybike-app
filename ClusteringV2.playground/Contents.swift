//: Playground - noun: a place where people can play

import UIKit

let center = TSMCPoint(x: 100, y: 100)
let boundary = TSMCBoundingBox(center: center, halfDimension: 100)
let quadTree = TSMCQuadTree(boundary: boundary)

/// Add some points

//let points = 5
//let xs = randomNumbers(points, Int(boundary.center.x - boundary.halfDimension), Int(boundary.center.x + boundary.halfDimension))
//let ys = randomNumbers(points, Int(boundary.center.y - boundary.halfDimension), Int(boundary.center.y + boundary.halfDimension))
//
//for i in 0..<points {
//    quadTree.insert(TSMCPoint(x: CGFloat(xs[i]), y: CGFloat(ys[i])))
//}


let points: [TSMCPoint] = [
    TSMCPoint(x: 50, y: 50),
//    TSMCPoint(x: 80, y: 80),
//    TSMCPoint(x: 30, y: 110),
//    TSMCPoint(x: 150, y: 100),
    TSMCPoint(x: 40, y: 50),
    TSMCPoint(x: 20, y: 10),
    TSMCPoint(x: 30, y: 40),
//    TSMCPoint(x: 10, y: 70),
    TSMCPoint(x: 10, y: 50)
]

for point in points {
    quadTree.insert(point)
}

let queriedPoints = quadTree.queryRange(TSMCBoundingBox(center: TSMCPoint(x: 25, y: 25), halfDimension: 25))
print(queriedPoints.count)

/// Draw preview of quad tree
let preview = UIView(frame: CGRect(x: boundary.center.x - boundary.halfDimension, y: boundary.center.y - boundary.halfDimension, width: 2.0 * boundary.halfDimension, height: 2.0 * boundary.halfDimension))
preview.layer.borderWidth = 1.0
preview.layer.borderColor = UIColor.blueColor().CGColor
quadTree.drawInView(preview)

preview

