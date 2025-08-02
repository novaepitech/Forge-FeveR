### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 1.4 - Forging Flow

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. Au sein de courtes boucles musicales qui s'intensifient, le joueur doit réussir des actions en rythme sur trois pistes thématiques pour débloquer des multiplicateurs de score exponentiels. Sa performance à chaque boucle détermine s'il progresse vers un défi plus grand, stagne, ou est renvoyé à un niveau de difficulté inférieur.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule la perfection (100% de réussite sur une boucle) permet de progresser vers les plus grands défis.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
  4.  **Punition des Erreurs :** Les erreurs sont sévèrement punies, non seulement par des pénalités de score, mais aussi par une possible régression du niveau de difficulté, renforçant l'importance de la précision.
- **Genre :** Jeu de rythme, Jeu d'arcade, Roguelite-like.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale Additive :** Le jeu est construit sur une unique mélodie de base qui se répète. Le tempo et la pulsation rythmique de cette mélodie ne changent **jamais**. À chaque "niveau" de difficulté, de nouvelles couches instrumentales s'ajoutent à cette boucle fondamentale, enrichissant la musique sans altérer son rythme de base.
    - **Note Technique :** Cet effet sera obtenu en lançant la lecture de **toutes les couches audio** (base, percussions, synthé, etc.) simultanément au début du jeu. Les couches des niveaux supérieurs sont initialement silencieuses (volume à -80dB). Le changement de niveau de difficulté modifie simplement le volume des couches concernées (de -80dB à 0dB et vice-versa), garantissant une transition parfaitement synchronisée et sans aucune coupure.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant et sans interruption pour attiser la "fièvre" de la forge, enchaînant les "Perfects" pour maximiser son score et faire évoluer la musique.
  - **Boucle de Rejouabilité (Roguelite)** : La promotion des notes en "Empowered" suit une logique hybride : les nouvelles notes d'un niveau ont une forte chance d'être promues, tandis que les anciennes peuvent l'être par surprise, garantissant une rejouabilité tendue et imprévisible.
  - **Boucle de Pénalité :** Un faible taux de réussite dans une boucle crée une spirale descendante punitive, pouvant entraîner une régression de niveau, contrebalancée par des checkpoints de progression visuels (les épées).

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Structure du Jeu & Flux de la Boucle Continue**

Le jeu n'est pas une succession de niveaux, mais un flux continu et ininterrompu basé sur une boucle de 24 secondes. La transition entre les niveaux de difficulté est intégrée dans le gameplay sans aucun temps mort.

- **Démarrage du jeu :**
    - Un métronome sonore se lance pour donner le tempo au joueur.
    - La première note est validée par le joueur, ce qui **déclenche** la musique de base du Niveau 1, créant un sentiment de puissance et d'agence.

- **Chronologie d'une Boucle de Transition (ex: 24 secondes) :**
    - **Phase 1 - Performance (`0s` à `21s`) :** Le joueur joue la séquence de notes du niveau actuel. La musique du niveau actuel est jouée.
    - **Phase 2 - Évaluation (`21s` à `22s`) :** Après la dernière note, le jeu calcule instantanément la performance. Le feedback visuel et sonore ("LEVEL UP!", "STAY", "LEVEL DOWN") est donné au joueur. La musique actuelle continue de jouer.
    - **Phase 3 - Anticipation Visuelle (`22s` à `24s`) :** **C'est le cœur du défi.** Les notes du **prochain** niveau de difficulté commencent à apparaître, se déplaçant vers la zone de validation. Le joueur doit les lire et anticiper leur rythme tout en entendant la fin de la musique du niveau précédent.
    - **Phase 4 - Déclenchement (`24s`) :** Au moment exact où la boucle recommence, le joueur doit frapper la première note de la nouvelle séquence. Cette action **déclenche** l'ajout (ou le retrait) des couches musicales correspondant au nouveau niveau de difficulté. L'enchaînement est parfait et l'action ne s'arrête jamais.

