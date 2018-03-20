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
    let touchesBegan = PublishRelay<CGPoint>()
    let touchesEnded = PublishRelay<CGPoint>()

    var crossPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    var drawPoint: DrawPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        let sMouseDown = touchesBegan.asObservable()
        let sMouseUp = touchesEnded.asObservable()
        sMouseUp.withLatestFrom(sMouseDown) { up, down in
                return DrawPoint(x0: down.x, y0: down.y, x1: up.x, y1: up.y)
            }
            .subscribe(onNext: { drawPoint in
                self.drawPoint = drawPoint
            })
            .disposed(by: disposeBag)
        Observable.merge(sMouseDown, sMouseUp)
            .subscribe(onNext: { point in
                self.crossPoint = point
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(1)

        if let p = crossPoint {
            context?.move(to: CGPoint(x: p.x-4, y: p.y))
            context?.addLine(to: CGPoint(x: p.x+4, y: p.y))
            context?.move(to: CGPoint(x: p.x, y: p.y-4))
            context?.addLine(to: CGPoint(x: p.x, y: p.y+4))
            context?.strokePath()
            crossPoint = nil
        }

        if let l = drawPoint {
            context?.move(to: CGPoint(x: l.x0, y: l.y0))
            context?.addLine(to: CGPoint(x: l.x1, y: l.y1))
            context?.strokePath()
            drawPoint = nil
        }

        context?.flush()
        imageView.image?.draw(in: CGRect(x: 0,
                                         y: 0,
                                         width: frame.size.width,
                                         height: frame.size.height))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let point = touches.first?.location(in: self) {
            touchesBegan.accept(point)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let point = touches.first?.location(in: self) {
            touchesEnded.accept(point)
        }
    }
}

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view = DrawView()
    }
}

PlaygroundPage.current.liveView = ViewController(nibName: nil, bundle: nil)

//: [Next](@next)
