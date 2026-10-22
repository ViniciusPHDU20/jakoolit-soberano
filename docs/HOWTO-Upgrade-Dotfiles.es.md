# Cómo actualizar los dotfiles de JaKooLit-Soberano

- Al actualizar los dotfiles, actualice primero el repositorio:
  - Descargue los cambios más recientes o vuelva a ejecutar el instalador Soberano:

```sh
  git clone https://github.com/ViniciusPHDU20/jakoolit-soberano.git ~/jakoolit-soberano --depth 1
  cd ~/jakoolit-soberano
  ./install-soberano.sh
```

- O use `copy.sh` con actualización exprés:

```sh
  cd ~/jakoolit-soberano
  ./copy.sh
  # seleccione `Express update` o:
  ./copy.sh --express-upgrade
```

- También hay disponible un menú simple en `TTY`:
  `./copy.sh --tty --express-upgrade`

- Si no hubo errores, reinicie o refresque con `SUPER ALT R`

| Nota: Si desea mantener limpio su directorio personal ($HOME), puede mover estos directorios

- Para usuarios más familiarizados con `git`:
  - Ejecute:
    - Arch se muestra aquí como ejemplo:

    ```sh
      cd ~/Arch-Hyprland
      git stash && git pull
      install-scripts/update-deps.sh
      cd ~/Hyprland-Dots
      git stash && git pull
      ./copy.sh
      seleccione Express Upgrade
    ```

  | Nota: Este método puede generar ocasionalmente conflictos de fusión (`merge`) en `git`. El método anterior siempre funciona
