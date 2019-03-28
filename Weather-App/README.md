This is a weather app that uses the Weather API and manipulates the JSON file. It does an http get request. 

It uses the phone GPS to show the weather for the current location, also the user can search for a city to get the

weather for a specific location. 

Note: The image assests are not designed by me; I have only coded the app.

To make such a app you need to have access to Cocoapod

  1. sudo gem install cocoapods
  2. pod setup --verbose
  3. Then inside the project directory do 'pod init'
  4. open -a Xcode Podfile
  5. Then modify the pod file, it has been written in Ruby, as pod file that I have provided
  6. pod install
