# ``Gassi Data Model``

Description of the Core Data Model used with Gassi.

## Overview

The Default Data UUID is composed out of following parts:
- Birthday of Spoony    07031973
- App                   07031973-1000   Gassi
- Entity                07031973-1000-xxxx
- Value                 07031973-1000-xxxx-xxxx
- (number)              07031973-1000-xxxx-xxxx-xxxxxxxxxxxx

## Entities

### DOG
*Entity ID: 1000*

- id            (UUID)
- name          (String)
- breed         (BREED)
- birthday      (Date)
- sex           (SEX)
- events        [EVENT]

#### Default Data
- 07031973-1000-1000-1000-000000001000  "Dein Hund"


### BREED
*Entity ID: 2000*

- id            (UUID)
- name          (String)
- dogs          [DOG]

#### Default Data
- none

### SEX
*Entity ID: 3000*

- id            (UUID)
- name          (String)
- dogs          [DOG]

#### Default Data
- 07031973-1000-3000-1000-000000001000  "weiblich"
- 07031973-1000-3000-2000-000000002000  "männlich"


### EVENT
*Entity ID: 5000*

- id            (UUID)
- timestamp     (Date)
- dog           (DOG)
- type          (TYPE)
- subtype       (SUBTYPE)

#### Default Data
- none

### TYPE
*Entity ID: 6000*

- id            (UUID)
- name          (String)
- predict       (Boolean)
- subtypes      [SUBTYPE]
- events        [EVENT]

#### Default Data
- 07031973-1000-6000-1000-000000000000  "Pipi"
- 07031973-1000-6000-1010-000000000000  "Kacka"
- 07031973-1000-6000-1050-000000000000  "Kotzen"
- 07031973-1000-6000-1100-000000000000  "Futter"
- 07031973-1000-6000-1200-000000000000  "Trinken"
- 07031973-1000-6000-2000-000000000000  "Training"
- 07031973-1000-6000-3000-000000000000  "Sport"
- 07031973-1000-6000-4000-000000000000  "Spiel"


### SUBTYPE
*Entity ID: 7000*

- id            (UUID)
- name          (String)
- types         [TYPE]
- events        [EVENT]

#### Default Data
- 07031973-1000-7000-1010-000000001000  "Hart"
- 07031973-1000-7000-1010-000000002000  "Weich"
- 07031973-1000-7000-1010-000000003000  "Durchfall"

- 07031973-1000-7000-1100-000000001000  "Trocken"
- 07031973-1000-7000-1100-000000002000  "Nass"
- 07031973-1000-7000-1100-000000003000  "Rohes Fleisch"
- 07031973-1000-7000-1100-000000003100  "BARF"
- 07031973-1000-7000-1100-000000003500  "Gekochtes Fleisch"
- 07031973-1000-7000-1100-000000004000  "Leckerchen"
- 07031973-1000-7000-1100-000000005000  "Kauartikel"

- 07031973-1000-7000-1200-000000001000  "Wasser"

- 07031973-1000-6000-2000-000000001000  "Sitz"
- 07031973-1000-6000-2000-000000002000  "Platz"
- 07031973-1000-6000-2000-000000003000  "Bleib"
- 07031973-1000-6000-2000-000000004000  "Hier"
- 07031973-1000-6000-2000-000000005000  "Fuß"
- 07031973-1000-6000-2000-000000006000  "Nein"
- 07031973-1000-6000-2000-000000006200  "Aus"
- 07031973-1000-6000-2000-000000006100  "Pfui"


-> Pee
-> Poo
    - Hard
    - Soft
    - Diarrhea

- Vomit
- Food
    - Dry
    - Wet
    - Raw meat
    - Boiled meat
    - Treat
    - Chew stick
- Drink
    - Water
- Training
    - Sit
    - Down
    - Stay
    - Come
    - Stop
    - Out
    - pfui
    - nein
- Sport
    - Agility
    - Dog Dancing
    - Obedience
    - Coursing
- Play

