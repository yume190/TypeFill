CWD=${PWD}/TestingData

.PHONY: kittenSingle
kittenSingle:
	sourcekitten doc --single-file \
		${CWD}/sample.swift.data \
		-- \
		${CWD}/sample.swift.data

.PHONY: kittenOpen
kittenOpen:
	sourcekitten request --yaml ${CWD}/yml/open.yml

.PHONY: kittencursor
kittencursor:
	sourcekitten request --yaml ${CWD}/yml/cursor.yml

.PHONY: kittenDoc
kittenDoc:
	sourcekitten request --yaml ${CWD}/yml/doc.yml

# .PHONY: open1
# open1:
# 	sourcekitten request --yaml '\
# 		key.request: source.request.editor.open\
# 		key.name: "${CWD}/sample.swift.data"\
# 		key.sourcefile: "${CWD}/sample.swift.data"\
# 		'