- **Règles de Transition (appliquées à `21s`) :**
    - **Promotion (Level Up) :** **100% de notes réussies.** Le joueur affrontera le niveau supérieur.
    - **Stagnation (Stay) :** **Entre 80% et 99% de notes réussies.** Le joueur rejouera le même niveau.
    - **Régression (Level Down) :** **Moins de 80% de notes réussies.** Le joueur est renvoyé au niveau précédent (minimum Niveau 1).

#### **2.2. Core Loop (L'expérience du joueur)**

1.  **ANTICIPER & AGIR :** Le joueur est dans un état constant d'anticipation. Guidé par le rythme immuable de la musique de base, il lit les patterns de notes qui défilent de droite à gauche et appuie sur la touche de la piste correspondante au moment précis où la note atteint la zone de validation.
2.  **SENTIR LE FEEDBACK :** Chaque action est validée instantanément.
    - **"Perfect" :** Une explosion sonore et visuelle. La "Fever Meter" grimpe, le score explose grâce au multiplicateur, et le bonus d'une note "Empowered" est activé.
    - **"Good" / "OK" :** Un son moins gratifiant. Le joueur gagne peu de points et sa "Fever Meter" est pénalisée.
    - **"Miss" :** Un son de brisure. La "Fever Meter" et le multiplicateur sont réinitialisés à zéro, et une pénalité de score est appliquée.
3.  **VIVRE LA TRANSITION :** Sans jamais s'arrêter de jouer, le joueur voit le résultat de sa performance après la dernière note de la séquence. Il doit immédiatement reporter son attention sur les nouvelles notes qui arrivent, se préparant à déclencher la prochaine vague de la forge au début de la boucle suivante.

#### **2.3. Le Système de "Fever Meter" & Multiplicateurs**

- **La Jauge :** Se remplit **QU'AVEC des "Perfects"**.
- **Baisse Continue :** La jauge se vide lentement avec le temps ET subit des pénalités sur les "Good"/"OK".
- **Multiplicateurs Exponentiels : x2, x4, x8, x16, x32 (Mode "Supernova Forge").**
- **Représentation Visuelle :** La Fever Meter est une longue barre horizontale **segmentée**. Chaque segment représente un palier de multiplicateur. Atteindre le palier maximum (x32) fait s'embraser **une flamme au bout de la jauge**, indiquant l'entrée en mode "Supernova Forge".

#### **2.4. Système de Pénalités de Score**

- **Pénalité Progressive :** Chaque miss consécutif applique une pénalité de score qui double : `-500`, `-1000`, etc.
- **Reset des Pénalités :** Toute réussite ("Perfect", "Good", "OK") réinitialise le compteur de miss et stoppe la progression des pénalités.

#### **2.5. Scoring & Système de "Braises Divines" (Notes Empowered)**

- **Score de Base :** Perfect : 1000 ; Good : 250 ; OK : 50.
- **Le Pari du "Perfect" :** Le bonus d'une note "Empowered" (ex: +1500 points) ne se déclenche **QUE sur un "Perfect"**.
- **Génération Hybride des "Braises Divines" :**
  - **"Braises Vives" (Haute Probabilité) :** Les **nouvelles notes** introduites au niveau de difficulté actuel ont une **chance ÉLEVÉE** (ex: 15%) de devenir "Empowered".
  - **"Braises Anciennes" (Basse Probabilité) :** Les notes des **niveaux de difficulté précédents** ont une **chance FAIBLE mais non-nulle** (ex: 2%) de devenir "Empowered".

#### **2.6. Évolution de l'Épée et Checkpoints de Progression**

- **Structure par Paliers et Niveaux :**
  - La progression globale du joueur est visualisée par l'épée affichée sur le parchemin. Son apparence est directement liée au score total.
  - Cette progression est divisée en **Paliers de qualité** (ex : Fer, Acier, Argent, Or...).
  - Chaque Palier est lui-même subdivisé en **3 Niveaux d'épée** (Niveau 1, Niveau 2, Niveau 3). Le joueur progresse à travers ces Niveaux en augmentant son score.
