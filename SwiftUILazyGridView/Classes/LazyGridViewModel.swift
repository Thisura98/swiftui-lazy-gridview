//
//  LazyGridViewModel.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

public class GridViewModel<Input: Any, Output: Any>: ObservableObject{
    
    var gridViewItems: [GridViewItemModel<Input, Output>] = []
    var initializedOnce: Bool = false
    
    private var currentProcessingOperation: DispatchWorkItem?
    private var viewRenderingSize: CGSize = .zero
    
    private var initComplete: Bool = false
    
    private var _previousGalleryWidth: CGFloat = 100.0
    private var _previousSpacing: CGFloat = 100.0
    
    var galleryViewWidth: CGFloat = 100.0{
        didSet{
            if galleryViewWidth != _previousGalleryWidth{
                setNeedsViewUpdate();
            }
            _previousGalleryWidth = galleryViewWidth
        }
    }
    var spacing: CGFloat = 10.0{
        didSet {
            if spacing != _previousSpacing{
                setNeedsViewUpdate();
            }
            _previousSpacing = spacing
        }
    }
    /**
     Width of one item
     */
    var itemViewWidth: CGFloat = 20.0
    /**
     No of columns
     */
    var columns: Int = 3 {
        didSet{
            setNeedsViewUpdate()
        }
    }
    
    @Published var vStacksCount: Int = 0
    @Published var vStackIndexHalfFilled: Int = 0
    @Published var vStackHalfFilledItemCount: Int = 0
    @Published var isProcessing: Bool = false
    @Published var noItemsToShow: Bool = false
    
    public init(_ galleryViewWidth: CGFloat, spacing: CGFloat){
        self.galleryViewWidth = galleryViewWidth
        self.spacing = spacing
        
        initComplete = true
        setNeedsViewUpdate()
    }
    
    private func processItems(){
        isProcessing = true
        noItemsToShow = false
         
        if let currentOperation = currentProcessingOperation{
            currentOperation.cancel()
            dispatchWorkItemCleanup()
        }
        
        currentProcessingOperation = DispatchWorkItem(qos: .background, flags: [], block: { [weak self] in
            print("GridView started processing items")
            
            guard let s = self else { return }
            guard s.gridViewItems.count > 0 else {
                DispatchQueue.main.async{
                    s.isProcessing = false
                    s.noItemsToShow = true
                }
                return
            }
            
            let spacingWidth = (CGFloat(s.columns - 1) * s.spacing)
            s.itemViewWidth = (s.galleryViewWidth - (spacingWidth)) / CGFloat(s.columns)
            
            let divResult = s.gridViewItems.count.quotientAndRemainder(dividingBy: s.columns)
            let vStacksCount = divResult.quotient + (divResult.remainder > 0 ? 1 : 0)
            var vStackIndexHalfFilled = -1
            var vStackHalfFilledItemCount = 0
            
            if divResult.remainder > 0{
                vStackIndexHalfFilled = divResult.quotient
                vStackHalfFilledItemCount = divResult.remainder
            }
            
            DispatchQueue.main.async{ [weak self] in
                self?.isProcessing = false
                self?.vStackIndexHalfFilled = vStackIndexHalfFilled
                self?.vStacksCount = vStacksCount
                self?.vStackHalfFilledItemCount = vStackHalfFilledItemCount
                self?.dispatchWorkItemCleanup()
            }
            
            // Process data items
            for item in s.gridViewItems{
                item.processData()
            }
        })
        
        DispatchQueue.global().async(execute: currentProcessingOperation!)
    }
    
    private func dispatchWorkItemCleanup(){
        currentProcessingOperation = nil
    }
    
    func setNeedsViewUpdate(){
        guard initComplete else { return }
        processItems()
    }
    
    internal func getItem(atRow: Int, column: Int) -> GridViewItemModel<Input, Output>?{
        var index = max(0, atRow * columns)
        index += column
        if index < gridViewItems.count{
            return gridViewItems[index]
        }
        else{
            return nil
        }
    }
    
    func addItem(_ item: GridViewItemModel<Input, Output>, at: Int){
        if at < gridViewItems.count{
            gridViewItems.insert(item, at: at)
        }
        else{
            gridViewItems.append(item)
        }
        setNeedsViewUpdate()
    }
    
    @discardableResult
    func removeItem(_ at: Int) -> GridViewItemModel<Input, Output>?{
        var result: GridViewItemModel<Input, Output>?
        if at < gridViewItems.count{
            result = gridViewItems.remove(at: at)
        }
        else{
            result = gridViewItems.popLast()
        }
        
        if result != nil{
            setNeedsViewUpdate()
        }
        
        return result
    }
    
    @discardableResult
    func adjustWidth(_ to: CGFloat) -> GridViewModel{
        self.galleryViewWidth = to
        return self
    }
}
