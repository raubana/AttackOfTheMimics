Attack of the Mimics - ReadMe
Updated 7/30/2017
Dylan J. Raub


================================================================================
  Installation
================================================================================

To install this gamemode, use GIT to clone the entire project to your addons
folder, or just download the project and extract it to your addons folder.

The addons folder is located in your Garry's Mod folder. The path should be
something like this:

  Steam/steamapps/common/GarrysMod/garrysmod/addons

Make sure that the folder this ReadMe is contained in is what is dropped into
the addons folder.




================================================================================
  aotm_mall_v1.bsp
================================================================================

The gamemode used to come with a map for your enjoyment. However, there were
problems with errors. Instead, here is the link to the packed version:

   http://steamcommunity.com/sharedfiles/filedetails/?id=1095448769

If you're running a dedicated server, you can use GMAD to unpack the .bsp from
the .gma. Shh!




================================================================================
  Team Selection
================================================================================

Players will spawn into the server in "spectate mode". To move from
"spectate mode" to "play mode," a player must hit their Menu key (Default: Q) to
open the team-select window and then press the button with the text "I want to
play!" Note that this will not take effect until a new round has begun.

Players will remain in whichever mode they picked between rounds until they
disconnect from the server.

Once the minimum number of players have moved into "play mode," the gamemode
will start a timer that counts down. When it reaches zero, a new round will
begin.

Players are assigned roles randomly. However, the gamemode uses prior play
history to help assign roles to players. This means a player who hasn't played
for a few rounds is more likely to get to play in the future, and a player who
hasn't been on a specific team for a while is more likely to end up on that
team in the future.




================================================================================
  How To Play - General
================================================================================

All players will have stamina that they will need to manage carefully. Their
stamina will be shown at the bottom right of the HUD as the bar labeled "NRG."

You lose stamina when you run, jump, or attack.

If your stamina ever runs out, you will become tired. When you're tired, you 
cannot run and won't be able to jump very high. Once you've regained all of your
stamina, you will no longer be tired.



================================================================================
  How To Play - Mechanic
================================================================================
The mechanics have to complete a set of tasks in order to win. Naturally, they
must also survive. They can also win by killing all of the mimics. 

The mechanics have a set of useful tools:


1)  Walkie Talkie
	
    The walkie talkie (also known as a two-way radio) can be used to communicate
	between mechanics from long distances. To use it, simply hold your primary
	fire button (Default: Mouse Left Button) and talk.
	
	You cannot talk to someone using the walkie talkie unless you have it
	deployed. However, you can still hear someone through the walkie talkie,
	even when it is holstered.
	
	Don't stand too close to another walkie talkie while transmitting, or you
	will create feedback. Ouch!
	
	
2)  Task Board

    The task board shows the list of tasks that must be completed in order to
	win. If there are no tasks listed, then you must kill the mimics to win.
	
	Whenever a task has been completed, the box next to the task will have a 
	checkmark in it.


3)  Key Ring

    The key ring has a set of keys you can use to unlock and lock some doors
	on the map.
	
	To use it, first select the key you want to use by pressing Reload
	(Default: R) until the key's code is shown by the crosshair. Then look at
	the door and either press your primary fire (Default: Mouse Left Button) to
	unlock it, or press your secondary fire (Default: Mouse Right Button)
	to lock it.
	
	Every time you put your keys away, you lose your spot on the ring.


4)  Flashlight
    
    The flashlight can be used both as a tool and a weapon. To toggle the light,
	press your primary fire (Default: Mouse Left Button). To attack with the
	flashlight, hit your secondary fire (Default: Mouse Right Button).
	
	Each attack with the flashlight does 25 damage.
	
	The flashlight can only be on while it is deployed.


	

================================================================================
  How To Play - Mimic
================================================================================
The mimics must kill the mechanics before their tasks are completed to win.

The mimic can see a little in the dark. They can also toggle between first and
third person by hitting their Left-Alt key.

The mimics have two tools:

1)  Claws
	
    Press your primary fire button (Default: Mouse Left Button) to attack
	whatever is in front of you.
	
	By default, the claws do 10 damage. However, the claws can do up to 6 times
	this amount of damage if the conditions are right.
	
	You can do up to 2 times more damage based on how much stamina you have, as
	long and you're not tired.
	
	You can do up to 3 times more damage if you attack a person's back.
	
	
2)  Mimic
    
	The mimic tool is used to mimic props around the map. To mimic a prop, go up
	to it and press your primary fire (Default: Mouse Left Button) while aiming
	at it.
	
	Bear in mind, you can only mimic props of certian dimentions and volumes.
	You might not be able to mimic something if it's too thin, too small, too
	long, too tall, or too large.
	
	Remember: hit your Left-Alt button to toggle between first person and third
	person.

    