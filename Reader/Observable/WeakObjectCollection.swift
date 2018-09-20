import Foundation

public class WeakObject {
    public weak var obj: AnyObject?
    
    public init(_ obj: AnyObject) {
        self.obj = obj
    }
}

class WeakObjectCollection<T> {
    
    // MARK: Public methods
    
    func array() -> [T] {
        filter()
        return collection.map { x in x.obj as! T}
    }
    
    func insert(_ element: T) {
        filter()
        remove(element)
        collection.append(WeakObject(element as AnyObject))
    }
    
    func remove(_ element: T) {
        filter()
        collection = collection.filter { return !(($0.obj! as AnyObject) === (element as AnyObject)) }
    }
    
    func count() -> Int {
        filter()
        return collection.count
    }
    
    func clear() {
        collection = []
    }
    
    func contains(_ member: T) -> Bool {
        for obj in collection {
            if (obj.obj as AnyObject) === (member as AnyObject) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Private properties
    
    fileprivate var collection = [WeakObject]()
}

fileprivate extension WeakObjectCollection {
    
    // MARK: Private methods
    
    func filter() {
        collection = collection.filter { return $0.obj != nil }
    }
    
}
