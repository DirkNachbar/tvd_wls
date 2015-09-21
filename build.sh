#!/bin/bash
#---------------------------------------------------------------------
# 
# Author: Dirk Nachbar, Trivadis AG, Bern Switzerland
#
# Purpose: Main build script for creating WebLogic Server Image
#          and WebLogic Server Domain Creation
#
# Parameters: -i <ConfigFile>
#             e.g.  ./build.sh -i build.ini
#
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
Usage() 
#
# PURPOSE: Displays the Usage of the script
#---------------------------------------------------------------------
{
cat << EOF
Usage: build_wls_image.sh -i <ConfigFile>
Builds a Docker Image for WebLogic.

Parameters:
   -i: creates WebLogic Server image according to provided values
       in the configfile

LICENSE GPL 2.0
EOF
exit 0
}

#---------------------------------------------------------------------
CheckParams()
#
# PURPOSE: Checks the input Parmeter -i
#---------------------------------------------------------------------
{
    if [ "${ConfigFile}" = "" ] ; then
        echo "ERR: Missing parameter(s), the flags -i must be used."
        Usage
    fi
}

#---------------------------------------------------------------------
ReadParams()
#
# PURPOSE: Reads the Parmeters of the Configfile.
#---------------------------------------------------------------------
{
TheVersion="$(cat ${ConfigFile} | grep -i "^Version=" | head -n 1 | cut -d= -f2-)"
TheImageName="$(cat ${ConfigFile} | grep -i "^ImageName=" | head -n 1 | cut -d= -f2-)"
TheJdkRpm="$(cat ${ConfigFile} | grep -i "^JdkRpm=" | head -n 1 | cut -d= -f2-)"
TheWlsSource="$(cat ${ConfigFile} | grep -i "^WlsSource=" | head -n 1 | cut -d= -f2-)"
TheOracleLinux="$(cat ${ConfigFile} | grep -i "^OracleLinux=" | head -n 1 | cut -d= -f2-)"
TheAdminPassword="$(cat ${ConfigFile} | grep -i "^AdminPassword=" | head -n 1 | cut -d= -f2-)"
TheAdminPort="$(cat ${ConfigFile} | grep -i "^AdminPort=" | head -n 1 | cut -d= -f2-)"
TheNodeManagerPort="$(cat ${ConfigFile} | grep -i "^NodeManagerPort=" | head -n 1 | cut -d= -f2-)"
TheManagedServerPort="$(cat ${ConfigFile} | grep -i "^ManagedServerPort=" | head -n 1 | cut -d= -f2-)"
TheWlsImageName="$(cat ${ConfigFile} | grep -i "^WlsImageName=" | head -n 1 | cut -d= -f2-)"
TheWlsContainerName="$(cat ${ConfigFile} | grep -i "^WlsContainerName=" | head -n 1 | cut -d= -f2-)"

    if [ "${TheVersion}" = "" ] ; then
        echo "ERR: Missing value Version in the provided Config File."
        exit 0
    fi

    if [ "${TheImageName}" = "" ] ; then
        echo "ERR: Missing value ImageName in the provided Config File."
        exit 0
    fi

    if [ "${TheJdkRpm}" = "" ] ; then
        echo "ERR: Missing value JdkRpm in the provided Config File."
        exit 0
    fi

    if [ "${TheWlsSource}" = "" ] ; then
        echo "ERR: Missing value WlsSource in the provided Config File."
        exit 0
    fi

    if [ "${TheOracleLinux}" = "" ] ; then
        echo "ERR: Missing value OracleLinux in the provided Config File."
        exit 0
    fi

    if [ "${TheAdminPassword}" = "" ] ; then
        echo "ERR: Missing value AdminPassword in the provided Config File."
        exit 0
    fi

    if [ "${TheAdminPort}" = "" ] ; then
        echo "ERR: Missing value AdminPort in the provided Config File."
        exit 0
    fi

    if [ "${TheNodeManagerPort}" = "" ] ; then
        echo "ERR: Missing value NodeManagerPort in the provided Config File."
        exit 0
    fi

    if [ "${TheManagedServerPort}" = "" ] ; then
        echo "ERR: Missing value ManagedServerPort in the provided Config File."
        exit 0
    fi

    if [ "${TheWlsImageName}" = "" ] ; then
        echo "ERR: Missing value WlsImageName in the provided Config File."
        exit 0
    fi

    if [ "${TheWlsContainerName}" = "" ] ; then
        echo "ERR: Missing value WlsContainerName in the provided Config File."
        exit 0
    fi

}

