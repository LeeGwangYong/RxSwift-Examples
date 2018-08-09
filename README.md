# RxSwift Examples

## [RxColorPicker](https://github.com/LeeGwangYong/RxSwift-Study/tree/master/RxColorPicker)

`combineLatest()`, `subscribe(onNext:)`, `bind(to:)`, `ControlEvent`

custom `Binder`

```swift
extension Reactive where Base: UIView {
    public var backgroundColor: Binder<UIColor> {
        return Binder(self.base) { view, bgColor in
            view.backgroundColor = bgColor
        }
    }
}

```

make observable using extension

```swift
extension Reactive where Base: ViewController {
    internal var tapEvent: Observable<Void> {
        return self.base.subject.asObservable()
    }
}
```

![2018-08-09 12_43_15](/Users/igwang-yong/Downloads/2018-08-09 12_43_15.gif){: width="60%" height="60%"}