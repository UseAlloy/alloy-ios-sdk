//
//  DocumentViewModel.swift
//  
//
//  Created by Marc Hervera on 31/5/22.
//

import Foundation

@MainActor
internal class DocumentViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var evaluation: DocumentEvaluationResponse?
    @Published var outcome: DocumentEvaluationResponse.EvaluationSummary.Outcome?
    
    // MARK: - Custom
    private func create(document: DocumentPayload) async throws -> DocumentCreateUploadResponse {

        try await DocumentEndpoint
            .create(payload: document)
            .request(type: DocumentCreateUploadResponse.self)
        
    }
    
    private func upload(document: Data, createResponse: DocumentCreateUploadResponse) async throws -> DocumentCreateUploadResponse {

        try await DocumentEndpoint
            .upload(image: document, boundaryID: UUID().uuidString, createUploadResponse: createResponse)
            .request(type: DocumentCreateUploadResponse.self)
        
    }

    // MARK: - Public
    func create(document: DocumentPayload, andUploadData: Data?) async throws -> DocumentCreateUploadResponse {
        
        guard let data = andUploadData else { throw "Invalid image data" }
        
        isLoading = true
        defer { isLoading = false }
        
        // Create document
        let createResult = try await create(document: document)
        
        // Upload
        return try await upload(document: data, createResponse: createResult)
        
    }
    
    func evaluate(step: Evaluation.Variant, evaluationData: EvaluationData, createUploadResponse: DocumentCreateUploadResponse) async throws {
        
        isLoading = true
        defer { isLoading = false }
        
        evaluation = try await EvaluationEndpoint
            .evaluate(step: step, data: evaluationData, createUploadResponse: createUploadResponse)
            .request(type: DocumentEvaluationResponse.self)
        outcome = evaluation?.summary.outcome
        
    }
    
    func restart() {
        
        evaluation = nil
        outcome = nil
        
    }
    
}