- **Le Système de Checkpoint :**
  - Un **checkpoint est activé dès que le joueur atteint un nouveau Palier de qualité** (en passant du Niveau 3 d'un palier au Niveau 1 du palier supérieur).
  - Une fois un palier-checkpoint atteint, deux règles s'appliquent :
    1.  **Plancher de Score :** Le score total du joueur ne pourra plus jamais descendre en dessous du score minimum requis pour atteindre ce palier.
    2.  **Verrouillage Visuel :** L'apparence de l'épée sur le parchemin ne pourra plus jamais être rétrogradée en dessous du Niveau 1 de ce palier.
- **Progression et Rétrogradation à l'Intérieur d'un Palier :**
  - Tant que le joueur reste à l'intérieur d'un même palier, son apparence d'épée peut évoluer ou régresser.
  - **Exemple :** Un joueur au **Palier 3, Niveau 2** qui subit des pénalités de score peut voir son épée régresser visuellement au **Palier 3, Niveau 1**. Cependant, grâce au checkpoint, il ne pourra jamais retomber au **Palier 2**, et son score ne descendra pas sous le seuil du Palier 3.

### **3. Interface & Présentation (UI/UX)**

#### **3.1. Disposition Générale de l'Écran**

- **Centre :** La scène principale avec le forgeron animé. Sur l'enclume se trouve un **modèle d'épée statique et incandescent**, représentant la lame en cours de travail, qui ne change pas d'apparence.
- **Haut :** La **Fever Meter**.
- **Gauche :** Le **Parchemin de Progression**, affichant l'épée dans son état **ACTUEL**, reflétant le score et les checkpoints atteints.
- **Bas :** La zone de jeu rythmique à trois pistes.
- **Superposés :** Indicateurs de score, multiplicateur, pénalités.

#### **3.2. Représentation Visuelle du Gameplay**

- **Flux des Notes :** Droite à gauche.
- **Zone de Validation :** Côté gauche de l'écran.
- **Pistes Thématiques :** L'input est déterminé par la piste, pas par l'icône de la note (enclume, seau, soufflet).

#### **3.3. Feedback Joueur Clé**

- **Audio :** Sons percutants pour Perfect, Miss, transition de niveau (haut/bas), pénalité. Un métronome initial.
- **Visuel :** Chiffres de score avec impact, pénalités en rouge, flash de transition de niveau.
- **Feedback de Rétrogradation :** Son de "fissure", perte d'éclat de l'épée sur le parchemin. Son de "CRACK" pour la régression de niveau.

### **4. Données du Jeu**

- **Chart Data :** Un `chart` par niveau de difficulté. Chaque chart est conçu pour s'intégrer dans la boucle de 24 secondes, avec des notes s'arrêtant avant la fin pour permettre la phase d'anticipation.
- **Génération dynamique :** Le statut "Empowered" est assigné via l'algorithme hybride.

### **5. Scope pour la Game Jam (MVP - v1.4)**

- Mise en place de la boucle de jeu **continue** de 24 secondes avec au moins 3 niveaux de difficulté.
- Construction de l'UI de jeu respectant la maquette.
- Mise en place de la logique de jeu à 3 pistes.
- Implémentation du système de progression dynamique (promotion, stagnation, régression) et du **flux de transition sans interruption**.
- Implémentation complète du système de Fever Meter, des pénalités, et des **checkpoints de score et visuels basés sur les Paliers d'épées**.
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- Visuels et sons de base pour toutes les mécaniques.
- Au moins 2 Paliers de qualité, chacun avec 3 Niveaux d'épée (total 6 apparences), incluant au moins un checkpoint.
- Pas de menus complexes, une expérience jouable de bout en bout.
