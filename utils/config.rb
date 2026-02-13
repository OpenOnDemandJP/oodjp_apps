require "yaml"
require "erb"

# Load site-specific configuration from config.yml located in the same directory
# as this Ruby file, evaluate embedded ERB, and extract only the values required
# by the application.
#
# Returns:
# - xdg_data_home   (String): Base directory for application data storage
# - container_image (String): Container image name used for job execution
#
def load_app_config
  config_path = File.join(__dir__, "config.yml")
  config = YAML.safe_load(
    ERB.new(File.read(config_path)).result,
    aliases: true
  )

  [
    config["xdg_data_home"],
    config["container_image"]
  ]
end

# Generate the Xfce startup shell script used by Open OnDemand applications.
#
# This method returns a Bash script that initializes the Xfce desktop
# environment inside the interactive session. 
#
# When is_virtualgl is true, the script enables VirtualGL support for
# hardware-accelerated OpenGL rendering (e.g., for visualization workloads).
#
def set_xfce(is_virtualgl = false)
  <<~BASH
  #!/usr/bin/env bash
  
  # Change working directory to user's home directory
  cd "${HOME}"
  
  # Reset module environment (may require login shell for some HPC clusters)
  #module purge && module restore
  
  # Ensure that the user's configured login shell is used
  export SHELL="$(getent passwd $USER | cut -d: -f7)"
  
  # use a safe PATH to boot the desktop because dbus-launch can be
  # in another location from a python/conda installation and that will
  # conflict and cause issues. See https://github.com/OSC/ondemand/issues/700 for more.
  #SAFE_PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/bin"
  
  # Start up desktop
  #PATH="$SAFE_PATH" source "<%= session.staged_root.join("xfce.sh") %>"

  # Remove any preconfigured monitors
  if [[ -f "${HOME}/.config/monitors.xml" ]]; then
    mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
  fi
  
  # Copy over default panel if doesn't exist, otherwise it will prompt the user
  PANEL_CONFIG="${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
  if [[ ! -e "${PANEL_CONFIG}" ]]; then
    mkdir -p "$(dirname "${PANEL_CONFIG}")"
    cp "/etc/xdg/xfce4/panel/default.xml" "${PANEL_CONFIG}"
  fi
  
  # Disable startup services
  xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
  xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false
  
  # Disable useless services on autostart
  AUTOSTART="${HOME}/.config/autostart"
  rm -fr "${AUTOSTART}"    # clean up previous autostarts
  mkdir -p "${AUTOSTART}"
  for service in "pulseaudio" "rhsm-icon" "spice-vdagent" "tracker-extract" "tracker-miner-apps" "tracker-miner-user-guides" "xfce4-power-manager" "xfce-polkit"; do
    echo -e "[Desktop Entry]\nHidden=true" > "${AUTOSTART}/${service}.desktop"
  done

  # Run Xfce4 Terminal as login shell (sets proper TERM)
  TERM_CONFIG="${HOME}/.config/xfce4/terminal/terminalrc"
  if [[ ! -e "${TERM_CONFIG}" ]]; then
    mkdir -p "$(dirname "${TERM_CONFIG}")"
    sed 's/^ \{4\}//' > "${TERM_CONFIG}" << EOL
      [Configuration]
      CommandLoginShell=TRUE
  EOL
  else
    sed -i \
      '/^CommandLoginShell=/{h;s/=.*/=TRUE/};${x;/^$/{s//CommandLoginShell=TRUE/;H};x}' \
      "${TERM_CONFIG}"
  fi
  
  # launch dbus first through eval becuase it can conflict with a conda environment
  # see https://github.com/OSC/ondemand/issues/700
  eval $(dbus-launch --sh-syntax)

  # Enable VirtualGL
  _VIRTUALGL=""
  [ "#{is_virtualgl}" = "true" ] && _VIRTUALGL="vglrun -d egl"

  BASH
end

# Generates a Bash script snippet that configures GPU-related bind paths
# for Singularity containers.
#
# - If NVIDIA CUDA is detected under /usr/local/cuda*, it enables --nv
#   and appends CUDA and optional /opt/nvidia directories to SINGULARITY_BINDPATH.
# - If AMD ROCm is detected under /opt/rocm*, it enables --rocm
#   and appends ROCm, optional /opt/amdgpu, and related modulefiles
#   (resolved via realpath) to SINGULARITY_BINDPATH.
#
# The script also sets the _OPTION variable (--nv or --rocm).
#
def set_bindpath
  <<~BASH
_OPTION=""
    append_bindpath() {
      local _path="$1"
      [ -z "${_path}" ] && return
      if [ -z "${SINGULARITY_BINDPATH:-}" ]; then
        export SINGULARITY_BINDPATH="${_path}"
      else
        export SINGULARITY_BINDPATH="${SINGULARITY_BINDPATH},${_path}"
      fi
    }

    if [ -e /usr/local/cuda ]; then
      _OPTION="--nv"
      for dir in $(ls -d1 /usr/local/cuda*); do
        append_bindpath "${dir}"
      done
      [ -e /opt/nvidia ] && append_bindpath "/opt/nvidia"
    elif [ -e /opt/rocm ]; then
      _OPTION="--rocm"
      for dir in $(ls -d1 /opt/rocm*); do
        append_bindpath "${dir}"
      done
      [ -e /opt/amdgpu ] && append_bindpath "/opt/amdgpu"
      for file in $(ls -d1 /usr/share/Modules/modulefiles/rocm/*); do
        r=$(realpath "${file}")
        append_bindpath "${r}:${file}"
      done
    fi
  BASH
end
