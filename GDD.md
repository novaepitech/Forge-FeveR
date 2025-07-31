### **Game Design Document : Forge FeveR**

- **Jeu :** Forge FeveR
- **Thème de la Jam :** Loop
- **Version :** 0.5 (Jam - Checkpoint Update)

### **1. Vision & Concept (High Concept)**

- **Pitch :** _Forge FeveR_ est un jeu de rythme arcade avec une touche de roguelite, où le joueur incarne un forgeron au tempérament de feu. En réussissant parfaitement des actions de forge en rythme, il doit faire monter une "Fever Meter" pour débloquer des multiplicateurs de score exponentiels. **Chaque partie offre des opportunités uniques grâce à un système de notes bonus randomisées**, transformant la quête de l'épée légendaire en un défi toujours renouvelé.
- **Piliers de Design :**
  1.  **Satisfaction Exponentielle :** Le plaisir vient de voir des chiffres exploser, passant de scores modestes à des gains colossaux en une fraction de seconde.
  2.  **Quête de la Perfection :** Le jeu ne récompense pas la médiocrité. Seule l'excellence (les "Perfects") permet de débloquer les multiplicateurs et les plus grandes récompenses.
  3.  **Feedback Sensoriel Intense :** Chaque action doit être accompagnée d'un son percutant, d'un visuel éclatant et d'une sensation de puissance.
  4.  **Punition des Erreurs :** Les erreurs consécutives sont sévèrement punies par un système de pénalités croissantes, renforçant l'importance de la précision.
- **Genre :** Jeu de rythme, Jeu d'arcade, Roguelite-like.
- **Le Twist sur le Thème "Loop" :**
  - **Boucle Musicale :** La musique s'enrichit et devient plus complexe en fonction de la performance du joueur.
  - **Boucle de Gameplay "Fever" :** Le joueur est dans un cycle constant pour attiser la "fièvre" de la forge. Il doit enchaîner les "Perfects" pour faire monter la jauge, sachant qu'elle redescend constamment et qu'un seul faux pas peut anéantir sa progression.
  - **Boucle de Rejouabilité (Roguelite)** : La disposition des notes bonus ("Empowered") est générée aléatoirement à chaque partie, rendant chaque tentative unique et imprévisible.
  - **Boucle de Pénalité :** Les miss consécutifs créent une spirale descendante punitive, forçant le joueur à briser le cycle en réussissant une note.

### **2. Mécaniques de Jeu (Gameplay)**

#### **2.1. Core Loop (La Boucle Principale)**

1.  **VOIR :** Des notes défilent. Au début du niveau, certaines notes sont promues aléatoirement au rang "Empowered" et sont visuellement distinctes. Le joueur surveille sa "Fever Meter".
2.  **AGIR :** Le joueur exécute l'action de forge correspondante au bon moment.
3.  **FEEDBACK & CONSÉQUENCE :**
    - **"Perfect" :** Coup critique ! Fait grimper significativement la "Fever Meter". Le joueur gagne une grande quantité de points de base, multipliés par son `ScoreMultiplier`. **Si la note est "Empowered", le joueur obtient un bonus de score massif ("Bonus Critique") en plus, mais UNIQUEMENT sur un Perfect.** **Remet à zéro le compteur de miss consécutifs.**
    - **"Good" / "OK" :** Coup Imparfait. Apporte peu de points de base. Applique une pénalité mineure à la "Fever Meter". **Sur une note "Empowered", ces jugements ne déclenchent AUCUN bonus et sont traités comme des coups normaux.** L'opportunité du bonus est perdue. **Remet à zéro le compteur de miss consécutifs.**
    - **"Miss" :** Échec cuisant ! La "Fever Meter" et le `ScoreMultiplier` sont **instantanément réinitialisés à zéro/x1**. Aucun point n'est marqué. **Applique une pénalité de score croissante basée sur les miss consécutifs.**
4.  **PROGRESSER :** La "Fever Meter" débloque des multiplicateurs. Le score total fait évoluer l'épée, qui peut maintenant être promue ou rétrogradée.

#### **2.2. Le Système de "Fever Meter" & Multiplicateurs**

- **La Jauge :** Une barre de progression qui ne se remplit **QU'AVEC des "Perfects"**.
- **Baisse Continue :** La jauge se vide lentement mais constamment avec le temps ET subit des pénalités mineures sur les "Good"/"OK".
- **Multiplicateurs Exponentiels : x2, x4, x8, x16, x32 (Mode "Supernova Forge").**
- **Paliers de la Fever Meter :**
  - 0-19% : x1 (Pas de multiplicateur)
  - 20-39% : x2
  - 40-59% : x4
  - 60-79% : x8
  - 80-94% : x16
  - 95-100% : x32 (Supernova Forge)

#### **2.3. Système de Pénalités et Checkpoints**

- **Pénalité Progressive :** Chaque miss consécutif applique une pénalité de score qui double à chaque occurrence :
  - **1er miss :** -500 points
  - **2ème miss consécutif :** -1000 points
  - **3ème miss consécutif :** -2000 points
  - **4ème miss consécutif :** -4000 points
  - Et ainsi de suite, doublant à chaque fois...
