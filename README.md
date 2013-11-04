ly.g0v.tw
=========

WARNING: this is work in progress and the file format is likely to change!

# Usage

to install needed packages

    $ npm install

to run app locally,

    $ npm start    # then open http://localhost:3333/

# API Endpoint

By default the frontend uses api-beta.ly.g0v.tw.  The code is at http://github.com/g0v/api.ly

# Terminologies

List some terminologies which will be used in source code

* sitting - 會議(maybe 院會)
* bill - 提案
* debate - 質詢
* motions - 議案
* committee - 委員會
* annoucement - 報告事項
* discussion - 討論事項
* exmotion - 臨時提案
* interpellation - 質詢事項

# Note

While running deploy if following message is shown:

    " fatal: Not a valid object name: '-m' "

It is a bug of git fixed after 1.7.11.4. Check you git version (`git --version`) and upgrade if < 1.7.11.4.

# Cordova - mobile

Using Cordova as a platform for building mobile apps

Download the latest Cordova version 3.1.0 (We're using)

After download and unzip the file, unzip `cordova-ios.zip`, and go to `bin/` enter `./update_cordova_subproject ~/Documents/<your path to the repo>/contrib/ly_ios/ly_g0v.xcodeproj` and open up Xcode to run `ly_g0v.xcodeproj`, before you build start your server. And you can see the simulator on your mac :).

##Setting in cordova :

Setting in cordova is really easy, all the settings are in `contrib/ly_ios/ly_g0v/config.xml`

```
    <name>ly.g0v.tw</name>

    <description>
        ly.g0v.tw - Congress Website
    </description>

    <author href="http://g0v.tw" >
        g0v.tw
    </author>

    <access origin="*"/>

    <content src="http://localhost:3333" />  <!-- which url you want to direct to -->
    <!-- <content src="index.html" /> -->

```

# License

The MIT license: http://g0v.mit-license.org/
