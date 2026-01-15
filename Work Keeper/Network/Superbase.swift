import Supabase
import Foundation

enum SupabaseConfig {
    private static let plistName = "Supabase"

    private static var dict: [String: Any] {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist") else {
            fatalError("Missing \(plistName).plist in app bundle. Make sure the file exists and is included in the app target.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to read \(plistName).plist")
        }
        guard let obj = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = obj as? [String: Any] else {
            fatalError("Invalid format for \(plistName).plist. Expected a root Dictionary.")
        }
        return dict
    }

    static var url: URL {
        guard let s = dict["SUPABASE_URL"] as? String, let url = URL(string: s) else {
            fatalError("Missing or invalid SUPABASE_URL in \(plistName).plist")
        }
        return url
    }

    static var anonKey: String {
        guard let key = dict["SUPABASE_ANON_KEY"] as? String, !key.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY in \(plistName).plist")
        }
        return key
    }
}
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
                       supabaseKey: SupabaseConfig.anonKey
        )
    }
}
