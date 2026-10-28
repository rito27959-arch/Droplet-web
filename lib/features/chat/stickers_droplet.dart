// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES STICKERS DE DROPLET — « Goutte » (gratuit) et « Éclat » (premium) :
// le catalogue, la vue, et ce qui se dit d'eux (descriptions, emojis).
//
// ── Ce que font les autres ────────────────────────────────────────────
//
// • WHATSAPP, lots tiers : images WebP 512 × 512, 500 ko au plus animées.
// • WHATSAPP, lots maison (fichier `.was`, ex. « Tuft ») : une archive de
//   DEUX animations Lottie — le sticker (512 × 512, 60 i/s, 2,5 s, un
//   personnage articulé de 30 calques) et une scène « d'emphase » de
//   2048 × 2048 (4,3 s) jouée autour, plus une description pour
//   l'accessibilité et les emojis associés.
// • TELEGRAM : Lottie `.tgs`, 512 × 512, 60 i/s, 3 s ; les premium ont
//   une animation d'effet plus grande que le sticker.
//
// ── Ce que font ceux de Droplet ───────────────────────────────────────
//
// • LE PERSONNAGE est articulé (`stickers_personnage.dart`) : tête qui
//   tourne de trois quarts, sourcils, pupilles, paupières, bouches,
//   bras ; joué par images clés (anticipation, action, maintien).
// • LES « ÉCLAT » ont chacun leur SCÈNE, quatre fois plus grande que le
//   sticker, 3,6 s (`stickers_gerbes.dart`).
// • ILS NE PÈSENT RIEN SUR LE RÉSEAU : le message ne transporte que leur
//   nom (`🎞tgs:goutte/salut`, une trentaine d'octets) — ils passent par
//   Bluetooth aussi vite qu'un « ok ». Ils sont dessinés en direct, nets
//   à toutes les tailles, et réagissent au doigt.
// • CHACUN A SA DESCRIPTION dans les dix langues de l'app (lecteurs
//   d'écran) et ses emojis associés.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/services/premium_service.dart';
import 'animated_sticker.dart' show kStickerPrefix;
import 'stickers_gerbes.dart';
import 'stickers_personnage.dart';

export 'stickers_gerbes.dart' show GenreEffet, GerbePremium;

// ─────────────────────────────────────────────────────────────
//  LE CATALOGUE
// ─────────────────────────────────────────────────────────────

@immutable
class StickerDroplet {
  const StickerDroplet(this.lot, this.id, this.nom, this.emojis, {this.effet});

  final String lot;
  final String id;

  /// Son nom (français), pour le repli des versions anciennes.
  final String nom;

  /// Les emojis qui lui correspondent (comme les lots de WhatsApp).
  final List<String> emojis;

  /// La scène premium — seulement les « Éclat ».
  final GenreEffet? effet;

  bool get premium => effet != null;

  String get reference => '$kStickerPrefix$lot/$id';

  /// Ce que lit un lecteur d'écran, dans la langue de l'app.
  String description(String langue) {
    final d = _descriptions['$lot/$id'];
    return d?[langue] ?? d?['en'] ?? nom;
  }
}

class StickersDroplet {
  StickersDroplet._();

  static const String lotGratuit = 'goutte';
  static const String lotPremium = 'eclat';

  static const List<StickerDroplet> gratuits = [
    StickerDroplet(lotGratuit, 'salut', 'Salut', ['👋', '🙂', '😉']),
    StickerDroplet(lotGratuit, 'rire', 'Mort de rire', ['😂', '🤣', '😆']),
    StickerDroplet(lotGratuit, 'coeur', 'Amoureux', ['😍', '🥰', '❤️']),
    StickerDroplet(lotGratuit, 'merci', 'Merci', ['🙏', '😊', '🤗']),
    StickerDroplet(lotGratuit, 'ok', "D'accord", ['👍', '✅', '😏']),
    StickerDroplet(lotGratuit, 'triste', 'Triste', ['😢', '😞', '🥺']),
    StickerDroplet(lotGratuit, 'colere', 'En colère', ['😡', '😤', '💢']),
    StickerDroplet(lotGratuit, 'dodo', 'Dodo', ['😴', '💤', '🌙']),
    StickerDroplet(lotGratuit, 'wow', 'Waouh', ['😮', '😲', '🤯']),
    StickerDroplet(lotGratuit, 'fete', 'La fête', ['🥳', '🎉', '💃']),
    StickerDroplet(lotGratuit, 'bisou', 'Bisou', ['😘', '💋', '😚']),
    StickerDroplet(lotGratuit, 'pense', 'Je réfléchis', ['🤔', '💭', '🧐']),
  ];

