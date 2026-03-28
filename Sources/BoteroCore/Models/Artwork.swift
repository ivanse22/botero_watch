import Foundation

/// Obra del museo; `wallNumber` es el número visible en sala (Flow 02).
public struct Artwork: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public let wallNumber: String
    public let titulo: String
    public let año: String
    public let tecnica: String
    public let sala: String
    public let piso: Int
    public let desc: String
    public let iaRespuesta: String

    public init(
        id: String,
        wallNumber: String,
        titulo: String,
        año: String,
        tecnica: String,
        sala: String,
        piso: Int,
        desc: String,
        iaRespuesta: String
    ) {
        self.id = id
        self.wallNumber = wallNumber
        self.titulo = titulo
        self.año = año
        self.tecnica = tecnica
        self.sala = sala
        self.piso = piso
        self.desc = desc
        self.iaRespuesta = iaRespuesta
    }
}

public struct MuseumCatalog: Codable, Sendable {
    public let version: Int
    public let obras: [Artwork]

    public init(version: Int, obras: [Artwork]) {
        self.version = version
        self.obras = obras
    }

    public static func loadFromModuleBundle() throws -> MuseumCatalog {
        guard let url = Bundle.module.url(forResource: "museum_catalog", withExtension: "json") else {
            throw CatalogError.missingResource
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(MuseumCatalog.self, from: data)
    }
}

public enum CatalogError: Error {
    case missingResource
    case artworkNotFound
}
