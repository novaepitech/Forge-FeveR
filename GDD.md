### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.3 (Jam)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. En réussissant parfaitement des actions de forge en rythme, il doit faire monter une "Fever Meter" pour débloquer des multiplicateurs de score exponentiels. **Chaque partie offre des opportunités uniques grâce à un système de notes bonus randomisées**, transformant la quête de l'épée légendaire en un défi toujours renouvelé.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule l'excellence (les "Perfects") permet de débloquer les multiplicateurs et les plus grandes récompenses.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
- **Genre :** Jeu de rythme, Jeu d'arcade, Roguelite-like.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale :** La musique s'enrichit et devient plus complexe en fonction de la performance du joueur.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant pour attiser la "fièvre" de la forge. Il doit enchaîner les "Perfects" pour faire monter la jauge, sachant qu'elle redescend constamment et qu'un seul faux pas peut anéantir sa progression.
  - **Boucle de Rejouabilité (Roguelite)** : La disposition des notes bonus ("Empowered") est générée aléatoirement à chaque partie, rendant chaque tentative unique et imprévisible.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Core Loop (La Boucle Principale)**

1.  **VOIR :** Des notes défilent. Au début du niveau, certaines notes sont promues aléatoirement au rang "Empowered" et sont visuellement distinctes. Le joueur surveille sa "Fever Meter".
2.  **AGIR :** Le joueur exécute l'action de forge correspondante au bon moment.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Coup critique ! Fait grimper significativement la "Fever Meter". Le joueur gagne une grande quantité de points de base, multipliés par son `ScoreMultiplier`. **Si la note est "Empowered", le joueur obtient un bonus de score massif ("Bonus Critique") en plus, mais UNIQUEMENT sur un Perfect.**
    - **"Good" / "OK" :** Coup Imparfait. Apporte peu de points de base. Applique une pénalité mineure à la "Fever Meter". **Sur une note "Empowered", ces jugements ne déclenchent AUCUN bonus et sont traités comme des coups normaux.** L'opportunité du bonus est perdue.
    - **"Miss" :** Échec cuisant ! La "Fever Meter" et le `ScoreMultiplier` sont **instantanément réinitialisés à zéro/x1**. Aucun point n'est marqué.
4.  **PROGRESSER :** La "Fever Meter" débloque des multiplicateurs. Le score total fait évoluer l'épée.

#### **2.2. Le Système de "Fever Meter" & Multiplicateurs**

- (Inchangé par rapport à la v0.2)
- **La Jauge :** Une barre de progression qui ne se remplit **QU'AVEC des "Perfects"**.
- **Baisse Continue :** La jauge se vide lentement mais constamment avec le temps ET subit des pénalités mineures sur les "Good"/"OK".
- **Multiplicateurs Exponentiels : x2, x4, x8, x16, x32 (Mode "Supernova Forge").**

#### **2.3. Scoring & Randomisation des Notes "Empowered"**

- (Section majeure mise à jour)
- Le scoring est conçu pour créer des pics de tension et des récompenses spectaculaires.
- **Score de Base Élevé :** Un "Perfect" sur une note standard rapporte au moins **1000 points** de base.

- **Système de "Braises Divines" (Notes Empowered) :**
  - **Génération Procédurale :** Au début de chaque partie, le jeu identifie les "nouvelles" notes introduites à chaque palier de difficulté de la chanson. Chacune de ces notes a une chance (ex: 30%) d'être promue au rang "Empowered" pour cette partie uniquement.
  - **Le Pari du "Perfect" :** Le statut "Empowered" est une opportunité "tout ou rien". Son avantage ne se manifeste QUE sur un "Perfect".
    - **Perfect sur Empowered :** Déclenche un **"Bonus Critique"**, ajoutant une grande quantité de points supplémentaires (ex: +1500, pour un total de 2500) AVANT l'application du multiplicateur. C'est le chemin vers les scores légendaires.
    - **Good/OK sur Empowered :** La note est traitée comme une note standard. L'opportunité du bonus est manquée, augmentant la tension pour la prochaine note "Empowered".

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

- **Chart Data :** La structure reste la même, mais son utilisation change.
  - `{"time": float, "lane": int, "input": string}`. (Le `type` est maintenant géré dynamiquement).
  - **Processus d'Initialisation** : Le "type" de note ("normal" ou "empowered") n'est plus stocké dans le chart, mais assigné dans un tableau temporaire généré au début de chaque partie par l'algorithme de randomisation.

### **5. Scope pour la Game Jam (MVP - v0.3)**

- **1 seul niveau/chanson** d'environ 2 minutes.
- Implémentation complète du système de **Fever Meter**.
- Multiplicateurs exponentiels **(x2 à x32)** fonctionnels.
- **Mise en place du système de randomisation des notes 'Empowered' au début de chaque partie.**
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- **Visuels et sons de base pour le feedback :**
  - Différenciation visuelle claire des notes "Empowered".
  - Affichage du score avec des chiffres qui ont de l'impact (taille, couleur).
  - Un son pour "Perfect", un pour "Miss", un pour "Empowered Perfect".
- 3-4 états visuels pour l'épée, liés au score total.
- Pas de menus complexes.
