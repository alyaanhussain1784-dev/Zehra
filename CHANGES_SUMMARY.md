# Zehra OS - Comprehensive Rebranding & Configuration Summary

## Overview
This document summarizes all changes made to transform the EndeavourOS-based ISO into **Zehra OS** with **Celestia Shell** as the default desktop environment.

---

## 1. Package Manifest Updates (`packages.x86_64`)

### Added Pre-installed Applications:

**Office & Productivity:**
- `libreoffice-fresh`

**Media & Audio/Video:**
- `vlc`
- `kdenlive`

**Digital Art & 3D Content Creation:**
- `blender`
- `inkscape`
- `gimp`

**Core System Utilities:**
- `fastfetch`
- `btop`
- `nautilus` (GTK file manager for GNOME app compatibility)
- `ark` (already present)

**Development & Containerization:**
- `docker`
- `docker-compose`
- `flatpak`

**Celestia Shell Dependencies (reorganized):**
- Window Manager: `hyprland`, `wayland`, `xorg-xwayland`
- Qt6 Base: `qt6-base`, `qt6-declarative`, `qt6-shadertools`, `qt6-multimedia`
- Audio: `matugen`, `cava`, `pipewire`, `wireplumber`
- Display Manager: `sddm`
- Lockscreen: Built from source - `ryoku-orbital-clock-lockscreen` (https://github.com/Rizmi/ryoku-orbital-clock-lockscreen)

**Preserved EndeavourOS Repositories:**
- `endeavouros-mirrorlist`, `endeavouros-keyring`, `endeavouros-branding`, etc.

---

## 2. System Identity Rebranding (EndeavourOS → Zehra OS)

| File | Changes |
|------|---------|
| `profiledef.sh` | `iso_name="Zehra_OS"`, `iso_label="ZEHRA_..."`, `iso_publisher="Zehra OS <https://github.com/zehra-os>"`, `iso_application="Zehra OS Live/Rescue CD"` |
| `airootfs/etc/hostname` | `zehra-os` |
| `airootfs/etc/motd` | Complete rewrite with Zehra OS branding, links, and community info |
| `run_before_squashfs.sh` | Removed `endeavouros` from `pacman-key --populate`, updated wallpaper paths to `zehra-wallpaper.png`, fallback motd |
| `prepare.sh` / `prepare_auto.sh` | Updated wallpaper download URL to `https://raw.githubusercontent.com/zehra-os/branding/main/backgrounds/zehra-wallpaper.png` |
| `airootfs/root/endeavouros-skel-liveuser/PKGBUILD` | Updated maintainer, pkgdesc, url |
| `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.bashrc` | Changed PS1 prefix from `eos-` to `zehra-`, updated fallback message |

---

## 3. Boot Splash Screen (Zehra OS - NOT "Sehra")

### Syslinux (BIOS) - `syslinux/archiso_sys-linux.cfg`
- Updated all `MENU LABEL` entries: "Zehra OS All GPUs (BIOS)", "Zehra OS with NVIDIA drivers (BIOS)", "Zehra OS Fallback nomodeset (BIOS)"
- Added `quiet splash` kernel parameters for Plymouth integration

### systemd-boot (UEFI) - `efiboot/loader/entries/*.conf`
- `archiso-x86_64-linux.conf`: "Zehra OS with open source drivers: All GPUs"
- `archiso-x86_64-linux-nv.conf`: "Zehra OS with NVIDIA drivers: Only RTX GPUs, Turing, or later"
- `fallback.conf`: "Zehra OS fallback nomodeset"
- All entries: Added `quiet splash` kernel parameters

### Note
**Strictly uses "Zehra OS" everywhere** - no "Sehra" spelling anywhere in boot configs.

---

## 4. Core Software UI Renaming (ryoku/ryostore → Zehra)

### GitHub Actions Workflow (`.github/workflows/build.yml`)
| Original Binary | New Binary |
|-----------------|------------|
| `ryoku` | `zehra` |
| `ryoku-hub` | `zehra-hub` |
| `ryoku-shell-install` | `zehra-shell-install` |
| `ryoku-wm` | `zehra-wm` |
| `ryoku-i18n` | `zehra-i18n` |
| `ryoku-shell-ipc` | `zehra-shell-ipc` |
| `ryoku-palette-bridge` | `zehra-palette-bridge` |
| `ryoku-rashin-backend` | `zehra-rashin-backend` |
| `ryovm-fetch` | `zevra-vm-fetch` |
| `ryovm-remote` | `zevra-vm-remote` |
| `ryovm-mon` | `zevra-vm-mon` |
| `ryostore-backend` | `zehra-store-backend` |

**Preserved:** Qt QML plugin module name `Ryoku.Blobs` (upstream module name, required for build)

---

## 5. Celestia Shell Configuration

### Hyprland Keybindings (`airootfs/etc/skel/.config/hypr/hyprland.conf`)
- **Super+Tab**: `cyclenext` (forward window switching)
- **Super+Shift+Tab**: `cyclenext, prev` (reverse window switching)
- **Super+Shift+L**: Launch `ryoku-orbital-clock-lockscreen`

### Autostart Applications
- `caelestia shell -d` (Celestia Shell desktop)
- `pipewire & wireplumber` (Audio)
- `swww-daemon` (Wallpaper)
- `hypridle` (Idle management)
- `ryoku-orbital-clock-lockscreen` (Lockscreen daemon)

### Shell Configuration (`airootfs/etc/skel/.config/caelestia/shell.json`)
- Audio visualizers **already enabled**: `showVisualiser: true`, `visualiserStyle: "bars"`
- Lockscreen visualizer: `mediaVisualiser: "bars"`
- Dashboard visualizer: `showVisualiser: true`, `visualiserStyle: "bars"`

---

## 6. Ryoku Orbital Clock Lockscreen Integration

### Source
- Repository: https://github.com/Rizmi/ryoku-orbital-clock-lockscreen
- Fetched during `prepare.sh` and `prepare_auto.sh`
- Built during `run_before_squashfs.sh` (supports PKGBUILD, CMake, or Meson)

### Configuration
- Hyprland: `exec-once = ryoku-orbital-clock-lockscreen &`
- Keybinding: `bind = $mainMod SHIFT, L, exec, ryoku-orbital-clock-lockscreen`
- User commands: Copies to `/etc/caelestia/lockscreen/` for installed system

---

## 7. Calamares & KDE Branding

| File | Changes |
|------|---------|
| `calamares.desktop` | `Name=Install Zehra OS`, `Comment=Calamares — Zehra OS System Installer`, `Exec=zehra-welcome` |
| `plasma look-and-feel metadata.json` | `Id=com.zehraos.breezedarkzehra.desktop`, `Name=Breeze Dark Zehra OS` |
| `wallpaper metadata.json` | `Id=ZehraOS`, `Name=Zehra OS` |
| `konsole profile` | `Name=Zehra OS` |
| `kdeglobals` | `LookAndFeelPackage=com.zehraos.breezedarkzehra.desktop` |

---

## 8. SDDM Configuration (Live ISO)
Added to `user-commands-before.bash`:
- Creates `/etc/sddm.conf.d/10-celestia.conf` with Celestia Shell as default session
- Auto-login for liveuser

---

## 9. Directory Structure Preserved

Per requirements, the following were **NOT renamed** (to avoid build breakage):
- `EndeavourOS-ISO-main/` directory
- `airootfs/root/endeavouros-skel-liveuser/` directory
- `endeavouros-skel-liveuser` package name
- EndeavourOS repositories in `pacman.conf` and `packages.x86_64`

---

## 10. Files Modified

### ISO Profile (`EndeavourOS-ISO-main/`)
1. `packages.x86_64` - Added all pre-installed apps + reorganized dependencies
2. `profiledef.sh` - ISO identity
3. `prepare.sh` - Wallpaper URL + lockscreen fetch
4. `prepare_auto.sh` - Wallpaper URL + lockscreen fetch
5. `run_before_squashfs.sh` - Key imports, wallpaper paths, lockscreen build/install
6. `reset.sh` - Cleanup for new wallpaper name
7. `syslinux/archiso_sys-linux.cfg` - Boot menu labels + splash params
8. `efiboot/loader/entries/archiso-x86_64-linux.conf` - UEFI boot title + splash
9. `efiboot/loader/entries/archiso-x86_64-linux-nv.conf` - UEFI NVIDIA title + splash
10. `efiboot/loader/entries/fallback.conf` - UEFI fallback title + splash
11. `airootfs/etc/hostname` - System hostname
12. `airootfs/etc/motd` - Welcome message
13. `airootfs/etc/skel/.config/hypr/hyprland.conf` - Keybindings, autostart, lockscreen
14. `airootfs/etc/skel/.config/caelestia/shell.json` - (Already had visualizers enabled)
15. `airootfs/root/endeavouros-skel-liveuser/PKGBUILD` - Package metadata
16. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.bashrc` - PS1 + ISO info
17. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/user-commands-before.bash` - SDDM + lockscreen setup
18. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.local/share/applications/calamares.desktop` - Installer branding
19. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.local/share/plasma/look-and-feel/.../metadata.json` - Theme branding
20. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.local/share/wallpapers/EndeavourOS/metadata.json` - Wallpaper branding
21. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.local/share/konsole/EndeavourOS.profile` - Terminal profile
22. `airootfs/root/endeavouros-skel-liveuser/src/etc/skel/.local/etc/xdg/kdeglobals` - KDE theme selection

### CI/CD (`.github/`)
23. `.github/workflows/build.yml` - Binary renaming for Zehra OS CLI tools

### Root Scripts
24. `build_local.sh` - (Already branded as Zehra OS)

---

## 11. Build Readiness for GitHub Actions

The repository is now ready for cloud compilation via GitHub Actions:

1. **Trigger**: Push to main/master or manual workflow_dispatch
2. **Go Build Job**: Builds all Zehra OS CLI tools (renamed from ryoku)
3. **Qt Plugin Job**: Builds Ryoku.Blobs QML plugin (upstream name preserved)
4. **QML Lint**: Validates all QML files
5. **Shellcheck**: Validates all shell scripts
6. **Go Format**: Ensures code style compliance
7. **Artifacts**: All binaries uploaded for ISO build

### Local Build
```bash
./build_local.sh --clean --verbose
```

### Requirements
- Docker with privileged access
- 20GB+ free disk space
- Arch Linux base image (used in CI)

---

## 12. Post-Build Verification Checklist

- [ ] ISO boots to GRUB showing "Zehra OS" entries
- [ ] Plymouth splash shows "Zehra OS" (requires plymouth package + theme)
- [ ] Live session starts Celestia Shell automatically
- [ ] Super+Tab switches windows fluidly
- [ ] Super+Shift+L launches orbital clock lockscreen
- [ ] Audio visualizers work in dashboard/lockscreen
- [ ] Calamares installer shows "Install Zehra OS"
- [ ] Installed system has all pre-installed applications
- [ ] GTK apps (Nautilus, GNOME Text Editor) run under Celestia Shell
- [ ] Docker, Flatpak, and development tools functional

---

## 13. Notes for Future Development

1. **Plymouth Theme**: Create a Zehra OS Plymouth theme at `/usr/share/plymouth/themes/zehra-os/`
2. **Wallpaper**: Host Zehra OS branded wallpapers at `https://github.com/zehra-os/branding`
3. **Lockscreen**: Monitor ryoku-orbital-clock-lockscreen for releases; consider packaging for AUR
4. **Calamares Branding**: Add Zehra OS slides/images to `/etc/calamares/branding/`
5. **Welcome App**: Develop `zehra-welcome` to replace `eos-welcome` for post-install setup

---

*Generated on: $(date)*
*Zehra OS Build System*
