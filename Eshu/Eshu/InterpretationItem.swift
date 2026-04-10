//
//  InterpretationItem.swift
//  Eshu
//
//  Created by CETYS Universidad on 09/04/26.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Models
struct InterpretationItem: Identifiable {
    let id = UUID()
    var text: String
    let time: String
    var isAmbiguous: Bool
    var suggestions: [String]?
}

// MARK: - Main View
struct SignLanguageInterpreterView: View {
    @StateObject private var viewModel = SignLanguageViewModel()

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 0.99)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HeaderView(onSettingsTapped: {
                    // Acción de configuración
                })

                // Main Content
                HStack(spacing: 24) {
                    // Camera Section
                    CameraSection(
                        cameraActive: $viewModel.cameraActive,
                        isDetecting: viewModel.isDetecting
                    )

                    // Interpretation Panel
                    InterpretationPanel(
                        currentSign: viewModel.currentSign,
                        showAmbiguity: viewModel.showAmbiguity,
                        ambiguousSuggestions: viewModel.ambiguousSuggestions,
                        precision: viewModel.currentPrecision,
                        onSuggestionSelect: { suggestion in
                            viewModel.selectSuggestion(suggestion)
                        },
                        history: viewModel.history,
                        editingId: $viewModel.editingId,
                        editText: $viewModel.editText,
                        onEditStart: { item in
                            viewModel.startEditing(item)
                        },
                        onEditSave: {
                            viewModel.saveEdit()
                        },
                        onEditCancel: {
                            viewModel.cancelEdit()
                        }
                    )
                    .frame(width: 384)
                }
                .padding(32)
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let onSettingsTapped: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Intérprete de Lenguaje de Señas")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))

                Text("Reconocimiento en tiempo real")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))
            }

            Spacer()

            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 2)
                    )
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            Rectangle()
                .fill(Color(red: 0.94, green: 0.96, blue: 0.99))
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.70, green: 0.83, blue: 0.91))
                        .frame(height: 2),
                    alignment: .bottom
                )
        )
    }
}

// MARK: - Camera Section
struct CameraSection: View {
    @Binding var cameraActive: Bool
    let isDetecting: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Vista de Cámara")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))

                Spacer()

                Button(action: { cameraActive.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: cameraActive ? "video.fill" : "video.slash.fill")
                            .font(.system(size: 18))
                        Text(cameraActive ? "Detener" : "Iniciar")
                    }
                    .foregroundColor(cameraActive ? .white : Color(red: 0.00, green: 0.16, blue: 0.29))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(cameraActive ? Color(red: 0.39, green: 0.59, blue: 0.69) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.39, green: 0.59, blue: 0.69), lineWidth: 2)
                            )
                    )
                }
            }

            // Camera Frame
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isDetecting ? Color(red: 0.39, green: 0.59, blue: 0.69) : Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: isDetecting)
                    )

                if !cameraActive {
                    VStack(spacing: 16) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 64))
                            .foregroundColor(Color(red: 0.70, green: 0.83, blue: 0.91))

                        Text("Cámara desactivada")
                            .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))
                    }
                } else {
                    CameraWireframeView(isDetecting: isDetecting)
                }

                // Status Indicator
                if cameraActive {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(red: 0.39, green: 0.59, blue: 0.69))
                                    .frame(width: 8, height: 8)
                                    .opacity(isDetecting ? 1 : 0.3)
                                    .animation(.easeInOut(duration: 2).repeatForever(), value: isDetecting)

                                Text("Activo")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 1)
                                    )
                            )
                            .padding(16)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Camera Wireframe View
struct CameraWireframeView: View {
    let isDetecting: Bool

    var body: some View {
        ZStack {
            // Grid
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.85, green: 0.91, blue: 0.96), style: StrokeStyle(lineWidth: 2, dash: [5]))
                .padding(32)

            // Grid lines
            VStack(spacing: 0) {
                ForEach(0..<3) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<3) { col in
                            Rectangle()
                                .stroke(Color(red: 0.91, green: 0.95, blue: 0.97), lineWidth: 1)
                        }
                    }
                }
            }
            .padding(32)

            // Center focus
            Circle()
                .stroke(Color(red: 0.39, green: 0.59, blue: 0.69), lineWidth: 2)
                .frame(width: 200, height: 200)
                .scaleEffect(isDetecting ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.8), value: isDetecting)
                .overlay(
                    VStack(spacing: 8) {
                        Text("Manos detectadas")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isDetecting ? Color(red: 0.91, green: 0.96, blue: 0.97) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isDetecting ? Color(red: 0.39, green: 0.59, blue: 0.69) : Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 2)
                            )
                    )
                )

            // Corner brackets
            VStack {
                HStack {
                    CornerBracket(corners: [.topLeft])
                    Spacer()
                    CornerBracket(corners: [.topRight])
                }
                Spacer()
                HStack {
                    CornerBracket(corners: [.bottomLeft])
                    Spacer()
                    CornerBracket(corners: [.bottomRight])
                }
            }
            .padding(48)
        }
        .padding(32)
    }
}

