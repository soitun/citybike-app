import Foundation
import CoreGraphics
import UIKit

protocol Drawable {
    func drawInView(view: UIView)
}

protocol ViewRepresentation {
    func viewRepresentation(color: UIColor, width: CGFloat) -> UIView
}

public struct TSMCPoint: ViewRepresentation {
    public var x, y: CGFloat
    
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    func viewRepresentation(color: UIColor, width: CGFloat) -> UIView {
        let rect = CGRect(x: x - width / 2.0, y: y - width / 2.0, width: width, height: width)
        let view = UIView(frame: rect)
        view.backgroundColor = color
        view.layer.cornerRadius = width / 2.0
        
        return view
    }
}

public struct TSMCBoundingBox {
    public let center: TSMCPoint
    public let halfDimension: CGFloat
    
    public init(center: TSMCPoint, halfDimension: CGFloat) {
        self.center = center
        self.halfDimension = halfDimension
    }
    
    func containsPoint(p: TSMCPoint) -> Bool {
        return (p.x >= x0) && (p.x <= xf) && (p.y >= y0) && (p.y <= yf)
    }
    
    func intersectsBox(b: TSMCBoundingBox) -> Bool {
        return containsPoint(b.center)
    }
    
    private var x0: CGFloat { return center.x - halfDimension }
    private var xf: CGFloat { return center.x + halfDimension }
    private var y0: CGFloat { return center.y - halfDimension }
    private var yf: CGFloat { return center.y + halfDimension }
}

public class TSMCQuadTree: Drawable {
    private let TSMCNodeCapacity = 4
    
    private let boundary: TSMCBoundingBox
    private var divided = false
    
    private var northWest: TSMCQuadTree?
    private var northEast: TSMCQuadTree?
    private var southWest: TSMCQuadTree?
    private var southEast: TSMCQuadTree?
    
    private var points = [TSMCPoint]()
    
    public init(boundary: TSMCBoundingBox) {
        self.boundary = boundary
    }
    
    public func insert(point: TSMCPoint) -> Bool {
        /// Is point in boundary?
        if boundary.containsPoint(point) == false { return false }
        
        /// Add point if there is a space
        if points.count < TSMCNodeCapacity {
            points.append(point)
            return true
        }
        
        /// Otherwise add point to whichever node will accept it
        if divided == false {
            divided = true
            subdivide()
        }
        
        if northWest!.insert(point) { return true }
        if northEast!.insert(point) { return true }
        if southWest!.insert(point) { return true }
        if southEast!.insert(point) { return true }
        
        return false
    }
    
    private func subdivide() {
        let center = boundary.center
        let quadDimension = boundary.halfDimension / 2.0
        
        let northWestCenter = TSMCPoint(x: center.x - quadDimension, y: center.y - quadDimension)
        northWest = TSMCQuadTree(boundary: TSMCBoundingBox(center: northWestCenter, halfDimension: quadDimension))
        
        let northEastCenter = TSMCPoint(x: center.x + quadDimension, y: center.y - quadDimension)
        northEast = TSMCQuadTree(boundary: TSMCBoundingBox(center: northEastCenter, halfDimension: quadDimension))
        
        let southWestCenter = TSMCPoint(x: center.x - quadDimension, y: center.y + quadDimension)
        southWest = TSMCQuadTree(boundary: TSMCBoundingBox(center: southWestCenter, halfDimension: quadDimension))
        
        let southEastCenter = TSMCPoint(x: center.x + quadDimension, y: center.y + quadDimension)
        southEast = TSMCQuadTree(boundary: TSMCBoundingBox(center: southEastCenter, halfDimension: quadDimension))
    }
    
    public func queryRange(range: TSMCBoundingBox) -> [TSMCPoint] {
        var pointsInRange = [TSMCPoint]()
        
        /// if range is not in boundary
        if boundary.intersectsBox(range) == false { return pointsInRange }
        
        for point in points {
            if range.containsPoint(point) {
                pointsInRange.append(point)
            }
        }
        
        if divided {
            pointsInRange += northWest!.queryRange(range)
            pointsInRange += northEast!.queryRange(range)
            pointsInRange += southWest!.queryRange(range)
            pointsInRange += southEast!.queryRange(range)
        }
        
        return pointsInRange
    }
    
    public func drawInView(view: UIView) {
        let rect = CGRect(x: boundary.x0, y: boundary.y0, width: 2.0 * boundary.halfDimension, height: 2.0 * boundary.halfDimension)
        let quadTreeView = UIView(frame: rect)
        quadTreeView.layer.borderWidth = 1.0
        quadTreeView.layer.borderColor = UIColor.blackColor().CGColor
        
        view.addSubview(quadTreeView)
        
        for point in points {
            view.addSubview(point.viewRepresentation(UIColor.redColor(), width: 10.0))
        }
        
        northWest?.drawInView(view)
        northEast?.drawInView(view)
        southWest?.drawInView(view)
        southEast?.drawInView(view)
    }
}
