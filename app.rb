require 'bundler'
Bundler.require
require 'json'
require 'optparse'

params = ARGV.getopts("", "channel:", "dry-run", "token:", "user:")

conn = Faraday.new(url: "https://slack.com/api/") do |conn|
  conn.request :json
  conn.adapter Faraday.default_adapter
end

messages = []
history_args = { token: params["token"], channel: params["channel"], limit: 200 }
while response = conn.get("conversations.history", history_args) do
  body = JSON.parse(response.body)
  messages.concat(body["messages"])
  break unless body["response_metadata"]&.has_key?("next_cursor")
  history_args["cursor"] = body["response_metadata"]["next_cursor"]
  sleep 1
end

timestamps = []
dry_run_messages = []
messages.each do |message|
  if message["user"] == params["user"]
    timestamps << message["ts"]
    dry_run_messages << message if params["dry-run"]
  end
  if message["replies"]
    message["replies"].each do |reply|
      if reply["user"] == params["user"]
        timestamps << reply["ts"]
        if params["dry-run"]
          response = conn.get("conversations.replies", { token: params["token"], channel: params["channel"], ts: reply["ts"] })
          dry_run_messages.concat(JSON.parse(response.body)["messages"])
        end
      end
    end
  end
end

if params["dry-run"]
  puts JSON.pretty_generate(dry_run_messages)
else
  timestamps.sort.reverse.each do |ts|
    response = conn.post do |req|
      req.url "chat.delete"
      req.headers["Authorization"] = "Bearer #{params["token"]}"
      req.body = { token: params["token"], channel: params["channel"], ts: ts }
    end
    sleep 1
  end
end
