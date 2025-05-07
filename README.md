# Taboola API Client

A comprehensive Ruby client for interacting with the Taboola API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add taboola_api
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install taboola_api
```

## Usage

### Configuration

```ruby
require 'taboola_api'

TaboolaApi.configure do |config|
  config.client_id = "your-client-id"
  config.client_secret = "your-client-secret"
  config.account_id = "your-account-id" # Optional
  config.verbose = true # Optional
  config.formatter = :json # Optional
  config.output_color = :green # Optional
end
```

### Campaigns

```ruby
# List campaigns
campaigns = TaboolaApi.campaigns.list
puts campaigns

# Get a campaign
campaign = TaboolaApi.campaigns.get("campaign-id")
puts campaign

# Create campaign
new_campaign = TaboolaApi.campaigns.create({
  name: "My Campaign",
  branding_text: "My Brand",
  cpc: 0.5
})

# Update campaign
updated_campaign = TaboolaApi.campaigns.update("campaign-id", {
  name: "Updated Campaign Name"
})

# Delete campaign
TaboolaApi.campaigns.delete("campaign-id")
```

### Account Information

```ruby
account_info = TaboolaApi.accounts.info
puts account_info
```

### Command Line Interface

```bash
# Show help
$ taboola-api help

# List campaigns
$ taboola-api campaigns list --client-id YOUR_ID --client-secret YOUR_SECRET

# Get campaign
$ taboola-api campaigns get CAMPAIGN_ID --client-id YOUR_ID --client-secret YOUR_SECRET

# Show version
$ taboola-api version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).