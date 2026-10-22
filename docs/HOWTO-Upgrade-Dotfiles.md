# How to upgrade JaKooLit-Soberano Dotfiles

- On updates to dotfiles, update the repository first:
  - Pull the latest changes or re-run the Soberano installer

```sh
  git clone https://github.com/ViniciusPHDU20/jakoolit-soberano.git ~/jakoolit-soberano --depth 1
  cd ~/jakoolit-soberano
  ./install-soberano.sh
```

- Or use `copy.sh` with express update:

```sh
  cd ~/jakoolit-soberano
  ./copy.sh
  # select `Express update` or:
  ./copy.sh --express-upgrade
```

- A simple `TTY` menu is also available:
  `./copy.sh --tty --express-upgrade`

- Assuming no errors, reboot or refresh: `SUPER ALT R`

| Note: If you want to de-clutter your home directory you can move these directories

- For those more familiar with `git`
  - Run:
    - Arch here is example

    ```sh
      cd ~/Arch-Hyprland
      git stash && git pull
      install-scripts/update-deps.sh
      cd ~/Hyprland-Dots
      git stash && git pull
      ./copy.sh
      select Express Upgrade
    ```

  | Note: This method on occasion can generate `git` merge errors. Method above always works