#---------------------------------------------------------------------
CreateBuildFiles()
#
# PURPOSE: Creates the required files for the WLS Image build
#---------------------------------------------------------------------
{

# Create required files for Oracle WebLogic Server image installation
mkdir ${TheImageName}
cp Dockerfile.template ${TheImageName}/Dockerfile
cp ${TheJdkRpm} ${TheImageName}/${TheJdkRpm}
cp ${TheWlsSource} ${TheImageName}/${TheWlsSource}
cp oraInst.loc ${TheImageName}/
cp install.rsp ${TheImageName}/

sed -i  "s/<TheJdkRpm>/${TheJdkRpm}/g" ${TheImageName}/Dockerfile
sed -i  "s/<TheWlsSource>/${TheWlsSource}/g" ${TheImageName}/Dockerfile
sed -i "s/<TheOracleLinux>/${TheOracleLinux}/g" ${TheImageName}/Dockerfile

# Create required files for Oracle WebLogic Domain Creation
mkdir ${TheImageName}/create_domain
cp script_templates/Dockerfile.template ${TheImageName}/create_domain/Dockerfile
cp script_templates/create-wls-domain.template ${TheImageName}/create_domain/create-wls-domain.py
cp script_templates/commEnv.sh ${TheImageName}/create_domain/commEnv.sh
cp script_templates/jaxrs2-template.jar ${TheImageName}/create_domain/jaxrs2-template.jar
cp script_templates/add-machine.template ${TheImageName}/create_domain/add-machine.py
cp script_templates/createMachine.sh ${TheImageName}/create_domain/createMachine.sh


sed -i "s/<BaseImage>/${TheImageName}:${TheVersion}/g" ${TheImageName}/create_domain/Dockerfile
sed -i "s/<AdminPassword>/${TheAdminPassword}/g" ${TheImageName}/create_domain/Dockerfile
sed -i "s/<AdminPort>/${TheAdminPort}/g" ${TheImageName}/create_domain/Dockerfile
sed -i "s/<NodeManagerPort>/${TheNodeManagerPort}/g" ${TheImageName}/create_domain/Dockerfile
sed -i "s/<ManagedServerPort>/${TheManagedServerPort}/g" ${TheImageName}/create_domain/Dockerfile

sed -i "s/<AdminPort>/${TheAdminPort}/g" ${TheImageName}/create_domain/create-wls-domain.py
sed -i "s/<AdminPassword>/${TheAdminPassword}/g" ${TheImageName}/create_domain/create-wls-domain.py
sed -i "s/<NodeManagerPort>/${TheNodeManagerPort}/g" ${TheImageName}/create_domain/create-wls-domain.py

sed -i "s/<AdminPassword>/${TheAdminPort}/g" ${TheImageName}/create_domain/add-machine.py
sed -i "s/<WlsContainerName>/${TheWlsContainerName}/g" ${TheImageName}/create_domain/add-machine.py
sed -i "s/<AdminPort>/${TheAdminPort}/g" ${TheImageName}/create_domain/add-machine.py
sed -i "s/<NodeManagerPort>/${TheNodeManagerPort}/g" ${TheImageName}/create_domain/add-machine.py


}


#---------------------------------------------------------------------
# MAIN
#---------------------------------------------------------------------


ConfigFile=""
# All required ConfigParameters are initially set to empty
TheVersion=""
TheImageName=""
TheJdkRpm=""
TheWlsSource=""
TheOracleLinux=""
TheAdminPassword=""
TheAdminPort=""
TheNodeManagerPort=""
TheManagedServerPort=""
TheWlsImageName=""
TheWlsContainerName=""

while getopts i: CurOpt; do
    case ${CurOpt} in
        i) ConfigFile="${OPTARG}" ;;
        ?) Usage
           exit 1 ;;
    esac
done
shift $((${OPTIND}-1))

if [ $# -ne 0 ]; then
    Usage
fi

# Check Input Params
CheckParams

# Read the Params from the Config File
ReadParams

# Create the required files for Image build and WLS Domain Creation
CreateBuildFiles

cd ${TheImageName}

# Build the Image
echo "Docker Image build command"
echo "Following Command will be executed:"
echo "     docker build --force-rm=true --no-cache=true --rm=true -t ${TheImageName}:${TheVersion} ."
docker build --force-rm=true --no-cache=true --rm=true -t ${TheImageName}:${TheVersion} . 

cd create_domain

# Create the WLS Domain
echo "WLS Domain Creation"
echo "Following Command will be executed:"
echo "     docker build -t ${TheWlsImageName}:${TheVersion} ."
docker build -t ${TheWlsImageName}:${TheVersion} .

# Startup the Admin Server
echo "Startup the newly created Admin Server on port ${TheAdminPort}"
echo "Following Command will be executed:"
echo "     docker run -d -p ${TheAdminPort}:${TheAdminPort} -h ${TheWlsContainerName} --name=${TheWlsContainerName} ${TheWlsImageName}:${TheVersion} startWebLogic.sh"
docker run -d -p ${TheAdminPort}:${TheAdminPort} -h ${TheWlsContainerName} --name=${TheWlsContainerName} ${TheWlsImageName}:${TheVersion} startWebLogic.sh


# set a sleep of 60 seconds in order to allow the Admin Server to be up and running
echo "Wait for 60 seconds in order to allow the Admin Server to be up and running"
echo "..."
sleep 60

# retrieve the IP Address for above created WLS Admin Server
TheContainerIP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${TheWlsContainerName})
echo "Admin server can be reached either via"
echo "Docker internal IP: http://${TheContainerIP}:${TheAdminPort}/console"
echo "Docker server IP: http://xxx:${TheAdminPort}/console"


# Node Manager creation and startup
echo "Node Manager Creation"
echo "Following Command will be executed:"
echo "     docker -it ${TheWlsContainerName} createMachine.sh"
docker exec -it ${TheWlsContainerName} createMachine.sh

echo "Done with Weblogic Server Installation and configuration on Docker"
echo "****************************************************************************"
echo "Admin Server URL: http://${TheContainerIP}:${TheAdminPort}/console"
echo "NodeManager Port: ${TheNodeManagerPort}"