  static const List<StickerDroplet> premiums = [
    StickerDroplet(lotPremium, 'feu', "Feu d'artifice", ['🎆', '🎇', '🥳'], effet: GenreEffet.feuArtifice),
    StickerDroplet(lotPremium, 'prisme', 'Arc-en-ciel', ['🌈', '✨', '😮'], effet: GenreEffet.arcEnCiel),
    StickerDroplet(lotPremium, 'coeur', 'Cœur liquide', ['❤️', '💖', '😍'], effet: GenreEffet.coeurs),
    StickerDroplet(lotPremium, 'couronne', 'Couronne', ['👑', '😎', '💰'], effet: GenreEffet.or),
    StickerDroplet(lotPremium, 'fusee', 'Fusée', ['🚀', '🌟', '💨'], effet: GenreEffet.etincelles),
    StickerDroplet(lotPremium, 'nova', 'Supernova', ['💥', '🤩', '⚡'], effet: GenreEffet.onde),
    StickerDroplet(lotPremium, 'vague', 'Vague', ['🌊', '🏄', '😄'], effet: GenreEffet.eclaboussure),
    StickerDroplet(lotPremium, 'cristal', 'Cristal', ['💎', '✨', '🥰'], effet: GenreEffet.cristal),
  ];

  static StickerDroplet? resoudre(String reference) {
    final r = reference.trim();
    if (!r.startsWith(kStickerPrefix)) return null;
    final chemin = r.substring(kStickerPrefix.length);
    for (final s in [...gratuits, ...premiums]) {
      if ('${s.lot}/${s.id}' == chemin) return s;
    }
    return null;
  }

  /// Les stickers qui vont avec un emoji.
  static List<StickerDroplet> pourEmoji(String emoji) => [
        for (final s in [...gratuits, ...premiums])
          if (s.emojis.contains(emoji.trim())) s,
      ];

  /// Cet appareil peut-il ENVOYER ce sticker ?
  static bool envoyable(StickerDroplet s) => !s.premium || PremiumService.niveau.donneAccesAuPack;
}

// ─────────────────────────────────────────────────────────────
//  LA VUE
// ─────────────────────────────────────────────────────────────

class VueStickerDroplet extends StatefulWidget {
  const VueStickerDroplet({
    super.key,
    required this.sticker,
    required this.taille,
    this.interactif = false,
    this.cleEffet,
    this.tempsFixe,
  });

  final StickerDroplet sticker;
  final double taille;

  /// Dans la conversation : un toucher le fait réagir (et rejoue la scène
  /// d'un premium).
  final bool interactif;

  /// L'identifiant du message : la scène premium ne se joue d'elle-même
  /// qu'UNE fois par message et par session, comme chez Telegram.
  final String? cleEffet;

  /// Pour les tests de rendu : un instant imposé, en secondes.
  @visibleForTesting
  final double? tempsFixe;

  @override
  State<VueStickerDroplet> createState() => _VueStickerDropletState();
}

class _VueStickerDropletState extends State<VueStickerDroplet> with TickerProviderStateMixin {
  static final Set<String> _scenesJouees = {};

  late final Ticker _ticker = createTicker((d) => _temps.value = d.inMicroseconds / 1e6);
  final ValueNotifier<double> _temps = ValueNotifier(0);

