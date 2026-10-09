// LES ÉMOJIS — le sélecteur du champ de saisie, et la barre de réactions.
//
// Le sélecteur reprend les familles d'iOS (Smileys, Personnes, Nature,
// Nourriture, Activités, Voyages, Objets, Symboles) avec les récents en
// tête. La barre de réactions propose les six de l'app, et « + » ouvre le
// sélecteur complet.
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import 'composants.dart';
import 'portee.dart';

const List<String> reactionsRapides = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

final List<String> _recents = ['👍', '❤️', '😂', '🙏', '🔥', '😊', '🎉', '😍'];

void retenirEmoji(String e) {
  _recents.remove(e);
  _recents.insert(0, e);
  if (_recents.length > 24) _recents.removeLast();
}

const _familles = <(IconData, String)>[
  (Icons.sentiment_satisfied_alt_rounded,
      '😀 😃 😄 😁 😆 😅 🤣 😂 🙂 🙃 😉 😊 😇 🥰 😍 🤩 😘 😗 😚 😙 🥲 😋 😛 😜 🤪 😝 🤑 🤗 🤭 🤫 🤔 🤐 🤨 😐 😑 😶 😏 😒 🙄 😬 😮‍💨 🤥 😌 😔 😪 🤤 😴 😷 🤒 🤕 🤢 🤮 🤧 🥵 🥶 🥴 😵 🤯 🤠 🥳 🥸 😎 🤓 🧐 😕 😟 🙁 😮 😯 😲 😳 🥺 😦 😧 😨 😰 😥 😢 😭 😱 😖 😣 😞 😓 😩 😫 🥱 😤 😡 😠 🤬 😈 👿 💀 💩 🤡 👻 👽 🤖 😺 😸 😹 😻 😼 😽 🙀 😿 😾'),
  (Icons.waving_hand_outlined,
      '👋 🤚 🖐️ ✋ 🖖 👌 🤌 🤏 ✌️ 🤞 🤟 🤘 🤙 👈 👉 👆 🖕 👇 ☝️ 👍 👎 ✊ 👊 🤛 🤜 👏 🙌 👐 🤲 🤝 🙏 ✍️ 💅 🤳 💪 🦾 🧠 👀 👁️ 👅 👄 💋 👶 🧒 👦 👧 🧑 👱 👨 🧔 👩 🧓 👴 👵 🙍 🙎 🙅 🙆 💁 🙋 🧏 🙇 🤦 🤷 👮 🕵️ 💂 👷 🤴 👸 👳 👲 🧕 🤵 👰 🤰 🤱 👼 🎅 🤶 🦸 🦹 🧙 🧚 🧛 🧜 🧝 🧞 🧟 💆 💇 🚶 🧍 🧎 🏃 💃 🕺 👯 🧖 🧗 🤺 🏇 ⛷️ 🏂 🏌️ 🏄 🚣 🏊 ⛹️ 🏋️ 🚴 🚵 🤸 🤼 🤽 🤾 🤹 🧘 🛀 🛌 👭 👫 👬 💏 💑 👪'),
  (Icons.favorite_border_rounded,
      '❤️ 🧡 💛 💚 💙 💜 🖤 🤍 🤎 💔 ❣️ 💕 💞 💓 💗 💖 💘 💝 💟 ❤️‍🔥 ❤️‍🩹 💌 💯 💢 💥 💫 💦 💨 🕳️ 💬 👁️‍🗨️ 🗨️ 🗯️ 💭 💤 ✨ 🌟 ⭐ 🔥 🎉 🎊'),
  (Icons.pets_rounded,
      '🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐵 🙈 🙉 🙊 🐒 🐔 🐧 🐦 🐤 🦆 🦅 🦉 🦇 🐺 🐗 🐴 🦄 🐝 🐛 🦋 🐌 🐞 🐜 🦟 🐢 🐍 🦎 🐙 🦑 🦐 🦀 🐡 🐠 🐟 🐬 🐳 🐋 🦈 🐊 🐅 🐆 🦓 🦍 🐘 🦛 🦏 🐪 🐫 🦒 🦘 🐃 🐂 🐄 🐎 🐖 🐏 🐑 🦙 🐐 🦌 🐕 🐩 🐈 🐓 🦃 🦚 🦜 🦢 🕊️ 🐇 🦝 🦨 🦡 🦦 🦥 🐁 🐀 🐿️ 🦔 🌵 🎄 🌲 🌳 🌴 🌱 🌿 ☘️ 🍀 🎍 🎋 🍃 🍂 🍁 🍄 🌾 💐 🌷 🌹 🥀 🌺 🌸 🌼 🌻 🌞 🌝 🌛 🌜 🌚 🌕 🌙 🌎 🌍 🌏 🪐 💫 ⭐ 🌟 ⚡ ☄️ 💥 🔥 🌪️ 🌈 ☀️ 🌤️ ⛅ 🌥️ ☁️ 🌦️ 🌧️ ⛈️ 🌩️ 🌨️ ❄️ ☃️ ⛄ 🌬️ 💨 💧 💦 ☔ 🌊'),
  (Icons.restaurant_rounded,
      '🍏 🍎 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🫐 🍈 🍒 🍑 🥭 🍍 🥥 🥝 🍅 🍆 🥑 🥦 🥬 🥒 🌶️ 🌽 🥕 🧄 🧅 🥔 🍠 🥐 🥯 🍞 🥖 🥨 🧀 🥚 🍳 🧈 🥞 🧇 🥓 🥩 🍗 🍖 🌭 🍔 🍟 🍕 🥪 🥙 🧆 🌮 🌯 🥗 🥘 🥫 🍝 🍜 🍲 🍛 🍣 🍱 🥟 🍤 🍙 🍚 🍘 🍥 🥠 🥮 🍢 🍡 🍧 🍨 🍦 🥧 🧁 🍰 🎂 🍮 🍭 🍬 🍫 🍿 🍩 🍪 🌰 🥜 🍯 🥛 🍼 ☕ 🍵 🧃 🥤 🍶 🍺 🍻 🥂 🍷 🥃 🍸 🍹 🧉 🍾 🧊 🥄 🍴 🍽️'),
  (Icons.sports_soccer_rounded,
      '⚽ 🏀 🏈 ⚾ 🥎 🎾 🏐 🏉 🥏 🎱 🪀 🏓 🏸 🏒 🏑 🥍 🏏 🥅 ⛳ 🪁 🏹 🎣 🤿 🥊 🥋 🎽 🛹 🛼 🛷 ⛸️ 🥌 🎿 🏆 🥇 🥈 🥉 🏅 🎖️ 🏵️ 🎗️ 🎫 🎟️ 🎪 🤹 🎭 🩰 🎨 🎬 🎤 🎧 🎼 🎹 🥁 🎷 🎺 🎸 🪕 🎻 🎲 ♟️ 🎯 🎳 🎮 🎰 🧩'),
  (Icons.flight_rounded,
      '🚗 🚕 🚙 🚌 🚎 🏎️ 🚓 🚑 🚒 🚐 🛻 🚚 🚛 🚜 🦯 🦽 🦼 🛴 🚲 🛵 🏍️ 🛺 🚨 🚔 🚍 🚘 🚖 🚡 🚠 🚟 🚃 🚋 🚞 🚝 🚄 🚅 🚈 🚂 🚆 🚇 🚊 🚉 ✈️ 🛫 🛬 🛩️ 💺 🛰️ 🚀 🛸 🚁 🛶 ⛵ 🚤 🛥️ 🛳️ ⛴️ 🚢 ⚓ ⛽ 🚧 🚦 🚥 🚏 🗺️ 🗿 🗽 🗼 🏰 🏯 🏟️ 🎡 🎢 🎠 ⛲ ⛱️ 🏖️ 🏝️ 🏜️ 🌋 ⛰️ 🏔️ 🗻 🏕️ ⛺ 🏠 🏡 🏘️ 🏚️ 🏗️ 🏭 🏢 🏬 🏣 🏤 🏥 🏦 🏨 🏪 🏫 🏩 💒 🏛️ ⛪ 🕌 🕍 🛕 🕋 ⛩️ 🛤️ 🛣️ 🗾 🎑 🏞️ 🌅 🌄 🌠 🎇 🎆 🌇 🌆 🏙️ 🌃 🌌 🌉 🌁'),
  (Icons.lightbulb_outline_rounded,
      '⌚ 📱 📲 💻 ⌨️ 🖥️ 🖨️ 🖱️ 🖲️ 🕹️ 🗜️ 💽 💾 💿 📀 📼 📷 📸 📹 🎥 📽️ 🎞️ 📞 ☎️ 📟 📠 📺 📻 🎙️ 🎚️ 🎛️ 🧭 ⏱️ ⏲️ ⏰ 🕰️ ⌛ ⏳ 📡 🔋 🔌 💡 🔦 🕯️ 🧯 🛢️ 💸 💵 💴 💶 💷 💰 💳 💎 ⚖️ 🧰 🔧 🔨 ⚒️ 🛠️ ⛏️ 🔩 ⚙️ 🧱 ⛓️ 🧲 🔫 💣 🧨 🪓 🔪 🗡️ ⚔️ 🛡️ 🚬 ⚰️ ⚱️ 🏺 🔮 📿 🧿 💈 ⚗️ 🔭 🔬 🕳️ 🩹 🩺 💊 💉 🩸 🧬 🦠 🧫 🧪 🌡️ 🧹 🧺 🧻 🚽 🚰 🚿 🛁 🛀 🧼 🪒 🧽 🧴 🛎️ 🔑 🗝️ 🚪 🪑 🛋️ 🛏️ 🛌 🧸 🖼️ 🛍️ 🛒 🎁 🎈 🎏 🎀 🎊 🎉 🎎 🏮 🎐 🧧 ✉️ 📩 📨 📧 💌 📥 📤 📦 🏷️ 📪 📫 📬 📭 📮 📯 📜 📃 📄 📑 🧾 📊 📈 📉 🗒️ 🗓️ 📆 📅 🗑️ 📇 🗃️ 🗳️ 🗄️ 📋 📁 📂 🗂️ 🗞️ 📰 📓 📔 📒 📕 📗 📘 📙 📚 📖 🔖 🧷 🔗 📎 🖇️ 📐 📏 🧮 📌 📍 ✂️ 🖊️ 🖋️ ✒️ 🖌️ 🖍️ 📝 ✏️ 🔍 🔎 🔏 🔐 🔒 🔓'),
  (Icons.tag_rounded,
      '✅ ☑️ ✔️ ❌ ❎ ➕ ➖ ➗ ✖️ ♾️ ‼️ ⁉️ ❓ ❔ ❕ ❗ 〰️ 💱 💲 ⚕️ ♻️ ⚜️ 🔱 📛 🔰 ⭕ ✳️ ✴️ ❇️ ©️ ®️ ™️ #️⃣ *️⃣ 0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ 🔟 🔠 🔡 🔢 🔣 🔤 🅰️ 🆎 🅱️ 🆑 🆒 🆓 ℹ️ 🆔 Ⓜ️ 🆕 🆖 🅾️ 🆗 🅿️ 🆘 🆙 🆚 🔴 🟠 🟡 🟢 🔵 🟣 🟤 ⚫ ⚪ 🟥 🟧 🟨 🟩 🟦 🟪 🟫 ⬛ ⬜ 🔶 🔷 🔸 🔹 🔺 🔻 💠 🔘 🔳 🔲 🏁 🚩 🎌 🏴 🏳️ 🏳️‍🌈 🇫🇷 🇧🇪 🇨🇭 🇨🇦 🇺🇸 🇬🇧 🇩🇪 🇪🇸 🇮🇹 🇵🇹 🇧🇷 🇷🇺 🇨🇳 🇮🇳 🇸🇦 🇲🇦 🇩🇿 🇹🇳 🇸🇳 🇨🇮 🇨🇲 🇨🇩 🇲🇱 🇧🇫 🇳🇬 🇯🇵 🇰🇷'),
];

