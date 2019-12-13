## What is this
This script can delete your messages in slack.
Other users messages is not be deleted.

## Usage

```ruby
$ ruby app.rb --channel CHANNEL_ID --user USER_ID --token xoxp-*** [--dry-run]
```

## Options

### channel (required)
Slack channel id.

### user (required)
Slack user id.

### token (required)
Slack api token. The token require scopes:

```
channels:history
groups:history
im:history
mpim:history 
chat:write:bot
chat:write:user
```

### dry-run (optional)
Output the message to be deleted. The message is not deleted.