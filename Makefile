install: install-dependence
	sudo install ./display_gpu_process.sh /usr/local/bin/

install-dependence:
	git submodule update --init
	sudo install prettytable.sh/prettytable /usr/local/bin/

install-ttyd:
	curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.$(shell arch)
	mv ttyd.$(shell arch) ttyd
	chmod +x ./ttyd
	sudo install ./ttyd /usr/local/bin/

enable-systemd:
	mkdir -p ~/.config/systemd/user
	cp ./systemd/gpu-monitor.service ~/.config/systemd/user/
	systemctl --user enable gpu-monitor.service
	systemctl --user start gpu-monitor.service