  /// Le « boing » du toucher : un ressort amorti, 0 → 1.
  late final AnimationController _boing = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.tempsFixe != null) {
      _temps.value = widget.tempsFixe!;
    } else if (reduit) {
      _ticker.stop();
      // L'image la plus parlante de la plupart des boucles : en plein
      // jeu, après l'anticipation.
      _temps.value = 1.0;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
    final cle = widget.cleEffet;
    if (cle != null && widget.sticker.premium && !reduit && _scenesJouees.add(cle)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scene());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _boing.dispose();
    _temps.dispose();
    super.dispose();
  }

  void _toucher() {
    HapticFeedback.lightImpact();
    _boing.forward(from: 0);
    if (widget.sticker.premium) _scene();
  }

  void _scene() {
    if (!mounted) return;
    final boite = context.findRenderObject();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (boite is! RenderBox || !boite.hasSize || overlay == null) return;
    final rect = boite.localToGlobal(Offset.zero) & boite.size;
    late OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: GerbePremium(
            genre: widget.sticker.effet!,
            centre: rect.center,
            taille: rect.shortestSide,
            surFin: () => entree.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entree);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final langue = Localizations.maybeLocaleOf(context)?.languageCode ?? 'fr';
    final dessin = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.taille),
        painter: _PeintreSticker(
          cle: '${widget.sticker.lot}/${widget.sticker.id}',
          temps: _temps,
          boing: _boing,
          sombre: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
    return Semantics(
      label: widget.sticker.description(langue),
      image: true,
      child: widget.interactif ? GestureDetector(onTap: _toucher, child: dessin) : dessin,
    );
  }
}

class _PeintreSticker extends CustomPainter {
  _PeintreSticker({required this.cle, required this.temps, required this.boing, required this.sombre}) : super(repaint: Listenable.merge([temps, boing]));

  final String cle;
  final ValueNotifier<double> temps;
  final AnimationController boing;
  final bool sombre;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width);
    dessinerSticker(canvas, cle, temps.value, sombre: sombre, boing: boing.value);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreSticker o) => o.cle != cle || o.sombre != sombre;
}

// ─────────────────────────────────────────────────────────────
//  LES DESCRIPTIONS (accessibilité), dans les dix langues de l'app
// ─────────────────────────────────────────────────────────────

