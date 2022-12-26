NAME=Prynt3r
VERSION=0.0.1
#DEST_BIN=~/bin/
DEST_BIN=/usr/bin
DEST_SHARE=/usr/share
CMD=prynt3r
NICK=prynt3r
CPAN=cpan

all::
	@echo "make requirements install deinstall"
	@echo "-- on low RAM systems use 'apt install cpanminus' and then 'make CPAN=cpanm requirements'"

requirements::
	sudo apt install ser2net socat slic3r
	sudo apt install yagv libperl-dev
	pip3 install -r requirements.txt

install::
	sudo cp ${CMD} ${DEST_BIN}/
	mkdir -p ${HOME}/.config/${NICK}; cd ${HOME}/.config/${NICK}; mkdir -p printer macro macro/filament slicer gconsole gconsole/commands 
	sudo mkdir -p ${DEST_SHARE}/${NICK}
	cd settings; tar cf - printer/*.ini macro/*.ini macro/filament/*.ini slicer/*.json slicer/*/base.ini slicer/*/map.ini slicer/*/*.def.json slicer/*/strict.ini gconsole | (cd ${DEST_SHARE}/${NICK}/; sudo tar xf -)

deinstall::
	sudo rm -f ${DEST_BIN}/${CMD}

# ---------------------------------------------------------------------------------------------------------------
# -- developer(s) only:

edit::
	dee4 prynt3r Makefile CHANGELOG README.md LICENSE settings/slicer/*.json settings/*/*.ini settings/*/*/*.ini settings/gconsole/commands/*

backup::
	cd ..; tar cfz ${NAME}-${VERSION}.tar.gz "--exclude=*/slicers/*" ${NAME}; mv ${NAME}-${VERSION}.tar.gz ~/Backup; scp ~/Backup/${NAME}-${VERSION}.tar.gz backup:Backup/

backup-settings::
	cd ~/; tar cfz ${NAME}-Config-`date +%F`.tar.gz .config/prynt3r; mv ${NAME}-Config-`date +%F`.tar.gz ~/Backup/; scp ~/Backup/${NAME}-Config-`date +%F`.tar.gz backup:Backup/

change::
	git commit -am "..."

pull::
	git pull

push::
	git push -u origin master

examples::
	./prynt3r --fill-density=0 --output=examples/cube.png render Parts/cube.scad
	./prynt3r --fill-density=0 --scale=50mm --output=examples/cube-scaled1.png render Parts/cube.scad
	./prynt3r --fill-density=0 --scale=10mm,20mm,100mm --output=examples/cube-scaled2.png render Parts/cube.scad
	./prynt3r --fill-density=0 --output=examples/benchy.png render Parts/3DBenchy.stl
	./prynt3r --fill-density=0 --scale=0,0,150mm --output=examples/benchy-scaled.png render Parts/3DBenchy.stl

logdb::	logdb-setup
	sqltk --uri=pg://prynt3r --input=jsonl --filter=ascii --keys=@ -- "insert into parts (data) values (?)" < ~/.prynt3r/log.json

logdb-setup::
	createdb prynt3r
	sqltk --uri=pg://prynt3r "create table parts ( data jsonb )"

logdb-test::
	sqltk --uri=pg://prynt3r --output=json "select data from parts where data->'uid' = ?" '"...."'
	sqltk --uri=pg://prynt3r --output=json "select data from parts where data->'file_list' @> ?" '"cube.stl"'

stuffdb::	stuffdb-setup
	sqltk --uri=pg://mystuff --input=jsonl --filter=ascii --keys=@ -- "insert into prynt3r (data) values (?)" < ~/.prynt3r/log.json

stuffdb-setup::
	sqltk --uri=pg://mystuff "drop table prynt3r"
	sqltk --uri=pg://mystuff "create table prynt3r ( data jsonb )"


