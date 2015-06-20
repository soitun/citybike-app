import Foundation
import CoreGraphics

public typealias CBPoint = CGPoint
public typealias CBSize = CGSize
public typealias CBRegion = CGRect

public class CBCell {
    let region: CBRegion
    var points = [CBPoint]()
    var center = CBPoint()
    
    init(region: CBRegion) {
        self.region = region
    }
}

public class CBClusterer {
    public var debugger = CBClusterDebugger()
    
    public init() {}
    
    public func calculate(points: [CBPoint], region: CBRegion, cellSize: CBSize) {
        debugger = CBClusterDebugger()
        debugger.drawInitial(region.size)
        
        let cells = generateGrid(cellSize, region: region)
        debugger.drawGrid(cells)
        debugger.drawSinglePoints(points)

        groupPoints(points, cells: cells)
        calculateCenterOfPoints(cells)
        debugger.drawCenterOfPointsInGrid(cells)
    }
    
    private func generateGrid(cellSize: CBSize, region: CBRegion) -> [CBCell] {
        // Calculate number of cells in each dimension
        let horizontalCells = Int(ceil(region.width / cellSize.width))
        let verticalCells = Int((region.height / cellSize.height))
        
        var cells = [CBCell]()
        
        for i in 0..<horizontalCells {
            for j in 0..<verticalCells {
                // Calculate region for cell
                let x = region.origin.x + (CGFloat(i) * cellSize.width)
                let y = region.origin.y + (CGFloat(j) * cellSize.height)
                let cellRegion = CBRegion(x: x, y: y, width: cellSize.width, height: cellSize.height)
                
                cells.append(CBCell(region: cellRegion))
            }
        }
        
        
        return cells
    }
    
    private func groupPoints(points: [CBPoint], cells: [CBCell]) {
        println("A")
        for point in points {
            for cell in cells {
                if CGRectContainsPoint(cell.region, point) {
                    cell.points.append(point)
                    break
                }
            }
        }
    }
    
    private func calculateCenterOfPoints(cells: [CBCell]) {
        for cell in cells {
            if cell.points.count == 0 { continue }
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            for point in cell.points {
                x += point.x
                y += point.y
            }
            
            let count = CGFloat(cell.points.count)
            x /= count
            y /= count
            
            cell.center = CBPoint(x: x, y: y)
        }
    }
}