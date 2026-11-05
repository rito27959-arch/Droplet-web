import 'package:droplet/core/services/share_intent_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les liens droplet:// deviennent des routes, pas des partages', () {
    expect(ShareIntentService.routeDeLien('droplet://droplet/autoriser?app=kunfox&cle=abc&etat=x1'),
        '/autoriser?app=kunfox&cle=abc&etat=x1');
    expect(ShareIntentService.routeDeLien('droplet://droplet/chats'), '/chats');
    expect(ShareIntentService.routeDeLien('droplet://droplet'), '/chats');
    expect(ShareIntentService.routeDeLien('droplet://invite?code=9'), '/invite?code=9');
    expect(ShareIntentService.routeDeLien('Salut, regarde ça'), isNull);
    expect(ShareIntentService.routeDeLien('https://droplet.app/x'), isNull);
    expect(ShareIntentService.routeDeLien('/storage/photo.jpg'), isNull);
    expect(ShareIntentService.routeDeLien(null), isNull);
  });
}
