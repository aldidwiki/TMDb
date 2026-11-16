import Combine
import Foundation
import Observation

@MainActor
@Observable
final class BackdropGalleryPresenter {
    enum State {
        case idle
        case loading
        case loaded([ImageModel])
        case failed
    }

    private let fetchBackdrops: () -> AnyPublisher<[ImageModel], Error>
    private var request: AnyCancellable?
    private(set) var state: State = .idle

    init(fetchBackdrops: @escaping () -> AnyPublisher<[ImageModel], Error>) {
        self.fetchBackdrops = fetchBackdrops
    }

    func load() {
        switch state {
        case .idle, .failed:
            break
        case .loading, .loaded:
            return
        }
        state = .loading

        request = fetchBackdrops()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.state = .failed
                } else if let self, case .loading = self.state {
                    self.state = .loaded([])
                }
            } receiveValue: { [weak self] backdrops in
                var seen: Set<String> = []
                let photos = backdrops.filter { photo in
                    photo.filePath.hasPrefix("/") && photo.filePath.count > 1
                        && seen.insert(photo.filePath).inserted
                }
                self?.state = .loaded(photos)
            }
    }
}
