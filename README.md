# check-update-on-arch
Check if arch needs an update and reminds you

Step 1: Create the Systemd Service File

First, you'll need to create a service file that tells systemd how to run your script.
Create the directory for user-specific systemd units if it doesn't already exist:

mkdir -p ~/.config/systemd/user Now, create the service file:

nano ~/.config/systemd/user/check-update.service

Paste the following content, making sure to replace /path/to/check_update.sh with the actual path to your script.

[Unit]
Description=Check for system updates and notify user
[Service]
ExecStart=/bin/bash /your-path/check_update.sh
[Install]
WantedBy=default.target

Step 2: Create the Systemd Timer File

Next, you'll create a timer file that schedules the service to run at a specific time.
Create the timer file:

nano ~/.config/systemd/user/check-update.timer

Paste the following content into the file:

[Unit]
Description=Run my-script daily
[Timer]
# Runs the service every day at 00:00
OnCalendar=daily
# Ensures the script runs if the system was off during the scheduled time.
Persistent=true
[Install]
WantedBy=timers.target

This timer is set to run the associated service (check-update.service) every day. The Persistent=true option is a lifesaver, as it ensures the service runs as soon as your system is turned back on if it missed a scheduled check.

Step 3: Enable and Start the Timer

With both files created, you can now enable and start the timer. This will not only run the service but also ensure it starts automatically on boot.
First, enable the timer:
​
systemctl --user daemon-reload
systemctl --user enable check-update.timer

Next, start the timer. Note that you start the timer, not the service directly. The timer is what activates the service.

systemctl --user start check-update.timer

To verify that your timer is active, you can use the following command:

systemctl --user list-timers

You should see your check-update.timer listed with its next scheduled run time.

This simple, automated setup ensures you're always aware of available updates, making your Arch Linux experience even smoother. Happy updating!

---Issues---
Not running or not showing popup box
Run:
systemctl --user status check-update.service

If it's dead start it:

​systemctl --user enable check-update.service
systemctl --user start check-update.service
