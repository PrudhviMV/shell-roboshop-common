#!/bin/bash

source ./common.sh
app_name=user

check_root
app_setup
nodejs_setup
service_setup
print_total_time