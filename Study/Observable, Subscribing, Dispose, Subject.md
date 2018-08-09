# Observable, Subscribing, Dispose

#### 1. Observable 

- **An Observable (`ObservableType`) is equivalent to a Sequence.**

- `Observable`은 `Event<Element>`를 시간의 흐름에 따라 emiting(방출)합니다.

```swift
enum Event<Element>  {
    case next(Element)      // event를 계속해서 방출할 수 있습니다.
    case error(Swift.Error) // 완전 종료
    case completed          // 완전 종료
}

protocol ObserverType {
    func on(_ event: Event<Element>)
}
```

#### 2. Subscribing

- `Observable`은 sequence의 정의일 뿐, **subscribing 전에는 subscription closure를 수행하지않습니다.** 

```swift
example("Observable with no subscribers") {
    _ = Observable<String>.create { observerOfString -> Disposable in
        print("This will never be printed")
        observerOfString.on(.next("😬"))
        observerOfString.on(.completed)
        return Disposables.create()
    }
}
// (no result)
example("Observable with subscriber") {
  _ = Observable<String>.create { observerOfString in
            print("Observable created")
            observerOfString.on(.next("😉"))
            observerOfString.on(.completed)
            return Disposables.create()
        }
        .subscribe { event in
            print(event)
    }
}
//Observable created
//next(😉)
//completed
```

- `subscribe(_:) ` :  `Observable` 를 subscirbe하기 위한 method, **`Disposable`를 반환**합니다.

```swift
class Observable<Element> {
    func subscribe(_ observer: Observer<Element>) -> Disposable
}
```

#### 3. Dispose

- subscribe를 취소시키거나, event의 emiting을 중지시킵니다.
- `DisposeBag`이 deinit될 때, 담겨져 있던 Observable들이 같이 dispose됩니다.

```swift
//직접 dispose
subscription.dispose()
//위임
let disposeBage = DisposeBag()
.disposed(by: disposeBag)
```

# [Subject](http://reactivex.io/documentation/subject.html)

Observable이자, Observer입니다.

```swift
extension ObservableType {
    
    /**
     Add observer with `id` and print each emitted event.
     - parameter id: an identifier for the subscription.
     */
    func addObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
    
}
```

#### 1. PublishSubject

- **새로운** subscriber에게 `subscribe()` **이후 새로운 event**에 대해서만  broadcast합니다.

![http://reactivex.io/documentation/operators/images/S.PublishSubject.png](http://reactivex.io/documentation/operators/images/S.PublishSubject.png){: width="100%" height="100%"}

```swift
example("PublishSubject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.onNext("before subscribe")
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*
--- PublishSubject example ---
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
*/
```

#### 2. ReplaySubject

- **새로운** subscriber에게 `subscribe()` **이전 bufferSize만큼의 event**를 broadcast하고, **모든** subscriber에게  **새로운 event**를 broadcast합니다.

![http://reactivex.io/documentation/operators/images/S.ReplaySubject.png](http://reactivex.io/documentation/operators/images/S.ReplaySubject.png){: width="100%" height="100%"}

```swift
example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)
    
    subject.onNext("before subscribe")
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*
Subscription: 1 Event: next(before subscribe)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)

*/
```

#### 3. BehaviorSubject

- **새로운** subscriber에게 `subscribe()` **직전(혹은 최초의) event**를 broadcast하고, **모든** subscriber에게  **새로운 event**를 broadcast합니다.

![http://reactivex.io/documentation/operators/images/S.BehaviorSubject.png](http://reactivex.io/documentation/operators/images/S.BehaviorSubject.png){: width="100%" height="100%"}

```swift
example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorSubject(value: "🔴")
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
    
    subject.addObserver("3").disposed(by: disposeBag)
    subject.onNext("🍐")
    subject.onNext("🍊")
}
/*
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 3 Event: next(🅱️)
Subscription: 1 Event: next(🍐)
Subscription: 2 Event: next(🍐)
Subscription: 3 Event: next(🍐)
Subscription: 1 Event: next(🍊)
Subscription: 2 Event: next(🍊)
Subscription: 3 Event: next(🍊)
*/
```

>  PublishSubject, ReplaySubject, and BehaviorSubject는 dispose될 때 **자동으로 Completed event를 emit하지 않습니다.**

#### 4. Variable

- BehaviorSubject를 wrap한 것입니다.
-  **새로운** subscriber에게 `subscribe()` **직전(혹은 최초의) event**를 broadcast하고, **모든** subscriber에게  **새로운 event**를 broadcast합니다. 
- `value` state를 갖으며, 절대 **error를 emit하지 않습니다.**
- deinit 시 자동으로 **Completed event를 emit**합니다.

```swift
example("Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("🔴")
    
    variable.asObservable().addObserver("1").disposed(by: disposeBag)
    variable.value = "🐶"
    variable.value = "🐱"
    
    variable.asObservable().addObserver("2").disposed(by: disposeBag)
    variable.value = "🅰️"
    variable.value = "🅱️"
}
/*
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 1 Event: completed
Subscription: 2 Event: completed
*/
```

> 관련사이트
>
> [https://www.slideshare.net/sunhyouplee/functional-reactive-programming-with-rxswift-62123571](https://www.slideshare.net/sunhyouplee/functional-reactive-programming-with-rxswift-62123571)
>
> [https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md)
>
> [https://www.youtube.com/watch?v=WN6s3xWZ3tw&feature=youtu.be](https://www.youtube.com/watch?v=WN6s3xWZ3tw&feature=youtu.be)