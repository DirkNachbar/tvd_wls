# tvd_wls
# Docker image for Oracle WebLogic Server

Fully customized build script for Oracle WebLogic Server (WLS) based on oraclelinux Image from Dockerhub

## Provided Files

* build.sh: Main script for installing Oracle WLS and configuring Oracle WLS Domain
* build.ini: Sample configuration file to customize Oracle WLS installation and WLS Domain creation
* dockerfile.template: template Dockerfile, which will be used as master file for customized WLS installation and Domain configuration
* install.rsp: Oracle response file for silent installation of Oracle WebLogic Server
* oraInst.loc: Oracle Inventory location file
* script_templates/Dockerfile.template: template Dockerfile, which will be used as master file for customized WLS Domain creation
* script_templates/create-wls-domain.template: template create-wls-domain.py file, which will be used as master file for customized WLS Domain creation
 
## Usage

### Requirements
Docker must be installed and configured on your target server.
Oracle Linux image should be present in your Docker or make sure that your server has the possibility to pull the Oracle Linux image from Docker Hub.
Transfer all files including script_templates directory to your Docker Server.

### Config file (build.ini)
Following configuration parameter must be used within the Config File (sample file build.ini):

```
# WLS Installation values
Version=12.1.3
ImageName=demowls_oel71
JdkRpm=jdk-7u79-linux-x64.rpm
WlsSource=fmw_12.1.3.0.0_wls.jar
OracleLinux=oraclelinux:7.1
# Domain Creation values
AdminPassword=Oracle12c
AdminPort=7001
NodeManagerPort=5556
ManagedServerPort=7003
WlsImageName=demowls
WlsContainerName=wlsadmin
```
Parameters explained:
* Version: the Oracle WebLogic Server 3-digit Release number
* ImageName: Image creation name for the Oracle WebLogic Server image
* JdkRpm: specifies the to be used JDK rpm, must be downloaded before from [http://www.oracle.com/technetwork/java/javase/downloads/index-jsp-138363.html]
* WlsSource: specifies the to be used WebLogic Server installation source, must be downloaded before from [http://www.oracle.com/technetwork/middleware/fusion-middleware/downloads/index.html]. You can only use the Generic WebLogic Installer
* OracleLinux: specifies the required Oracle Enterprise Linux Base Image. **Important Note:** use only from oraclelinux:7 going, as with oraclelinux:6 are some bugs due to read-only filesystem problems
