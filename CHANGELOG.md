# Changelog

What changed for someone running the patcher, newest first. Small fixes count. The commit history has the detail.

## 2026-09-22

- **Correction for Omarchy 4.0.4 — the earlier "ready" note was wrong.** `linux-omarchy` is not plain 7.2.5: it carries 91 Omarchy patches, several of which change core DRM struct layouts. The 5K module was built from plain kernel.org source, loaded anyway (the version string matched), and hung the boot on a black screen before the LUKS prompt. The installer now rebuilds linux-omarchy's exact source (the omarchy-pkgs commit matching the installed package's build date) and refuses to build whenever the source headers differ from the kernel's own — which also protects any future distro kernel. Separately, linux-omarchy enables the Intel IOMMU by default, which black-screens this iMac: add `intel_iommu=off` (a no-op on Arch's kernel; the Intel GPU keeps working). Boot test on the hardware pending.
- **Ready for Omarchy 4.0.4 and the `linux-omarchy` kernel (7.2.5).** 4.0.4 installs `linux-omarchy` 7.2.5, makes it the first Limine entry and keeps the old kernel as a fallback. The whole patch stack now applies to 7.2.5 with no fuzz: the 5K panel-quirk hunk was re-anchored above the PHY SSC case, because 7.2.5 adds an Apple Studio Display quirk exactly where ours used to attach. Nothing changes on 7.1–7.2.3. Remember the 5K module is built per kernel — re-run `--apply 5k` after updating, before rebooting.

## 2026-09-19

- **EarPods buttons hold properly.** Holding volume up or down now ramps the volume the whole time you hold it, instead of moving one step. The kernel's usual helper for jack buttons reports a press and its release back to back, so every press reached the desktop as a 0 ms tap however long the button was held; the driver now reports the press and the release itself. Holding the centre button sends `KEY_VOICECOMMAND` the moment the hold passes 300 ms, while it is still held (the way holding it starts Siri), so it can drive dictation; a tap is still play/pause. A held key is released anyway after 3 s if its release is ever lost, and on unplug and suspend. Thresholds are the `button_long_press_ms` and `button_max_hold_ms` module parameters.

## 2026-09-14

- **Auto-brightness works from the first minute.** Like a Mac, it now starts from a sensible curve (30% in a dark room up to 100% outdoors) instead of doing nothing until taught; any light level you have already set by hand keeps your own value, and every adjustment still teaches it.
- **Auto-brightness reacts to room lights.** The iMac's light sensor sits behind the glass and reads far below real lux (about 38 under office lights), so wluma's standard light bands called a lit office "dark" and barely changed anything. The bands are now set for this sensor: switching the office lights on takes the screen from about 45% to 75%.

## 2026-09-13

- **Auto-brightness** (new `autobright` module). The iMac's light sensor now drives the brightness through wluma, which learns from you: set the brightness by hand a few times in different light and it takes over, and later changes teach it instead of being undone. Sensor only: no screen capture, no GPU, no root, no idle dimming or colour changes. Switch it with `systemctl --user disable --now wluma` (and `enable --now` to turn it back on). Needs macOS mode. (Arch's `marked-man` is currently broken, so the install falls back to building wluma without its man page.)

## 2026-09-12

- **Screen recordings at full speed** (new `record` module). The Radeon encodes 4K at only ~29 fps, so Omarchy's 4K recordings came out sped up, shorter than their audio, and slow to stop (sometimes "force-killed"). The Screenrecord menu now records at 1920×1080, a real 60 fps even with the webcam and audio on, so recordings play at the right speed (keeping Omarchy's icons and labels). 2560×1440 managed only 52 fps under that load.
- **Smooth webcam in recordings** (`record` module). Omarchy's webcam overlay got the FaceTime camera's raw format, which it can only send at 10 fps, and it cost the recorder frames, so you looked choppy and sped up. An mpv profile for webcams asks for MJPEG instead: 30 fps, and the recorder back at full speed.
- **The patcher no longer risks locking your account.** It asks for your sudo password only when run in a terminal. Run from anything else (a widget, a script), each unanswered sudo prompt counted as a failed login, and ten in a row lock the account for ten minutes.
- **macOS mode is now the normal boot entry.** The kernel's own boot code tells the firmware "macOS is starting" (iMac18,3 added to its model list by an initramfs hook), so there is no separate EFI app and no extra menu entry: one "Omarchy > linux" entry, with or without the OpenCore USB.
- **Intel Quick Sync and working brightness** (new `macos` module): the hidden Intel HD 630 appears and becomes the default for video (H.264 about 3.7× faster than the Radeon, plus VP9 and HEVC 10-bit); the brightness slider works over the panel's full range; the panel comes up at your saved brightness from power-on.
- **`wifi` module retired.** Omarchy now ships the same Broadcom handshake fix for every Mac (omacom/omarchy#6652). Its "remove" would have deleted Omarchy's copy.
- The patcher's status shows macOS mode correctly without sudo; applying no longer shows the boot module as "n/a".
- The GPU-reset test script finds the Radeon's debug directory when the Intel GPU is exposed.
- Docs match the current setup; one-off investigation tools moved out of the repo.

## 2026-09-11

- **Screen recording and H.264 export no longer hang the GPU.** Backport of AMD's fix for the VCE encoder hang that every Polaris card has had since kernel 7.1.6 (drm/amd#5595).
- **A GPU hang now recovers** (new `gpureset` module plus two amdgpu fixes, reported as drm/amd#5810): a fresh desktop about five seconds later instead of a frozen machine, with a text message during the handoff.
- **One display in settings panels.** With the stitch on, the second tile reports disconnected, so Omarchy's display panel no longer offers it as a second output.

## 2026-09-10

- Speaker EQ parked (see `TODO.md`); the jack-aware audio panel moved to its own place.
