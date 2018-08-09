//
//  ViewController.swift
//  RxColorPicker
//
//  Created by 이광용 on 2018. 8. 8..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//https://academy.realm.io/kr/posts/how-to-use-rxswift-with-simple-examples-ios-techtalk/

class ViewController: UIViewController {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    let subject = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        rxInit()
    }
    
    func rxInit() {
//--------Slider Color Observable--------
//        colorObservalbe을 combineLatest operator를 이용하여 Observable<UIColor>로 만들어주었습니다.
//        Observable이 되었으니 subscribe 또는 binding이 가능합니다.
        let colorObservable = Observable.combineLatest(self.redSlider.rx.value,
                                                       self.greenSlider.rx.value,
                                                       self.blueSlider.rx.value) { (red, green, blue) -> UIColor in
                                                        UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        }
//        방법 1. subscribe
//        colorObservable을 subscribe하여, event가 emit될 때마다 나오는 UIColor를 직접 self.colorView.backgroundColor에 할당해줍니다.
        /*
        colorObservable.subscribe(onNext: { [weak self] (color) in
            self?.colorView.backgroundColor = color
        }).disposed(by: disposeBag)
        */
//        방법 2. bind
//        bind(to:)를 이용하여 observable을 다른 속성(Subject)에 바인딩할 수 있습니다.
//        bind의 Reciever는 ObserverType이어야합니다.
//        하지만, UIView.backgroundColor는 ObservableType가 아니기 때문에, extension을 이용하여 ObserverType으로 만들어줍니다.
        colorObservable.bind(to: colorView.rx.backgroundColor).disposed(by: disposeBag)
        
//--------Button Tap ControlEvent--------
//        button.rx.tap은 ControlEvent의 일종으로, ControlEvent는 UI 요소의 event를 listen하기 위해 됩니다. (Trait for Observable/ObservableType)
//        ControlEvent는 절대 오류가 발생하지 않으며, 최초값을 보내지않습니다. 또한 MainScheduler.instance에서 이벤트를 전달합니다.
//        방법 1. subscribe + onNext
//        button.rx.tap을 subscribe하여, 미리 만들어준 PublishSubject에 onNext() method를 이용하여 event를 emit합니다.
        /*
        self.button.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.subject.onNext(())
        }).disposed(by: self.disposeBag)
         */

//        방법 2. bind
//        PublishSubject는 Subject이고, Subject는 Observer이자 Observable이므로, bind의 reciever가 될 수 있습니다.
//        producer를 button.rx.tap으로, reciever를 subject로 하여 binding해줍니다.
        self.button.rx.tap.bind(to: subject).disposed(by: disposeBag)
        
//        위의 subscribe + onNext 혹은 bind를 이용하여, subject에서 event를 emit할 수 있습니다.
//        subject는 Observer이자 Observable이므로, subscribe 가능합니다.
//        방법 1. subscribe
        /*
        subject.subscribe(onNext: { _ in
            print("Tapped")
        }).disposed(by: disposeBag)
         */
        
//         방법 2. extension
//         MVVM에서 사용하기 좋은 방식입니다.
//         해당 ViewController를 Base로 하는 Observable을 만들어, 다른 ViewController에서도 쉽게 사용할 수 있게합니다.
//         vc.rx.tapEvent.subscribe...
        self.rx.tapEvent.subscribe(onNext: { _ in
            print("Tapped")
        }).disposed(by: disposeBag)
        
    }
}

extension Reactive where Base: UIView {
//--------Slider Color Observable--------
//    방법 2. bind
//    bind(to:)를 이용하여 observable을 다른 속성(Subject)에 바인딩할 수 있습니다.
//    bind의 Reciever는 ObserverType이어야합니다.
//    하지만, UIView.backgroundColor는 ObservableType가 아니기 때문에, extension을 이용하여 ObserverType으로 만들어줍니다.
    public var backgroundColor: Binder<UIColor> {
        return Binder(self.base) { view, bgColor in
            view.backgroundColor = bgColor
        }
    }
}

extension Reactive where Base: ViewController {
//--------Button Tap ControlEvent--------
//    방법 2. extension
//    MVVM에서 사용하기 좋은 방식입니다.
//    해당 ViewController를 Base로 하는 Observable을 만들어, 다른 ViewController에서도 쉽게 사용할 수 있게합니다.
//    vc.rx.tapEvent.subscribe...
    internal var tapEvent: Observable<Void> {
        return self.base.subject.asObservable()
    }
}
