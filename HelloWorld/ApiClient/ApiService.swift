//
//  ApiService.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - ApiService
//
// Cliente HTTP genérico basado en el ejemplo de clase y adaptado a iNaturalist:
//
//   • `request`: peticiones con parámetros en la URL o en el cuerpo (JSON).
//   • `upload`:  envío de una imagen como multipart/form-data (identificación).
//
// Ambas decodifican la respuesta JSON al tipo indicado y traducen los fallos
// a NetworkingError.
final class ApiService: NSObject {

    static let shared = ApiService()

    // MARK: - Properties

    private let configuration: URLSessionConfiguration
    private lazy var session = URLSession(configuration: self.configuration)

    // MARK: - Init

    override init() {
        self.configuration = URLSessionConfiguration.default
        self.configuration.timeoutIntervalForRequest = 60
        self.configuration.timeoutIntervalForResource = 60
    }

    // MARK: - Requests

    /// Ejecuta una petición y decodifica la respuesta.
    /// - Parameters:
    ///   - requestModel: Endpoint, método, encabezados, codificación y parámetros.
    ///   - modelType: Tipo Decodable esperado en la respuesta.
    func request<T: Decodable>(_ requestModel: ApiRequestModel, _ modelType: T.Type) async throws -> T {
        var request = try makeRequest(for: requestModel)

        if let parameters = requestModel.parameters {
            switch requestModel.encoding {
            case .url:
                // Los parámetros se agregan a la URL: ?q=quercus&locale=es
                var components = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
                let existing = components?.percentEncodedQuery.map { $0 + "&" } ?? ""
                components?.percentEncodedQuery = existing + query(parameters)
                request.url = components?.url

            case .json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }

        return try await perform(request, modelType)
    }

    /// Envía una imagen JPEG como multipart/form-data y decodifica la respuesta.
    /// - Parameters:
    ///   - requestModel: Endpoint, método y encabezados (la codificación se ignora).
    ///   - imageData: Bytes de la imagen JPEG.
    ///   - fieldName: Nombre del campo que espera el servidor (en iNaturalist, «image»).
    ///   - modelType: Tipo Decodable esperado en la respuesta.
    func upload<T: Decodable>(
        _ requestModel: ApiRequestModel,
        imageData: Data,
        fieldName: String = "image",
        _ modelType: T.Type
    ) async throws -> T {
        var request = try makeRequest(for: requestModel)

        // Cada parte del formulario se separa con un delimitador único.
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"photo.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        request.httpBody = body

        return try await perform(request, modelType)
    }

    // MARK: - Helpers

    /// Construye la petición base: URL, método y encabezados.
    private func makeRequest(for requestModel: ApiRequestModel) throws -> URLRequest {
        guard let url = URL(string: BaseUrl.getUrl(with: requestModel.endpoint)) else {
            throw NetworkingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = requestModel.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        switch requestModel.header {
        case .Authorization:
            // iNaturalist espera el JWT tal cual, sin el prefijo «Bearer».
            guard let token = ApiConfiguration.iNaturalistToken else { throw NetworkingError.unauthorized }
            request.setValue(token, forHTTPHeaderField: "Authorization")
        case .noHeader:
            break
        }
        return request
    }

    /// Envía la petición, valida el código HTTP y decodifica la respuesta.
    private func perform<T: Decodable>(_ request: URLRequest, _ modelType: T.Type) async throws -> T {
        #if DEBUG
        print("-------- REQUEST --------")
        print("\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "N/A")")
        #endif

        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .timedOut:                 throw NetworkingError.timeOut
            case .networkConnectionLost:    throw NetworkingError.connectionLost
            case .notConnectedToInternet:   throw NetworkingError.noConnection
            default:                        throw NetworkingError.generalError
            }
        }

        let (data, response) = result
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.httpResponseError
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401, 403:
            throw NetworkingError.unauthorized
        case 500...599:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.generalError
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("⚠️ ApiService: error al decodificar \(T.self): \(error)")
            #endif
            throw NetworkingError.decodingError
        }
    }

    /// Convierte los parámetros en una cadena de consulta: clave=valor&clave=valor.
    func query(_ parameters: ParameterType) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            guard let value = parameters[key] else { continue }
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape("\(value.boolValue)")))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape("\(bool)")))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }

    /// Codifica los caracteres reservados para que viajen correctamente en la URL.
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

// MARK: - Convenience checks
fileprivate extension NSNumber {
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}
