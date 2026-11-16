#!/usr/bin/env ruby
# frozen_string_literal: true

# Ribose-managed gem version ledger for a release wave.
#
# Usage: gem-ledger.rb <prev-docker-tag> <wave-docker-tag> [owner/repo]
#
# Fetches metanorma-debian/Gemfile.lock from both metanorma-docker tags,
# diffs the versions of every Ribose-managed gem (per GEM-OWNERSHIP.md,
# grouped by org), and prints the wave-issue ledger as markdown:
#   - changed rows show `old → new`
#   - gems new to the bundle are highlighted
#   - gems dropped from the bundle are struck through with their last version
#   - gems absent from both bundles fall back to their rubygems version
#
# Example: gem-ledger.rb v1.18.5 v1.18.6

require "net/http"
require "json"

TAG1 = ARGV[0] or abort "usage: gem-ledger.rb <prev-tag> <wave-tag> [owner/repo]"
TAG2 = ARGV[1] or abort "usage: gem-ledger.rb <prev-tag> <wave-tag> [owner/repo]"
REPO = ARGV[2] || "metanorma/metanorma-docker"
LOCK = "metanorma-debian/Gemfile.lock"

def norm(tag) = tag.start_with?("v") ? tag : "v#{tag}"

def fetch_lock(tag)
  uri = URI("https://raw.githubusercontent.com/#{REPO}/#{norm(tag)}/#{LOCK}")
  res = Net::HTTP.get_response(uri)
  abort "cannot fetch #{uri} (HTTP #{res.code})" unless res.is_a?(Net::HTTPSuccess)
  res.body
end

def parse_versions(lock_body)
  lock_body.scan(/^    ([a-zA-Z0-9_.-]+) \(([^\s()]+)\)$/).to_h
end

def rubygems_version(gem)
  uri = URI("https://rubygems.org/api/v1/gems/#{gem}.json")
  JSON.parse(Net::HTTP.get(uri))["version"]
rescue StandardError
  "?"
end

def manifest
  path = File.join(__dir__, "GEM-OWNERSHIP.md")
  orgs = {}
  cur = nil
  File.foreach(path) do |line|
    if (m = line.match(/^## (\S+) \(\d+ gems?\)/))
      cur = m[1]
      orgs[cur] = []
    elsif (m = line.match(/^- `([a-z0-9_-]+)`/)) && cur
      orgs[cur] << m[1]
    end
  end
  orgs
end

old = parse_versions(fetch_lock(TAG1))
new = parse_versions(fetch_lock(TAG2))

n_chg = 0
added_names = []
removed_names = []
body = []

manifest.each do |org, gems|
  rows = gems.map do |g|
    o = old[g]
    v = new[g]
    if o && v && o != v
      n_chg += 1
      "| `#{g}` | `#{o}` → `#{v}` |"
    elsif o.nil? && v
      added_names << "#{g} #{v}"
      "| `#{g}` | `#{v}` — **new in this wave** |"
    elsif v.nil? && o
      removed_names << g
      "| `#{g}` | ~~`#{o}`~~ — removed from the bundle |"
    else
      v ||= "#{rubygems_version(g)} (not in bundle)"
      "| `#{g}` | `#{v}` |"
    end
  end
  body << ""
  body << "**#{org}** (#{gems.size})"
  body << ""
  body << "| gem | version |"
  body << "|---|---|"
  body.concat(rows)
end

summary = [
  "### Ribose-managed gem versions — #{norm(TAG2).delete_prefix('v')} wave",
  "",
  "Resolved versions of every Ribose-managed gem (per `GEM-OWNERSHIP.md`, grouped by org) in the shipped state, from the frozen bundle (`#{LOCK}` at the `#{REPO}` #{norm(TAG2)} tag), **diffed against the previous wave's frozen bundle (#{norm(TAG1)})**:",
  "",
  "- **#{n_chg} version changes** carried into this wave",
  "- **#{added_names.size} gems newly added** to the bundle#{added_names.empty? ? '' : ': ' + added_names.join(', ')}",
  "- **#{removed_names.size} gems removed**#{removed_names.empty? ? '' : ': ' + removed_names.join(', ')}",
  "",
  "Changed rows show `old → new`; new rows are highlighted; removed gems are struck through with their last carried version. The full lock remains the reference for external gems.",
]
puts (summary + body).join("\n")
