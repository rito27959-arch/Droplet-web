// ============================================================================
// LA TOILE FINE — pourquoi les stickers avaient des yeux en losange.
// ----------------------------------------------------------------------------
// Les stickers sont dessinés dans un carré de 1 × 1 (un œil y mesure 0,03),
// puis la toile est agrandie à la taille de l'écran (× 140, × 400…).
//
// Sur téléphone, Flutter dessine avec Impeller, qui découpe chaque courbe
// en petits segments droits. Combien de segments ? Il en juge d'après la
// taille de la forme DANS SON REPÈRE : un cercle de rayon 0,03 lui paraît
// minuscule, il le découpe en quatre ou six segments… puis la toile
// l'agrandit 140 fois. Résultat : des yeux en losange, une bulle de pensée
// hexagonale, des reflets anguleux — exactement la capture du 29 octobre.
// Les tests de rendu, eux, passent par l'ancien moteur (Skia), qui ne fait
// pas cette erreur : d'où des planches parfaites et un téléphone qui ne
// l'est pas.
//
// ── La parade ────────────────────────────────────────────────────────
//
// `ToileFine` se glisse entre le dessin et la vraie toile. Le dessin parle
// toujours en unités de 1 ; elle, elle transmet chaque forme MILLE FOIS
// plus grande, dans une toile réduite mille fois. L'image est identique,
// mais Impeller voit des cercles de rayon 30 : il les découpe finement.
//
// Les déplacements sont multipliés aussi ; les rotations et échelles,
// qui ne dépendent pas de l'unité, passent telles quelles. Une forme peinte
// avec un dégradé (calculé en unités de 1 par le dessin) ou un flou est
// dessinée comme avant, dans le repère d'origine : ce sont les grandes
// formes (le corps de la goutte, les halos), qui n'en souffraient pas.
// ============================================================================

import 'dart:typed_data';
import 'dart:ui';

class ToileFine implements Canvas {
  ToileFine(this._c, {this.k = 1000}) {
    _c.save();
    _c.scale(1 / k);
  }

  final Canvas _c;
  final double k;

  /// À appeler une fois le dessin fini : rend la toile dans son état.
  void terminer() => _c.restore();

  Offset _o(Offset o) => o * k;
  Rect _r(Rect r) => Rect.fromLTRB(r.left * k, r.top * k, r.right * k, r.bottom * k);
  RRect _rr(RRect r) => RRect.fromLTRBAndCorners(
        r.left * k,
        r.top * k,
        r.right * k,
        r.bottom * k,
        topLeft: r.tlRadius * k,
        topRight: r.trRadius * k,
        bottomRight: r.brRadius * k,
        bottomLeft: r.blRadius * k,
      );
  Path _p(Path p) => p.transform(Float64List.fromList([k, 0, 0, 0, 0, k, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));

  /// Un dégradé ou un flou sont exprimés en unités de 1 : on les peint
  /// dans le repère d'origine.
  bool _repereOrigine(Paint p) => p.shader != null || p.maskFilter != null || p.imageFilter != null;

  /// Peint avec l'épaisseur de trait mise à l'échelle, puis la rétablit.
  void _trait(Paint p, void Function() dessin) {
    final w = p.strokeWidth;
    if (w != 0) p.strokeWidth = w * k;
    dessin();
    if (w != 0) p.strokeWidth = w;
  }

  void _origine(void Function(Canvas c) dessin) {
    _c.save();
    _c.scale(k);
    dessin(_c);
    _c.restore();
  }

  // ── L'état ─────────────────────────────────────────────────────────

  @override
  void save() => _c.save();

  @override
  void saveLayer(Rect? bounds, Paint paint) => _c.saveLayer(bounds == null ? null : _r(bounds), paint);

  @override
  void restore() => _c.restore();

  @override
  void restoreToCount(int count) => _c.restoreToCount(count);

  @override
  int getSaveCount() => _c.getSaveCount();

  @override
  void translate(double dx, double dy) => _c.translate(dx * k, dy * k);

  @override
  void scale(double sx, [double? sy]) => _c.scale(sx, sy);

  @override
  void rotate(double radians) => _c.rotate(radians);

  @override
  void skew(double sx, double sy) => _c.skew(sx, sy);

  @override
  void transform(Float64List matrix4) {
    final m = Float64List.fromList(matrix4);
    m[12] *= k;
    m[13] *= k;
    m[14] *= k;
    _c.transform(m);
  }

  // ── Les découpes ───────────────────────────────────────────────────

  @override
  void clipRect(Rect rect, {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) =>
      _c.clipRect(_r(rect), clipOp: clipOp, doAntiAlias: doAntiAlias);

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) => _c.clipRRect(_rr(rrect), doAntiAlias: doAntiAlias);

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) => _c.clipPath(_p(path), doAntiAlias: doAntiAlias);

  // ── Les formes ─────────────────────────────────────────────────────

  @override
  void drawColor(Color color, BlendMode blendMode) => _c.drawColor(color, blendMode);

  @override
  void drawPaint(Paint paint) => _c.drawPaint(paint);

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawLine(p1, p2, paint));
    _trait(paint, () => _c.drawLine(_o(p1), _o(p2), paint));
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawRect(rect, paint));
    _trait(paint, () => _c.drawRect(_r(rect), paint));
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawRRect(rrect, paint));
    _trait(paint, () => _c.drawRRect(_rr(rrect), paint));
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawDRRect(outer, inner, paint));
    _trait(paint, () => _c.drawDRRect(_rr(outer), _rr(inner), paint));
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawOval(rect, paint));
    _trait(paint, () => _c.drawOval(_r(rect), paint));
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (_repereOrigine(paint)) return _origine((t) => t.drawCircle(c, radius, paint));
    _trait(paint, () => _c.drawCircle(_o(c), radius * k, paint));
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawArc(rect, startAngle, sweepAngle, useCenter, paint));
    _trait(paint, () => _c.drawArc(_r(rect), startAngle, sweepAngle, useCenter, paint));
  }

  @override
  void drawPath(Path path, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawPath(path, paint));
    _trait(paint, () => _c.drawPath(_p(path), paint));
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    if (_repereOrigine(paint)) return _origine((c) => c.drawPoints(pointMode, points, paint));
    _trait(paint, () => _c.drawPoints(pointMode, [for (final p in points) _o(p)], paint));
  }

  // Tout le reste (images, texte, ombres…) : dans le repère d'origine.
  @override
  void drawImage(Image image, Offset offset, Paint paint) => _origine((c) => c.drawImage(image, offset, paint));

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) => _origine((c) => c.drawImageRect(image, src, dst, paint));

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) => _origine((c) => c.drawParagraph(paragraph, offset));

  @override
  void drawPicture(Picture picture) => _origine((c) => c.drawPicture(picture));

  @override
  void drawShadow(Path path, Color color, double elevation, bool transparentOccluder) =>
      _origine((c) => c.drawShadow(path, color, elevation, transparentOccluder));

  @override
  Float64List getTransform() => _c.getTransform();

  @override
  Rect getLocalClipBounds() {
    final r = _c.getLocalClipBounds();
    return Rect.fromLTRB(r.left / k, r.top / k, r.right / k, r.bottom / k);
  }

  @override
  Rect getDestinationClipBounds() => _c.getDestinationClipBounds();

  /// Les autres opérations de la toile ne servent pas aux stickers.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('ToileFine : ${invocation.memberName} non pris en charge');
}
