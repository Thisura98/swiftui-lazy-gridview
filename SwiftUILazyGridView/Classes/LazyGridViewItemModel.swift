//
//  LazyGridViewItemModel.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

public class GridViewItemModel<Input: Any, Output: Any>: ObservableObject{
    
    enum ViewState{
        case loading, noContent, contentShowing
    }
    
    @Published internal var viewState: ViewState = .loading
    internal var data: Input? = nil
    @Published internal var processedOutput: Output? = nil
    
    internal init(_ data: Input?, state: ViewState){
        self.data = data
        self.viewState = state
    }
    
    internal func setSelfStateInMain(_ newState: ViewState){
        DispatchQueue.main.async { [weak self] in
            self?.viewState = newState
        }
    }
    
    internal func processData(){
        assert(!Thread.isMainThread, "\(#function) Must be run from a Background Thread")
        
        setSelfStateInMain(.loading)
        
        // let filePath = TellaFileManager.fileNameToPath(name: fileName)
        // data = TellaFileManager.recoverAndDecrypt(filePath, privKey)
        
        // Further processing
        /*
        if type == .IMAGE{
            data = getPreviewImage(data)
        }*/
        
        if data == nil{
            setSelfStateInMain(.noContent)
        }
        else{
            setSelfStateInMain(.contentShowing)
        }
    }
    
    /*
    private func getPreviewImage(_ imageData: Data?) -> Data? {
        guard let imageData = imageData else { return nil }
        guard let image = TellaFileManager.recoverImage(imageData) else { return nil }
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        let fixedScaleFactor: CGFloat = 0.05
        let scaleFactor = fixedScaleFactor
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage?.jpegData(compressionQuality: 0.0)
    }*/
}
