.PHONY: bundle zip package

bundle:
	pushd src && zip -9 -r ../dist/httpshark.app/Contents/Resources/httpshark.love . && popd

zip:
	pushd dist && zip -9 -r ../release/httpshark_macos.zip httpshark.app && popd

package: bundle zip
