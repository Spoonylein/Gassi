# ``Gassi Data Model``

Description of the Core Data Model used with Gassi.

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->

SEX
- id            (UUID)
- name          (String)
- dogs          [DOG]

BREED
- id            (UUID)
- name          (String)
- dogs          [DOG]

DOG
- id            (UUID)
- name          (String)
- breed         (BREED)
- birthday      (Date)
- sex           (SEX)
- events        [EVENT]

EVENT by TYPE and SUBTYPE
- id            (UUID)
- timestamp     (Date)
- dog           (DOG)
- type          (TYPE)
- subtype       (SUBTYPE)

TYPE
- id            (UUID)
- name          (String)
- predict       (Boolean)
- subtypes      [SUBTYPE]
- events        [EVENT]

SUBTYPE
- id            (UUID)
- name          (String)
- types         [TYPE]
- events        [EVENT]


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
    - Obedience
- Sport
- Play

