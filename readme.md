# Doom Fire in Zig 

A version of the Doom Fire effect, inspired by the excellent article by [Fabien Sanglard](http://fabiensanglard.net/doom_fire_psx/)

## Notes
- SDL2 seems fairly straightforward to use via C interop.
- This is the first time I've played with Zig, there's some stuff in there that probably isn't best practice.
- Linux - you should be fine if you have a development version of SDL2 installed. 
- Windows - I was using the MinGW version of SDL2 (see build.zig)
    - Headers in "deps/include"
    - Libs in "deps/lib"
- Enjoy!
