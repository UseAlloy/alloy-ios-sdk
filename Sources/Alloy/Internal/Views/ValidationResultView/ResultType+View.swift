import SwiftUI

internal extension ResultType {

    var animation: Image.Identifier {
        switch self {
        case .success:
            return .resultSuccess
        case .pendingReview, .denied, .error:
            return .resultFailure
        case .retakeImages, .maxEvaluationAttempsExceded:
            // TODO: cambiar animacion
            return .resultFailure
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .success:
            return LocalizedStringKey("result_success")
        case .pendingReview:
            return LocalizedStringKey("result_pending")
        case .denied:
            return LocalizedStringKey("result_denied")
        case .retakeImages:
            return LocalizedStringKey("result_retake_images")
        case .maxEvaluationAttempsExceded:
            return LocalizedStringKey("result_unable_verify")
        case .error:
            return LocalizedStringKey("result_error")
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .success:
            return LocalizedStringKey("result_validated")
        case .pendingReview:
            return LocalizedStringKey("result_manual_review")
        case .denied:
            return LocalizedStringKey("result_cannot_validated")
        case .retakeImages:
            return LocalizedStringKey("result_go_back")
        case .maxEvaluationAttempsExceded:
            return ""
        case .error:
            return LocalizedStringKey("result_error_process")
        }
    }

    func buttonTitle(finalValidation: Bool, evaluationAttemptIsAllowed: Bool) -> LocalizedStringKey {
        switch self {
        case .success:
            if finalValidation {
                return LocalizedStringKey("result_finish")
            } else {
                return LocalizedStringKey("continue")
            }
        case .pendingReview,
                .denied,
                .error,
                .maxEvaluationAttempsExceded:
            return LocalizedStringKey("result_finish")
        case .retakeImages:
            guard evaluationAttemptIsAllowed else {
                return LocalizedStringKey("result_finish")
            }
            return LocalizedStringKey("result_retry")
        }
    }
}
