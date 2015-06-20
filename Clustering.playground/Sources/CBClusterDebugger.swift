import UIKit

public class CBClusterDebugger {
    private var view: UIView!
    public var debugView: UIView { return self.view }
    
    public init() {}
    
    public func drawInitial(size: CBSize) {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.view.backgroundColor = UIColor(white: 0.2, alpha: 1)
    }
    
    func drawGrid(cells: [CBCell]) {
        let colorStep: CGFloat = 1.0 / CGFloat(cells.count)
        
        var idx = 0
        for cell in cells {
            let cellView = UIView(frame: cell.region)
            cellView.backgroundColor = UIColor(white: CGFloat(idx) * colorStep, alpha: 1)
            debugView.addSubview(cellView)

            idx++
        }
    }
    
    public func drawSinglePoints(points: [CBPoint]) {
        for point in points {
            debugView.addSubview(createPointView(point, color: UIColor.redColor(), viewWidth: 10.0))
        }
    }
    
    public func drawCenterOfPointsInGrid(cells: [CBCell]) {
        for cell in cells {
            if cell.points.count > 0 {
                debugView.addSubview(createPointView(cell.center, color: UIColor.greenColor(), viewWidth: 6.0))
            }
        }
    }
    
    private func createPointView(point: CBPoint, color: UIColor, viewWidth: CGFloat) -> UIView {
        let rect = CGRect(x: point.x - viewWidth / 2.0, y: point.y - viewWidth / 2.0,
            width: viewWidth, height: viewWidth)
        let pointView = UIView(frame: rect)
        pointView.backgroundColor = color
        pointView.layer.cornerRadius = (viewWidth / 2.0)
        return pointView
    }
}
