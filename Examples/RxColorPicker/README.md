# RxColorPicker

- #### `combineLatest()`

```swift
Observable.combineLatest(self.redSlider.rx.value,
	self.greenSlider.rx.value,
	self.blueSlider.rx.value) { (red, green, blue) -> UIColor in
	UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
}
```

- ####  `subscribe(onNext:)`

```swift
colorObservable.subscribe(onNext: { [weak self] (color) in
	self?.colorView.backgroundColor = color
}).disposed(by: disposeBag)
```

- ####  `bind(to:)`

```swift
colorObservable.bind(to: colorView.rx.backgroundColor).disposed(by: disposeBag)
```

- ####  `ControlEvent`

  - ControlEvent는 UI 요소의 event를 listen하기 위해 됩니다. (Trait for Observable/ObservableType)
  - ControlEvent는 절대 오류가 발생하지 않으며, 최초값을 보내지않습니다. 또한 MainScheduler.instance에서 이벤트를 전달합니다.

- #### custom `Binder`

```swift
extension Reactive where Base: UIView {
    public var backgroundColor: Binder<UIColor> {
        return Binder(self.base) { view, bgColor in
            view.backgroundColor = bgColor
        }
    }
}

```

- #### make observable using extension


```swift
extension Reactive where Base: ViewController {
    internal var tapEvent: Observable<Void> {
        return self.base.subject.asObservable()
    }
}
```

![2018-08-09 12_43_15](https://ws2.sinaimg.cn/large/0069RVTdgy1fu3b5vatopg30ok1784qp.gif)