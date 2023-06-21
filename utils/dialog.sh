#!/bin/bash

adss_dialog() {
  dialog --title "Execution Message" --infobox "$1" 10 40
}

confirm_dialog() {
  dialog --title "Execution Message" --msgbox "$1" 10 40
}

