//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

/// Set region of points
let region = CBRegion(x: 0, y: 0, width: 400, height: 400)
let cellSize = CBSize(width: 80, height: 80)

/// Generate Xs and Ys for points
let numberOfPoints = 50
let randomXs = randomNumbers(numberOfPoints, Int(region.origin.x), Int(region.origin.x + region.size.width))
let randomYs = randomNumbers(numberOfPoints, Int(region.origin.y), Int(region.origin.y + region.size.height))

/// Generate points
var points = [CBPoint]()
for i in 0..<numberOfPoints {
    points.append(CBPoint(x: randomXs[i], y: randomYs[i]))
}

/// Create clusterer
let clusterer = CBClusterer()

measure() {
    clusterer.calculate(points, region: region, cellSize: cellSize)
}

clusterer.debugger.debugView


