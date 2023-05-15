#!/bin/bash

set_user_id() {
    read -p "Юзер ІД: " user_id
    export USER_ID=${user_id}
    echo -e "${GREEN}Успішно виконано${NC}"
}
