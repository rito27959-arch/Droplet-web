// ============================================================================
// LE TOAST DE DROPLET, DEPUIS N'IMPORTE QUEL WIDGET — même sans `ref`.
// ----------------------------------------------------------------------------
// Il remplace les SnackBar de Material : un bandeau gris qui monte du bas de
// l'écran n'existe pas sur iPhone, et Droplet a déjà son propre toast.
// ============================================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/mesh_provider.dart';

export '../../core/providers/mesh_provider.dart' show DropletToastType;

void afficherToast(
  BuildContext context,
  String message, {
  DropletToastType type = DropletToastType.info,
}) {
  ProviderScope.containerOf(context, listen: false)
      .read(toastProvider.notifier)
      .show(message, type: type);
}
