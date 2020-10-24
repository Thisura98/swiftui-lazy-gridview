//
//  LazyGridView.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import Foundation
import SwiftUI

public struct LazyGridView<Input: Any, Output: Any>: View{
    @ObservedObject var model: GridViewModel<Input, Output>
    var onClickAction: ((_ model: GridViewItemModel<Input, Output>) -> ())?
    var onDeleteAction: ((_ model: GridViewItemModel<Input, Output>) -> ())?
    
    public init(
    _ model: GridViewModel<Input, Output>,
    _ onClick: ((_ model: GridViewItemModel<Input, Output>) -> ())? = nil,
    _ onDelete: ((_ model: GridViewItemModel<Input, Output>) -> ())? = nil){
        
        self.model = model
        self.onClickAction = { m in
            onClick?(m)
        }
        self.onDeleteAction = { m in
            onDelete?(m)
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack {
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
                                        GridViewItem(
                                            model: item,
                                            size: model.itemViewWidth) { (onClickModel) in
                                            self.onClickAction?(onClickModel)
                                        } onDelete: { (onDeleteModel) in
                                            self.onDeleteAction?(onDeleteModel)
                                        }.frame(width: model.itemViewWidth, height: model.itemViewWidth)
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
                                        GridViewItem(
                                            model: item,
                                            size: model.itemViewWidth) { (onClickModel) in
                                            self.onClickAction?(onClickModel)
                                        } onDelete: { (onDeleteModel) in
                                            self.onDeleteAction?(onDeleteModel)
                                        }.frame(width: model.itemViewWidth, height: model.itemViewWidth)
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }
            }.frame(maxWidth: .infinity)
        }
    }
}
