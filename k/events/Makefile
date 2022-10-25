run:
	control create cm feh$$(date +%s) --from-file=script=events.sh
	sleep 1; control logs -f -l events.argoproj.io/trigger=run-this