//
//  LazyGridViewModel.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

public class GridViewModel<Input: Any, Output: Any>: ObservableObject{
    
    public typealias ItemModel = GridViewItemModel<Input, Output>
    public typealias ItemView = GridViewItem<Input, Output>
    public typealias ProcessFunction = ((_ model: Input, _ callback: @escaping ((_ processed: Output?) -> Void)) -> Void)
    
    var gridViewItems: [ItemModel] = []
    var initializedOnce: Bool = false
    
    private var currentProcessingOperation: DispatchWorkItem?
    private var viewRenderingSize: CGSize = .zero
    
    private var initComplete: Bool = false
    
    private var _previousGalleryWidth: CGFloat = 100.0
    private var _previousSpacing: CGFloat = 100.0
    
    var galleryViewWidth: CGFloat = 100.0{
        didSet{
            if galleryViewWidth != _previousGalleryWidth{
                setNeedsViewUpdate()
            }
            _previousGalleryWidth = galleryViewWidth
        }
    }
    var spacing: CGFloat = 10.0{
        didSet {
            if spacing != _previousSpacing{
                setNeedsViewUpdate()
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
    
    // internal var processItemBlock: ((_ data: Input) -> Output)!
    internal var processItemBlock: ProcessFunction!
    
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
                
                guard item.processedOutput == nil else {
                    s.updateItemPropertiesAfterProcess(item, item.processedOutput)
                    continue
                }
                
                if let inputData = item.data{
                    
                    DispatchQueue.main.async {
                        item.viewState = .loading
                    }
                    
                    // var changeHolder: Output?
                    
                    if s.processItemBlock != nil{
                        // changeHolder = s.processItemBlock(inputData)
                        s.processItemBlock!(inputData) { [weak self] (processedOut) in
                            guard let s2 = self else { return }
                            s2.updateItemPropertiesAfterProcess(item, processedOut)
                        }
                    }
                    else if Output.self == Input.self{
                        // changeHolder = inputData as? Output
                        s.updateItemPropertiesAfterProcess(item, inputData as? Output)
                    }
                }
            }
        })
        
        DispatchQueue.global().async(execute: currentProcessingOperation!)
    }
    
    private func updateItemPropertiesAfterProcess(_ item: ItemModel, _ processedValue: Output?){
        DispatchQueue.main.async {
            item.processedOutput = processedValue
            if item.processedOutput != nil{
                print("Processed, \(processedValue). Content is showing.")
                item.viewState = .contentShowing
            }
            else{
                print("Processed, \(processedValue), but content is nil. Showing not content.")
                item.viewState = .noContent
            }
        }
    }
    
    private func dispatchWorkItemCleanup(){
        currentProcessingOperation = nil
    }
    
    public func setNeedsViewUpdate(){
        guard initComplete else { return }
        processItems()
    }
    
    public  func getItem(atRow: Int, column: Int) -> ItemModel?{
        var index = max(0, atRow * columns)
        index += column
        if index < gridViewItems.count{
            return gridViewItems[index]
        }
        else{
            return nil
        }
    }
    
    public func setItems(_ items: [Input]){
        self.gridViewItems = items.map({ (i) -> ItemModel in
            return ItemModel(i, state: .loading)
        })
        setNeedsViewUpdate()
    }
    
    @discardableResult
    public func addItem(_ item: Input, at: Int? = nil) -> ItemModel{
        let itemViewModel = ItemModel(item, state: .loading)
        if let concreteAt = at{
            if concreteAt < gridViewItems.count{
                gridViewItems.insert(itemViewModel, at: concreteAt)
            }
            else{
                gridViewItems.append(itemViewModel)
            }
        }
        else{
            gridViewItems.append(itemViewModel)
        }
        setNeedsViewUpdate()
        
        return itemViewModel
    }
    
    @discardableResult
    public func removeItem(_ at: Int) -> ItemModel?{
        var result: ItemModel?
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
    
    public func getNumberOfItems() -> Int{
        return gridViewItems.count
    }
    
    public func getAllItemModels() -> [Input?]{
        return getAllItems().map { (im) -> Input? in
            return im.data
        }
    }
    
    public func getAllItems() -> [ItemModel]{
        return gridViewItems
    }
    
    @discardableResult
    public func adjustWidth(_ to: CGFloat) -> GridViewModel{
        self.galleryViewWidth = to
        return self
    }
}
