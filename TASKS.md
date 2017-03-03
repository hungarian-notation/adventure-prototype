# Tasks

The goal of this prototype is to test my combat model for gameplay quality. To
that end, I need to focus on elements that may enhance the players' enjoyment
of the combat.

- Add sound effects
- Enhance enemy AI
- Vary enemy AI   

# Considerations for Expansion 

It might make sense to track different entity types in different systems, though
passing multiple systems through our code will complicate things.

# Ai

I want some sort of high level interface to AI functionality so that I can implement
the strategic layer separate from the tactical layer.


Entity Controller: Moves the entity
Entity Tactics: Every frame, per entity; Utilizes the entity's motion controller to meet goals set by tactics.
Entity Strategy: Event driven, per entity; Manage the tactical state machine
Enemy Strategy: Event driven, per instance; Coordinate the strategic layers of all entities.