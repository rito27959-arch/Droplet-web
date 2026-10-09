package com.droplet.droplet

// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA FENÊTRE DANS LA BULLE — ce qui s'affiche quand on touche la pastille
// flottante d'une conversation Droplet, par-dessus l'application en cours.
//
// ── ⚠️ POURQUOI UNE ACTIVITÉ À PART, ET PAS `MainActivity` ────────────
//
// Parce qu'une bulle est une FENÊTRE SÉPARÉE, affichée en même temps que
// l'application qui l'héberge. Android exige pour cela une activité
// déclarée redimensionnable et « incorporable » (`allowEmbedded`), lancée
// en mode document (`documentLaunchMode="always"`) pour qu'elle ait sa
// propre tâche.
//
// `MainActivity` ne peut pas l'être : elle est le point d'entrée du
// lanceur, elle porte les alias d'icône, et la rendre incorporable
// changerait son comportement partout ailleurs. Deux activités, deux
// rôles.
//
// ── ⚠️ UN SECOND MOTEUR FLUTTER, ET CE N'EST PAS GRATUIT ──────────────
//
// Cette activité démarre son propre moteur. C'est la contrepartie
// assumée : une bulle est une seconde fenêtre vivant pendant que
// l'application principale vit aussi, et les deux ne peuvent pas partager
// un moteur qui ne sait afficher qu'une surface à la fois.
//
// Le coût se compte en quelques dizaines de mégaoctets pendant que la
// bulle est ouverte. Il se paie à l'ouverture, pas en continu : Android
// détruit l'activité quand la bulle est refermée.
//
// ── ⚠️ CE QUE LA BULLE NE DOIT PAS FAIRE ──────────────────────────────
//
// Elle n'a PAS à être une copie de l'application. Elle montre une
// conversation, elle permet d'y répondre, et c'est tout. Y brancher la
// navigation complète donnerait à quelqu'un la possibilité d'ouvrir les
// réglages dans une fenêtre de 600 points posée sur une autre application
// — ce qui n'a de sens pour personne.
//
// La route passée vaut donc `/bulle/<conversation>`, pas `/chat/<id>` :
// c'est à Dart de servir une vue réduite sur cette route.
// ============================================================================

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class BulleActivity : FlutterFragmentActivity() {

    /**
     * La route donnée au moteur au tout premier rendu.
     *
     * ⚠️ `getInitialRoute` EST LU UNE SEULE FOIS, à la création du moteur.
     * Changer la route ensuite n'a aucun effet : si la bulle doit changer
     * de conversation, c'est une NOUVELLE activité qu'Android lance, avec
     * son propre moteur. C'est pourquoi le mode document est nécessaire —
     * sans lui, Android réutiliserait l'activité existante et la bulle
     * resterait sur la conversation précédente.
     */
    override fun getInitialRoute(): String {
        val route = intent?.getStringExtra("payload")
        if (!route.isNullOrEmpty()) return route
        // Repli : l'identifiant est aussi dans l'URI de la bulle, qui est
        // ce qu'Android conserve quand la bulle survit à un redémarrage.
        val id = intent?.data?.lastPathSegment
        return if (id.isNullOrEmpty()) "/" else "/bulle/$id"
    }

    override fun onCreate(etatSauvegarde: Bundle?) {
        super.onCreate(etatSauvegarde)
        // Rien d'autre ici volontairement. Pas de plein écran, pas de
        // verrouillage d'orientation, pas de barre d'état masquée : dans
        // une bulle, c'est Android qui possède la fenêtre, et toute
        // tentative de la régler se traduit par un affichage qui saute au
        // premier changement de taille — et une bulle change de taille
        // chaque fois qu'on la déplace.
    }
}
