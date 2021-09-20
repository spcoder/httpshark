.PHONY: bundle zip package

bundle:
	zip -9 -r dist/httpshark.app/Resources/httpshark.love src

zip:
	zip -9 -r release/httpshark_macos.zip dist/httpshark.app

package: bundle zip
