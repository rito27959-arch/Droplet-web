// ============================================================================
// LE PONT « INTELLIGENCE » D'iOS — transcrire et traduire, hors ligne.
// ----------------------------------------------------------------------------
// Côté Dart, `service_intelligence.dart` appelle le canal
// `com.droplet.droplet/intelligence` avec trois méthodes. Android y répond
// via `IntelligenceBridge.kt` ; voici la réponse d'iOS :
//
//   • transcriptionDisponible → la reconnaissance vocale SUR L'APPAREIL
//     existe-t-elle pour cette langue (`supportsOnDeviceRecognition`) ?
//   • transcrire  → `SFSpeechURLRecognitionRequest` sur le fichier m4a du
//     vocal, avec `requiresOnDeviceRecognition = true` : rien ne part chez
//     Apple, ce qui est la seule option acceptable pour un message chiffré.
//   • traduire    → le cadre Translation d'iOS 18. Si le modèle de la langue
//     manque, iOS propose lui-même de l'installer.
//
// ⚠️ À FAIRE UNE FOIS DANS LE PROJET Xcode :
//   1. Ajouter ce fichier à la cible Runner.
//   2. Info.plist : NSSpeechRecognitionUsageDescription (« Droplet transcrit
//      vos messages vocaux directement sur votre téléphone. »).
//   3. AppDelegate.swift, dans didFinishLaunchingWithOptions, avant le
//      `return` :
//         if let registrar = self.registrar(forPlugin: "IntelligenceBridge") {
//           IntelligenceBridge.register(with: registrar)
//         }
// ============================================================================

import Flutter
import NaturalLanguage
import Speech
import SwiftUI
import UIKit

#if canImport(Translation)
import Translation
#endif

public class IntelligenceBridge: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let canal = FlutterMethodChannel(
      name: "com.droplet.droplet/intelligence",
      binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(IntelligenceBridge(), channel: canal)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "transcriptionDisponible":
      let enLigne = args["enLigne"] as? Bool ?? false
      result(IntelligenceBridge.moteurVocalPresent(langue: nil, enLigne: enLigne))

    case "transcrire":
      guard let chemin = args["chemin"] as? String else {
        result(["etat": "echec"])
        return
      }
      transcrire(chemin: chemin, langue: args["langue"] as? String,
                 enLigne: args["enLigne"] as? Bool ?? false, result: result)

    case "traduire":
      guard let texte = args["texte"] as? String,
            let cible = args["cible"] as? String else {
        result(["etat": "echec"])
        return
      }
      traduire(texte: texte, cible: cible, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // ── Transcription ────────────────────────────────────────────────────

  private static func langue(_ etiquette: String?) -> Locale {
    guard let etiquette = etiquette, !etiquette.isEmpty else { return Locale.current }
    return Locale(identifier: etiquette.replacingOccurrences(of: "_", with: "-"))
  }

  /// Hors ligne quand l'appareil sait faire ; sinon, seulement si
  /// l'utilisateur a autorisé le service en ligne d'Apple.
  private static func moteurVocalPresent(langue etiquette: String?, enLigne: Bool) -> Bool {
    guard let moteur = SFSpeechRecognizer(locale: langue(etiquette)) else { return false }
    return moteur.isAvailable && (moteur.supportsOnDeviceRecognition || enLigne)
  }

  private func transcrire(chemin: String, langue etiquette: String?, enLigne: Bool,
                          result: @escaping FlutterResult) {
    let locale = IntelligenceBridge.langue(etiquette)
    guard FileManager.default.fileExists(atPath: chemin) else {
      result(["etat": "echec"])
      return
    }
    guard let moteur = SFSpeechRecognizer(locale: locale),
          moteur.isAvailable, moteur.supportsOnDeviceRecognition || enLigne else {
      result(["etat": "indisponible"])
      return
    }

    SFSpeechRecognizer.requestAuthorization { statut in
      guard statut == .authorized else {
        DispatchQueue.main.async { result(["etat": "indisponible"]) }
        return
      }
      let requete = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: chemin))
      // Sur l'appareil dès qu'il sait faire. Le serveur d'Apple (gratuit,
      // environ une minute d'audio par requête) seulement si l'appareil n'a
      // pas de moteur pour cette langue ET que l'utilisateur l'a permis.
      requete.requiresOnDeviceRecognition = moteur.supportsOnDeviceRecognition
      requete.shouldReportPartialResults = false
      if #available(iOS 16.0, *) { requete.addsPunctuation = true }

      var repondu = false
      moteur.recognitionTask(with: requete) { reponse, erreur in
        guard !repondu else { return }
        if let reponse = reponse, reponse.isFinal {
          repondu = true
          let texte = reponse.bestTranscription.formattedString
            .trimmingCharacters(in: .whitespacesAndNewlines)
          DispatchQueue.main.async {
            if texte.isEmpty {
              result(["etat": "vide"])
            } else {
              result(["etat": "ok", "texte": texte, "source": locale.identifier])
            }
          }
        } else if let erreur = erreur {
          repondu = true
          // 1110 : aucune parole reconnue — ce n'est pas une panne.
          let code = (erreur as NSError).code
          DispatchQueue.main.async {
            result(["etat": code == 1110 ? "vide" : "echec"])
          }
        }
      }
    }
  }

  // ── Traduction ───────────────────────────────────────────────────────

  private func traduire(texte: String, cible: String, result: @escaping FlutterResult) {
    let detecteur = NLLanguageRecognizer()
    detecteur.processString(texte)
    let source = detecteur.dominantLanguage?.rawValue
    let cibleCourte = cible.split(separator: "-").first.map(String.init) ?? cible
    if let source = source,
       source.split(separator: "-").first.map(String.init) == cibleCourte {
      result(["etat": "identique"])
      return
    }

    #if canImport(Translation)
    if #available(iOS 18.0, *) {
      TraducteurApple.partage.traduire(texte: texte, source: source, cible: cibleCourte) { traduit, etat in
        if let traduit = traduit, !traduit.isEmpty {
          result(["etat": "ok", "texte": traduit, "source": source ?? ""])
        } else {
          result(["etat": etat])
        }
      }
      return
    }
    #endif
    result(["etat": "indisponible"])
  }
}

