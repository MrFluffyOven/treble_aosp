echo "MrFluffyOven Installer Script" 

Tools() {
echo "--> Installing Unzip" 
sudo apt-get install unzip
echo

echo "--> Installing Visual Studio Code" 
snap install code --classic
echo

echo "--> Installing Gdebi" 
sudo apt-get install gdebi
echo

echo "--> Installing Google Chrome" 
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
echo
}  


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

echo "--> Installing Github Desktop (Unofficial)" 
sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.2.0-linux1/GitHubDesktop-linux-3.2.0-linux1.deb
sudo gdebi GitHubDesktop-linux-3.2.0-linux1.deb
echo

echo "--> Installing REPO" 
apt install repo
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

Tools
Snap&Curl
Git&Repo
Python
Gradle

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Install Script completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo