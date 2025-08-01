### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.7 (Dynamic Sword & Checkpoint Update)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. Au sein de courtes boucles musicales qui s'intensifient, le joueur doit réussir des actions en rythme pour débloquer des multiplicateurs de score exponentiels. Son score détermine dynamiquement l'état visuel de son épée, qui peut être promue ou rétrogradée, tandis que des checkpoints assurent que sa progression n'est jamais entièrement perdue.
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

- **La Boucle Fondamentale :** Le cœur du jeu est une boucle musicale simple d'environ **20 secondes** qui se répète continuellement.
- **Le Système de "Niveaux" de Difficulté :**
    - **Progression de la Difficulté :** La **première fois** que le score du joueur atteint un seuil de promotion pour une nouvelle épée, il débloque le niveau de difficulté supérieur de manière permanente.
    - **Évolution Irréversible :** Une fois un niveau de difficulté débloqué, le jeu ne reviendra jamais en arrière. La boucle de notes contiendra toujours les motifs de ce niveau, même si le score total ou l'état visuel de l'épée redescendent.
- **Transition Fluide ("Level Up!") :** Le passage à un niveau de difficulté supérieur se fait sans interruption (flash, son "SHIIIING", courte pause sans notes).

#### **2.2. Core Loop (dans chaque boucle de 20s)**

1.  **VOIR :** Des notes défilent. Certaines sont "Empowered". Le joueur surveille sa "Fever Meter".
2.  **AGIR :** Le joueur exécute l'action de forge correspondante au bon moment.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Fait monter la "Fever Meter", rapporte beaucoup de points, active le bonus "Empowered", réinitialise le compteur de miss.
    - **"Good" / "OK" :** Apporte peu de points, pénalise légèrement la "Fever Meter", ne déclenche pas le bonus, réinitialise le compteur de miss.
    - **"Miss" :** Réinitialise "Fever Meter" et multiplicateur, apporte 0 point, et applique une pénalité de score croissante.

#### **2.3. Le Système de "Fever Meter" & Multiplicateurs**

- **La Jauge :** Se remplit **QU'AVEC des "Perfects"**.
- **Baisse Continue :** La jauge se vide lentement avec le temps ET subit des pénalités sur les "Good"/"OK".
- **Multiplicateurs Exponentiels : x2, x4, x8, x16, x32.**

#### **2.4. Système de Pénalités et Checkpoints de Score (Planchers Numériques)**

*Cette section concerne UNIQUEMENT la valeur numérique du score.*

- **Pénalité Progressive :** Chaque miss consécutif applique une pénalité de score qui double : `-500`, `-1000`, etc.
- **Reset des Pénalités :** Toute réussite (Perfect, Good, OK) réinitialise le compteur de miss.
- **Score Checkpoints :** Des paliers de score (ex: 20 000, 60 000) servent de **planchers de sécurité**. Le score total ne pourra jamais descendre en dessous du dernier checkpoint numérique atteint.

#### **2.5. Scoring & Randomisation des Notes "Empowered"**

- **Score de Base :** Perfect : 1000 ; Good : 250 ; OK : 50.
- **Système de "Braises Divines" (Notes Empowered) :**
  - **Génération Procédurale :** Au début de chaque passage à un niveau de difficulté supérieur, les "nouvelles" notes ont une chance d'être promues "Empowered".
  - **Le Pari du "Perfect" :** Le bonus "Empowered" (ex: +1500 points) ne se déclenche QUE sur un "Perfect".

#### **2.6. Évolution Dynamique de l'Épée**

L'état visuel de l'épée est un thermomètre de la performance actuelle du joueur, indépendant des niveaux de difficulté débloqués.

-   **Lien Strict au Score :** L'apparence de l'épée (Lingot, Lame Brute, etc.) est **strictement et uniquement déterminée par le score total ACTUEL du joueur**.
-   **Promotion & Rétrogradation Visuelle :**
    -   **Promotion :** Si le score du joueur dépasse le seuil d'une épée supérieure (ex: 50 000 points), elle se transforme visuellement. C'est à ce moment, et **seulement la première fois**, que le niveau de difficulté des notes est augmenté de façon permanente.
    -   **Rétrogradation :** Si le score redescend sous le seuil de l'épée actuelle (ex: passe de 51 000 à 48 000), elle est visuellement **rétrogradée** à l'état inférieur.
-   **Checkpoints d'Épée (Planchers Visuels) :**
    -   Pour récompenser la progression, certains niveaux d'épée (ex: "Lame Affûtée" à 25 000 pts) agissent comme des **"checkpoints visuels" permanents**.
    -   Une fois qu'un de ces paliers est activé, **l'apparence de l'épée ne pourra plus jamais être rétrogradée en dessous de cet état**, même si le score total redescend plus bas.
    -   **Exemple :** Le joueur atteint le checkpoint visuel "Lame Affûtée" (25 000 pts), puis son score retombe à 15 000. Son score numérique sera de 15 000, mais son épée restera visuellement une "Lame Affûtée".

### **3. Interface & Présentation (UI/UX)**

- **Disposition de l'Écran :** (Basée sur la maquette initiale).
- **Feedback Joueur Clé :**
    - **Audio :** Sons spécifiques et percutants pour chaque action majeure (Perfect, Miss, transition de niveau, pénalité...).
    - **Visuel :** Chiffres de score avec impact (style Balatro), affichage des pénalités en rouge, indicateurs visuels pour le Fever Meter. Feedback de transition fluide (flash, onde de choc, etc.).
    - **Feedback de Rétrogradation :** La rétrogradation de l'épée doit être accompagnée d'un feedback visuel et sonore distinct mais moins sévère qu'un "Miss". Par exemple, un son de "fissure" et l'épée qui perd brièvement son éclat.

### **4. Données du Jeu**

- **Chart Data :** Un `chart` par niveau de difficulté, contenant les nouvelles notes à ajouter à la boucle.
- **Génération dynamique :** Le statut "Empowered" est assigné par un algorithme au début de chaque partie, il n'est pas stocké dans le chart.

### **5. Scope pour la Game Jam (MVP - v0.7)**

- Mise en place de la boucle de jeu de 20 secondes avec au moins 3 niveaux de difficulté et des transitions fluides.
- Implémentation complète du système de Fever Meter, des pénalités, et de la randomisation.
- **Implémentation du système de Score Checkpoints (planchers numériques).**
- **Implémentation du système d'évolution de l'épée STRICTEMENT basé sur le score.**
- **Mise en place des "Checkpoints d'Épée" (planchers visuels) pour bloquer la rétrogradation à certains paliers.**
- Visuels et sons de base pour toutes les mécaniques, y compris la promotion ET la rétrogradation de l'épée.
- 4-5 états visuels pour l'épée.
- Pas de menus complexes, une expérience jouable de bout en bout.
