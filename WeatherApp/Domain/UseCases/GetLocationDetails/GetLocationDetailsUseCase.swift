import Foundation
import Combine

protocol GetLocationDetailsUseCaseProtocol {
    func getLocationDetails(for id: Int) -> AnyPublisher<LocationDetails, Error>
}

protocol GetLocationDetailsRepositoryProtocol {
    func getLocationDetails(for id: Int) -> AnyPublisher<LocationDetails, Error>
}

// Just to keep consistency for the architecture and have separation between repositories and use cases
// I could remove it but I want to keep the manier of having networking done in repositories
typealias GetLocationDetailsUseCase = GetLocationDetailsRepository
