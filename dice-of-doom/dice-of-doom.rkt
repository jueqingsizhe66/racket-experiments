#lang racket

#|
   The Dice of Doom game, the eager version
   ----------------------------------------

   The Dice of Doom game is a turn-based game for two players sharing one keyboard.
   Since this implementation employs an eager strategy to build the complete game
   tree of all possible moves, it is only a step in the right direction.

   Each player owns hexagonal territories, which are arranged into a planar game
   board. A territory comes with a number of dice. When it is a player's turn,
   she marks one of her territories as a launching pad for an attack at a
   neigboring territory of the other player. Such an attack is enabled only if
   her chosen territory has more dice than the territory of the other player.
   The effect of the attack is that the territory changes ownership and that all
   but one of the attack dice are moved to the newly conquered territory. A
   player may continue her turn as long as she can launch attacks. Optionally,
   she may choose to pass after her first attack is executed, meaning she ends
   her turn. At the end of a turn, a number of dices are distributed across the
   players' territories. The game is over when a player whose turn it is cannot
   attack on her first move.

   A player can use the following five keys to play the game:
    -- with ← and → (arrow keys), the player changes the territory focus
    -- with enter, the player marks a territory the launching pad for an attack
    -- with the "d" key, the player unmarks a territory
    -- with the "p" key the player passes.
   Once a player passes, the game announces whose turn it is next.

   Play
   ----

   Run and evaluate
     (roll-the-dice)
   This will pop up a window that the game board, and instructions.
|#

(require "lib/main.rkt")

(roll-the-dice)
