//
//  LazyGridView.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import Foundation
import SwiftUI

/**
 LazyGridView with input and output data types.
 
 The `Input` and `Output` types represent the raw data format
 and the processed data format respectively. For example,
 if items are added as `String`s, you are given the chance
 to process the items into `Ints`s before being displayed.
 
 This is what provides the "Lazy" behavior. The behavior is __NOT__
 identical to UIKit's CollectionView. Rather, it is a simple Grid
 that allows content __within__ each cell to be lazily loaded.
 */
public struct LazyGridView<Input: Any, Output: Any>: View{
    
    public typealias ItemModel = LazyGridViewItemModel<Input, Output>
    public typealias ItemView = LazyGridViewItem<Input, Output>
    public typealias GridModel = LazyGridViewModel<Input, Output>
    
    @ObservedObject var model: GridModel
    
    internal var viewBuilderBlock: ((_ data: Output) -> AnyView)!
    internal var onClickAction: ((_ model: Input?) -> ())?
    
    /**
     Initialize a LazyGridView instance.
     
     - parameter model: Object that holds the items of the grid
     - parameter processItems: Closure that processes items. This block is called from a background
     thread. Do not perform layout changes here. Simply process the passed in item if needed. Otherwise,
     return the same item to the callback.
     - parameter viewBuilder: Closure that builds items for display This block is called from the main
     thread.
     - parameter onClick: Closure when a cell is clicked.
     */
    public init(
    _ model: LazyGridViewModel<Input, Output>,
    _ processItems: GridModel.ProcessFunction? = nil,
    _ viewBuilder: ((_ data: Output) -> AnyView)? = nil,
    _ onClick: ((_ model: Input?) -> ())? = nil){
        
        self.model = model
        
        if let processItemsBlock = processItems{
            self.model.processItemBlock = { input, callback in
                processItemsBlock(input) { (result) in
                    callback(result)
                }
            }
        }
        else{
            self.model.processItemBlock = nil
        }
        
        if let viewBuilderBlock = viewBuilder{
            self.viewBuilderBlock = { processOutput in
                return viewBuilderBlock(processOutput)
            }
        }
        else{
            self.viewBuilderBlock = nil
        }
        
        self.onClickAction = { m in
            onClick?(m)
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            self.resizeIfNeeded(proxy)
            
            ScrollView {
                VStack {
                    
                    if model.isProcessing{
                        HStack {
                            ActivityIndicator(isAnimating: true, style: .medium)
                            Text("Loading...").font(.system(size: 8.0))
                        }.transition(.asymmetric(insertion: .scale, removal: .opacity))
                    }
                    else if model.noItemsToShow{
                        Text("No items to preview").font(.system(size: 8.0)).transition(.asymmetric(insertion: .scale, removal: .opacity))
                    }
                    
                    ForEach(0..<model.vStacksCount, id: \.self){ (i: Int) in
                        HStack(spacing: model.spacing / 2.0) {
                            if (model.vStackIndexHalfFilled == i){
                                // Last row with half filled items
                                ForEach(0..<model.vStackHalfFilledItemCount, id: \.self){ (j: Int) in
                                    if let item = model.getItem(atRow: i, column: j){
                                        ItemView(
                                            model: item,
                                            size: model.itemViewWidth,
                                            onClick: { (onClickModel) in
                                                self.onClickAction?(onClickModel)
                                            },
                                            viewBuilderBlock: { (model) in
                                                return self.getViewWithModel(model)
                                            }
                                        ).frame(width: model.itemViewWidth, height: model.itemViewWidth)
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }
                            else{
                                // All other rows
                                ForEach(0..<model.columns, id: \.self){ (j: Int) in
                                    if let item = model.getItem(atRow: i, column: j){
                                        ItemView(
                                            model: item,
                                            size: model.itemViewWidth,
                                            onClick: { (onClickModel) in
                                                self.onClickAction?(onClickModel)
                                            },
                                            viewBuilderBlock: { (model) in
                                                return self.getViewWithModel(model)
                                            }
                                        ).frame(width: model.itemViewWidth, height: model.itemViewWidth)
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity).shown(!model.isProcessing && !model.noItemsToShow).transition(.asymmetric(insertion: .scale, removal: .opacity))
                    }
                }.frame(maxWidth: .infinity)
            }
        }
    }
    
    private func resizeIfNeeded(_ proxy: GeometryProxy) -> EmptyView{
        self.model.adjustWidth(proxy.size.width)
        return EmptyView()
    }
    
    private func getViewWithModel(_ itemModel: ItemModel) -> AnyView{
        if itemModel.viewState == .contentShowing{
            if let viewBuilderBlock = self.viewBuilderBlock, let processedOutput = itemModel.processedOutput{
                return AnyView(viewBuilderBlock(processedOutput))
            }
        }
        return AnyView(EmptyView())
    }
}

// https://stackoverflow.com/questions/56490250/dynamically-hiding-view-in-swiftui
extension View {
    @ViewBuilder fileprivate func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden().animation(.easeInOut)
        case false: self.transition(.scale)
        }
    }
    
    @ViewBuilder fileprivate func shown(_ shouldShow: Bool) -> some View {
        switch shouldShow {
        case true: self.animation(.easeInOut)
        case false: self.hidden().animation(.easeInOut)
        }
    }
}
