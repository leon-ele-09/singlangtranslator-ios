import Network
import Foundation

class TranslationClient: ObservableObject {
    var browser: NWBrowser?
    // Referencia al ViewModel para actualizar la vista
    var viewModel: SignLanguageViewModel?
    
    // Busca dispositivos emisores en la red local
    func startBrowsing() {
        let parameters = NWParameters.udp
        let browserDescriptor = NWBrowser.Descriptor.bonjour(type: "_eshu._udp", domain: nil)
        browser = NWBrowser(for: browserDescriptor, using: parameters)
        
        browser?.browseResultsChangedHandler = { results, changes in
            if let result = results.first {
                self.connect(to: result.endpoint)
            }
        }
        browser?.start(queue: .main)
    }
    
    // Establece la conexion punto a punto
    private func connect(to endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .udp)
        connection.stateUpdateHandler = { state in
            if state == .ready { self.receiveData(on: connection) }
        }
        connection.start(queue: .main)
    }
    
    // Escucha paquetes entrantes de forma continua
    private func receiveData(on connection: NWConnection) {
        connection.receiveMessage { (data, context, isComplete, error) in
            if let data = data, let packet = try? JSONDecoder().decode(TranslationPacket.self, from: data) {
                DispatchQueue.main.async {
                    // Aqui actualizas tu SignLanguageViewModel existente
                    self.viewModel?.currentSign = packet.text
                    self.viewModel?.currentPrecision = packet.precision
                    self.viewModel?.showAmbiguity = packet.isAmbiguous
                }
            }
            // Mantiene el canal abierto para el siguiente paquete
            self.receiveData(on: connection)
        }
    }
}
