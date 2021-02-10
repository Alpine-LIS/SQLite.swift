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

/// All five date and time functions take a time string as an argument.
/// The time string is followed by zero or more modifiers.
/// The strftime() function also takes a format string as its first argument.
///
/// https://www.sqlite.org/lang_datefunc.html
public class DateFunctions {
    /// The date() function returns the date in this format: YYYY-MM-DD.
    public static func date(_ timestring: String, _ modifiers: String...) -> Expression<Date?> {
        return timefunction("date", timestring: timestring, modifiers: modifiers)
    }

    /// The time() function returns the time as HH:MM:SS.
    public static func time(_ timestring: String, _ modifiers: String...) -> Expression<Date?> {
        return timefunction("time", timestring: timestring, modifiers: modifiers)
    }

    /// The datetime() function returns "YYYY-MM-DD HH:MM:SS".
    public static func datetime(_ timestring: String, _ modifiers: String...) -> Expression<Date?> {
        return timefunction("datetime", timestring: timestring, modifiers: modifiers)
    }

    /// The julianday() function returns the Julian day -
    /// the number of days since noon in Greenwich on November 24, 4714 B.C.
    public static func julianday(_ timestring: String, _ modifiers: String...) -> Expression<Date?> {
        return timefunction("julianday", timestring: timestring, modifiers: modifiers)
    }

    ///  The strftime() routine returns the date formatted according to the format string specified as the first argument.
    public static func strftime(_ format: String, _ timestring: String, _ modifiers: String...) -> Expression<Date?> {
        if !modifiers.isEmpty {
            let templates = [String](repeating: "?", count: modifiers.count).joined(separator: ", ")
            return Expression("strftime(?, ?, \(templates))", [format, timestring] + modifiers)
        }
        return Expression("strftime(?, ?)", [format, timestring])
    }

    private static func timefunction(_ name: String, timestring: String, modifiers: [String]) -> Expression<Date?> {
        if !modifiers.isEmpty {
            let templates = [String](repeating: "?", count: modifiers.count).joined(separator: ", ")
            return Expression("\(name)(?, \(templates))", [timestring] + modifiers)
        }
        return Expression("\(name)(?)", [timestring])
    }
}

extension Date {
    public var date: Expression<Date?> {
        return DateFunctions.date(DateFunctions.dateFormatter.string(from: self))
    }

    public var time: Expression<Date?> {
        return DateFunctions.time(DateFunctions.dateFormatter.string(from: self))
    }

    public var datetime: Expression<Date?> {
        return DateFunctions.datetime(DateFunctions.dateFormatter.string(from: self))
    }

    public var julianday: Expression<Date?> {
        return DateFunctions.julianday(DateFunctions.dateFormatter.string(from: self))
    }
}

extension Expression where UnderlyingType == Date {
    public var date: Expression<Date> {
        return Expression<Date>("date(\(template))", bindings)
    }

    public var time: Expression<Date> {
        return Expression<Date>("time(\(template))", bindings)
    }

    public var datetime: Expression<Date> {
        return Expression<Date>("datetime(\(template))", bindings)
    }

    public var julianday: Expression<Date> {
        return Expression<Date>("julianday(\(template))", bindings)
    }
}

extension DateFunctions {

    /// A global date formatter used to serialize and deserialize `NSDate` objects.
    /// If multiple date formats are used in an application’s database(s), use a
    /// custom `Value` type per additional format.
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // "yyyy-MM-dd HH:mm:ssXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) /* nil for system setting*/
        return formatter
    }()

    /// A global list of date formatter used to deserialize `NSDate`/`Date` objects
    /// should the default `dateFormatter` fail to match.
    /// Decoding stops at the first successful date formatter.
    ///
    public static var dateFormatters: [DateFormatter] = {

        var formatters = [DateFormatter]()

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:ss"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        // secondary decoding attempts
        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSXXXXX"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }


        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        do {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.timeZone = TimeZone(secondsFromGMT: 0)
            formatters.append(formatter1)
        }

        class unixDateformatter: DateFormatter {
            override func string(from date: Date) -> String {
                let double = date.timeIntervalSince1970
                return "\(double)"
            }
            override func date(from string: String) -> Date? {
                let seconds = Double(string)
                return seconds == nil ? nil : Date.init(timeIntervalSince1970: seconds!)
            }
        }

        formatters.append(unixDateformatter())

        return formatters
    }()
}
