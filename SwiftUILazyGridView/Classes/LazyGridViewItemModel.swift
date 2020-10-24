//
//  LazyGridViewItemModel.swift
//  SwiftUILazyGridView
//
//  Created by Thisura Dodangoda on 10/24/20.
//

import SwiftUI
import Foundation

/**
 The model for a `LazyGridViewItem` View.
 */
public class LazyGridViewItemModel<Input: Any, Output: Any>: ObservableObject{
    
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
        
        if data == nil{
            setSelfStateInMain(.noContent)
        }
        else{
            setSelfStateInMain(.contentShowing)
        }
    }
}
