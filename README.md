![](https://github.com/leoncruz/api-responder/actions/workflows/tests.yml/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/ec2939be693459b7ce4d/maintainability)](https://codeclimate.com/github/leoncruz/api-responder/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ec2939be693459b7ce4d/test_coverage)](https://codeclimate.com/github/leoncruz/api-responder/test_coverage)

# Mini Api
A gem to standardize json responses in Rails applications, highly inspired on [Responders](https://github.com/heartcombo/responders)

## Table of Contents
- [Usage](#usage)
  - [Respondering json](#respondering-json)
  - [Success and failure actions](#success-and-failure-actions)
  - [Errors](#errors)
  - [Transform keys](#transform-keys)
- [Overriding response](#overriding-response)
- [Pagination](#pagination)
- [Contributing](#contributing)
- [License](#license)

## Installation
Add this line to your application's Gemfile:

```ruby
gem "mini_api"
```

And then execute:
```bash
$ bundle
```

You must install [Kaminari](https://github.com/kaminari/kaminari) to handle pagination
and [Active Model Serializers](http://github.com/rails-api/active_model_serializers) to handle data serialization

## Usage

After install the gem, include the `MiniApi` module into your `ApplicationController` or other parent controller
```ruby
class ApplicationController < ActionController::Base
  include MiniApi
end
```

This include three methods in your controllers: `render_json`, `page` and `per_page`

The methods `page` and `per_page` will handle the params: `page` and `per_page` respectively

### Respondering json

In your controller you only need to call the `render_json` method informing what you want to send. Example:
```ruby
class UsersController < ApplicationController
  def show
    user = User.find(params[:id])

    render_json user
  end
end
```

The generated json will be like:
```json
{
  "success": true,
  "data": { }, // user data here
  "message": ""
}
```

If your data is a `ActiveRecord::Relation`, the behavior is the same, with pagination data added to `meta` key
```ruby
class UsersController < ApplicationController
  def index
    users = User.all

    render_json users
  end
end
```
The response will be like:
```json
{
  "success": true,
  "data": { }, // users here
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 10,
    "total_records": 100
  }
}
```

### Success and failure actions

Many times, our controller actions need to persist or validate some data coming from request, the default approach to do that is like:
```ruby
class UsersController < ApplicationController
  def new
    user = User.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: user.errors.messages, status: :unprocessable_entity
    end
  end
end
```
But, with `mini_api`, you could simplify the action doing like:
```ruby
class UsersController < ApplicationController
  def new
    user = User.new(user_params)

    user.save

    render_json user
  end
end
```
If the `user` was created successfully, then the response will be like:
```json
{
  "success": true,
  "data": {  }, // user data here
  "message": "User was successfully created."
}
```
with `status_code` 201

But, if user is not valid, then the response will be like:
```json
{
  "success": false,
  "errors": {  }, // user errors here
  "message": "User could not be created."
}
```
witht `status_code` 422

The `message` key is different based on actions on informed model: create, update, and destroy

You can respond any type of data, but ActiveRecord/ActiveModel::Model and ActiveRecord::Relation has a special treatment as shown above

### Errors
To show errors of a model, by default will use the `errors.messages` method, but `MiniApi` adds an ability to `active_model_serializers` to create a error serializer
as a nested class in your serializer. Example:
```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name

  class Error < ActiveModel::Serializer
    attributes :user

    def user
      {
        first_name: object.errors[:first_name],
        last_name: object.errors[:last_name],
      }
    end
  end
end
```
The response will be like:
```json
{
  "success": false,
  "errors": {
    "user": {
      "first_name": "can't be blank",
      "last_name": "can't be blank"
    }
  },
  "message": "User could not be created."
}
```
You can create serializers for non `ActiveRecord` and add a nested `Error` class too

### Transform keys

It is possible to transform the keys of request and response. By default, will transform to `snake_case`, but the possible values are `snake_case`, `camel_lower` and `camel_case`

To change the transform operation, simply adds a initializer on initilizations folder with content:
```ruby
MiniApi::Config.configure do |config|
  config.transform_params_keys_to = :snake_case
  config.transform_response_keys_to = :camel_lower
end
```
The option `transform_params_keys_to` will transform request params.
The option `transform_response_keys_to` will transform responses.

## Overriding response

You can override the `status`, `message` and `sucess` keys simply informing values to `render_json`. Example:

```ruby
class UsersController < ApplicationController
  def new
    user = User.new(user_params)

    if user.save
      render_json user, message: 'custom message'
    else
      render_json user.errors.messages, status: :bad_request, success: true
    end
  end
end
```
This way, the response will contain the informed values

## Pagination

This plugin handle pagination using `kaminari` gem. The params to evaluate pagination are `page` and `per_page`

if no page is informed, by default will use page `1`

Default value of `per_page` is `25`. Only specific values are permitted to `per_page`, they are: 10, 25, 50, 100

If the value it is none of those, so the default value is used

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
