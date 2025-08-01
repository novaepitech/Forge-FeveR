### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 1.0 (Checkpoint System Refined)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. Au sein de courtes boucles musicales qui s'intensifient, le joueur doit réussir des actions en rythme sur trois pistes thématiques pour débloquer des multiplicateurs de score exponentiels. Son score détermine dynamiquement l'état visuel de son épée, comparé en permanence à un "Blueprint" de l'objectif final.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule l'excellence (les "Perfects") permet de débloquer les multiplicateurs et les plus grandes récompenses.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
  4.  **Punition des Erreurs :** Les erreurs consécutives sont sévèrement punies par un système de pénalités croissantes, renforçant l'importance de la précision.
- **Genre :** Jeu de rythme, Jeu d'arcade, Roguelite-like.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale Additive :** Le jeu est construit sur une unique mélodie de base de 20 secondes qui se répète en boucle. À chaque "niveau" de difficulté, de nouvelles couches instrumentales s'ajoutent à cette boucle fondamentale.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant pour attiser la "fièvre" de la forge en enchaînant les "Perfects".
  - **Boucle de Rejouabilité (Roguelite)** : La promotion des notes en "Empowered" suit une logique hybride : les nouvelles notes d'un niveau ont une forte chance d'être promues, tandis que les anciennes peuvent l'être par surprise, garantissant une rejouabilité tendue et imprévisible.
  - **Boucle de Pénalité :** Les miss consécutifs créent une spirale descendante punitive, contrebalancée par des checkpoints de progression tangibles.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Structure du Jeu & Progression par Boucles**

- **La Boucle Fondamentale :** Le cœur du jeu est une boucle musicale simple d'environ **20 secondes** qui se répète continuellement tout au long de la partie.
- **Le Système de "Niveaux" de Difficulté :**
  - **Progression de la Difficulté :** La **première fois** que le score du joueur atteint un seuil de promotion pour une nouvelle épée, il débloque le niveau de difficulté supérieur de manière permanente.
  - **Évolution Irréversible :** Une fois un niveau de difficulté débloqué, le jeu ne reviendra jamais en arrière. La boucle de notes contiendra toujours les motifs de ce niveau.
- **Transition Fluide ("Level Up!") :** Le passage à un niveau de difficulté supérieur se fait sans interruption ni écran de chargement (flash, son "SHIIIING", courte pause sans notes).

#### **2.2. Core Loop (dans chaque boucle de 20s)**

1.  **VOIR :** Des notes (icônes d'enclume, seau, soufflet) défilent de droite à gauche. Certaines sont "Empowered". Le joueur surveille sa "Fever Meter" et le "Blueprint" de l'épée.
2.  **AGIR :** Le joueur appuie sur la touche correspondant à la PISTE sur laquelle la note arrive, au moment où elle atteint la zone de validation à gauche.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Fait monter la "Fever Meter", rapporte beaucoup de points, active le bonus "Empowered", réinitialise le compteur de miss.
    - **"Good" / "OK" :** Apporte peu de points, pénalise légèrement la "Fever Meter", ne déclenche pas le bonus, réinitialise le compteur de miss.
    - **"Miss" :** Réinitialise "Fever Meter" et multiplicateur, apporte 0 point, et applique une pénalité de score croissante.

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

- **Lien Score-Épée :** L'apparence de l'épée est par défaut déterminée par le score total ACTUEL du joueur.
- **Promotion & Rétrogradation :**
  - **Promotion :** Si le score dépasse le seuil d'une nouvelle épée, celle-ci est forgée. La **première fois**, cela déclenche le passage au niveau de difficulté supérieur.
  - **Rétrogradation :** Si le score redescend sous le seuil d'une épée, son apparence est rétrogradée... **sauf si un checkpoint a été atteint.**
- **Checkpoints d'Épée (Le Jalon de Progression) :**
  - **Système de Sauvegarde Unique :** Les checkpoints sont uniquement basés sur des paliers d'épées clés (par exemple, la 3ème épée, la 6ème, etc.). C'est le seul système de checkpoint du jeu.
  - **Protection Contre la Rétrogradation :** Une fois qu'une épée-checkpoint est forgée, **l'apparence de l'arme ne pourra plus jamais être rétrogradée en dessous de ce palier**, même si le score du joueur chute bien en deçà du seuil requis. Cela offre au joueur un sentiment de sécurité et un accomplissement tangible et permanent.

### **3. Interface & Présentation (UI/UX)**

#### **3.1. Disposition Générale de l'Écran**

- **Centre :** La scène principale, avec le forgeron animé en action, l'enclume et l'épée évolutive.
- **Haut :** La **Fever Meter**.
- **Gauche :** Le **Parchemin "Blueprint"**, affichant l'épée dans son état final glorieux.
- **Bas :** La zone de jeu rythmique à trois pistes.
- **Superposés :** Indicateurs de score, multiplicateur, pénalités.

#### **3.2. Représentation Visuelle du Gameplay**

- **Flux des Notes :** Droite à gauche.
- **Zone de Validation :** Côté gauche de l'écran.
- **Pistes Thématiques :** L'input est déterminé par la piste, pas par l'icône de la note (enclume, seau, soufflet).

#### **3.3. Feedback Joueur Clé**

- **Audio :** Sons percutants pour Perfect, Miss, transition, pénalité.
- **Visuel :** Chiffres de score avec impact, pénalités en rouge, flash de transition.
- **Feedback de Rétrogradation :** Son de "fissure", perte d'éclat de l'épée.

### **4. Données du Jeu**

- **Chart Data :** Un `chart` par niveau de difficulté.
- **Génération dynamique :** Le statut "Empowered" est assigné via l'algorithme hybride.

### **5. Scope pour la Game Jam (MVP - v1.0)**

- Mise en place de la boucle de jeu de 20 secondes avec au moins 3 niveaux de difficulté.
- Construction de l'UI de jeu respectant la maquette.
- Mise en place de la logique de jeu à 3 pistes.
- Implémentation complète du système de Fever Meter, des pénalités, et des **checkpoints de progression basés sur les épées**.
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- Visuels et sons de base pour toutes les mécaniques.
- 4-5 états visuels pour l'épée, dont au moins une épée-checkpoint.
- Pas de menus complexes, une expérience jouable de bout en bout.
