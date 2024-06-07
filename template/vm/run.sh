#!/bin/sh
NIXOS_CONFIG="$PWD/configuration.nix" nixos-rebuild build-vm --max-jobs auto --builders '' && (
  if command -v kitty &>/dev/null; then
    kitty ${DEBUG:+--hold} sh -c "QEMU_KERNEL_PARAMS=console=ttyS0 result/bin/run-*-vm ${@@Q} -nographic || read" &
  else
    result/bin/run-*-vm "$@" &
  fi
)

