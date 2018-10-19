

# Source original bashrc file
if [ -f $HOME/.bashrc_orig ]; then
  . $HOME/.bashrc_orig
fi

# Source go PATHs
if [ -f $HOME/.bash_profile ]; then
  . ~/.bash_profile
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


if [ -f $HOME/.oci/config ]; then
  oci setup repair-file-permissions --file $HOME/.oci/config
fi


if [ -f $HOME/.oci/oci_api_key.pem ]; then
  oci setup repair-file-permissions --file $HOME/.oci/oci_api_key.pem
fi


function proxy() {

  function print_help() {
    echo "Usage:proxy [<on|off>]";
  }

  function proxy_status() {
    if [ -z "$HTTP_PROXY" ] && [ -z "$http_proxy" ] && [ -z "$HTTPS_PROXY" ] && [ -z "$https_proxy" ]; then
      echo "Container environment proxy is off...";
    else
      echo "Container environment proxy is on..."
    fi
  }

  function proxy_set() {
    proxy_file=$1
    proxy_var=$2
    if [ -s $proxy_file ]; then
      proxy=$(cat $proxy_file);
      echo "Setting up $proxy_var to $proxy..."
      export $proxy_var="$proxy"
    fi
  }

  if [ $# -ne 1 ]; then
    print_help
  fi

  if [ $# -eq 1 ] && [ "$1" != "on" ] && [ "$1" != "off" ]; then
    print_help
  fi

  if [ "$1" == "on" ]; then
    proxy_set $HOME/.HTTPS_PROXY HTTPS_PROXY
    proxy_set $HOME/.https_proxy https_proxy
    proxy_set $HOME/.HTTP_PROXY HTTP_PROXY
    proxy_set $HOME/.http_proxy http_proxy
    proxy_set $HOME/.no_proxy no_proxy
    proxy_set $HOME/.NO_PROXY NO_PROXY
  fi;

  if [ "$1" == "off" ]; then
    unset HTTP_PROXY;
    unset HTTPS_PROXY;
    unset NO_PROXY;
    unset http_proxy;
    unset https_proxy;
    unset no_proxy;
  fi;

  proxy_status;
}


function setup_terraform_environ() {

    OCI_CONFIG=$HOME/.oci/config

    if [ -f $OCI_CONFIG ]; then
      sed -i 's/\r$//g' $OCI_CONFIG
      sed -i -e "s/\~/\/root/g" $OCI_CONFIG
      echo "Setting up terraform environment variables..."
      export TF_VAR_user_ocid=$(cat $OCI_CONFIG | grep -e "^.*user[=]" | cut -d '=' -f 2)
      export TF_VAR_tenancy_ocid=$(cat $OCI_CONFIG | grep -e "^.*tenancy[=]" | cut -d '=' -f 2)
      export TF_VAR_compartment_ocid=$(cat $OCI_CONFIG | grep -e "^.*compartment[=]" | cut -d '=' -f 2)
      export TF_VAR_fingerprint=$(cat $OCI_CONFIG | grep -e "^.*fingerprint[=]" | cut -d '=' -f 2)
      export TF_VAR_private_key_path=$(cat $OCI_CONFIG | grep -e "^.*key_file[=]" | cut -d '=' -f 2)
      export TF_VAR_region=$(cat $OCI_CONFIG | grep -e "^.*region[=]" | cut -d '=' -f 2)
    else
      echo "Info: OCI Terraform variables will not be set as $OCI_CONFIG is missing..."
      echo "Info: When setting up $OCI_CONFIG, run setup_terraform_environ or restart the container."
    fi

}

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export EDITOR=nano

setup_terraform_environ
proxy on
