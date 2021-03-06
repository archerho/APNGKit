//
//  APNGImageTests.swift
//  APNGKit
//
//  Created by Wei Wang on 15/8/29.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import APNGKit

class APNGImageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        APNGImage.searchBundle = NSBundle.testBundle

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        APNGImage.searchBundle = NSBundle.mainBundle()
        super.tearDown()
    }
    
    func testMinimalAPNG() {
        let imageString = NSBundle(forClass: APNGImageTests.self).pathForResource("minimalAPNG", ofType: "apng")!
        let data = NSData(contentsOfFile: imageString)
        
        let image = APNGImage(data: data!)
        
        XCTAssertNotNil(image, "The minimal APNG file should be able to setup.")
        XCTAssertEqual(image!.frames.count, 2, "There should be 2 frames.")
        XCTAssertEqual(image!.size, CGSize(width: 1, height: 1), "The size of image is 1x1")
        
        // Red pixel
        let frame0Pixel = [image!.frames[0].bytes.memory,
                           image!.frames[0].bytes.advancedBy(1).memory,
                           image!.frames[0].bytes.advancedBy(2).memory,
                           image!.frames[0].bytes.advancedBy(3).memory]
        XCTAssertEqual(frame0Pixel, [0xff, 0x00, 0x00, 0xff])
        
        // Green pixel
        let frame1Pixel = [image!.frames[1].bytes.memory,
                           image!.frames[1].bytes.advancedBy(1).memory,
                           image!.frames[1].bytes.advancedBy(2).memory,
                           image!.frames[1].bytes.advancedBy(3).memory]
        XCTAssertEqual(frame1Pixel, [0x00, 0xff, 0x00, 0xff])
        
        XCTAssertEqual(image?.repeatCount, RepeatForever, "The repeat count should be forever.")
        XCTAssertEqual(image?.duration, 1.0, "Total duration is 1.0 sec")
        
        XCTAssertEqual(image?.frames[0].duration, 0.5, "The duration of a frame should be 0.5")
    }
    
    func testAPNGCreatingPerformance() {
        let ballString = NSBundle.testBundle.pathForResource("ball", ofType: "apng")!
        let data = NSData(contentsOfFile: ballString)
        
        self.measureBlock {
            for _ in 0 ..< 50 {
                _ = APNGImage(data: data!)
            }
        }
    }
    
    func testABitLargerAPNG() {
        let firefoxString = NSBundle.testBundle.pathForResource("spinfox", ofType: "apng")!
        let data = NSData(contentsOfFile: firefoxString)
        let image = APNGImage(data: data!)
        XCTAssertEqual(image?.frames.count, 25, "")
    }
    
    func testInitContentsOfFile() {
        let path = NSBundle.testBundle.pathForResource("ball", ofType: "apng")!
        let apng1 = APNGImage(contentsOfFile: path)
        XCTAssertNotNil(apng1, "ball.png should be able to init")
        
        let wrongPath = NSBundle.testBundle.pathForResource("ball", ofType: "apng")!.stringByReplacingOccurrencesOfString("ball", withString: "vall")
        let apng2 = APNGImage(contentsOfFile: wrongPath)
        XCTAssertNil(apng2, "ball.png should be able to init")
    }
    
    func testInitFromName() {
        let apng1 = APNGImage(named: "ball.png")
        XCTAssertNotNil(apng1, "ball.png should be able to init")
        
        let apng2 = APNGImage(named: "no-such-file.png")
        XCTAssertNil(apng2, "There is no such file.")
    }
    
    func testInitFromNameWithoutPng() {
        let apng1 = APNGImage(named: "ball")
        XCTAssertNotNil(apng1, "ball.png should be able to init")
        
        let apng2 = APNGImage(named: "no-such-file")
        XCTAssertNil(apng2, "There is no such file.")
    }
    
    func testInitRetinaImage() {
        let retinaAPNG = APNGImage(named: "elephant_apng")
        XCTAssertNotNil(retinaAPNG, "elephant_apng should be able to init at 2x.")
        XCTAssertEqual(retinaAPNG?.scale, 2, "Retina version should be loaded")
        XCTAssertEqual(retinaAPNG?.size, CGSizeMake(240, 200), "Size should be in point, not pixel.")

        let anotherRetinaAPNG = APNGImage(named: "elephant_apng@2x")
        XCTAssertNotNil(anotherRetinaAPNG, "elephant_apng should be able to init at 2x.")
        XCTAssertEqual(anotherRetinaAPNG?.scale, 2, "Retina version should be loaded")
        XCTAssertEqual(anotherRetinaAPNG?.size, CGSizeMake(240, 200), "Size should be in point, not pixel.")
        
        let normalAPNG = APNGImage(data: NSData(contentsOfFile: NSBundle.testBundle.pathForResource("elephant_apng", ofType: "apng")!)!)
        XCTAssertNotNil(normalAPNG, "elephant_apng should be able to init at 1x.")
        XCTAssertEqual(normalAPNG?.scale, 1, "Retina version should be loaded")
        XCTAssertEqual(normalAPNG?.size, CGSizeMake(480, 400), "Size should be in point, not pixel.")
        
        let wrongAPNG = APNGImage(named: "elephant_apng@3x")
        XCTAssertNil(wrongAPNG, "elephant_apng should be able to init at 3x.")
    }
    
    func testFirstFrameHidden() {
        let firstFrameHiddenImage = APNGImage(named: "pyani")
        XCTAssertNotNil(firstFrameHiddenImage, "image should be able to init")
        XCTAssertTrue(firstFrameHiddenImage!.firstFrameHidden, "The first frame should be hidden.")
        
        let notHiddenImage = APNGImage(named: "ball")
        XCTAssertNotNil(notHiddenImage, "image should be able to init")
        XCTAssertFalse(notHiddenImage!.firstFrameHidden, "The first frame should not be hidden.")
    }
}
