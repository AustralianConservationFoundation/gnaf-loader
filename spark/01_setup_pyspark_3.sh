#!/usr/bin/env bash

SECONDS=0*

echo "-------------------------------------------------------------------------"
echo " Start time : $(date)"

# --------------------------------------------------------------------------------------------------------------------
# Script installs Apache Spark locally on a Mac in standalone mode
# --------------------------------------------------------------------------------------------------------------------
#
# Author: Hugh Saalmans
# Date: 2020-09-25
#
# WARNINGS:
#   - Removes existing Spark install in $HOME/spark-$SPARK_VERSION-with-psycopg2 folder
#   - Removes existing 'spark3' Conda environment
#
# PRE_REQUISITES:
#   1. Java 8 OpenJDK is installed
#        - Install using Homebrew:
#            brew install openjdk@8
#        - Add the following lines to your .bash_profile file:
#            export PATH="/usr/local/opt/openjdk@8/bin:$PATH"
#            export JAVA_HOME="/usr/local/opt/openjdk@8"
#        - Reload .bash_profile:
#            source .bash_profile
#
#   2. Miniconda installed in default directory ($HOME/opt/miniconda3)
#        - Get the installer here: https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.pkg
#
# ISSUES:
#   1. Conda environment variables aren't accessible in IntelliJ/Pycharm due to a missing feature
#        - Pyspark scripts will fail in IntelliJ/Pycharm as Spark env vars aren't set (e.g. $SPARK_HOME)
#
# --------------------------------------------------------------------------------------------------------------------
#
# SETUP:
#   - edit these if it's the future and versions have changed

PYTHON_VERSION="3.9"
SPARK_VERSION="3.0.1"

# --------------------------------------------------------------------------------------------------------------------

## get directory this script is running from
#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SPARK_HOME_DIR="${HOME}/spark-${SPARK_VERSION}-with-psycopg2"

# WARNING - remove existing spark install
rm -r ${SPARK_HOME_DIR}

echo "-------------------------------------------------------------------------"
echo "Downloading and Installing Apache Spark"
echo "-------------------------------------------------------------------------"

mkdir ${SPARK_HOME_DIR}
cd ${SPARK_HOME_DIR} || exit

# download and untar Spark files
wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz
tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz --directory ${SPARK_HOME_DIR} --strip-components=1
rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

# add Postgres JDBC driver to Spark (required to export GNAF and Admin Bdys)
cd ${SPARK_HOME_DIR}/jars || exit
wget https://jdbc.postgresql.org/download/postgresql-42.2.19.jar

# create folder for Spark temp files
mkdir -p ${HOME}/tmp/spark

cd ${HOME} || exit

echo "-------------------------------------------------------------------------"
echo "Creating new Conda Environment 'spark3'"
echo "-------------------------------------------------------------------------"

# stop the Conda environment currently running
conda deactivate

# WARNING - remove existing environment
conda env remove --name spark3

# update Conda platform
echo "y" | conda update conda

# Create Conda environment
echo "y" | conda create -n spark3 python=${PYTHON_VERSION}

# activate and setup env
conda activate spark3
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict

# add environment variables for Pyspark
conda env config vars set JAVA_HOME="/usr/local/opt/openjdk@8"
conda env config vars set SPARK_HOME="${SPARK_HOME_DIR}"
conda env config vars set SPARK_LOCAL_IP="127.0.0.1"
conda env config vars set SPARK_LOCAL_DIRS="${HOME}/tmp/spark"
conda env config vars set PYSPARK_PYTHON="${HOME}/opt/miniconda3/envs/spark3/bin/python"
conda env config vars set PYSPARK_DRIVER_PYTHON="${HOME}/opt/miniconda3/envs/spark3/bin/ipython"
conda env config vars set PYLIB="${SPARK_HOME_DIR}/python/lib"

# reactivate for env vars to take effect
conda activate spark3

# install conda packages for Spark
echo "y" | conda install -c conda-forge pyspark=${SPARK_VERSION} psycopg2 boto3

echo "-------------------------------------------------------------------------"
echo "Verify Pyspark version"
echo "-------------------------------------------------------------------------"

conda list pyspark

echo "----------------------------------------------------------------------------------------------------------------"

cd ${HOME} || exit

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