#if canImport(Translation)

/// Le cadre Translation ne se pilote que depuis SwiftUI : on accroche donc une
/// vue invisible d'un point de côté, le temps d'une traduction.
@available(iOS 18.0, *)
final class TraducteurApple {

  static let partage = TraducteurApple()

  private var hote: UIViewController?

  func traduire(texte: String, source: String?, cible: String,
                fin: @escaping (String?, String) -> Void) {
    DispatchQueue.main.async {
      guard let racine = TraducteurApple.racine() else {
        fin(nil, "indisponible")
        return
      }
      let configuration = TranslationSession.Configuration(
        source: source.map { Locale.Language(identifier: $0) },
        target: Locale.Language(identifier: cible))

      var termine = false
      let vue = VueTraduction(texte: texte, configuration: configuration) { traduit, etat in
        guard !termine else { return }
        termine = true
        self.retirer()
        fin(traduit, etat)
      }
      let hote = UIHostingController(rootView: vue)
      hote.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
      hote.view.alpha = 0.01
      hote.view.isUserInteractionEnabled = false
      racine.addChild(hote)
      racine.view.addSubview(hote.view)
      hote.didMove(toParent: racine)
      self.hote = hote
    }
  }

  private func retirer() {
    hote?.willMove(toParent: nil)
    hote?.view.removeFromSuperview()
    hote?.removeFromParent()
    hote = nil
  }

  private static func racine() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    for scene in scenes {
      if let fenetre = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
        return fenetre.rootViewController
      }
    }
    return nil
  }
}

@available(iOS 18.0, *)
private struct VueTraduction: View {
  let texte: String
  let configuration: TranslationSession.Configuration
  let fin: (String?, String) -> Void

  var body: some View {
    Color.clear
      .translationTask(configuration) { session in
        do {
          let reponse = try await session.translate(texte)
          fin(reponse.targetText, "ok")
        } catch {
          // Modèle absent et téléchargement refusé, langue non gérée…
          fin(nil, "modele")
        }
      }
  }
}

#endif
