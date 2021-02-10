//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

extension Data : Value {

    public static var declaredDatatype: String {
        return Blob.declaredDatatype
    }

    public static func fromDatatypeValue(_ dataValue: Blob) -> Data {
        return Data(dataValue.bytes)
    }

    public var datatypeValue: Blob {
        return withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Blob in
            return Blob(bytes: pointer.baseAddress!, length: count)
        }
    }

}

extension Date : Value {

    public static var declaredDatatype: String {
        return String.declaredDatatype
    }

    public static func fromDatatypeValue(_ stringValue: String) -> Date? {
        if let date = DateFunctions.dateFormatter.date(from: stringValue) {
            return date
        }
        for formatter in DateFunctions.dateFormatters {
            if let date = formatter.date(from: stringValue) {
                return date
            }
        }
        return nil
    }

    public var datatypeValue: String {
        return DateFunctions.dateFormatter.string(from: self)
    }

}

///// A global date formatter used to serialize and deserialize `NSDate` objects.
///// If multiple date formats are used in an application’s database(s), use a
///// custom `Value` type per additional format.
//public var dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // "yyyy-MM-dd HH:mm:ssXXXXX"
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.timeZone = TimeZone(secondsFromGMT: 0) /* nil for system setting*/
//    return formatter
//}()
//
///// A global list of date formatter used to deserialize `NSDate`/`Date` objects
///// should the default `dateFormatter` fail to match.
///// Decoding stops at the first successful date formatter.
/////
//public var dateFormatters: [DateFormatter] = {
//
//    var formatters = [DateFormatter]()
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//    
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd HH:ss"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    // secondary decoding attempts
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSXXXXX"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    do {
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        formatter1.locale = Locale(identifier: "en_US_POSIX")
//        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
//        formatters.append(formatter1)
//    }
//
//    class unixDateformatter: DateFormatter {
//        override func string(from date: Date) -> String {
//            let double = date.timeIntervalSince1970
//            return "\(double)"
//        }
//        override func date(from string: String) -> Date? {
//            let seconds = Double(string)
//            return seconds == nil ? nil : Date.init(timeIntervalSince1970: seconds!)
//        }
//    }
//
//    formatters.append(unixDateformatter())
//
//    return formatters
//}()
