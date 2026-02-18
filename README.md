# Introduction
This repository collects interactive applications that run on compute nodes using Open OnDemand.
All applications are executed using Singularity, a Linux container runtime.
The Singularity image OS is Rocky Linux 9.7, and the supported architectures are x86_64 and aarch64.

In this repository, interactive applications are categorized into "Visualization Applications" and "Development Applications".
The applications currently provided are listed below.

## Visualization Applications
| Name | x86_64 | aarch64 | Description |
| --- | --- | --- | --- |
| [Gnuplot](http://www.gnuplot.info/) | 5.4.3 | 5.4.3 | Command-line driven graphing program |
| [ParaView](https://www.paraview.org/) | 6.0.1 | 5.11.1 | Scientific and technical data visualization program |
| [XCrySDen](http://www.xcrysden.org/) | 1.6.3 | 1.6.3 | Visualization program for crystal and molecular structures |
| [PyMOL](https://www.pymol.org/) | 2.5.0 | 2.5.0 | Visualization and analysis program for 3D structures of biomacromolecules |
| [GrADS](http://opengrads.org/) | 2.2.3 | - | Visualization and analysis program for gridded data in meteorology and climate fields |
| [VisIt](https://visit-dav.github.io/visit-website/) | 3.4.2 | - | Visualization and analysis program supporting various scientific data formats |
| [VESTA](https://jp-minerals.org/vesta/jp/) | 3.5.8 | - | Visualization program for crystal structures and 3D data such as electron/nuclear densities |
| [Smokeview](https://pages.nist.gov/fds-smv/) | 6.10.6 | - | Visualization program for displaying results from [FDS](https://pages.nist.gov/fds-smv/) and [CFAST](https://pages.nist.gov/cfast/index.html) |
| [OVITO](https://www.ovito.org/) | 3.14.1 | - | Visualization and analysis program for large datasets such as particle simulations |
| [ImageJ](https://imagej.net/ij/) | 1.54 | - | Image processing software running on the Java Virtual Machine |

## Development Applications
| Name | x86_64 | aarch64 | Description |
| --- | --- | --- | --- |
| [Desktop (Xfce)](https://www.xfce.org/) | 4.18 | 4.18 | Lightweight desktop environment running on the X Window System |
| [VSCode](https://code.visualstudio.com/) | 4.108.2 | 4.108.2 | Code editor developed by [Microsoft](https://www.microsoft.com/) |
| [JupyterLab](https://jupyter.org/) | 4.5.3 | 4.5.3 | Interactive execution environment for programs running in a web browser |

# Usage
## Download the Repository
Save this repository under `/var/www/ood/apps/sys/`.
```bash
$ cd /var/www/ood/apps/sys
$ sudo git clone https://github.com/OpenOnDemandJP/oodjp_apps.git
```

## Build Singularity Images
Use `containers/rocky97_x86_64.def` if the compute node architecture is x86_64, or `containers/rocky97_aarch64.def` if it is aarch64.
Commands are shown below.
Build time is about 20 minutes, depending on server and network performance.

### For x86_64
```bash
$ singularity build --fakeroot rocky97_x86_64.sif rocky97_x86_64.def
```

### For aarch64
```bash
$ singularity build --fakeroot rocky97_aarch64.sif rocky97_aarch64.def
```

## Edit the Configuration Files
Edit `/var/www/ood/apps/sys/oodjp_apps/utils/config.yml` to match your environment.
Settings for unused architectures are ignored, so you do not need to modify them.
  - `xdg_data_home`: Directory for storing application data
  - `container_image`: Path to the Singularity image
```yaml
xdg_data_home:
  x86_64:  "<%= ENV['HOME'] %>/ondemand/x86_64"
  aarch64: "<%= ENV['HOME'] %>/ondemand/aarch64"

container_image:
  x86_64:  /cloud_opt/ondemand/rocky97_x86_64.sif
  aarch64: /cloud_opt/ondemand/rocky97_aarch64.sif
```

## Register Applications in Open OnDemand
Create a symbolic link under `/var/www/ood/apps/sys/` for each interactive application you want to use.
The example below is for `Desktop`.

```bash
$ cd /var/www/ood/apps/sys/
$ sudo ln -s oodjp_apps/apps/Desktop .
```

Next, edit the application configuration files.
For syntax details, refer to the Open OnDemand manuals linked below.
- `Desktop/manifest.yml`: [Manual](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/manifest.html)
- `Desktop/form.yml.erb`: [Manual](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/form.html)
- `Desktop/submit.yml.erb`: [Manual](https://osc.github.io/ood-documentation/latest/how-tos/app-development/interactive/submit.html)

## Verification
Use the data in `sample_images/`.
For details, see [sample_images/README.md](./sample_images/README.md).

# Note
- Keep in mind that the development environments inside the Singularity container and on the host are different. This is especially important when using development applications. It is more convenient if the development environments in the container and on the host are aligned. To do that, in addition to proper bind settings for directories, you need to pass host environment variables, but even then it is difficult to make them completely identical. When possible, we recommend installing development applications on the host and using them from Open OnDemand without Singularity.
- The aarch64 Singularity container uses SBSA (Server Base System Architecture) `nvidia-driver-libs`. If you want to use this container on a non-SBSA server, create a container that does not use `nvidia-driver-libs`.