struct CornerBracket: View {
    let corners: UIRectCorner

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 48, height: 48)
            .overlay(
                Path { path in
                    if corners.contains(.topLeft) {
                        path.move(to: CGPoint(x: 48, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 48))
                    }
                    if corners.contains(.topRight) {
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 48, y: 0))
                        path.addLine(to: CGPoint(x: 48, y: 48))
                    }
                    if corners.contains(.bottomLeft) {
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 48))
                        path.addLine(to: CGPoint(x: 48, y: 48))
                    }
                    if corners.contains(.bottomRight) {
                        path.move(to: CGPoint(x: 0, y: 48))
                        path.addLine(to: CGPoint(x: 48, y: 48))
                        path.addLine(to: CGPoint(x: 48, y: 0))
                    }
                }
                .stroke(Color(red: 0.39, green: 0.59, blue: 0.69), lineWidth: 2)
            )
    }
}

// MARK: - Interpretation Panel
struct InterpretationPanel: View {
    let currentSign: String
    let showAmbiguity: Bool
    let ambiguousSuggestions: [String]
    let precision: Int
    let onSuggestionSelect: (String) -> Void
    let history: [InterpretationItem]
    @Binding var editingId: UUID?
    @Binding var editText: String
    let onEditStart: (InterpretationItem) -> Void
    let onEditSave: () -> Void
    let onEditCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Current Detection
            CurrentDetectionView(
                currentSign: currentSign,
                showAmbiguity: showAmbiguity,
                ambiguousSuggestions: ambiguousSuggestions,
                precision: precision,
                onSuggestionSelect: onSuggestionSelect
            )

            // History
            HistoryView(
                history: history,
                editingId: $editingId,
                editText: $editText,
                onEditStart: onEditStart,
                onEditSave: onEditSave,
                onEditCancel: onEditCancel
            )
        }
    }
}

// MARK: - Current Detection View
struct CurrentDetectionView: View {
    let currentSign: String
    let showAmbiguity: Bool
    let ambiguousSuggestions: [String]
    let precision: Int
    let onSuggestionSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Interpretación")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))

                Spacer()

                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.69))
            }
            .padding(24)

            // Main interpretation
            if currentSign.isEmpty {
                VStack {
                    Text("Esperando señas...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.70, green: 0.83, blue: 0.91))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.85, green: 0.91, blue: 0.96), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    if showAmbiguity {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.83, green: 0.76, blue: 0.26))

                            Text("Señal ambigua")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.83, green: 0.76, blue: 0.26))
                        }
                    }

                    Text("\"\(currentSign)\"")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(showAmbiguity ? Color(red: 1.00, green: 0.98, blue: 0.94) : Color(red: 0.97, green: 0.98, blue: 1.00))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showAmbiguity ? Color(red: 0.96, green: 0.76, blue: 0.42) : Color(red: 0.85, green: 0.91, blue: 0.96), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 24)
            }

            // Ambiguity suggestions
            if showAmbiguity && !ambiguousSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle()
                        .fill(Color(red: 0.91, green: 0.95, blue: 0.97))
                        .frame(height: 1)

                    Text("¿Quisiste decir?")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))

                    VStack(spacing: 8) {
                        ForEach(ambiguousSuggestions, id: \.self) { suggestion in
                            Button(action: { onSuggestionSelect(suggestion) }) {
                                Text(suggestion)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.85, green: 0.91, blue: 0.96), lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            // Precision
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color(red: 0.91, green: 0.95, blue: 0.97))
                    .frame(height: 1)

                HStack {
                    Text("Precisión")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))

                    Spacer()

                    Text("\(precision)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(showAmbiguity ? Color(red: 0.83, green: 0.76, blue: 0.26) : Color(red: 0.39, green: 0.59, blue: 0.69))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.91, green: 0.95, blue: 0.97))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(showAmbiguity ? Color(red: 0.83, green: 0.76, blue: 0.26) : Color(red: 0.39, green: 0.59, blue: 0.69))
                            .frame(width: geometry.size.width * CGFloat(precision) / 100)
                    }
                }
                .frame(height: 6)
            }
            .padding(24)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 2)
                )
        )
    }
}

// MARK: - History View
struct HistoryView: View {
    let history: [InterpretationItem]
    @Binding var editingId: UUID?
    @Binding var editText: String
    let onEditStart: (InterpretationItem) -> Void
    let onEditSave: () -> Void
    let onEditCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historial")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))
                .padding(.horizontal, 24)
                .padding(.top, 24)

            ScrollView {
                VStack(spacing: 8) {
                    if history.isEmpty {
                        Text("Sin historial")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.70, green: 0.83, blue: 0.91))
                            .frame(maxHeight: .infinity)
                            .padding(40)
                    } else {
                        ForEach(history) { item in
                            HistoryItemView(
                                item: item,
                                isEditing: editingId == item.id,
                                editText: $editText,
                                onEditStart: { onEditStart(item) },
                                onEditSave: onEditSave,
                                onEditCancel: onEditCancel
                            )
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.70, green: 0.83, blue: 0.91), lineWidth: 2)
                )
        )
    }
}

