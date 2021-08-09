//
//  DragEnvironment.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/29.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

// MARK: -  Corner Radius
extension View {
    @ViewBuilder func proposedCornerRadius() -> some View {
        if !UIDevice.isPad {
            self.modifier(ProposedCornerRadius())
        } else {
            self
        }
    }
}

fileprivate struct ProposedCornerRadius: ViewModifier {
    @State private var internalIsDragging = false
    @Environment(\.dragging) var dragging
    
    func body(content: Content) -> some View {
        content
            .onChange(of: dragging) { dragging in withAnimation { internalIsDragging = dragging  } }
            .roundedCorner(internalIsDragging ? 25 : 0)
    }
}

// MARK: - Is Dragging

extension View {
    func draggingEnvironment(_ dragging: Bool) -> some View {
        self.environment(\.dragging, dragging)
    }
    
    @ViewBuilder func proposedIgnoringSafeArea(regions: SafeAreaRegions = .container, edges: Edge.Set = .all) -> some View {
        if !UIDevice.isPad {
            self.modifier(ProposedIgnoringSafeArea(regions: regions, edges: edges))
        } else {
            self.ignoresSafeArea(regions, edges: edges)
        }
    }
}

fileprivate struct DraggingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var dragging: Bool {
        get { self[DraggingKey.self] }
        set { self[DraggingKey.self] = newValue }
    }
}

fileprivate struct ProposedIgnoringSafeArea: ViewModifier {
    let regions: SafeAreaRegions
    let edges: Edge.Set
    @State private var internalIsDragging = false
    @Environment(\.dragging) var dragging
    
    func body(content: Content) -> some View {
        content
            .onChange(of: dragging) { dragging in withAnimation { internalIsDragging = dragging  } }
            .ignoresSafeArea(regions, edges: internalIsDragging ? [] : edges)
    }
}

// MARK: - Padding

extension View {
    func respectivePadding(_ edges: Edge.Set, whenDragging: CGFloat?, whenNot: CGFloat?) -> some View {
        self.modifier(RespectivePadding(edges: edges, whenDragging: whenDragging, whenNot: whenNot))
    }
}

fileprivate struct RespectivePadding: ViewModifier {
    let edges: Edge.Set
    let whenDragging: CGFloat?
    let whenNot: CGFloat?
    @State private var internalIsDragging = false
    @Environment(\.dragging) var dragging
    
    func body(content: Content) -> some View {
        content
            .onChange(of: dragging) { dragging in withAnimation { internalIsDragging = dragging  } }
            .padding(edges, internalIsDragging ? whenDragging : whenNot)
    }
}
