//
//  LazyGridViewItem.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

public struct GridViewItem<Input: Any, Output: Any>: View{
    
    @ObservedObject var model: GridViewItemModel<Input, Output>
    var size: CGFloat = 10.0
    internal var onClick: ((_ model: GridViewItemModel<Input, Output>) -> ())? = nil
    internal var onDelete: ((_ model: GridViewItemModel<Input, Output>) -> ())? = nil
    
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
                        Text("We're still making it")
                        /*
                        switch(model.type){
                        case .IMAGE:
                            // GridViewImage(data: model.getData())
                        default:
                            Text("Unsuppported File Type").font(Font.system(size: 8.0))*/
                    }
                }
            }
            Button {
                onDelete?(model)
            } label: {
                Text("x")
                    .foregroundColor(Color.white)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                    .font(.system(size: 12.0))
            }
            .background(Color.black.opacity(0.4))
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(20.0)
            .offset(x: size / 2.0 - 20.0, y: size / 2.0 - 20.0)
        }
    }
}
