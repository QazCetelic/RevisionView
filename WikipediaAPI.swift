import Foundation

/// Enum used to represent the various regional Wikipedia subdomains
enum Wiki: Equatable, CaseIterable, Identifiable, Codable {
    case English, Nederlands, Deutsch, Français, Español

    var id: Self {
        return self
    }

    func countryCode() -> String {
        switch self {
            case .English:
                return "en"
            case .Nederlands:
                return "nl"
            case .Deutsch:
                return "de"
            case .Français:
                return "fr"
            case .Español:
                return "es"
        }
    }

    func name() -> String {
        switch self {
            case .English:
                return "English"
            case .Nederlands:
                return "Nederlands"
            case .Deutsch:
                return "Deutsch"
            case .Français:
                return "Français"
            case .Español:
                return "Español"
        }
    }
}

/// Fetches revisions
/// - Parameter article: The article to fetch revisions for
/// - Returns: An array of revisions or nil if something went wrong 
func fetchRevisions(article: Article) async -> [Revision]? {
    guard let url = URL(string: "https://\(article.wiki.countryCode()).wikipedia.org/w/api.php?action=query&prop=revisions&titles=\(article.name)&rvslots=*&rvprop=timestamp|user|parsedcomment|flags|size&format=json&rvlimit=50")
    else {
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if  let query = json?["query"] as? [String: Any],
            let pages = query["pages"] as? [String: Any],
            let firstPage = pages.first,
            let firstPageContent = firstPage.value as? [String: Any],
            let revisions = firstPageContent["revisions"] as? [[String: Any]] {
            
            var revisionList: [Revision] = []
            for revisionObject in revisions {
                if  let user = revisionObject["user"] as? String,
                    let timestamp = revisionObject["timestamp"] as? String,
                    let time = ISO8601DateFormatter().date(from: timestamp),
                    var comment = revisionObject["parsedcomment"] as? String,
                    let size = revisionObject["size"] as? Int {
                    // The HTML on Wikipedia, doesn't have to include the domain. Other applications do.
                    comment.replace("<a href=\"/wiki/", with: "<a href=\"https://\(article.wiki.countryCode()).wikipedia.org/wiki/")
                    let revision = Revision(user: user, timestamp: time, size: size, comment: comment)
                    revisionList.append(revision)
                }
            }
            
            return revisionList
        }
        else {
            return nil
        }
    }
    catch {
        return nil
    }
}

/// Check if a page of an article exists on a certain Wiki
/// - Parameters:
///   - article: The name of the article
///   - wiki: The wiki the article is supposed to be on
/// - Returns: Whether the page for the article exists
func pageExists(article: String, wiki: Wiki) async -> Bool {
    guard let url = URL(string: "https://\(wiki.countryCode()).wikipedia.org/wiki/\(article)")
    else {
        return false
    }
    let request = URLRequest(url: url)
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
    }
    catch {}
    return false
}
