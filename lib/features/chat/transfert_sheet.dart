// ============================================================================
// « TRANSFÉRER À… » — la feuille qui manquait.
// ----------------------------------------------------------------------------
// Droplet savait répondre, réagir, copier, supprimer… mais pas FAIRE SUIVRE.
// Un message reçu ne pouvait pas être montré à quelqu'un d'autre autrement
// qu'en le recopiant à la main.
//
// Cette feuille liste les conversations possibles — contacts connus et
// groupes — avec une recherche, et permet d'en choisir PLUSIEURS : transférer
// la même photo à trois personnes est le cas normal, pas l'exception.
//
// Elle ne fait que CHOISIR. L'envoi appartient à `MeshNotifier.transfererMessages`.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/models/mesh_message.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Les conversations choisies pour le transfert.
class CiblesTransfert {
  const CiblesTransfert({required this.contacts, required this.groupes});

  final List<String> contacts;
  final List<String> groupes;

  bool get vide => contacts.isEmpty && groupes.isEmpty;
  int get total => contacts.length + groupes.length;
}

/// Ouvre la feuille de transfert. `null` si on renonce.
Future<CiblesTransfert?> choisirCiblesTransfert(BuildContext context, {required int nombre}) {
  return showModalBottomSheet<CiblesTransfert>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransfertSheet(nombre: nombre),
  );
}

class _TransfertSheet extends StatefulWidget {
  const _TransfertSheet({required this.nombre});

  /// Combien de messages seront transférés (affiché sur le bouton).
  final int nombre;

  @override
  State<_TransfertSheet> createState() => _TransfertSheetState();
}

class _TransfertSheetState extends State<_TransfertSheet> {
  final _recherche = TextEditingController();
  final Set<String> _contacts = {};
  final Set<String> _groupes = {};
  String _filtre = '';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  bool _correspond(String nom) =>
      _filtre.isEmpty || nom.toLowerCase().contains(_filtre.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupes = StorageService.getGroups().where((g) => _correspond(g.name)).toList();
    final contacts = StorageService.getKnownPeers()
        .where((p) => _correspond(p.pseudo))
        .toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    final choisis = _contacts.length + _groupes.length;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusSheet)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: OuroColors.tertiaryLabel,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(l10n.chForwardTo, style: OuroTypography.headline),
                  const Spacer(),
                  OuroRetourIos(child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _recherche,
                onChanged: (v) => setState(() => _filtre = v.trim()),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  hintText: l10n.actionSearch,
                  filled: true,
                  fillColor: OuroColors.tertiarySystemBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final g in groupes)
                    _Ligne(
                      titre: g.name,
                      groupe: true,
                      choisi: _groupes.contains(g.id),
                      onTap: () => setState(() {
                        OuroHaptics.selection();
                        _groupes.contains(g.id) ? _groupes.remove(g.id) : _groupes.add(g.id);
                      }),
                    ),
                  for (final p in contacts)
                    _Ligne(
                      titre: p.pseudo,
                      peerId: p.peerId,
                      choisi: _contacts.contains(p.peerId),
                      onTap: () => setState(() {
                        OuroHaptics.selection();
                        _contacts.contains(p.peerId)
                            ? _contacts.remove(p.peerId)
                            : _contacts.add(p.peerId);
                      }),
                    ),
                  if (groupes.isEmpty && contacts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        l10n.asNoContactsAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: OuroColors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OuroRetourIos(child: FilledButton(
                    onPressed: choisis == 0
                        ? null
                        : () => Navigator.of(context).pop(CiblesTransfert(
                              contacts: _contacts.toList(),
                              groupes: _groupes.toList(),
                            )),
                    child: Text(
                      choisis == 0
                          ? l10n.chForward
                          : '${l10n.chForward} (${widget.nombre} → $choisis)',
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.titre,
    required this.choisi,
    required this.onTap,
    this.peerId,
    this.groupe = false,
  });

  final String titre;
  final bool choisi;
  final VoidCallback onTap;
  final String? peerId;
  final bool groupe;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: groupe
          ? CircleAvatar(
              radius: 20,
              backgroundColor: OuroColors.meshBlue.withValues(alpha: 0.18),
              child: Icon(Icons.groups_rounded, color: OuroColors.meshBlue, size: 22),
            )
          : PeerAvatar(pseudo: titre, radius: 20, imagePath: AvatarService.cheminPair(peerId)),
      title: Text(titre, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(
        choisi ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: choisi ? OuroColors.accent : OuroColors.tertiaryLabel,
      ),
    );
  }
}

/// Les messages qu'on peut transférer : tout sauf ce qui n'a pas de sens
/// ailleurs (un sondage vit dans sa conversation).
bool transferable(MeshMessage message) =>
    message.type != 'appel' &&
    (message.type != 'file' || (message.fileId != null && message.fileName != null));
