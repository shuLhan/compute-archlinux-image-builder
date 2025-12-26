.PHONY: all
all: image image.publish

.PHONY: image
image:
	sudo ./build-arch-gce
	ini set host::image $$(basename -s .tar.gz `ls *.tar.gz | tail -1`) awwan.env
	ls -lh

.PHONY: image-qemu
image-qemu:
	sudo IMAGE_QEMU=1 ./build-arch-gce

.PHONY: image.publish
image.publish:
	awwan local gcloud-image-publish.aww 5-
	awwan local gcloud-image-cleanup.aww 5-

.PHONY: image.test
image.test:
	awwan local gcloud-image-test.aww 4-18

## Preview the .md files in local using [ciigo].
## Open http://127.0.0.1:8080/README.html to preview the README.
##
## [ciigo]: https://sr.ht/~shulhan/ciigo/
.PHONY: serve.doc
serve.doc:
	ciigo -address 127.0.0.1:8080 serve .
