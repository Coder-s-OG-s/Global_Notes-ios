import SwiftUI

/// AI-powered email generator using GeminiService.
struct MailGeneratorView: View {
    @StateObject private var viewModel = MailGeneratorViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Recipient", text: $viewModel.recipient)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)

                    TextField("Subject", text: $viewModel.subject)

                    Picker("Tone", selection: $viewModel.tone) {
                        ForEach(MailGeneratorViewModel.tones, id: \.self) { tone in
                            Text(tone).tag(tone)
                        }
                    }
                }

                Section("Key Points") {
                    TextEditor(text: $viewModel.keyPoints)
                        .frame(minHeight: 100)
                }

                Section {
                    Button {
                        Task { await viewModel.generateEmail() }
                    } label: {
                        HStack {
                            Label("Generate Email", systemImage: "sparkles")
                            if viewModel.isGenerating {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.keyPoints.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isGenerating)
                }

                if let error = viewModel.error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                if !viewModel.generatedEmail.isEmpty {
                    Section("Generated Email") {
                        ScrollView {
                            Text(viewModel.generatedEmail)
                                .font(.body)
                                .textSelection(.enabled)
                        }
                        .frame(minHeight: 200)

                        Button {
                            viewModel.copyToClipboard()
                        } label: {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Mail Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
