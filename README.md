# RawGodot
This is a RAW image processor made with Godot.

It uses the Godot 4 Vulkan API for the image processing.


## Masking

With masks the user can apply the effects certain parts of the image. Multiple masks can be applied at the same time.
![Custom effects](images/masks.png)



![Default mask overlay](images/mask_with_default_overlay.png)
The default mask overlay color can be changed, aswell as the opacity of the overlay. 

![Changed mask overlay](images/mask_with_changed_overlay.png)

## Custom effects
It is possible to create custom effects during runtime. The shader parameters defined in the code will their own sliders which can be adjusted.

![Custom effects](images/mosaic_small2.png)