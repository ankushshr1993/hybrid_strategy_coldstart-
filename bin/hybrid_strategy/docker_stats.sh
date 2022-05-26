#!/usr/bin/bash
sudo docker stats --format "{{ json . }}" > docker_stats.json
