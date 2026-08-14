#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx