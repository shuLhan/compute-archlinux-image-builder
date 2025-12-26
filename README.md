## Arch Linux Image Builder for Google Compute Engine

This project provides a script that creates an
[Arch Linux](https://www.archlinux.org/)
image that can run on
[Google Compute Engine](https://cloud.google.com/compute/).

The image is configured to be as close as possible to a base Arch Linux
installation, while still allowing it to be fully functional and optimized for
Compute Engine.
Notable choices made and differences compared to a standard Arch Linux
installation are the following:

- systemd-boot is used with a UEFI-based boot and a GPT partition table.
- systemd-networkd is used to manage networks.
- systemd-resolved is used to manage resolv.conf (DNS).
- systemd-timesyncd is enabled and configured to synchronize time using the
  Compute Engine metadata server.
- Serial console logging is enabled from kernel command line and journald is
  configured to forward to it.
- Block multiqueue is configured from the kernel command line to optimize
  Compute Engine disk performance.
- A minimal initcpio is configured for booting on Compute Engine virtual
  machines.
- Root filesystem is ext4.
  Root partition and filesystem are automatically extended at boot using
  systemd-repart and systemd-growfs, to support dynamic disk resizing.
- Locale is set to en_GB.UTF-8
- Timezone is set to UTC.
- An OpenSSH server is installed and enabled, with root login and password
  authentication forbidden.
  User SSH keys are deployed and managed automatically by the Linux Guest
  Environment as described in the
  [corresponding documentation](https://cloud.google.com/compute/docs/instances/connecting-to-instance).
- Sudo is installed.
  Permission to use sudo is managed automatically by Linux Guest Environment.

An additional Pacman repository, build.kilabit.info, is used to install and
keep the [Linux Guest Environment](https://docs.cloud.google.com/compute/docs/images/guest-environment)
packages up to date.
List of installed Linux Guest Environment packages and link to their
corresponding AUR repository,

- [google-cloud-ops-agent](https://aur.archlinux.org/packages/google-cloud-ops-agent-git)
- [google-compute-engine](https://git.sr.ht/~shulhan/aur-google-compute-engine)
- [google-compute-engine-oslogin](https://git.sr.ht/~shulhan/aur-google-compute-engine-oslogin)
- [google-guest-agent](https://git.sr.ht/~shulhan/aur-google-guest-agent)

## Prebuilt Images

You can use [Cloud SDK](https://cloud.google.com/sdk/docs/) to create instances
with the latest prebuilt Arch Linux image. To do that follow the SDK
installation procedure, and then run the [following
command](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create):

```console
$ gcloud compute instances create INSTANCE_NAME \
      --image-project=kilabit --image-family=arch
```

List of latest images is available
[here](https://build.kilabit.info/compute-archlinux-image-builder/current-images.txt),
build and updated
[once a week](https://build.kilabit.info/karajo/app/#job_gcp-image-arch)
(usually at Saturday morning at 01:00 UTC).

## Build Your Own Image

You can build the Arch Linux image yourself with the following procedure:

1.  Install the required dependencies and build the image

    ```console
    $ sudo pacman -S --needed arch-install-scripts dosfstools e2fsprogs
    $ git clone https://github.com/shuLhan/compute-archlinux-image-builder.git
    $ cd compute-archlinux-image-builder
    $ sudo ./build-arch-gce
    ```

    If the build is successful, this will create an image file named
    arch-v$DATE.tar.gz in the current directory, where $DATE is the current
    date.

2.  Install and configure the [Cloud SDK](https://cloud.google.com/sdk/docs/).

3.  Create new storage bucket to copy the image, or you can use the existing
    one.
    For example, this one create bucket in region asia-southeast1 under
    project `$PROJECT_NAME`.

    ```console
    $ gcloud storage buckets create gs://$BUCKET_NAME \
      --default-storage-class=standard \
      --location=asia-southeast1 \
      --project=$PROJECT_NAME \
      --uniform-bucket-level-access

    ```

4.  Copy the local image file to Google Cloud Storage:

    ```console
    $ gcloud storage cp arch-v$DATE.tar.gz gs://$BUCKET_NAME/arch-v$DATE.tar.gz
    ```

5.  Import the image file to Google Compute Engine as a new custom image:

    ```console
    $ gcloud compute images create $IMAGE_NAME \
          --family=arch \
          --guest-os-features=GVNIC,UEFI_COMPATIBLE,VIRTIO_SCSI_MULTIQUEUE \
          --project=$PROJECT_NAME \
          --source-uri=gs://$BUCKET_NAME/arch-v$DATE.tar.gz
    ```

You can now create new instances with your custom image:

```console
$ gcloud compute instances create INSTANCE_NAME --image=$IMAGE_NAME
```

The image in storage file is no longer needed, so you can delete it if you
want:

```console
$ gcloud storage rm --all-versions gs://$BUCKET_NAME/arch-v$DATE.tar.gz
```

## Testing with qemu

Change the owner of disk or tar.gz file to your own user and then run

```
$ ./qemu.sh <disk | image-name>
```

## Contributing Changes

See [CONTRIB.md](CONTRIB.md).

## Licensing

All files in this repository are under the
[Apache License, Version 2.0](LICENSE)
unless noted otherwise.

## Support

Google LLC does not provide any support, guarantees, or warranty for this
project or the images provided.
