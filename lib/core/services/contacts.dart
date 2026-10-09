// ============================================================================
// « MES CONTACTS » — la règle de visibilité de la photo de profil.
//
// Droplet n'a pas de carnet d'adresses : un contact est une personne avec
// qui on a déjà une conversation à deux, dans un sens ou dans l'autre. C'est
// la même notion que la liste des discussions (`conversationsProvider`).
// Un inconnu simplement croisé en Bluetooth dans un bus n'en est pas un : il
// ne reçoit pas notre photo.
// ============================================================================

import '../models/mesh_message.dart';

/// [peerId] est-il un contact de [myId], d'après [messages] ?
bool estUnContact(Iterable<MeshMessage> messages, String myId, String peerId) {
  if (peerId.isEmpty || peerId == myId || peerId == 'broadcast') return false;
  for (final m in messages) {
    if (m.groupId != null) continue;
    final deLui = m.senderId == peerId && m.targetId == myId;
    final deMoi = m.senderId == myId && m.targetId == peerId;
    if (deLui || deMoi) return true;
  }
  return false;
}
