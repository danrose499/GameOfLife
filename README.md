### Conway's Game of Life (written in x86 Assembly)


When the program begins, it displays some instructions on how to set up the board, and prompts the user to enter a key to begin:
```Assembly
    instructions db "                          Welcome to THE GAME OF LIFE!                          "
                 db "Use the ARROW keys to move around the board and press SPACE to toggle a cell.   "
                 db "Press S to save the current board layout, and L to load the most recently saved "
                 db "board. When you want to begin the game, press ENTER.                            "
                 db "Enter any key to create the board:$"
```
After the user reads the instructions and presses any key, an initial 50x80 board of dead cells is printed to video memory with a highlighted cell which represents the "current cell."

![Empty Board](https://i.imgur.com/T2mZAQ5.png)

After setting up the board, the user can press __enter__ and the game begins. Additionally, the user can save the current configuration of the board or load the most previous saved game board using __S__ and __L__ respectively.

![Mid Game](https://i.imgur.com/iIuljWM.png)

#### Included Files
* __mGOL.asm__ is the assembly file with the code
* __mGOL.com__ is compiled and can be emulated using DOSBox or a similar software

Daniel Rosenthal
