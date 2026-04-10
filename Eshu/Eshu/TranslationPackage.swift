import Foundation

// Estructura para enviar datos entre dispositivos
struct TranslationPacket: Codable {
    let text: String
    let precision: Int
    let isAmbiguous: Bool
    let timestamp: Date
}
