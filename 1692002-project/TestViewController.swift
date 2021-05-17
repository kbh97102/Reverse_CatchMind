//
//  TestViewController.swift
//  1692002-project
//
//  Created by mac016 on 2021/05/17.
//

import UIKit
import PencilKit
import PhotosUI

class TestViewController: UIViewController , PKCanvasViewDelegate, PKToolPickerObserver{


    @IBOutlet weak var canvasView: PKCanvasView!
    
    private let canvasWidth:CGFloat = 768
    private let canvasOverScrollHeight = 500
    private let toolPicker = PKToolPicker()
    
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPkCanvas()
    }
    
    private func setUpPkCanvas(){

        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput

        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)

        
        canvasView.tool = PKInkingTool(.pen, color: .blue, width: 20)
        canvasView.becomeFirstResponder()
    }
    
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {success, fail in
                
            })
        }
    }

    @IBAction func toggleButton(_ sender: UIBarButtonItem) {
        
    }

}
