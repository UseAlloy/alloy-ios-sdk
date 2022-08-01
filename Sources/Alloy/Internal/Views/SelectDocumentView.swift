//
//  SelectDocumentView.swift
//  
//
//  Created by Marc Hervera on 9/5/22.
//

import SwiftUI

internal struct SelectDocumentView: View {
    
    // MARK: - Properties
    var step: Step
    @State var automaticSelectionType: DocumentType

    // MARK: - Private
    @EnvironmentObject private var configViewModel: ConfigViewModel
    @State private var selectedType: DocumentType = .none

    // MARK: - Main
    var body: some View {

        AutomaticNavigationLink(automaticSelectionType: automaticSelectionType)

        VStack(alignment: .center, spacing: 20) {
            
            Text("select_scan_document", bundle: .module)
                .font(.subheadline)
                .foregroundColor(configViewModel.theme.title)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
        
            DocumentTypesList(
                step: step,
                selectedType: $selectedType
            )
            
            Footer(selectedType: $selectedType)
                .adjustBottomPadding()
            
            
        }
        .padding(.horizontal, 40)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button {
                    
                    dismiss()
                    
                } label: {
                    
                    Image(.xMark)
                        .foregroundColor(.aBlack)
                    
                }

            }
            
            ToolbarItem(placement: .principal) {
                
                Text("select_title", bundle: .module)
                    .bold()
                    .foregroundColor(configViewModel.theme.title)
                
            }
            
        }
        
    }
    
}

private struct DocumentItem: View {
    
    // MARK: - Properties
    let selected: Bool
    let icon: Image
    let title: Text
    
    @EnvironmentObject private var configViewModel: ConfigViewModel
    
    // MARK: - Main
    var body: some View {
        
        HStack(spacing: 10) {
            
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(12)
                .cornerRadius(4)
                .foregroundColor(configViewModel.theme.icon)
            
            title
                .font(.subheadline)
                .bold()
                .foregroundColor(configViewModel.theme.title)
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            ZStack {
                
                Circle()
                    .stroke(selected ? configViewModel.theme.icon : Color.aGray, lineWidth: 2)
                    .frame(width: 20, height: 20, alignment: .center)
                
                if selected {
                    
                    Circle()
                        .fill(configViewModel.theme.icon)
                        .frame(width: 10, height: 10, alignment: .center)
                    
                }
                
            }
            .frame(width: 64, height: 64, alignment: .center)
            
        }
        .background(selected ? configViewModel.theme.icon.opacity(0.08) : .clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selected ? configViewModel.theme.icon : Color.aGray, lineWidth: 1)
        )
        
    }
    
}

private struct DocumentTypesList: View {
    
    // MARK: - Properties
    var step: Step
    @Binding var selectedType: DocumentType
    @EnvironmentObject private var configViewModel: ConfigViewModel

    // MARK: - Main
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 20) {
                
                ForEach(step.orDocumentTypes, id: \.rawValue) { type in
                    
                    Button {
                        
                        configViewModel.setLastAttemptSelectedDocument(type)
                        selectedType = type
                        
                    } label: {
                        
                        let title = "select_document_type_\(type.rawValue)"
                        DocumentItem(
                            selected: selectedType == type,
                            icon: type.icon,
                            title: Text(LocalizedStringKey(title), bundle: .module)
                        )
                        
                    }
                    
                }
                
            }
            .padding(1)
            
        }
        
    }
    
}

private struct Footer: View {
    
    // MARK: - Properties
    @Binding var selectedType: DocumentType
    @State private var showNext = false
    
    // MARK: - Main
    var body: some View {

        NavigationLink(isActive: $showNext) {
            
            ScanInstructionsView(documentType: selectedType)
            
        } label: {
            
            Button {
                
                showNext = true
                
            } label: {
                
                Text("continue", bundle: .module)
                
            }
            .buttonStyle(DefaultButtonStyle())
            .padding(.vertical, 5)
            
        }
        .disabled(selectedType == .none)
        
    }
    
}

private struct AutomaticNavigationLink: View {

    @State var automaticSelectionType: DocumentType

    var body: some View {
        let isActiveBind = Binding {
            automaticSelectionType != .none
        }
        set: { isActive in
            if !isActive {
                automaticSelectionType = .none
            }
        }

        NavigationLink(isActive: isActiveBind) {

            ScanInstructionsView(documentType: automaticSelectionType)

        } label: {

            EmptyView()

        }
        .hidden()
    }
}

struct SelectDocument_Previews: PreviewProvider {
    static var previews: some View {
        SelectDocumentView(step: .init(orDocumentTypes: [AllowedDocumentType.passport]), automaticSelectionType: .none)
            .environmentObject(ConfigViewModel())
    }
}
