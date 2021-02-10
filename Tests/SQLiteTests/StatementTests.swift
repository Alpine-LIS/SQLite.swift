import XCTest
import SQLite

class StatementTests : SQLiteTestCase {
    override func setUp() {
        super.setUp()
        CreateUsersTable()
    }

    func test_cursor_to_blob() {
        try! InsertUsers("alice")
        let statement = try! db.prepare("SELECT email FROM users")
        XCTAssert(try! statement.step())
        let blob = statement.row[0] as Blob
        XCTAssertEqual("alice@example.com", String(bytes: blob.bytes, encoding: .utf8)!)
    }

    func test_zero_sized_blob_returns_null() {
        let blobs = Table("blobs")
        let blobColumn = Expression<Blob>("blob_column")
        try! db.run(blobs.create { $0.column(blobColumn) })
        try! db.run(blobs.insert(blobColumn <- Blob(bytes: [])))
        let blobValue = try! db.scalar(blobs.select(blobColumn).limit(1, offset: 0))
        XCTAssertEqual([], blobValue.bytes)
    }


    func test_codable_string_statement1() throws {

        let table = try buildCodableTable(db)

        let value1 = TestCodableRowid.init(ROWID: nil, int: 5, intOptional: 101, string: "6", stringOptional: "6 Opt", bool: true, boolOptional: true, float: 7, floatOptional: -1.1, double: 8, doubleOptional: nil, date: Date.init(timeIntervalSince1970: 16.0625), dateOptional: nil)
        let value2 = TestCodableRowid.init(ROWID: 1100, int: 51, intOptional: 55, string: "6", stringOptional: "6 Opt", bool: false, boolOptional: false, float: 7, floatOptional: -1.1, double: 8, doubleOptional: 1.0/7.0, date: Date.init(timeIntervalSince1970: 16.0625), dateOptional: nil)


        try db.run(table.insert(value1))
        try db.run(table.insert(value2))
        try db.run("INSERT INTO codable (int,string,bool,float,double,date,doubleOptional) VALUES(5,'6',1,7.0,8.0,'1970-01-01T00:00:16.063','7');")
        try db.run("INSERT INTO codable (int,string,string_optional,bool,float,double,date,doubleOptional) VALUES(5,99,NULL,1,7.0,8.0,'1970-01-01T00:00:16.063','');")
        try db.run("INSERT INTO codable VALUES('-554','','string A','','0','','7.0','','8.0','','1970-01-01T00:00:16.063','');")

        do {
            let query = "SELECT * FROM [codable] LIMIT 2"
            let rows = try db.prepareRowIterator(query)
            let values: [TestCodableRowid] = try rows.map({ try $0.decode() })
            XCTAssertEqual(values.count, 2)
            XCTAssertEqual(values[0].int, 5)
            XCTAssertEqual(values[0].intOptional, 101)
            XCTAssertEqual(values[0].string, "6")
            XCTAssertEqual(values[0].stringOptional, "6 Opt")
            XCTAssertEqual(values[0].bool, true)
            XCTAssertEqual(values[0].boolOptional, true)
            XCTAssertEqual(values[0].float, 7)
            XCTAssertEqual(values[0].floatOptional, -1.1)
            XCTAssertEqual(values[0].double, 8)
            XCTAssertEqual(values[0].dateOptional, nil)
            XCTAssertEqual(values[0].date, Date.init(timeIntervalSince1970: 16.063)) // rounded to milliseconds
            XCTAssertEqual(values[0].doubleOptional, nil)
            XCTAssertEqual(values[1].doubleOptional, 1.0/7.0)
            XCTAssertEqual(values[0].ROWID, nil)
            XCTAssertEqual(values[1].ROWID, nil)
        }

        do {
            let value1 = TestCodableRowid.init(ROWID: 1101, int: 5101, intOptional: 5501, string: "was 1101", stringOptional: "601 Opt", bool: false, boolOptional: false, float: 7, floatOptional: -1.1, double: 8, doubleOptional: 1.0/7.0, date: Date.init(timeIntervalSince1970: 16.0625), dateOptional: nil)
            do {
                try db.run(table.insert(value1))
                XCTFail("Should throw UNIQUE constraint failed: codable.rowid (code: 19)")
            } catch {
                // should throw
            }
            try db.run(table.insert(or: .replace, value1))
            let query = "SELECT *,rowid FROM [codable]"
            let rows = try db.prepareRowIterator(query)
            let values1: [TestCodableRowid] = try rows.map({ try $0.decode() })
            XCTAssertEqual(values1.count, 5)
            XCTAssertEqual(values1[2].int, 5101)

            let query2 = "SELECT rowid,string,int,float,bool,date,double FROM [codable]"
            let rows2 = try db.prepareRowIterator(query2)
            let values2: [TestCodableRowid] = try rows2.map({
                try $0.decode()
            })
            XCTAssertEqual(values2.count, 5)

            for ii in 0..<5 {
                XCTAssertEqual(values2[ii].ROWID, values1[ii].ROWID)
                XCTAssertEqual(values2[ii].int, values1[ii].int)
                XCTAssertEqual(values2[ii].intOptional, nil)
                XCTAssertEqual(values2[ii].string, values1[ii].string)
                XCTAssertEqual(values2[ii].stringOptional, nil)
                XCTAssertEqual(values2[ii].bool, values1[ii].bool)
                XCTAssertEqual(values2[ii].boolOptional, nil)
                XCTAssertEqual(values2[ii].float, values1[ii].float)
                XCTAssertEqual(values2[ii].floatOptional, nil)
                XCTAssertEqual(values2[ii].double, values1[ii].double)
                XCTAssertEqual(values2[ii].doubleOptional, nil)
                XCTAssertEqual(values2[ii].date, values1[ii].date)
                XCTAssertEqual(values2[ii].dateOptional, nil)
            }
        }
    }
}
