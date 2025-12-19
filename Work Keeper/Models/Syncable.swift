import Foundation
protocol Syncable {
    var id: UUID { get }
    var remoteId: UUID? { get set }
    var updatedAt: Date { get set }
    var deletedAt: Date? { get set }
}
