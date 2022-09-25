


> # DOSP FALL 2022
> ## Project 1 - _Bitcoin Miner_
> ## Team Members:
> - Kshitij Sinha, UFID: 1416-0481
> - Rajdev Kapoor, UFID: 9319-4222

> ### Running the project:
> - Open two different terminals/CMDs.
> - In the first, write the command: 
> ``` erl -sname master ```
> This creates our master/server erl shell.
> - Next, compile the code using 
> ``` c(master). ```
> - Similarly, we create an actor shell/client using
> ``` erl -sname actor ``` and compile the code here also.
> - Next in the ```master``` shell, we start our program by
> ``` master:runner().```
> This will ask for the number of zeros as input (image shown below).
> 
> &emsp; ![image](https://user-images.githubusercontent.com/43610780/192123304-2d304b28-5662-4856-a747-45fe7875685e.png)
> - On the ```actor``` shell, we spawn our workers by
> ```master:spawn([number of workers], 'master@[PC-name]').```
> 
> Here,  ```[number of workers]``` is the number of actors/workers you want to spawn, ideally in our project, we found 10 workers each with 10,000 work units to be the most efficient.
> 
> 

> ### Working:
> Every time an actor/worker is spawned, it calls the ```message_actor``` function which sends the master a message that it has spawned and needs job to be allocated. The master then sends a message back (do_hash) which signals the actor to start ```hash_loop()```. This basically runs our hashing function and mines bitcoins according to our requirement and sends the coin back to the master as a message that the master prints on the console.

> ### NOTE: 
> - To use different machines on a network (distributed implementation), we just pass the IP address of the machines like this  
> ```master:spawn([number of workers], 'master@192.168.1.1').``` .
> - Remember to use ```-setcookie``` flag so that only the desired machines can communicate. 
> ```erl -sname master -setcookie secret_cookie```  and ```erl -sname actor -setcookie secret_cookie```
> 
> ### Work Unit
> The work unit we decided to go for was ```10,000``` as 
> - We tested our code with multiple combinations and this was the unit for which we found the CPU utlisation to be maximum for our machines. Though this can vary depending on which machine the mining is done one. 
>  - And this will reduce the number of same random string generations which might happen in lower units.
> ### Result for number of 0's = 4
> &emsp; ![image](https://user-images.githubusercontent.com/43610780/192123710-46ffdc7e-39fb-4687-aea6-4bedc3907528.png)
> 
> The CPU time was ```869407000 ``` and Real time elapsed was ```138334000 ```
> 
> The ratio = CPU utilisation comes out to be ```6.28 ``` which is acceptable for a 8-core CPU with some applications running in the background.
> 
> ### Coin with most 0's
> The coin with most 0 we could find on our machines was with ```7``` 
> ```"00000009bd27c2e109f9e7545c6044c448a7387a64557d5ce22384b1ff13d6ea" ``` 
> 
> with the random string ```"sinha.kshitij88usQEGqfGGaKg" ```
> 
> &emsp; ![image](https://user-images.githubusercontent.com/43610780/192123563-47b1e6b7-1cb3-4497-96d2-160a9af60e22.png)

> ### Largest number of working machines
> We tried our program on ```2``` different machines but we could detect multiple machines on the same network with the same ``` secret_cookie``` which gives us some confidence that ```more than 2``` machines could possibly push working requests to our ```master/server``` and it would allocate the job accordingly.
> ![Image]()
