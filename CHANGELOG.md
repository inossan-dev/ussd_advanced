## 3.0.0

* Require Dart 3.12 and adopt the Flutter platform interface.
* Split dialing, multi-session replies, permissions, and USSD parsing behind replaceable contracts.
* `onEnd` returns a shared `Stream` instead of a new `StreamController`.
* `requestPermissions` returns a `Future` and no longer hides platform failures.
* Complete the Android cancel callback so `cancelSession` finishes.

## 2.0.0

* Open Accessibility settings if ussd service is turned off
* Use StreamController over Stream when listening to on End

## 1.1.0

* Exposed onEnd StreamController


## 1.0.0

* Added multi-session ussd call
* Changed package name

## 0.1.1

* Updated readme

## 0.0.1

* initial release.
