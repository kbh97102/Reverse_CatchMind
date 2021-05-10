//
//  ViewController.swift
//  1692002-project
//
//  Created by mac006 on 2021/05/10.
//

import UIKit
import PencilKit



class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIScreenshotServiceDelegate {


    @IBOutlet weak var canvasView: PKCanvasView!
    
    static var canvasOverscrollHeight: CGFloat = 500
    var toolPicker : PKToolPicker!
    var dataModelController : DataModelController!
    var signDrawingItem: UIBarButtonItem!
    
    var drawingIndex = 0
    var hasModifiedDrawing = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        canvasView.delegate = self
        canvasView.drawing = dataModelController.drawings[drawingIndex]
        canvasView .alwaysBounceVertical = true
        
        
        toolPicker = PKToolPicker()
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        updateLayout(for: toolPicker)
        canvasView.becomeFirstResponder()
        
        signDrawingItem = UIBarButtonItem(title: "Sign Drawing", style: .plain, target: self, action: #selector(signDrawing(sender:)))
        navigationItem.rightBarButtonItems?.append(signDrawingItem)
        
        
        navigationItem.leftItemsSupplementBackButton = true
        
        
        parent?.view.window?.windowScene?.screenshotService?.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / DataModel.canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hasModifiedDrawing{
            dataModelController.updateDrawing(canvasView.drawing, at: drawingIndex)
        }
        
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + ViewController.canvasOverscrollHeight)*canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: DataModel.canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
    
    @IBAction func signDrawing(sender: UIBarButtonItem){
        var signature = dataModelController.signature
        let signatureBounds = signature.bounds
        let loc = CGPoint(x: canvasView.bounds.maxX, y: canvasView.bounds.maxY)
        let scaledLoc = CGPoint(x: loc.x/canvasView.zoomScale, y: loc.y/canvasView.zoomScale)
        signature.transform(using: CGAffineTransform(translationX: scaledLoc.x - signatureBounds.maxX, y: scaledLoc.y - signatureBounds.maxY))
    }

    
    func updateLayout(for toolPicker: PKToolPicker){
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        if obscuredFrame.isNull{
            canvasView.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        }
        else{
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
            //TODO Redo Undo
//            navigationItem.leftBarButtonItems =
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
}

