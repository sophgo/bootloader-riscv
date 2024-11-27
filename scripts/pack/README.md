# PC Pack Tools
This tool is used to pack loader, application and upgrader togather. The input of this tool is loader, application and upgrader binary file, besides application and upgrader offset in flash.  
Loader located at fixed offset of 0, efit (executable file information table) at fixed offset of 28K byte.

# How to compile
Just make.

# How to use
pack loader application application-offset upgrader upgrader-offset flash-image-file
