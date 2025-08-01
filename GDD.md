### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.8 (Final Mockup Sync)

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
    - **Boucle de Rejouabilité (Roguelite)** : La disposition des notes bonus ("Empowered") est générée aléatoirement à chaque partie.
    - **Boucle de Pénalité :** Les miss consécutifs créent une spirale descendante punitive.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Structure du Jeu & Progression par Boucles**

- **La Boucle Fondamentale :** Le cœur du jeu est une boucle musicale simple d'environ **20 secondes** qui se répète continuellement tout au long de la partie.
- **Le Système de "Niveaux" de Difficulté :**
    - **Progression de la Difficulté :** La **première fois** que le score du joueur atteint un seuil de promotion pour une nouvelle épée, il débloque le niveau de difficulté supérieur de manière permanente.
    - **Évolution Irréversible :** Une fois un niveau de difficulté débloqué, le jeu ne reviendra jamais en arrière. La boucle de notes contiendra toujours les motifs de ce niveau, même si le score total ou l'état visuel de l'épée redescendent.
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

#### **2.4. Système de Pénalités et Checkpoints de Score (Planchers Numériques)**

- **Pénalité Progressive :** Chaque miss consécutif applique une pénalité de score qui double : `-500`, `-1000`, etc.
- **Reset des Pénalités :** Toute réussite réinitialise le compteur de miss.
- **Score Checkpoints :** Des paliers de score (ex: 20 000, 60 000) servent de **planchers de sécurité**. Le score total ne pourra jamais descendre en dessous du dernier checkpoint numérique atteint.

#### **2.5. Scoring & Randomisation des Notes "Empowered"**

- **Score de Base :** Perfect : 1000 ; Good : 250 ; OK : 50.
- **Système de "Braises Divines" (Notes Empowered) :**
  - **Génération Procédurale :** Au début de chaque passage à un niveau de difficulté supérieur, les "nouvelles" notes ont une chance d'être promues "Empowered".
  - **Le Pari du "Perfect" :** Le bonus "Empowered" (ex: +1500 points) ne se déclenche QUE sur un "Perfect".

#### **2.6. Évolution Dynamique de l'Épée**

- **Lien Strict au Score :** L'apparence de l'épée est **strictement et uniquement déterminée par le score total ACTUEL du joueur**.
- **Promotion & Rétrogradation Visuelle :**
    - **Promotion :** Si le score dépasse un seuil, l'épée se transforme visuellement. **Seulement la première fois**, cela déclenche le passage au niveau de difficulté supérieur.
    - **Rétrogradation :** Si le score redescend sous ce seuil, l'épée est visuellement rétrogradée.
- **Checkpoints d'Épée (Planchers Visuels) :**
    - Certains niveaux d'épée (ex: "Lame Affûtée") agissent comme des **"checkpoints visuels" permanents**. Une fois cet état atteint, **l'apparence de l'épée ne pourra plus jamais être rétrogradée en dessous**, même si le score redescend plus bas.

### **3. Interface & Présentation (UI/UX)**

#### **3.1. Disposition Générale de l'Écran**

*Basée sur la maquette visuelle initiale.*

-   **Centre :** La scène principale, avec le forgeron animé en action, l'enclume et l'épée évolutive.
-   **Haut :** La **Fever Meter**.
-   **Gauche :** Le **Parchemin "Blueprint"**, affichant en permanence une silhouette ou un dessin de l'épée dans son état final glorieux, servant d'objectif visuel constant.
-   **Bas :** La zone de jeu rythmique, avec ses trois pistes et sa zone de validation.
-   **Superposés :** Les indicateurs de score, multiplicateur, et pénalités.

#### **3.2. Représentation Visuelle du Gameplay**

*Cette section clarifie le fonctionnement visuel des pistes de rythme.*

-   **Flux des Notes :** Les notes se déplacent horizontalement de **droite à gauche** sur l'écran.
-   **Zone de Validation :** Une zone de validation fixe est située sur le **côté gauche de l'écran**. C'est dans cette zone que le joueur doit valider les notes.
-   **Pistes Thématiques :**
    -   Chaque piste est associée à une **action de forge** et un **input** spécifique.
    -   Les **objets qui voyagent** sur les pistes sont des icônes de l'action requise (enclume pour marteler, seau pour tremper, soufflet pour attiser).
    -   L'input correct est déterminé par la **piste sur laquelle la note arrive**, et non par la forme de la note elle-même (Ex: Touche HAUT pour la piste du haut, TOUJOURS).

#### **3.3. Feedback Joueur Clé**

- **Audio :** Sons spécifiques et percutants pour chaque action majeure (Perfect, Miss, transition de niveau, pénalité...).
- **Visuel :** Chiffres de score avec impact (style Balatro), affichage des pénalités en rouge. Feedback de transition fluide (flash, onde de choc, etc.).
- **Feedback de Rétrogradation :** La rétrogradation de l'épée doit être accompagnée d'un feedback visuel et sonore distinct (ex: son de "fissure", l'épée perd son éclat).

### **4. Données du Jeu**

- **Chart Data :** Un `chart` par niveau de difficulté, contenant les nouvelles notes à ajouter à la boucle.
- **Génération dynamique :** Le statut "Empowered" est assigné par un algorithme au début de chaque partie et n'est pas stocké dans le chart.

### **5. Scope pour la Game Jam (MVP - v0.8)**

- Mise en place de la boucle de jeu de 20 secondes avec au moins 3 niveaux de difficulté et des transitions fluides.
- **Construction de l'UI de jeu respectant la disposition de la maquette** (zone de jeu en bas, Blueprint à gauche, etc.).
- **Mise en place de la logique de jeu à 3 pistes de droite à gauche**.
- Implémentation complète du système de Fever Meter, des pénalités, des checkpoints de score, des checkpoints d'épée et de la randomisation "Empowered".
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- Visuels et sons de base pour toutes les mécaniques.
- 4-5 états visuels pour l'épée.
- Pas de menus complexes, une expérience jouable de bout en bout.
