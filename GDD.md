### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.2 (Jam)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade "roguelite-like" où le joueur incarne un forgeron au tempérament de feu. En réussissant parfaitement des actions de forge en rythme, le joueur doit faire monter une "Fever Meter" pour débloquer des multiplicateurs de score exponentiels et déclencher une pluie de points jubilatoire, transformant un simple lingot en une épée légendaire aux pouvoirs démesurés.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule l'excellence (les "Perfects") permet de progresser et d'accéder aux plus grandes récompenses.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
- **Genre :** Jeu de rythme, Jeu d'arcade, Hyper-satisfaisant.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale :** La musique s'enrichit et devient plus complexe en fonction de la performance du joueur.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant pour attiser la "fièvre" de la forge. Il doit enchaîner les "Perfects" pour faire monter la jauge, sachant qu'elle redescend constamment et qu'un seul faux pas peut anéantir sa progression.
  - **Boucle de Score :** Des boucles de gameplay parfaites déclenchent des boucles de scores massifs.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Core Loop (La Boucle Principale)**

1.  **VOIR :** Des notes défilent sur 3 pistes thématiques. Certaines notes sont visuellement distinctes ("Empowered"), indiquant une valeur de points supérieure. Le joueur surveille sa "Fever Meter".
2.  **AGIR :** Le joueur exécute l'action de forge correspondante au bon moment.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Coup critique ! Fait grimper significativement la "Fever Meter". Le joueur gagne une grande quantité de points de base, multipliés par son `ScoreMultiplier` actuel. Le jeu répond par un impact sonore, visuel et une animation puissante.
    - **"Good"** / **"OK" :** Coup Imparfait. N'apporte que très peu de points de base et n'augmente pas la "Fever Meter". Pire, ces jugements appliquent une pénalité mineure et immédiate à la jauge, en plus de sa baisse naturelle constante, renforçant la nécessité d'atteindre la perfection pour progresser.
    - **"Miss" :** Échec cuisant ! La "Fever Meter" et le `ScoreMultiplier` sont **instantanément réinitialisés à zéro/x1**. Aucun point n'est marqué.
4.  **PROGRESSER :** La "Fever Meter" pleine déclenche le `ScoreMultiplier` suivant. Les points de base des notes augmentent avec les "Niveaux" de la chanson.

#### **2.2. Le Système de "Fever Meter" & Multiplicateurs**

- C'est la mécanique centrale de progression. Elle remplace un système de combo classique.
- **La Jauge :** Une barre de progression qui ne se remplit **QU'AVEC des "Perfects"**.
- **Baisse Continue :** La jauge se vide lentement mais constamment avec le temps.
- **Multiplicateurs Exponentiels :** La jauge est divisée en paliers qui débloquent des multiplicateurs de plus en plus puissants.
  - Palier 1 : **x2**
  - Palier 2 : **x4**
  - Palier 3 : **x8**
  - Palier 4 : **x16**
  - Palier 5 : **x32 (Mode "Supernova Forge")**
- Le multiplicateur est appliqué au score de base de la note.

#### **2.3. Scoring & Notes "Empowered"**

- Le scoring est conçu pour être exponentiel et spectaculaire.
- **Score de Base Élevé :** Un "Perfect" sur une note standard rapporte au moins **1000 points** de base.
- **Notes "Empowered" (Spéciales) :**
  - Certaines sections plus difficiles de la chanson contiennent des notes visuellement distinctes (enflammées, dorées).
  - Ces notes rapportent une valeur de base bien plus élevée (ex: **2500+ points**).
  - Réussir une séquence de notes "Empowered" avec un multiplicateur élevé est la clé pour atteindre des scores stratosphériques.
- **Augmentation par Niveau de Chanson :** Lorsque la musique passe à un "Niveau" de difficulté supérieur (ex: couplet 2, refrain intense), la valeur de base de toutes les notes peut augmenter, reflétant la puissance grandissante de la forge.

#### **2.4. Évolution de l'Épée et Feedback**

- L'évolution de l'épée est directement liée aux paliers du **score total**. Elle sert de "checkpoint" de progression global et de vitrine de la réussite du joueur.
- **États de l'épée :** Lingot -> Lame brute -> Lame affûtée -> etc. Le dernier niveau, atteint avec un score très élevé, devrait être visuellement spectaculaire.

### **3. Interface & Présentation (UI/UX)**

- **Disposition de l'Écran :** (Identique à la v0.1, basée sur la maquette).
- **Feedback Joueur Clé :**
  - **Audio :**
    - Un son **CRÉPITANT** et puissant pour le remplissage de la "Fever Meter" sur un "Perfect".
    - Musique dynamique : L'atteinte de nouveaux paliers de multiplicateur (x8, x16...) ajoute des couches instrumentales épiques à la musique.
    - Son d'échec BRUTAL pour le "Miss" qui réinitialise la jauge.
  - **Visuel :**
    - La "Fever Meter" doit pulser ou prendre feu lorsqu'elle est presque pleine.
    - Le passage à un multiplicateur supérieur doit déclencher un flash à l'écran, un effet visuel sur l'épée (elle devient plus incandescente).
    - **Les chiffres du score doivent sauter, grossir et s'estomper avec style**. C'est crucial pour le feeling "Balatro". "+32 000" doit être plus gros et plus impactant que "+1 000".

### **4. Données du Jeu**

- **Chart Data :** Le dictionnaire par note doit inclure une notion de `type`.
  - `{"time": float, "lane": int, "input": string, "type": string}`
  - `type` peut être "normal" ou "empowered". Le code attribuera un score de base différent en fonction de ce type.

### **5. Scope pour la Game Jam (MVP - v0.2)**

- **1 seul niveau/chanson** d'environ 2 minutes, avec une difficulté progressive et des sections de notes "Empowered" bien identifiées.
- Implémentation complète du système de **Fever Meter** qui se remplit avec les "Perfects" et baisse avec le temps.
- Multiplicateurs exponentiels **(x2, x4, x8, x16, x32)** fonctionnels et liés à la Fever Meter.
- **Visuels et sons de base pour le feedback :**
  - Différenciation visuelle des notes "Empowered".
  - Affichage du score avec des chiffres qui ont de l'impact.
  - Un son pour "Perfect", un son pour "Miss", un son de passage de palier.
- 3-4 états visuels pour l'épée, liés au score total.
- Pas de menus complexes. L'expérience doit être jouable du début à la fin.
