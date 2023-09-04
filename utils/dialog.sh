#!/bin/bash

adss_dialog() {
  dialog --ascii-lines --title "Execution Message" --infobox "$1" 10 40
}

confirm_dialog() {
  dialog --ascii-lines --title "Execution Message" --infobox "$1" 10 40
  sleep 2
}