/// Le sélecteur d'émojis, en popover au-dessus du bouton.
Future<void> choisirEmoji(BuildContext context, {required Offset position, required ValueChanged<String> onChoix, bool fermerApres = false}) {
  return montrerPopover(
    context,
    position: position,
    largeur: 360,
    hauteurEstimee: 392,
    auDessus: true,
    builder: (fermer) => _Selecteur(
      onChoix: (e) {
        retenirEmoji(e);
        onChoix(e);
        if (fermerApres) fermer();
      },
    ),
  );
}

class _Selecteur extends StatefulWidget {
  const _Selecteur({required this.onChoix});

  final ValueChanged<String> onChoix;

  @override
  State<_Selecteur> createState() => _SelecteurState();
}

class _SelecteurState extends State<_Selecteur> {
  int _famille = -1; // -1 : récents

  @override
  Widget build(BuildContext context) {
    final emojis = _famille < 0 ? _recents : _familles[_famille].$2.split(' ');
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Onglet(icone: Icons.schedule_rounded, actif: _famille == -1, onTap: () => setState(() => _famille = -1)),
                for (var i = 0; i < _familles.length; i++)
                  _Onglet(icone: _familles[i].$1, actif: _famille == i, onTap: () => setState(() => _famille = i)),
              ],
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
          if (_famille < 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(context.t.recents.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemCount: emojis.length,
              itemBuilder: (context, i) => Survol(
                onTap: () => widget.onChoix(emojis[i]),
                builder: (context, survol) => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: survol ? OuroColors.tertiarySystemFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: survol ? 1.18 : 1,
                    duration: const Duration(milliseconds: 160),
                    curve: kSortie,
                    child: Text(emojis[i], style: const TextStyle(fontSize: 26, height: 1.1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({required this.icone, required this.actif, required this.onTap});

  final IconData icone;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BoutonIcone(
        icone: icone,
        onTap: onTap,
        actif: actif,
        diametre: 32,
        taille: 18,
      );
}

/// La barre de réactions rapides, au-dessus d'un message.
Future<void> barreReactions(
  BuildContext context, {
  required Offset position,
  required List<String> actuelles,
  required ValueChanged<String> onChoix,
}) {
  return montrerPopover(
    context,
    position: position,
    largeur: 7 * 46 + 16,
    hauteurEstimee: 56,
    auDessus: true,
    builder: (fermer) => SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (i, e) in reactionsRapides.indexed)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + i * 40),
              curve: Curves.easeOutBack,
              builder: (context, v, enfant) => Transform.scale(scale: v, child: enfant),
              child: Survol(
                onTap: () {
                  fermer();
                  onChoix(e);
                },
                builder: (context, survol) => AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: actuelles.contains(e) ? OuroColors.accent.withValues(alpha: 0.2) : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: survol ? 1.3 : 1,
                    duration: const Duration(milliseconds: 160),
                    curve: kSortie,
                    child: Text(e, style: const TextStyle(fontSize: 26, height: 1.1)),
                  ),
                ),
              ),
            ),
          BoutonIcone(
            icone: Icons.add_rounded,
            diametre: 36,
            onTap: () {
              fermer();
              choisirEmoji(context, position: position, onChoix: onChoix, fermerApres: true);
            },
          ),
        ],
      ),
    ),
  );
}
