//
//  Atomicable.swift
//  Atomicable_iOS
//
//  Created by André Campana on 07.11.20.
//  Copyright © 2020 Bell App Lab. All rights reserved.
//
//  Adapted from and inspired by: https://github.com/mattgallagher/CwlUtils
/*
 ISC License

 Copyright © 2017 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.

 Permission to use, copy, modify, and/or distribute this software for any
 purpose with or without fee is hereby granted, provided that the above
 copyright notice and this permission notice appear in all copies.

 THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
 IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#if os(Linux)
import Glibc
#else
import Darwin
#endif


public protocol Runner {
    func sync<R>(execute work: () throws -> R) rethrows -> R
    func trySync<R>(execute work: () throws -> R) rethrows -> R?
}


public protocol RawLock: Runner {
    associatedtype Primitive

    var primitive: Primitive { get set }

    func lock()
    func tryLock() -> Bool
    func unlock()
}

public extension RawLock {
    @inlinable
    func sync<R>(execute work: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try work()
    }

    @inlinable
    func trySync<R>(execute work: () throws -> R) rethrows -> R? {
        guard tryLock() else { return nil }
        defer { unlock() }
        return try work()
    }
}


#if os(Linux)
public final class PThreadMutex: RawLock {
    public init() {
        var attr = pthread_mutexattr_t()
        guard pthread_mutexattr_init(&attr) == 0 else {
            preconditionFailure()
        }
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        guard pthread_mutex_init(&primitive, &attr) == 0 else {
            preconditionFailure()
        }
        pthread_mutexattr_destroy(&attr)
    }

    deinit {
        pthread_mutex_destroy(&primitive)
    }

    // MARK: Raw Lock
    public typealias Primitive = pthread_mutex_t

    public var primitive = pthread_mutex_t()

    @inlinable
    public func lock() {
        pthread_mutex_lock(&primitive)
    }

    @inlinable
    public func tryLock() -> Bool {
        pthread_mutex_trylock(&primitive)
    }

    @inlinable
    public func unlock() {
        pthread_mutex_unlock(&primitive)
    }
}
#else
public final class UnfairLock: RawLock {
    public init() {}

    // MARK: Raw Lock
    public typealias Primitive = os_unfair_lock

    public var primitive = os_unfair_lock()

    @inlinable
    public func lock() {
        os_unfair_lock_lock(&primitive)
    }

    @inlinable
    public func tryLock() -> Bool {
        os_unfair_lock_trylock(&primitive)
    }

    @inlinable
    public func unlock() {
        os_unfair_lock_unlock(&primitive)
    }
}
#endif


@propertyWrapper
public struct Atomic<Value> {
    public let lock: Runner
    public var value: Value

    @inlinable
    public init(wrappedValue: Value, lock: Runner? = nil) {
        value = wrappedValue
        if let lock = lock {
            self.lock = lock
        } else {
            #if os(Linux)
            self.lock = PThreadMutex()
            #else
            self.lock = UnfairLock()
            #endif
        }
    }

    @inlinable
    public var wrappedValue: Value {
        get { lock.sync { value } }
        set { lock.sync { value = newValue } }
    }

    @inlinable
    public mutating func mutate(_ mutation: (inout Value) -> Void) {
        lock.sync {
            mutation(&value)
        }
    }

    public var projectedValue: Self { self }
}
