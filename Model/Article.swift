import Foundation
import SwiftData

@Model
class Article: Identifiable {
    let id: UUID = UUID()
    var added: Date
    var reloaded: Date
    var name: String
    var storedRevisions: [Revision]
    var notes: String
    var wiki: Wiki
    
    init(name: String, wiki: Wiki) {
        self.added = Date()
        self.name = name
        self.storedRevisions = []
        self.reloaded = Date.distantPast
        self.notes = ""
        self.wiki = wiki
    }

    func loadRevisions() async {
        if let newRevisions = await fetchRevisions(article: self) {
            var revisionsToAdd: [Revision] = []
            for newRevision in newRevisions {
                if !containsRevision(revision: newRevision) {
                    revisionsToAdd.append(newRevision)
                }
            }
            // Combine with existing revisions on main thread
            // SwiftData will crash when modifying stored revisions on another thread
            DispatchQueue.main.async { [self, revisionsToAdd] in
                storedRevisions.append(contentsOf: revisionsToAdd)
            }
            self.reloaded = Date()
        }
    }

    /// Checks if article already has a certain revision stored
    /// - Parameter revision: The revision to check
    /// - Returns: Whether the provided revision was found in the stored revisions
    private func containsRevision(revision: Revision) -> Bool {
        for r in storedRevisions {
            if r.sameAs(other: revision) {
                return true
            }
        }
        return false
    }

    /// Called by UI when interacting with articles to reload revisions when necessary
    func freshRevisions() async {
        if shouldReloadRevisions() {
            await loadRevisions()
        }
    }
    
    func shouldReloadRevisions() -> Bool {
        let fifteenMinutesAgo = Calendar.current.date(byAdding: .minute, value: -15, to: Date())!
        return reloaded < fifteenMinutesAgo
    }

    func countUnseenRevisions() -> Int {
        var count = 0
        for revision in storedRevisions {
            if !revision.seen {
                count += 1
            }
        }
        return count
    }

    func countRevisions() -> Int {
        return storedRevisions.count
    }

    func setAllRevisionRead(to: Bool) {
        for revision in storedRevisions {
            revision.seen = to
        }
    }

    var chronologicalRevisions: [Revision] {
        get {
            storedRevisions.sorted(by: { $0.timestamp > $1.timestamp })
        }
        set {
            storedRevisions = newValue
        }
    }
}
