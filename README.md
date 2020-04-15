<img src="https://github.com/rmc-team/osx-patcher/raw/master/MacBook.png" width="256">

# OS X Patcher
OS X Patcher is a command line tool for running OS X on unsupported Macs

# Contributers
I'd like to the thank the following people, and many others, for their research, help, and inspiration.
- [parrotgeek1](https://forums.macrumors.com/members/1033441/)
- [TMRJIJ](https://forums.macrumors.com/members/tmrjij.878094/)

# Links
- [RMC GitHub](https://github.com/rmc-team)
- [RMC Website](https://www.rmc-team.ch/)
- [RMC Twitter](https://twitter.com/_rmcteam)
- [More Documentation](https://www.rmc-team.ch/osx-patcher)

# Supported Macs
## iMacs
-   iMac4,1
-   iMac4,2
-   iMac5,1
-   iMac5,2
## MacBooks
-   MacBook2,1
-   MacBook3,1
-   MacBook4,1
## MacBook Airs
-   MacBookAir1,1
## MacBook Pros
-   MacBookPro2,1
-   MacBookPro2,2
## Mac minis
-   Macmini1,1
-   Macmini2,1
## Mac Pros
-   MacPro1,1
-   MacPro2,1
## Xserves
-   Xserve1,1
-   Xserve2,1

# Usage
chmod +x ./OS\ X\ Patcher.sh —> makes the script runnable  
sudo ./OS\ X\ Patcher.sh —> runs the script with root permissions  

# Brightness Slider and NoSleep
You might notice two little applications have been installed along with OS X Patcher's other patches. They help solve some issues and should be opened and configured after patching. NoSleep is open source and can be found [here](https://github.com/integralpro/nosleep). Brightness Slider is made by ACT Productions and can be found on the [Mac App Store](http://itunes.apple.com/us/app/brightness-control/id456624497?ls=1&mt=12).

# Graphics acceleration
Your Mac won't support graphics acceleration with this patcher. This means brightness control and sleep won't work (see above) and applications that rely on your graphics card will perform slower or will simply not work. parrotgeek1 will soon release a patcher with support for graphics acceleration on certain Macs.