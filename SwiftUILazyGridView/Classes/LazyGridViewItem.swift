//
//  LazyGridViewItem.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

/**
 A cell displayed within a `LazyGridView`
 */
public struct LazyGridViewItem<Input: Any, Output: Any>: View{
    
    public typealias ViewBuilderBlock = ((_ model: Model) -> AnyView)
    public typealias Model = LazyGridViewItemModel<Input, Output>
    
    @ObservedObject var model: Model
    var size: CGFloat = 10.0
    internal var onClick: ((_ model: Input?) -> ())? = nil
    internal var viewBuilderBlock: ViewBuilderBlock
    
    public var body: some View {
        ZStack{
            Button {
                onClick?(model.data)
            } label: {
                VStack {
                    switch(model.viewState){
                    case .loading:
                        ActivityIndicator(isAnimating: model.viewState == .loading, style: .medium)
                    case .noContent:
                        Text("No Content")
                    case .contentShowing:
                        self.viewBuilderBlock(model)
                    }
                }
            }
        }
    }
}
