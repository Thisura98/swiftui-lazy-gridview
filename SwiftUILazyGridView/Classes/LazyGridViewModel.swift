//
//  LazyGridViewModel.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

/**
 The model for a `LazyGridView` instance. Holds item and layout
 information for the Grid View. This is also your item container,
 as you do not need to create a customer data container for your objects (for example, an Array).
 */
public class LazyGridViewModel<Input: Any, Output: Any>: ObservableObject{
    
    public typealias ItemModel = LazyGridViewItemModel<Input, Output>
    public typealias ItemView = LazyGridViewItem<Input, Output>
    public typealias ProcessFunction = ((_ model: Input, _ callback: @escaping ((_ processed: Output?) -> Void)) -> Void)
    
    var gridViewItems: [ItemModel] = []
    var initializedOnce: Bool = false
    
    private var currentProcessingOperation: DispatchWorkItem?
    private var viewRenderingSize: CGSize = .zero
    
    private var initComplete: Bool = false
    
    private var _previousGridWidth: CGFloat = 100.0
    private var _previousSpacing: CGFloat = 100.0
    
    var gridViewWidth: CGFloat = 100.0{
        didSet{
            if gridViewWidth != _previousGridWidth{
                setNeedsViewUpdate()
            }
            _previousGridWidth = gridViewWidth
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
     No of columns
     */
    var columns: Int = 3 {
        didSet{
            setNeedsViewUpdate()
        }
    }
    /**
     Width of one item
     */
    var itemViewWidth: CGFloat = 20.0
    
    @Published var vStacksCount: Int = 0
    @Published var vStackIndexHalfFilled: Int = 0
    @Published var vStackHalfFilledItemCount: Int = 0
    @Published var isProcessing: Bool = false
    @Published var noItemsToShow: Bool = false
    
    internal var processItemBlock: ProcessFunction!
    
    /**
     Initialize a LazyGridViewModel instance.
     
     - parameter gridViewWidth: Initial size for the grid view
     - parameter spacing: Spacing between items
     - parameter columns: Number of columns (default is 3)
     */
    public init(_ gridViewWidth: CGFloat, spacing: CGFloat, columns: Int = 3){
        self.gridViewWidth = gridViewWidth
        self.spacing = spacing
        self.columns = columns
        
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
            
            guard let s = self else { return }
            guard s.gridViewItems.count > 0 else {
                DispatchQueue.main.async{
                    s.isProcessing = false
                    s.noItemsToShow = true
                }
                return
            }
            
            let spacingWidth = (CGFloat(s.columns - 1) * s.spacing)
            s.itemViewWidth = (s.gridViewWidth - (spacingWidth)) / CGFloat(s.columns)
            
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
            //
            // Data processing occurs in background thread.
            
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
                item.viewState = .contentShowing
            }
            else{
                item.viewState = .noContent
            }
        }
    }
    
    private func dispatchWorkItemCleanup(){
        currentProcessingOperation = nil
    }
    
    /**
     Request layout update
     */
    public func setNeedsViewUpdate(){
        guard initComplete else { return }
        processItems()
    }
    
    /**
     Retrieve an item using row and column 0 based indices.
     */
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
    
    /**
     Sets the raw (Input) items for the model. This requests
     a new a layout update.
     */
    public func setItems(_ items: [Input]){
        self.gridViewItems = items.map({ (i) -> ItemModel in
            return ItemModel(i, state: .loading)
        })
        setNeedsViewUpdate()
    }
    
    /**
     Add a raw (Input) item into the model. Optionally provide
     the 0 based index. The added item is returned and can be ignored.
     */
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
    
    /**
     Remove a raw (Input) item from the model at a 0 based index.
     The removed item is returned and can be ignored.
     */
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
    
    /**
     Number of items currently displayed in the Grid View
     */
    public func getNumberOfItems() -> Int{
        return gridViewItems.count
    }
    
    /**
     All the raw (Input) items added to the model
     */
    public func getAllItems() -> [Input?]{
        return getAllItemModels().map { (im) -> Input? in
            return im.data
        }
    }
    
    /**
     All the view models for the individual cells.
     */
    public func getAllItemModels() -> [ItemModel]{
        return gridViewItems
    }
    
    /**
     Notifies the layout of the GridView that the size has changed.
     Changes are idempotent.
     */
    @discardableResult
    public func adjustWidth(_ to: CGFloat) -> LazyGridViewModel{
        self.gridViewWidth = to
        return self
    }
}
