//
//  FullCastTests.swift
//  FullCastTests
//
//  Created by Vishwa  R on 14/02/22.
//

import XCTest
@testable import FullCast

class FullCastTests: XCTestCase {
    
    var testCoreDataStack: TestCoreDataStack!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func setUp() {
        super.setUp()
        testCoreDataStack = TestCoreDataStack()
    }
    
    //MARK: -  Testing for Category ViewModel
    
    func test_CategoryViewModel_folders_shouldByEmpty() {
        let categoryViewModel = CategoryViewModel()
        let folders = categoryViewModel.folders
        XCTAssertEqual(folders.count, 0)
    }
    
    func test_CategoryModel_category_saveFolderToCoreData() {
        for _ in 0..<100 {
            let folderName = UUID().uuidString
            testCoreDataStack.addFolderToDataBase(folderName: folderName)
            let gotResult = testCoreDataStack.fetchFolderWithName(folderName: folderName)
            XCTAssertEqual(gotResult.count, 1)
            XCTAssertEqual(folderName, gotResult[0].wrappedCategoryName)
        }
        let fetchAllItem = testCoreDataStack.fetchAllFolders()
        XCTAssertGreaterThan(fetchAllItem.count, 0)
    }
    
    func test_CategoryModel_category_hasUnqiueNames() {
        let folder1 = "Apple"
        let folder2 = "Apple"
        testCoreDataStack.addFolderToDataBase(folderName: folder1)
        testCoreDataStack.addFolderToDataBase(folderName: folder2)
        let getResult = testCoreDataStack.fetchAllFolders()
        print(getResult)
    }
    
    //MARK: - Testing for RecorderViewModel
    
    func test_RecorderViewModel_recordingsList_shouldBeEmpty() {
        let recorderViewModel = RecorderViewModel()
        let recordingList = recorderViewModel.recordingsList
        XCTAssertEqual(recordingList.count, 0)
    }
    
}
