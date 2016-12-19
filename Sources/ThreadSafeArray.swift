//
//  ThreadSafeArray.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/19.
//
//

import PerfectThread

internal class ThreadSafeArray<T:Equatable> {
    typealias ArrayType = Array<T>
    private var elements = ArrayType()
    
    private let rwLock = Threading.RWLock()
    
    public func append(_ element: T) {
        rwLock.doWithWriteLock {
            self.elements.append(element)
        }
    }
    
//    public func append<T>(contentsOf newElements: Collection) {
//        rwLock.doWithWriteLock {
//            self.elements.append(contentsOf: newElements)
//        }
//    }
    
//    public mutating func append<C : Collection where C.Iterator.Element == Element>(contentsOf newElements: C)
    
    public func remove(_ element:T) {
        rwLock.doWithWriteLock {
            let index = self.elements.index{ $0 == element }
            guard let i = index else { return }
            self.elements.remove(at: i)
        }
    }
    
    public func removeFirst() {
        rwLock.doWithWriteLock {
            self.elements.remove(at: 0)
        }
    }

    
    
    public var count: Int {
        var count = 0
        rwLock.readLock()
        count = elements.count
        rwLock.unlock()
        return count
    }
    
    public var first:T? {
        var element: T?
        rwLock.readLock()
        element = elements.first
        rwLock.unlock()
        return element
    }
    
    public subscript(index: Int) -> T {
        set {
            rwLock.doWithWriteLock {
                self.elements[index] = newValue
            }
        }
        get {
            var element: T!
            rwLock.readLock()
            element = elements[index]
            rwLock.unlock()
            return element
        }
    }
}
