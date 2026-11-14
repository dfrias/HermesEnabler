import SwiftUI

struct DiagnosticsView: View {
    var model: ContentModel
    @State private var busy = false

    var body: some View {
        List {
            Section("Watch") {
                labeled("Build", model.diagnosticBuild)
                labeled("watchOS", model.diagnosticProductVersion)
                labeled("Model", model.diagnosticMachine)
            }

            Section("MobileGestalt cache") {
                labeled("CacheUUID", model.diagnosticCacheUUID)
                labeled("CacheData length", model.diagnosticCacheLengthText)
                labeled("Layout known", model.diagnosticLayoutKnown ? "yes" : "no")
            }

            if let error = model.diagnosticError, !error.isEmpty {
                Section("Status") {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            } else if !model.diagnosticReportText.isEmpty {
                Section("Report") {
                    Text(model.diagnosticReportText)
                        .font(.system(.caption2, design: .monospaced))
                        .textSelection(.enabled)
                }

                Section("Export") {
                    ShareLink(
                        item: model.diagnosticReportText,
                        subject: Text("HermesEnabler layout diagnostic"),
                        message: Text("Read-only MobileGestalt layout dump for adding a watchOS build.")
                    ) {
                        Label("Share text report", systemImage: "square.and.arrow.up")
                    }

                    if let reportURL = model.diagnosticReportURL {
                        ShareLink(item: reportURL) {
                            Label("Share report file", systemImage: "doc.text")
                        }
                    }

                    if let cacheURL = model.diagnosticCacheURL {
                        ShareLink(item: cacheURL) {
                            Label("Share MobileGestalt cache", systemImage: "externaldrive")
                        }
                    }

                    Text("This diagnostic only reads MobileGestalt. It does not enable features or write the system cache. Attach both files to the GitHub issue.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button {
                    busy = true
                    model.refreshDiagnostic()
                    busy = false
                } label: {
                    if busy {
                        ProgressView()
                    } else {
                        Label("Refresh dump", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .navigationTitle("Diagnostics")
        .onAppear {
            if model.diagnosticReportText.isEmpty && model.diagnosticError == nil {
                model.refreshDiagnostic()
            }
        }
    }

    @ViewBuilder
    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.footnote.monospaced())
                .textSelection(.enabled)
        }
    }
}
