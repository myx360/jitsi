# update OS on startups after setup is complete
[[ -f /etc/startup_upgrade ]] && \
	sudo apt-get update -y && \
	sudo apt-get full-upgrade -y --allow-downgrades --allow-remove-essential --allow-change-held-packages

# shutdown in 5 hours (300 minutes) to prevent overspending
sudo shutdown -P +300
