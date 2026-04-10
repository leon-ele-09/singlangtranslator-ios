import Network
import Foundation

class TranslationServer {
    var listener: NWListener?
    var connection: NWConnection?
    
    // Inicia el servicio de escucha local
    func startServer() {
        do {
            // Se usa UDP para transmitir datos sin retardo
            listener = try NWListener(using: .udp)
            // Define el nombre del servicio para que el otro dispositivo lo encuentre
            listener?.service = NWListener.Service(name: "EshuTranslation", type: "_eshu._udp")
            
            listener?.newConnectionHandler = { newConnection in
                self.connection = newConnection
                self.connection?.start(queue: .main)
                print("Receptor conectado")
            }
            
            listener?.start(queue: .main)
        } catch {
            print("Error al iniciar el servidor local")
        }
    }
    
    // Envia la traduccion procesada al otro dispositivo
    func sendTranslation(text: String, precision: Int, ambiguous: Bool) {
        let packet = TranslationPacket(text: text, precision: precision, isAmbiguous: ambiguous, timestamp: Date())
        guard let data = try? JSONEncoder().encode(packet) else { return }
        
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error { print("Error de envio: \(error)") }
        }))
    }
}
