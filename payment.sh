#!/bin/bash

source ./common.sh
app_name=payment

check_root
app_setup
python_setup
service_setup
service_restart
print_total_time