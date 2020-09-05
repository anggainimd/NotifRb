# Notification Message 
## Description 
 Implement the notification in a flexible way such that it can cater to new types of notification, Due to the different types of notification with different message templates.

The Main Feature for this project are:
- grouping with current user_id
- grouping data per 1 minute
- grouping data with notification type
- array to sentence

## Requirements
- ruby 2.7
- rspec

## Installation
```
rbenv install 2.7.1 / rbenv global 2.7.1
gem install rspec
gem install simplecov
```
here is how to install rbenv with ruby [2.7.1](https://www.techiediaries.com/install-ruby-2-7-rails-6-ubuntu-20-04/)


## Test

### Run code on terminal
```
$ ruby notif.rb [inputFile] [user_id]
$ ruby notif.rb notifications.json hackamorevisiting
```

### Run with Rspec

```
rspec spec
```

### Coverage
Open file coverage/index.html

### Contact

anggainmail@gmail.com

