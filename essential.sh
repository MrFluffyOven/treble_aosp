echo
echo "------------------"
echo " Installer Script "
echo " by MrFluffyOven  " 
echo "  Essential Only  " 
echo "------------------"
echo


Snap&Curl() {
echo "--> Installing Snap" 
sudo apt-get install snap
echo

echo "--> Installing Curl"
snap install curl
echo 
}  

Git&Repo() {
echo "--> Installing Git" 
sudo apt-get install git-all 
echo

echo "--> Installing REPO" 
sudo apt-get install repo
echo
} 


Python() {
echo "--> Installing Python 3.11" 
sudo apt-get install python3.11
sudo apt-get install python-is-python3
echo 

echo "--> Installing Python 3 pip" 
sudo apt-get install python3-pip
echo

echo "--> Installing Python Lunch" 
pip3 install lunch
echo 
}


Gradle() {
echo "--> Installing JDK 11"
sudo apt-get install openjdk-11-jdk
echo

echo "--> Installing Gradle 7.2"
snap install gradle --classic
echo 
} 


START=$(date +%s)

Snap&Curl
Git&Repo
Python
Gradle

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Install Script completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo