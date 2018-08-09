# doOn vs subscribe

#### `do(onNext: , onError: , onCompleted: , onSubscribe: , onSubscribed: , onDispose: )` 

- Observable Sequence에서 특정 event가 발생할 때의 콜백입니다
- **data(element)를 변경시키지않고** event를 그대로 통과시킵니다.

#### `subscribe(_ :)` 

- `Observable`은 sequence의 정의일 뿐, **subscribing 전에는 subscription closure를 수행하지않습니다.**
- `Observable` 를 subscirbe하기 위한 method, **Disposable를 반환**합니다.

```swift
Observable.of(1,2,3,4,5).do(onNext: {
	print("do onNext : ", $0 * 10) // This has no effect on the actual subscription
	})
	.subscribe(onNext:{
		print("subscribe onNext : ", $0)
    })
/*
do onNext :  10
subscribe onNext :  1
do onNext :  20
subscribe onNext :  2
do onNext :  30
subscribe onNext :  3
do onNext :  40
subscribe onNext :  4
do onNext :  50
subscribe onNext :  5
*/
```