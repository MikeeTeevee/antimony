"use strict";
// Data models mirroring Dart models for TypeScript
Object.defineProperty(exports, "__esModule", { value: true });
exports.CompletionState = exports.QuestionCategory = exports.ComplianceType = void 0;
var ComplianceType;
(function (ComplianceType) {
    ComplianceType["SOX"] = "sox";
})(ComplianceType || (exports.ComplianceType = ComplianceType = {}));
var QuestionCategory;
(function (QuestionCategory) {
    QuestionCategory["AccessControls"] = "accessControls";
    QuestionCategory["ChangeManagement"] = "changeManagement";
    QuestionCategory["FinancialReporting"] = "financialReporting";
    QuestionCategory["ItControls"] = "itControls";
    QuestionCategory["Documentation"] = "documentation";
    QuestionCategory["Testing"] = "testing";
})(QuestionCategory || (exports.QuestionCategory = QuestionCategory = {}));
var CompletionState;
(function (CompletionState) {
    CompletionState["NotStarted"] = "notStarted";
    CompletionState["Partial"] = "partial";
    CompletionState["Complete"] = "complete";
})(CompletionState || (exports.CompletionState = CompletionState = {}));
//# sourceMappingURL=types.js.map