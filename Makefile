ALL: sheet.pdf

sheet.pdf: clean
	typst index.typ sheet.pdf

dev:
	typst watch index.typ sheet.pdf

clean:
	@find . | grep -e=*.pdf | xargs -r rm
