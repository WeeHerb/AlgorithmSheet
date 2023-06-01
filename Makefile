ALL: sheet.pdf

sheet.pdf: clean
	date > build_time.txt
	typst compile index.typ sheet.pdf

dev: sheet.pdf
	cmd /C start ./sheet.pdf
	typst watch index.typ sheet.pdf

clean:
	@find . | grep -e=*.pdf | xargs -r rm
