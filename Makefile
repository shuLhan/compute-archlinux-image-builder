.PHONY: all
all: image publish

.PHONY: image
image:
	sudo ./build-arch-gce
	ini set host::image $$(basename -s .tar.gz `ls *.tar.gz | tail -1`) awwan.env
	ls -lh

.PHONY: publish
publish:
	awwan local gcloud-image-publish.aww 5-
	awwan local gcloud-image-cleanup.aww 5-