// MARK: - History Item View
struct HistoryItemView: View {
    let item: InterpretationItem
    let isEditing: Bool
    @Binding var editText: String
    let onEditStart: () -> Void
    let onEditSave: () -> Void
    let onEditCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                VStack(spacing: 8) {
                    TextField("Editar texto", text: $editText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 14))

                    HStack(spacing: 8) {
                        Button(action: onEditSave) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14))
                                Text("Guardar")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.69))
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.39, green: 0.59, blue: 0.69), lineWidth: 2)
                            )
                        }

                        Button(action: onEditCancel) {
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14))
                                Text("Cancelar")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.85, green: 0.91, blue: 0.96), lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(12)
            } else {
                HStack(alignment: .top) {
                    if item.isAmbiguous {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.83, green: 0.76, blue: 0.26))
                    }

                    Text(item.text)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.00, green: 0.16, blue: 0.29))

                    Spacer()

                    HStack(spacing: 8) {
                        Text(item.time)
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.36, green: 0.49, blue: 0.60))

                        Button(action: onEditStart) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.69))
                        }
                    }
                }
                .padding(12)

                if item.isAmbiguous, let suggestions = item.suggestions {
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(Color(red: 0.96, green: 0.90, blue: 0.76))
                            .frame(height: 1)

                        Text("Otras opciones:")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.83, green: 0.76, blue: 0.26))

                        HStack(spacing: 4) {
                            ForEach(suggestions.filter { $0 != item.text }, id: \.self) { suggestion in
                                Text(suggestion)
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 0.83, green: 0.76, blue: 0.26))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(red: 0.96, green: 0.90, blue: 0.76), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(item.isAmbiguous ? Color(red: 1.00, green: 0.98, blue: 0.94) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.isAmbiguous ? Color(red: 0.96, green: 0.76, blue: 0.42) : Color(red: 0.85, green: 0.91, blue: 0.96), lineWidth: 1)
                )
        )
    }
}

// MARK: - View Model
class SignLanguageViewModel: ObservableObject {
    @Published var cameraActive = false
    @Published var currentSign = ""
    @Published var isDetecting = false
    @Published var history: [InterpretationItem] = []
    @Published var editingId: UUID?
    @Published var editText = ""
    @Published var showAmbiguity = false
    @Published var ambiguousSuggestions: [String] = []
    @Published var currentPrecision = 94

    private var timer: Timer?

    private let mockSigns = ["Hola", "Gracias", "Por favor", "Adiós", "Sí", "No", "Ayuda", "¿Cómo estás?"]
    private let ambiguityPairs: [(main: String, suggestions: [String])] = [
        ("Gracias", ["Gracias", "De nada", "Perdón"]),
        ("Hola", ["Hola", "Buenos días", "Buenas tardes"]),
        ("Sí", ["Sí", "Entiendo", "Correcto"])
    ]

    func toggleCamera() {
        cameraActive.toggle()

        if cameraActive {
            startDetection()
        } else {
            stopDetection()
        }
    }

    private func startDetection() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.simulateDetection()
        }
    }

    private func stopDetection() {
        timer?.invalidate()
        timer = nil
    }

    private func simulateDetection() {
        let isAmbiguous = Double.random(in: 0...1) > 0.6
        var sign: String
        var suggestions: [String]?

        if isAmbiguous, !ambiguityPairs.isEmpty {
            let pair = ambiguityPairs.randomElement()!
            sign = pair.main
            suggestions = pair.suggestions
            showAmbiguity = true
            ambiguousSuggestions = pair.suggestions
            currentPrecision = 67
        } else {
            sign = mockSigns.randomElement()!
            showAmbiguity = false
            ambiguousSuggestions = []
            currentPrecision = 94
        }

        isDetecting = true
        currentSign = sign

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeStr = formatter.string(from: Date())

        let newItem = InterpretationItem(
            text: sign,
            time: timeStr,
            isAmbiguous: isAmbiguous,
            suggestions: suggestions
        )

        history.insert(newItem, at: 0)
        if history.count > 8 {
            history.removeLast()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.isDetecting = false
        }
    }

    func startEditing(_ item: InterpretationItem) {
        editingId = item.id
        editText = item.text
    }

    func saveEdit() {
        guard let editingId = editingId else { return }

        if let index = history.firstIndex(where: { $0.id == editingId }) {
            history[index].text = editText
            history[index].isAmbiguous = false
        }

        cancelEdit()
    }

    func cancelEdit() {
        editingId = nil
        editText = ""
    }

    func selectSuggestion(_ suggestion: String) {
        currentSign = suggestion

        if let firstItem = history.first {
            if let index = history.firstIndex(where: { $0.id == firstItem.id }) {
                history[index].text = suggestion
                history[index].isAmbiguous = false
            }
        }

        showAmbiguity = false
        currentPrecision = 94
    }
}

// MARK: - Preview
struct SignLanguageInterpreterView_Previews: PreviewProvider {
    static var previews: some View {
        SignLanguageInterpreterView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
