//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

struct DrawPoint {
    let x0, y0, x1, y1: CGFloat
    static let zero = DrawPoint(x0: 0, y0: 0, x1: 0, y1: 0)
}

class DrawView: UIView {
    let imageView = UIImageView()
    let disposeBag = DisposeBag()

    private var drawPoint: DrawPoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    init(drawPoint: Observable<DrawPoint>) {
        super.init(frame: .zero)
        backgroundColor = .white
        drawPoint
            .subscribe(onNext: { [unowned self] point in
                self.drawPoint = point
            })
            .disposed(by: disposeBag)

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(3)
        context?.move(to: CGPoint(x: drawPoint.x0, y: drawPoint.y0))
        context?.addLine(to: CGPoint(x: drawPoint.x1, y: drawPoint.y1))
        context?.strokePath()
        context?.flush()
        imageView.image?.draw(in: CGRect(x: 0,
                                         y: 0,
                                         width: frame.size.width,
                                         height: frame.size.height))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer()
        let sMouseDown = tapGesture.rx.event.map { $0.location(in: self.view) }
        let initial = DrawPoint.zero
        let sLines = sMouseDown.scan(initial) { last, point in
            return DrawPoint(x0: last.x1, y0: last.y1, x1: point.x, y1: point.y)
        }

        let drawView = DrawView(drawPoint: sLines)
        drawView.addGestureRecognizer(tapGesture)
        view = drawView
    }
}

PlaygroundPage.current.liveView = ViewController(nibName: nil, bundle: nil)

//: [Next](@next)
