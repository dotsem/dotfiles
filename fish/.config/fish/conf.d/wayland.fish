# Wayland environment (for Hyprland)
if test "$XDG_SESSION_TYPE" = "wayland"
    set -gx MOZ_ENABLE_WAYLAND 1
    set -gx QT_QPA_PLATFORM wayland
    set -gx GDK_BACKEND wayland,x11
    set -gx SDL_VIDEODRIVER wayland
    set -gx CLUTTER_BACKEND wayland
end
