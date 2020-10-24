//
//  LazyGridViewItem.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

public struct GridViewItem<Input: Any, Output: Any>: View{
    
    public typealias ViewBuilderBlock = ((_ model: Model) -> AnyView)
    public typealias Model = GridViewItemModel<Input, Output>
    
    @ObservedObject var model: Model
    var size: CGFloat = 10.0
    internal var onClick: ((_ model: Model) -> ())? = nil
    internal var viewBuilderBlock: ViewBuilderBlock
    
    public var body: some View {
        ZStack{
            Button {
                onClick?(model)
            } label: {
                VStack {
                    switch(model.viewState){
                    case .loading:
                        ActivityIndicator(isAnimating: model.viewState == .loading, style: .medium)
                    case .noContent:
                        Text("No Contnet")
                    case .contentShowing:
                        self.viewBuilderBlock(model)
                    }
                }
            }
        }
    }
}