const Map<String, Map<String, String>> _descriptions = {
  'goutte/salut': {
    'fr': 'Salut : la goutte lève la main, salue en souriant puis fait un clin d\'œil.',
    'en': 'Hi: the drop raises a hand, waves with a smile, then winks.',
    'es': 'Hola: la gota levanta la mano, saluda sonriendo y guiña un ojo.',
    'pt': 'Oi: a gota levanta a mão, acena sorrindo e depois pisca.',
    'it': 'Ciao: la goccia alza la mano, saluta sorridendo e fa l\'occhiolino.',
    'de': 'Hallo: Der Tropfen hebt die Hand, winkt lächelnd und zwinkert dann.',
    'ru': 'Привет: капля поднимает руку, машет с улыбкой и подмигивает.',
    'ar': 'مرحبًا: القطرة ترفع يدها وتلوّح مبتسمة ثم تغمز.',
    'hi': 'नमस्ते: बूँद हाथ उठाकर मुस्कुराते हुए हिलाती है, फिर आँख मारती है।',
    'zh': '你好：水滴举起手，微笑着挥手，然后眨眨眼。',
  },
  'goutte/rire': {
    'fr': 'Mort de rire : la goutte éclate de rire, la tête en arrière, avec des larmes de joie.',
    'en': 'Laughing: the drop bursts out laughing, head thrown back, with tears of joy.',
    'es': 'Muerto de risa: la gota estalla en carcajadas, con lágrimas de alegría.',
    'pt': 'Morrendo de rir: a gota cai na gargalhada, com lágrimas de alegria.',
    'it': 'Morto dal ridere: la goccia scoppia a ridere, con lacrime di gioia.',
    'de': 'Totlachen: Der Tropfen lacht laut los, den Kopf zurück, mit Freudentränen.',
    'ru': 'Умираю со смеху: капля хохочет, запрокинув голову, со слезами радости.',
    'ar': 'ضحك شديد: القطرة تنفجر ضحكًا ورأسها إلى الوراء مع دموع الفرح.',
    'hi': 'हँसी से लोटपोट: बूँद सिर पीछे करके ज़ोर से हँसती है, खुशी के आँसुओं के साथ।',
    'zh': '笑死了：水滴仰头大笑，笑出了眼泪。',
  },
  'goutte/coeur': {
    'fr': 'Amoureux : la goutte a des cœurs à la place des yeux et se balance, rêveuse.',
    'en': 'In love: the drop has hearts for eyes and sways dreamily.',
    'es': 'Enamorado: la gota tiene corazones en los ojos y se balancea soñadora.',
    'pt': 'Apaixonado: a gota tem corações nos olhos e balança, sonhadora.',
    'it': 'Innamorato: la goccia ha cuori al posto degli occhi e dondola sognante.',
    'de': 'Verliebt: Der Tropfen hat Herzen als Augen und wiegt sich verträumt.',
    'ru': 'Влюблён: у капли сердечки вместо глаз, она мечтательно покачивается.',
    'ar': 'عاشق: للقطرة قلوب مكان العينين وتتمايل حالمة.',
    'hi': 'प्यार में: बूँद की आँखों में दिल हैं और वह सपनों में झूमती है।',
    'zh': '恋爱中：水滴眼睛变成爱心，陶醉地摇摆。',
  },
  'goutte/merci': {
    'fr': 'Merci : la goutte fait une révérence, les mains jointes, avec des étincelles.',
    'en': 'Thank you: the drop bows with joined hands, among sparkles.',
    'es': 'Gracias: la gota hace una reverencia con las manos juntas, entre destellos.',
    'pt': 'Obrigado: a gota faz uma reverência de mãos juntas, entre brilhos.',
    'it': 'Grazie: la goccia fa un inchino a mani giunte, tra scintille.',
    'de': 'Danke: Der Tropfen verbeugt sich mit gefalteten Händen, umgeben von Funkeln.',
    'ru': 'Спасибо: капля кланяется, сложив руки, среди искорок.',
    'ar': 'شكرًا: القطرة تنحني ويداها متشابكتان وسط بريق.',
    'hi': 'धन्यवाद: बूँद हाथ जोड़कर झुकती है, चमक के बीच।',
    'zh': '谢谢：水滴双手合十鞠躬，周围闪着光。',
  },
  'goutte/ok': {
    'fr': 'D\'accord : la goutte, de trois quarts, lève un sourcil, fait un clin d\'œil et brandit une coche verte.',
    'en': 'OK: the drop, in three-quarter view, raises an eyebrow, winks and shows a green check mark.',
    'es': 'De acuerdo: la gota levanta una ceja, guiña y muestra una marca verde.',
    'pt': 'Combinado: a gota levanta uma sobrancelha, pisca e mostra um visto verde.',
    'it': 'Va bene: la goccia alza un sopracciglio, fa l\'occhiolino e mostra una spunta verde.',
    'de': 'Okay: Der Tropfen hebt eine Augenbraue, zwinkert und zeigt einen grünen Haken.',
    'ru': 'Договорились: капля поднимает бровь, подмигивает и показывает зелёную галочку.',
    'ar': 'حسنًا: القطرة ترفع حاجبًا وتغمز وتُظهر علامة صح خضراء.',
    'hi': 'ठीक है: बूँद एक भौंह उठाती है, आँख मारती है और हरा टिक दिखाती है।',
    'zh': '好的：水滴侧着脸挑眉、眨眼，举起绿色对勾。',
  },
  'goutte/triste': {
    'fr': 'Triste : la goutte baisse les yeux, la lèvre tremblante ; une larme tombe dans une petite flaque.',
    'en': 'Sad: the drop looks down, lip trembling; a tear falls into a small puddle.',
    'es': 'Triste: la gota mira abajo, con el labio temblando; una lágrima cae en un charquito.',
    'pt': 'Triste: a gota olha para baixo, lábio tremendo; uma lágrima cai numa poça.',
    'it': 'Triste: la goccia abbassa lo sguardo, labbro tremante; una lacrima cade in una pozza.',
    'de': 'Traurig: Der Tropfen schaut nach unten, die Lippe zittert; eine Träne fällt in eine Pfütze.',
    'ru': 'Грусть: капля опускает глаза, губа дрожит; слеза падает в лужицу.',
    'ar': 'حزين: القطرة تنظر إلى الأسفل وشفتها ترتجف، ودمعة تسقط في بركة صغيرة.',
    'hi': 'उदास: बूँद नीचे देखती है, होंठ काँपते हैं; एक आँसू छोटे से गड्ढे में गिरता है।',
    'zh': '难过：水滴低着头，嘴唇颤抖，一滴眼泪落进小水洼。',
  },
  'goutte/colere': {
    'fr': 'En colère : la goutte rougit, fronce les sourcils, serre les dents et fume, poings levés.',
    'en': 'Angry: the drop turns red, frowns, grits its teeth and steams, fists raised.',
    'es': 'Enfadado: la gota se pone roja, frunce el ceño, aprieta los dientes y echa humo.',
    'pt': 'Bravo: a gota fica vermelha, franze a testa, range os dentes e solta fumaça.',
    'it': 'Arrabbiato: la goccia diventa rossa, aggrotta la fronte, digrigna i denti e fuma.',
    'de': 'Wütend: Der Tropfen wird rot, runzelt die Stirn, beißt die Zähne zusammen und dampft.',
    'ru': 'Злость: капля краснеет, хмурится, стискивает зубы и пыхтит паром.',
    'ar': 'غاضب: القطرة تحمرّ وتعقد حاجبيها وتصرّ على أسنانها ويتصاعد منها البخار.',
    'hi': 'गुस्सा: बूँद लाल हो जाती है, भौंहें चढ़ाती है, दाँत पीसती है और भाप निकलती है।',
    'zh': '生气：水滴涨红了脸，皱眉咬牙，头顶冒烟，举起拳头。',
  },
  'goutte/dodo': {
    'fr': 'Dodo : la goutte dort, la tête penchée ; elle sursaute, ouvre un œil et se rendort.',
    'en': 'Sleepy: the drop dozes off, head tilted; it jolts awake, opens one eye and falls back asleep.',
    'es': 'A dormir: la gota dormita, se sobresalta, abre un ojo y vuelve a dormirse.',
    'pt': 'Soninho: a gota cochila, leva um susto, abre um olho e volta a dormir.',
    'it': 'Nanna: la goccia sonnecchia, sobbalza, apre un occhio e si riaddormenta.',
    'de': 'Müde: Der Tropfen nickt ein, schreckt hoch, öffnet ein Auge und schläft wieder ein.',
    'ru': 'Сон: капля дремлет, вздрагивает, открывает один глаз и снова засыпает.',
    'ar': 'نوم: القطرة تغفو ثم تنتفض وتفتح عينًا وتعود إلى النوم.',
    'hi': 'नींद: बूँद ऊँघती है, चौंककर एक आँख खोलती है और फिर सो जाती है।',
    'zh': '睡觉：水滴歪着头打盹，惊醒睁开一只眼，又睡着了。',
  },
  'goutte/wow': {
    'fr': 'Waouh : la goutte se tasse puis s\'étire d\'un coup, grands yeux, bouche ouverte, mains aux joues.',
    'en': 'Wow: the drop squashes then stretches up, big eyes, open mouth, hands on cheeks.',
    'es': 'Guau: la gota se encoge y se estira de golpe, ojos grandes y boca abierta.',
    'pt': 'Uau: a gota se encolhe e se estica de repente, olhos grandes e boca aberta.',
    'it': 'Wow: la goccia si schiaccia e poi si allunga, occhi grandi e bocca aperta.',
    'de': 'Wow: Der Tropfen staucht sich und schnellt hoch, große Augen, offener Mund.',
    'ru': 'Вау: капля сжимается и резко вытягивается, большие глаза, открытый рот.',
    'ar': 'واو: القطرة تنكمش ثم تتمدد فجأة بعينين واسعتين وفم مفتوح.',
    'hi': 'वाह: बूँद सिकुड़कर अचानक लंबी हो जाती है, बड़ी आँखें, खुला मुँह।',
    'zh': '哇：水滴先缩紧再猛地拉长，瞪大眼睛张大嘴，双手捧脸。',
  },
  'goutte/fete': {
    'fr': 'La fête : la goutte danse avec un chapeau pointu sous une pluie de confettis.',
    'en': 'Party: the drop dances in a party hat under falling confetti.',
    'es': 'Fiesta: la gota baila con un gorro de fiesta bajo una lluvia de confeti.',
    'pt': 'Festa: a gota dança com chapéu de festa sob uma chuva de confete.',
    'it': 'Festa: la goccia balla con un cappellino sotto una pioggia di coriandoli.',
    'de': 'Party: Der Tropfen tanzt mit Partyhut im Konfettiregen.',
    'ru': 'Праздник: капля танцует в колпаке под дождём конфетти.',
    'ar': 'حفلة: القطرة ترقص بقبعة حفلة تحت مطر من القصاصات الملونة.',
    'hi': 'पार्टी: बूँद पार्टी टोपी पहनकर कंफ़ेटी की बारिश में नाचती है।',
    'zh': '派对：水滴戴着派对帽，在彩纸雨中跳舞。',
  },
  'goutte/bisou': {
    'fr': 'Bisou : la goutte ferme les yeux, envoie un baiser, et un cœur s\'envole.',
    'en': 'Kiss: the drop closes its eyes, blows a kiss, and a heart flies away.',
    'es': 'Beso: la gota cierra los ojos, lanza un beso y un corazón sale volando.',
    'pt': 'Beijo: a gota fecha os olhos, manda um beijo e um coração voa.',
    'it': 'Bacio: la goccia chiude gli occhi, manda un bacio e un cuore vola via.',
    'de': 'Kuss: Der Tropfen schließt die Augen, wirft einen Kuss, ein Herz fliegt davon.',
    'ru': 'Поцелуй: капля закрывает глаза, посылает поцелуй, и улетает сердечко.',
    'ar': 'قبلة: القطرة تغمض عينيها وترسل قبلة فيطير قلب.',
    'hi': 'चुंबन: बूँद आँखें बंद करके चुंबन भेजती है और एक दिल उड़ जाता है।',
    'zh': '飞吻：水滴闭上眼睛送出飞吻，一颗爱心飞走了。',
  },
  'goutte/pense': {
    'fr': 'Je réfléchis : la goutte, la main au menton, regarde en l\'air d\'un côté puis de l\'autre ; trois points s\'allument.',
    'en': 'Thinking: hand on chin, the drop looks up to one side then the other; three dots light up.',
    'es': 'Pensando: con la mano en la barbilla, la gota mira arriba a un lado y al otro.',
    'pt': 'Pensando: mão no queixo, a gota olha para cima de um lado e do outro.',
    'it': 'Sto pensando: mano sul mento, la goccia guarda in alto da un lato e dall\'altro.',
    'de': 'Nachdenken: Hand am Kinn, der Tropfen schaut nach oben, mal links, mal rechts.',
    'ru': 'Размышляю: рука у подбородка, капля смотрит вверх то в одну, то в другую сторону.',
    'ar': 'أفكر: يدها على ذقنها، القطرة تنظر للأعلى يمينًا ثم يسارًا.',
    'hi': 'सोच रहा हूँ: ठोड़ी पर हाथ रखे बूँद ऊपर एक ओर फिर दूसरी ओर देखती है।',
    'zh': '思考中：水滴手托下巴，向上左看右看，三个点依次亮起。',
  },
  'eclat/feu': {
    'fr': 'Feu d\'artifice (premium) : la goutte irisée s\'élance et explose en gerbe de gouttes colorées.',
    'en': 'Fireworks (premium): the iridescent drop shoots up and bursts into colourful droplets.',
    'es': 'Fuegos artificiales (premium): la gota iridiscente sube y estalla en gotas de colores.',
    'pt': 'Fogos de artifício (premium): a gota iridescente sobe e explode em gotas coloridas.',
    'it': 'Fuochi d\'artificio (premium): la goccia iridescente sale ed esplode in gocce colorate.',
    'de': 'Feuerwerk (Premium): Der schillernde Tropfen schießt hoch und zerplatzt in bunte Tropfen.',
    'ru': 'Фейерверк (премиум): радужная капля взлетает и взрывается цветными каплями.',
    'ar': 'ألعاب نارية (مميز): القطرة المتلألئة تنطلق وتنفجر قطرات ملوّنة.',
    'hi': 'आतिशबाज़ी (प्रीमियम): इंद्रधनुषी बूँद ऊपर उठकर रंगीन बूँदों में फूटती है।',
    'zh': '烟花（高级）：七彩水滴冲上天，炸开成彩色水珠。',
  },
  'eclat/prisme': {
    'fr': 'Arc-en-ciel (premium) : un arc-en-ciel se déploie et la goutte irisée le suit des yeux, émerveillée.',
    'en': 'Rainbow (premium): a rainbow unfolds and the iridescent drop follows it, amazed.',
    'es': 'Arcoíris (premium): se despliega un arcoíris y la gota lo sigue con la mirada.',
    'pt': 'Arco-íris (premium): um arco-íris se abre e a gota o acompanha com o olhar.',
    'it': 'Arcobaleno (premium): si apre un arcobaleno e la goccia lo segue con lo sguardo.',
    'de': 'Regenbogen (Premium): Ein Regenbogen entfaltet sich, der Tropfen folgt ihm staunend.',
    'ru': 'Радуга (премиум): раскрывается радуга, и капля восхищённо следит за ней.',
    'ar': 'قوس قزح (مميز): ينبسط قوس قزح والقطرة تتابعه بدهشة.',
    'hi': 'इंद्रधनुष (प्रीमियम): इंद्रधनुष खुलता है और बूँद उसे हैरानी से देखती है।',
    'zh': '彩虹（高级）：彩虹展开，七彩水滴惊喜地看着它。',
  },
  'eclat/coeur': {
    'fr': 'Cœur liquide (premium) : la goutte se change en cœur qui bat, puis redevient goutte.',
    'en': 'Liquid heart (premium): the drop turns into a beating heart, then back into a drop.',
    'es': 'Corazón líquido (premium): la gota se convierte en un corazón que late.',
    'pt': 'Coração líquido (premium): a gota vira um coração que bate e volta a ser gota.',
    'it': 'Cuore liquido (premium): la goccia diventa un cuore che batte, poi torna goccia.',
    'de': 'Flüssiges Herz (Premium): Der Tropfen wird zu einem schlagenden Herzen und zurück.',
    'ru': 'Жидкое сердце (премиум): капля превращается в бьющееся сердце и обратно.',
    'ar': 'قلب سائل (مميز): القطرة تتحول إلى قلب نابض ثم تعود قطرة.',
    'hi': 'तरल दिल (प्रीमियम): बूँद धड़कते दिल में बदलती है, फिर बूँद बन जाती है।',
    'zh': '液态爱心（高级）：水滴变成跳动的爱心，又变回水滴。',
  },
  'eclat/couronne': {
    'fr': 'Couronne (premium) : la goutte irisée ajuste sa couronne d\'or, menton levé, l\'air sûr d\'elle.',
    'en': 'Crown (premium): the iridescent drop adjusts its golden crown, chin up, self-assured.',
    'es': 'Corona (premium): la gota ajusta su corona de oro, con la barbilla en alto.',
    'pt': 'Coroa (premium): a gota ajeita sua coroa de ouro, de queixo erguido.',
    'it': 'Corona (premium): la goccia sistema la sua corona d\'oro, mento in su.',
    'de': 'Krone (Premium): Der Tropfen rückt seine goldene Krone zurecht, Kinn hoch.',
    'ru': 'Корона (премиум): капля поправляет золотую корону, гордо подняв подбородок.',
    'ar': 'تاج (مميز): القطرة تعدّل تاجها الذهبي رافعة ذقنها بثقة.',
    'hi': 'ताज (प्रीमियम): बूँद ठोड़ी उठाकर अपना सुनहरा ताज ठीक करती है।',
    'zh': '皇冠（高级）：七彩水滴扶正金冠，昂首挺胸，自信满满。',
  },
  'eclat/fusee': {
    'fr': 'Fusée (premium) : la goutte serre les dents, s\'allume et décolle dans une traînée de feu.',
    'en': 'Rocket (premium): the drop grits its teeth, ignites and blasts off in a trail of fire.',
    'es': 'Cohete (premium): la gota aprieta los dientes, se enciende y despega.',
    'pt': 'Foguete (premium): a gota cerra os dentes, acende e decola num rastro de fogo.',
    'it': 'Razzo (premium): la goccia stringe i denti, si accende e decolla.',
    'de': 'Rakete (Premium): Der Tropfen beißt die Zähne zusammen, zündet und hebt ab.',
    'ru': 'Ракета (премиум): капля стискивает зубы, загорается и взлетает.',
    'ar': 'صاروخ (مميز): القطرة تصرّ على أسنانها وتشتعل وتنطلق بذيل من نار.',
    'hi': 'रॉकेट (प्रीमियम): बूँद दाँत भींचकर जलती है और आग की लकीर में उड़ जाती है।',
    'zh': '火箭（高级）：水滴咬紧牙关，点火升空，拖出火焰尾迹。',
  },
  'eclat/nova': {
    'fr': 'Supernova (premium) : la goutte se concentre puis rayonne d\'un coup en ondes de lumière.',
    'en': 'Supernova (premium): the drop concentrates, then bursts out in waves of light.',
    'es': 'Supernova (premium): la gota se concentra y estalla en ondas de luz.',
    'pt': 'Supernova (premium): a gota se concentra e explode em ondas de luz.',
    'it': 'Supernova (premium): la goccia si concentra e poi esplode in onde di luce.',
    'de': 'Supernova (Premium): Der Tropfen konzentriert sich und strahlt in Lichtwellen aus.',
    'ru': 'Сверхновая (премиум): капля сосредотачивается и вспыхивает волнами света.',
    'ar': 'مستعر أعظم (مميز): القطرة تتركز ثم تشعّ بموجات من الضوء.',
    'hi': 'सुपरनोवा (प्रीमियम): बूँद ध्यान लगाती है, फिर रोशनी की लहरों में चमक उठती है।',
    'zh': '超新星（高级）：水滴蓄力，然后迸发出一圈圈光波。',
  },
  'eclat/vague': {
    'fr': 'Vague (premium) : la goutte irisée surfe sur une vague, bras écartés, dans les embruns.',
    'en': 'Wave (premium): the iridescent drop surfs a wave, arms out, in the spray.',
    'es': 'Ola (premium): la gota surfea una ola con los brazos abiertos.',
    'pt': 'Onda (premium): a gota surfa uma onda de braços abertos.',
    'it': 'Onda (premium): la goccia cavalca un\'onda a braccia aperte.',
    'de': 'Welle (Premium): Der Tropfen surft mit ausgebreiteten Armen auf einer Welle.',
    'ru': 'Волна (премиум): капля катается на волне, раскинув руки.',
    'ar': 'موجة (مميز): القطرة تركب الموج فاتحة ذراعيها وسط الرذاذ.',
    'hi': 'लहर (प्रीमियम): बूँद बाँहें फैलाकर लहर पर सर्फ़ करती है।',
    'zh': '浪花（高级）：七彩水滴张开双臂在浪尖冲浪。',
  },
  'eclat/cristal': {
    'fr': 'Cristal (premium) : la goutte devient un cristal taillé qui tourne et scintille.',
    'en': 'Crystal (premium): the drop becomes a cut crystal that turns and sparkles.',
    'es': 'Cristal (premium): la gota se vuelve un cristal tallado que gira y brilla.',
    'pt': 'Cristal (premium): a gota vira um cristal lapidado que gira e brilha.',
    'it': 'Cristallo (premium): la goccia diventa un cristallo sfaccettato che gira e brilla.',
    'de': 'Kristall (Premium): Der Tropfen wird zu einem geschliffenen Kristall, der sich dreht und funkelt.',
    'ru': 'Кристалл (премиум): капля становится гранёным кристаллом, который вращается и сверкает.',
    'ar': 'كريستال (مميز): القطرة تصبح كريستالة مصقولة تدور وتتلألأ.',
    'hi': 'क्रिस्टल (प्रीमियम): बूँद तराशा हुआ क्रिस्टल बनकर घूमती और चमकती है।',
    'zh': '水晶（高级）：水滴变成切面水晶，旋转闪耀。',
  },
};