- **Reset des Pénalités :** Dès qu'le joueur réussit une note (Perfect, Good, ou OK), le compteur de miss consécutifs est remis à zéro et la prochaine pénalité de miss reviendra à -500 points.
- **Score Checkpoints (Planchers de Sécurité) :** Pour contrebalancer la dureté des pénalités, des paliers de score "checkpoints" sont mis en place. Une fois qu'un de ces paliers est dépassé, le score total du joueur ne pourra **plus jamais descendre en dessous de cette valeur** pour le reste de la partie.
- **Protection du Score :** Le score total ne peut jamais descendre en dessous du dernier checkpoint atteint (ou de 0 si aucun n'a été atteint).
- **Impact Psychologique :** Ce système crée une tension croissante et encourage fortement le joueur à briser la chaîne de miss le plus rapidement possible, tout en offrant des moments de soulagement en atteignant un checkpoint.

#### **2.4. Scoring & Randomisation des Notes "Empowered"**

- Le scoring est conçu pour créer des pics de tension et des récompenses spectaculaires.
- **Score de Base :**
  - **Perfect :** 1000 points de base
  - **Good :** 250 points de base
  - **OK :** 50 points de base
  - **Miss :** 0 points + pénalité progressive

- **Système de "Braises Divines" (Notes Empowered) :**
  - **Génération Procédurale :** Au début de chaque partie, le jeu identifie les "nouvelles" notes introduites à chaque palier de difficulté de la chanson. Chacune de ces notes a une chance (ex: 30%) d'être promue au rang "Empowered" pour cette partie uniquement.
  - **Le Pari du "Perfect" :** Le statut "Empowered" est une opportunité "tout ou rien". Son avantage ne se manifeste QUE sur un "Perfect".
    - **Perfect sur Empowered :** Déclenche un **"Bonus Critique"**, ajoutant une grande quantité de points supplémentaires (ex: +1500, pour un total de 2500) AVANT l'application du multiplicateur. C'est le chemin vers les scores légendaires.
    - **Good/OK sur Empowered :** La note est traitée comme une note standard. L'opportunité du bonus est manquée, augmentant la tension pour la prochaine note "Empowered".

#### **2.5. Évolution Dynamique de l'Épée**

- L'état de l'épée est un indicateur **dynamique** de la performance actuelle du joueur. Contrairement à une progression permanente, l'épée peut être **promue à un état supérieur ou rétrogradée à un état inférieur** en fonction du score total.
- **États de l'épée :** Lingot -> Lame brute -> Lame affûtée -> etc. Le dernier niveau, atteint avec un score très élevé, devrait être visuellement spectaculaire.
- **Promotion & Rétrogradation :** Si le score du joueur dépasse le seuil d'une nouvelle épée, elle est améliorée. Cependant, si le score redescend sous le seuil de l'épée actuelle (à cause de pénalités de miss), elle est visuellement **rétrogradée**. Cela crée une tension constante pour maintenir un score élevé.
- **Paliers de Score Configurables :** [10000, 25000, 50000] par défaut, permettant une progression visuelle claire de la réussite.

### **3. Interface & Présentation (UI/UX)**

- **Disposition de l'Écran :** (Identique à la v0.1, basée sur la maquette).
- **Feedback Joueur Clé :**
  - **Audio :**
    - Un son **CRÉPITANT** et puissant pour le remplissage de la "Fever Meter" sur un "Perfect".
    - Musique dynamique : L'atteinte de nouveaux paliers de multiplicateur (x8, x16...) ajoute des couches instrumentales épiques à la musique.
    - Son d'échec BRUTAL pour le "Miss" qui réinitialise la jauge.
    - **Son de pénalité spécifique pour les miss consécutifs, de plus en plus dramatique.**
  - **Visuel :**
    - La "Fever Meter" doit pulser ou prendre feu lorsqu'elle est presque pleine.
    - Le passage à un multiplicateur supérieur doit déclencher un flash à l'écran, un effet visuel sur l'épée (elle devient plus incandescente).
    - **Les chiffres du score doivent sauter, grossir et s'estomper avec style**. C'est crucial pour le feeling "Balatro". "+32 000" doit être plus gros et plus impactant que "+1 000".
    - **Les pénalités de miss doivent être affichées visuellement en rouge, avec une taille croissante pour montrer l'escalade : "-500", "-1000", "-2000", etc.**
    - **Indicateur visuel du nombre de miss consécutifs** pour créer de la tension.

### **4. Données du Jeu**

- **Chart Data :** La structure reste la même, mais son utilisation change.
  - `{"time": float, "lane": int, "input": string}`. (Le `type` est maintenant géré dynamiquement).
  - **Processus d'Initialisation** : Le "type" de note ("normal" ou "empowered") n'est plus stocké dans le chart, mais assigné dans un tableau temporaire généré au début de chaque partie par l'algorithme de randomisation.

### **5. Scope pour la Game Jam (MVP - v0.5)**

- **1 seul niveau/chanson** d'environ 2 minutes.
- Implémentation complète du système de **Fever Meter**.
- Multiplicateurs exponentiels **(x2 à x32)** fonctionnels.
- **Système de pénalités progressives pour les miss consécutifs** complètement implémenté.
- **Implémentation du système de Score Checkpoints.**
- **Mise en place du système de promotion/rétrogradation de l'épée.**
- **Mise en place du système de randomisation des notes 'Empowered' au début de chaque partie.**
- Le bonus "Empowered" qui se déclenche **uniquement sur un "Perfect"**.
- **Visuels et sons de base pour le feedback :**
  - Différenciation visuelle claire des notes "Empowered".
  - Affichage du score avec des chiffres qui ont de l'impact (taille, couleur).
  - **Affichage visuel des pénalités de miss avec escalade dramatique.**
  - Un son pour "Perfect", un pour "Miss", un pour "Empowered Perfect".
  - **Sons spécifiques pour les miss consécutifs de plus en plus dramatiques.**
- 4-5 états visuels pour l'épée, liés dynamiquement au score total.
- Pas de menus complexes.
- **Debug console affichant les informations de miss consécutifs et pénalités pour le développement.**
