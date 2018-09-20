import Foundation

public class Observer<T> {
    typealias CallbackType = (T) -> Void
    
    var callback: CallbackType
    
    init(_ cb: @escaping CallbackType = { v in }) {
        callback = cb
    }
    
    var isEnabled = true
}

public class Observable<T> {
    
    typealias ObserverType = Observer<T>
    fileprivate typealias WeakObserverType = (owner: WeakObject, callback: ObserverType.CallbackType)

    fileprivate class Binding<T> {
        let observable: Any
        let observer: Any
        
        init(observable: Observable<T>, observer: Observer<T>) {
            self.observable = observable
            self.observer = observer
        }

        init(observable: ReadOnlyObservable<T>, observer: Observer<T>) {
            self.observable = observable
            self.observer = observer
        }
    }
    
    typealias EqualityCallback = ((T, T) -> Bool)
    
    // MARK: public properties
    
    var equality: EqualityCallback? = nil
    
    var value: T {
        didSet {
            filterWeakObervers()
            
            if !(equality?(value, oldValue) ?? false) {
                for cb in ( observers.array().filter { $0.isEnabled }.map { $0.callback } + weakObservers.map { $0.callback } ) {
                    cb(value)
                }
            }
        }
    }
    
    var readOnly: ReadOnlyObservable<T> {
        return ReadOnlyObservable<T>(impl: self)
    }
    
    // MARK: initialization
    
    init(_ value: T, equality: EqualityCallback? = nil) {
        self.value = value
        self.equality = equality
    }

    // MARK: methods
    func addObserver(callImmediately: Bool = false, callback: @escaping ObserverType.CallbackType) -> ObserverType {
        filterWeakObervers()
        
        let observer = ObserverType(callback)
        observers.insert(observer)
        if callImmediately {
            callback(value)
        }
        
        return observer
    }
    
    func addObserver(owner: AnyObject, callImmediately: Bool = false, callback: @escaping ObserverType.CallbackType) {
        filterWeakObervers()
        
        let observer = WeakObserverType(owner: WeakObject(owner), callback: callback)
        weakObservers.append(observer)
        if callImmediately {
            callback(value)
        }
    }

    func addObserver(_ observer: ObserverType, callImmediately: Bool = false) {
        filterWeakObervers()
        
        observers.insert(observer)
        if callImmediately {
            observer.callback(value)
        }
    }
    
    func observersCount() -> Int {
        return observers.array().count + weakObservers.count
    }

    // MARK: -
    
    func bind(to other: Observable<T>) {
        let observer = other.addObserver(callImmediately: true) { [weak self] value in
            self?.value = value
        }
        binding = Binding<T>(observable: other, observer: observer)
    }

    func bind(to other: ReadOnlyObservable<T>) {
        let observer = other.addObserver(callImmediately: true) { [weak self] value in
            self?.value = value
        }
        binding = Binding<T>(observable: other, observer: observer)
    }


    func unbind() {
        binding = nil
    }

    // MARK: -

    func map<U>(_ block: @escaping (T) -> U) -> ReadOnlyObservable<U> {
        return ObservableMap<U>(block(value), source: self, block: block).readOnly
    }

    func flatMap<U>(_ block: @escaping (T) -> U?) -> ReadOnlyObservable<U> {
        return ObservableFlatMap<U>(block(value)!, source: self, block: block).readOnly
    }

    // MARK: Private
    
    fileprivate let observers = WeakObjectCollection<Observer<T>>()
    fileprivate var weakObservers: [WeakObserverType] = []
    fileprivate var binding: Binding<T>?
    
    fileprivate func filterWeakObervers() {
        weakObservers = weakObservers.filter { observer in observer.owner.obj != nil }
    }

}

public class EqualityObservable<T: Equatable>: Observable<T> {
    init(_ value: T) {
        super.init(value, equality: { $0 == $1} )
    }
}

public class ReadOnlyObservable<T> {
    
    // MARK: - Public Nested Types
    
    typealias ObserverType = Observable<T>.ObserverType
    
    // MARK: - Public Properties
    
    var value: T { return impl.value }
    
    // MARK: - Constructors
    
    fileprivate init(impl: Observable<T>) {
        self.impl = impl
    }
    
    // MARK: - Public
    
    func addObserver(callImmediately: Bool = false, callback: @escaping ObserverType.CallbackType) -> ObserverType {
        return impl.addObserver(callImmediately: callImmediately, callback: callback)
    }
    
    func addObserver(owner: AnyObject, callImmediately: Bool = false, callback: @escaping ObserverType.CallbackType) {
        return impl.addObserver(owner: owner, callImmediately: callImmediately, callback: callback)
    }
    
    func addObserver(_ observer: ObserverType, callImmediately: Bool = false) {
        return impl.addObserver(observer, callImmediately: callImmediately)
    }
    
    // MARK: -
    
    func map<U>(_ block: @escaping (T) -> U) -> ReadOnlyObservable<U> {
        return impl.map(block)
    }

    func flatMap<U>(_ block: @escaping (T) -> U?) -> ReadOnlyObservable<U> {
        return impl.flatMap(block)
    }

    // MARK: - Private Properties
    
    fileprivate let impl: Observable<T>
    
}

fileprivate class ObservableMap<T>: Observable<T> {

    init<U>(_ value: T, source: Observable<U>, block: @escaping (U) -> T) {
        super.init(value)

        source.addObserver(owner: self) { [weak self] value in
            guard let slf = self else { return }
            slf.value = block(value)
        }
    }

}

fileprivate class ObservableFlatMap<T>: Observable<T> {

    init<U>(_ value: T, source: Observable<U>, block: @escaping (U) -> T?) {
        super.init(value)

        source.addObserver(owner: self) { [weak self] value in
            guard let slf = self else { return }
            if let newValue = block(value) {
                slf.value = newValue
            }
        }
    }
    
}
