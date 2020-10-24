//
//  LazyGridView.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import Foundation
import SwiftUI

public struct LazyGridView<Input: Any, Output: Any>: View{
    
    public typealias ItemModel = GridViewItemModel<Input, Output>
    public typealias ItemView = GridViewItem<Input, Output>
    public typealias GridModel = GridViewModel<Input, Output>
    
    @ObservedObject var model: GridModel
    
    internal var viewBuilderBlock: ((_ data: Output) -> AnyView)!
    internal var onClickAction: ((_ model: ItemModel) -> ())?
    
    public init(
    _ model: GridViewModel<Input, Output>,
    _ processItems: GridModel.ProcessFunction? = nil,
    _ viewBuilder: ((_ data: Output) -> AnyView)? = nil,
    _ onClick: ((_ model: ItemModel) -> ())? = nil){
        
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
                    HStack {
                        ActivityIndicator(isAnimating: true, style: .medium)
                        Text("Loading...").font(.system(size: 8.0))
                    }.shown(model.isProcessing).transition(.asymmetric(insertion: .scale, removal: .opacity))
                    
                    Text("No items to preview").font(.system(size: 8.0)).shown(!model.isProcessing && model.noItemsToShow).transition(.asymmetric(insertion: .scale, removal: .opacity))
                    
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
                    /*
                    if model.isProcessing {
                        HStack {
                            ActivityIndicator(isAnimating: true, style: .medium)
                            Text("Loading...").font(.system(size: 8.0))
                        }
                    }
                    else if model.noItemsToShow{
                        Text("No items to preview").font(.system(size: 8.0))
                    }
                    else{
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
                            }.frame(maxWidth: .infinity)
                        }
                    }*/
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
