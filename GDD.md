### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 1.3 - Paliers

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. Au sein de courtes boucles musicales qui s'intensifient, le joueur doit réussir des actions en rythme sur trois pistes thématiques pour débloquer des multiplicateurs de score exponentiels. Sa performance à chaque boucle détermine s'il progresse vers un défi plus grand, stagne, ou est renvoyé à un niveau de difficulté inférieur.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule la perfection (100% de réussite sur une boucle) permet de progresser vers les plus grands défis.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
  4.  **Punition des Erreurs :** Les erreurs sont sévèrement punies, non seulement par des pénalités de score, mais aussi par une possible régression du niveau de difficulté, renforçant l'importance de la précision.
- **Genre :** Jeu de rythme, Jeu d'arcade, Roguelite-like.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale Additive :** Le jeu est construit sur une unique mélodie de base de 20 secondes qui se répète en boucle. À chaque "niveau" de difficulté, de nouvelles couches instrumentales s'ajoutent à cette boucle fondamentale.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant pour attiser la "fièvre" de la forge en enchaînant les "Perfects" pour maximiser son score.
  - **Boucle de Rejouabilité (Roguelite)** : La promotion des notes en "Empowered" suit une logique hybride : les nouvelles notes d'un niveau ont une forte chance d'être promues, tandis que les anciennes peuvent l'être par surprise, garantissant une rejouabilité tendue et imprévisible.
  - **Boucle de Pénalité :** Un faible taux de réussite dans une boucle crée une spirale descendante punitive, pouvant entraîner une régression de niveau, contrebalancée par des checkpoints de progression visuels (les épées).

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Structure du Jeu & Progression par Boucles**

- **La Boucle Fondamentale :** Le cœur du jeu est une boucle musicale simple d'environ **20 secondes** qui se répète continuellement tout au long de la partie.
- **Le Système de "Niveaux" de Difficulté Dynamique :**
  - **Évaluation en Fin de Boucle :** À la fin de chaque boucle de 20 secondes, le jeu évalue la performance du joueur pour déterminer le niveau de difficulté de la boucle suivante. Une "note réussie" correspond à un "Perfect", "Good" ou "OK".
  - **Règles de Transition :**
    - **Promotion (Level Up) :** Si le joueur réussit **100% des notes** de la boucle, il passe au niveau de difficulté supérieur.
    - **Stagnation (Stay) :** S'il réussit **entre 80% et 99%** des notes, il reste au même niveau de difficulté pour la boucle suivante.
    - **Régression (Level Down) :** S'il réussit **moins de 80%** des notes, il est renvoyé au niveau de difficulté précédent. Le joueur ne peut pas régresser en dessous du Niveau 1.
- **Transition Fluide :** Le changement de niveau se fait sans interruption (un flash visuel et un son distinct pour la promotion "SHIIIING" ou la régression "CRACK").

#### **2.2. Core Loop (dans chaque boucle de 20s)**

1.  **VOIR :** Des notes (icônes d'enclume, seau, soufflet) défilent de droite à gauche. Certaines sont "Empowered". Le joueur surveille sa "Fever Meter" et le parchemin de progression.
2.  **AGIR :** Le joueur appuie sur la touche correspondant à la PISTE sur laquelle la note arrive, au moment où elle atteint la zone de validation à gauche.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Fait monter la "Fever Meter", rapporte beaucoup de points, active le bonus "Empowered", réinitialise le compteur de miss.
    - **"Good" / "OK" :** Apporte peu de points, pénalise légèrement la "Fever Meter", ne déclenche pas le bonus, réinitialise le compteur de miss.
    - **"Miss" :** Réinitialise "Fever Meter" et multiplicateur, apporte 0 point, et applique une pénalité de score croissante.
4.  **ÉVALUATION & TRANSITION :** À la fin de la boucle, le pourcentage de notes réussies est calculé, déterminant si le joueur monte de niveau, stagne, ou régresse pour la boucle suivante.

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

- **Audio :** Sons percutants pour Perfect, Miss, transition de niveau (haut/bas), pénalité.
- **Visuel :** Chiffres de score avec impact, pénalités en rouge, flash de transition de niveau.
- **Feedback de Rétrogradation :** Son de "fissure", perte d'éclat de l'épée sur le parchemin. Son de "CRACK" pour la régression de niveau.

### **4. Données du Jeu**

- **Chart Data :** Un `chart` par niveau de difficulté.
- **Génération dynamique :** Le statut "Empowered" est assigné via l'algorithme hybride.

### **5. Scope pour la Game Jam (MVP - v1.3)**

- Mise en place de la boucle de jeu de 20 secondes avec au moins 3 niveaux de difficulté.
- Construction de l'UI de jeu respectant la maquette.
- Mise en place de la logique de jeu à 3 pistes.
- Implémentation du système de progression dynamique par niveau (promotion, stagnation, régression) basé sur le pourcentage de réussite par boucle.
- Implémentation complète du système de Fever Meter, des pénalités, et des **checkpoints de score et visuels basés sur les Paliers d'épées**.
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- Visuels et sons de base pour toutes les mécaniques.
- Au moins 2 Paliers de qualité, chacun avec 3 Niveaux d'épée (total 6 apparences), incluant au moins un checkpoint.
- Pas de menus complexes, une expérience jouable de bout en bout.
