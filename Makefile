compile:
	hetu compile src/plugin.ht build/plugin.out; cp build/plugin.out example/assets/bytecode/

archive:
	mkdir -p build/archive; \
	cp plugin.json build/plugin.out assets/logo.png build/archive/; \
	cd build/archive; \
	zip -r plugin.zip ./; \
	cd ../..; \
	mv build/archive/plugin.zip build/plugin.smplug

PLUGIN_NAME = deezer-arl-metadata

default: build

build:
\thetu compile src/plugin.ht -o build/plugin.out
\tmkdir -p dist
\tcp build/plugin.out dist/plugin.hetu
\tcp plugin.json dist/
\tcd dist && zip -r $(PLUGIN_NAME).smplug plugin.json plugin.hetu

clean:
\trm -rf build dist