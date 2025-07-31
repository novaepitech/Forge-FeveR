### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.1 (Jam)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade où le joueur incarne un forgeron au tempérament de feu. En suivant le rythme frénétique d'actions de forge (marteler, tremper, souffler) sur plusieurs pistes, il doit transformer un simple lingot de métal en une épée légendaire.
- **Genre :** Jeu de rythme, Jeu d'arcade
- **Public Cible :** Joueurs appréciant les jeux de rythme exigeants (_Guitar Hero_, _DDR_, _Patapon_) et les boucles de gameplay satisfaisantes et addictives.
- **Le Twist sur le Thème "Loop" :** La boucle est triple :
  1.  **Boucle Musicale :** La musique s'enrichit et se complexifie en couches successives à mesure que le joueur progresse.
  2.  **Boucle de Gameplay :** Le joueur est pris dans un cycle intense d'actions de forge, visant la perfection pour améliorer son œuvre.
  3.  **Boucle de Progression/Régression :** La qualité de l'épée peut augmenter ou diminuer, créant un cycle de tension permanent.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Core Loop (La Boucle Principale)**

1.  **VOIR :** Des notes représentant des actions de forge défilent sur 3 pistes distinctes. Le joueur voit son score actuel et la "Fever Meter" progresser.
2.  **AGIR :** Le joueur appuie sur les touches correspondantes (ex: touches directionnelles) au bon moment quand la note atteint la zone de validation de la bonne piste.
3.  **RÉCOMPENSE / CONSÉQUENCE :**
    - **Succès :** Le joueur gagne des points, augmente son combo, et son score est multiplié. Une animation et un son satisfaisant se déclenchent (un coup de marteau, un "pschitt" de trempe). L'épée et la "Fever Meter" progressent.
    - **Échec :** Le combo est brisé, le multiplicateur retombe à 1. La progression stagne.
4.  **RÉPÉTER :** Le cycle se poursuit, avec des motifs de plus en plus rapides et complexes, synchronisés avec la musique.

#### **2.2. Le Système de Pistes Thématiques**

- Le jeu se déroule sur 3 pistes horizontales. Chaque piste est associée à une action de forge :
  - **Piste 1 (Haut) : Marteler (icône enclume)** - Pour façonner le métal.
  - **Piste 2 (Milieu) : Tremper (icône seau d'eau)** - Pour refroidir et durcir la lame.
  - **Piste 3 (Bas) : Souffler (icône soufflet)** - Pour attiser les flammes et chauffer le métal.
- Chaque note est liée à une de ces pistes. Les schémas de contrôle associeront des touches spécifiques à ces actions.

#### **2.3. Scoring & Progression**

- **Jugement :** La précision est jugée sur 4 niveaux : **Perfect**, **Good**, **OK**, **Miss**.
- **Score de Base :** `Perfect: 100`, `Good: 50`, `OK: 10`, `Miss: 0`.
- **Combo :** Enchaîner des "Perfect" et "Good" augmente un compteur de combo. Un "Miss" réinitialise le combo à 0. Un "OK" ne l'affecte pas.
- **Multiplicateur :** Le combo débloque des multiplicateurs de score (x2, x3, x4) à des paliers définis (ex: 10, 20, 30 de combo).
- **"Fever Meter" (Barre de Progression) :** Une barre de progression qui se remplit en fonction du score total. C'est l'indicateur principal de la qualité de l'épée.
- **Checkpoints :** En atteignant certains paliers de score, le joueur débloque un nouveau **Niveau d'Épée**. Ce niveau devient un checkpoint : le joueur ne peut pas régresser en dessous, garantissant un sentiment de progression.

#### **2.4. Évolution de l'Épée**

- Au centre de l'écran se trouve l'épée en cours de fabrication sur une enclume.
- L'aspect visuel de l'épée change à chaque checkpoint atteint sur la "Fever Meter".
- **États possibles :** Lingot brut -> Lame grossière -> Lame affûtée -> Lame gravée -> Épée Légendaire flamboyante.

### **3. Interface & Présentation (UI/UX)**

#### **3.1. Disposition de l'Écran (Basée sur la maquette)**

- **Centre :** La scène de la forge, avec le forgeron animé, l'enclume et l'épée évolutive.
- **Gauche :** Un parchemin ("Blueprint") affichant l'objectif final de l'épée à créer.
- **Bas :** Les 3 pistes de rythme avec les icônes thématiques.
- **Haut :** La "Fever Meter" qui se remplit de gauche à droite.
- **UI Superposée :**
  - Score (en haut).
  - Multiplicateur (en haut à droite).
  - Compteur de combo (apparaît au-dessus de la scène centrale lors d'une série).

#### **3.2. Feedback Joueur**

- **Audio :**
  - Sons d'impact distincts pour chaque action (marteau, trempe, soufflet).
  - Son de validation (clair pour "Perfect", plus doux pour "Good").
  - Son de rupture de combo ("Miss").
  - Musique dynamique qui gagne en intensité et en pistes instrumentales à chaque niveau de multiplicateur/qualité d'épée.
- **Visuel :**
  - Animations du forgeron pour chaque action.
  - Étincelles et effets de particules sur un coup réussi.
  - "Flash" ou "Shake" de l'écran sur un "Perfect".
  - Texte de jugement ("PERFECT!", "MISS") qui apparaît et s'estompe rapidement.
  - Mise en valeur visuelle de l'épée lorsqu'elle change de niveau.

### **4. Données du Jeu**

- **Chart Data :** La structure des niveaux sera un tableau de dictionnaires, chaque dictionnaire contenant :
  - `time` (float) : Le moment exact où la note doit être validée.
  - `lane` (int) : L'index de la piste (0, 1 ou 2).
  - `input` (string) : L'action d'input requise (ex: "ui_left").

### **5. Scope pour la Game Jam (MVP - Produit Viable Minimum)**

- **1 seul niveau complet** avec 1 chanson.
- Toutes les mécaniques de base (3 pistes, score, combo, multiplicateur) fonctionnelles.
- Au moins **3-4 états visuels** pour l'épée.
- Feedback audio et visuel de base (sons d'impact, texte de jugement).
- Pas de menu complexe (juste "Appuyer sur Start"). Pas de système de sauvegarde. L'objectif est de livrer une expérience de jeu complète de 2 minutes.
