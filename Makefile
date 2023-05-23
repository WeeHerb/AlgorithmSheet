ALL: sheet.pdf

sheet.pdf: clean
	typst compile index.typ sheet.pdf

dev:
	typst compile index.typ sheet.pdf
	cmd /c "start ./sheet.pdf"
	typst watch index.typ sheet.pdf

clean:
	@find . | grep -e=*.pdf | xargs -r rm
